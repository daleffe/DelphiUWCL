unit UCL.MenuAnyWhere;

interface

uses
  SysUtils,
  Classes,
  Controls,
  Menus,
  Messages,
  Types,
  Graphics,
  ComCtrls
{$IF CompilerVersion > 29}
  ,UITypes
{$ELSE}
  ,ImgList
{$IFEND}
  ;

type
  TMenuTriggerMode = (mtmUnknown, mtmMouse, mtmKeyboard);

  TUMenuAnyWhere = class;
  TUMenuButton = class;

  TUMenuButtonActionLink = class(TControlActionLink)
  protected
    FClient: TUMenuButton;
    procedure AssignClient(AClient: TObject); override;
    function IsCheckedLinked: Boolean; override;
    function IsDropdownMenuLinked: Boolean; override;
    function IsEnableDropdownLinked: Boolean; override;
    function IsImageIndexLinked: Boolean; override;
    procedure SetChecked(Value: Boolean); override;
    procedure SetDropdownMenu(Value: TPopupMenu); override;
    procedure SetEnableDropdown(Value: Boolean); override;
    procedure SetImageIndex(Value: Integer); override;
  end;

  TUMenuButton = class(TGraphicControl)
  private
    FDown: Boolean;
    FImageIndex: TImageIndex; // UITypes
    FMenuItem: TMenuItem;
    FUpdateCount: Integer;
    FMouseInClient: Boolean;
    function  GetIndex: Integer;
    procedure SetDown(Value: Boolean);
    procedure SetImageIndex(Value: TImageIndex);
    procedure SetMenuItem(Value: TMenuItem);
    procedure CMHitTest(var Message: TCMHitTest); message CM_HITTEST;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    FMenuController: TUMenuAnyWhere;
    //
    procedure SetParent(AParent: TWinControl); override;
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
    procedure AssignTo(Dest: TPersistent); override;
    procedure BeginUpdate; virtual;
    procedure EndUpdate; virtual;
    function  CheckMenuDropdown: Boolean; dynamic;
    function  GetActionLinkClass: TControlActionLinkClass; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Click; override;
    property Index: Integer read GetIndex;
    property MouseInClient: Boolean read FMouseInClient;
  published
    property Action;
    property Caption;
    property Down: Boolean read FDown write SetDown default False;
//    property DragCursor;
//    property DragKind;
//    property DragMode;
    property Enabled;
    property Height stored False;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex default -1;
    property MenuItem: TMenuItem read FMenuItem write SetMenuItem;
//    property ParentShowHint;
//    property PopupMenu;
    property ShowHint;
    property Visible;
    property Width;
//    property OnClick;
//    property OnContextPopup;
//    property OnDragDrop;
//    property OnDragOver;
//    property OnEndDock;
//    property OnEndDrag;
//    property OnMouseActivate;
//    property OnMouseDown;
//    property OnMouseEnter;
//    property OnMouseLeave;
//    property OnMouseMove;
//    property OnMouseUp;
//    property OnStartDock;
//    property OnStartDrag;
  end;

  TUMenuAnyWhere = class(TComponent)
  private
    FControl: TWinControl;
    FMenu: TMainMenu;
    FPos: TPoint;
    FBackColor: TColor;
    FTransparent: Boolean;
    FButtons: TList;
    FButtonWidth: Integer;
    FButtonHeight: Integer;
    FControlWndProcHooked: Boolean;
    FControlWndProcOld: TWndMethod;
    FMenuTriggerMode: TMenuTriggerMode;
    FInMenuLoop: Boolean;
    FCaptureChangeCancels: Boolean;
    FTempMenu: TPopupMenu;
    FMenuResult: Boolean;
    FButtonMenu: TMenuItem;
    FMenuButton: TUMenuButton;
    FMenuDropped: Boolean;
    FHotItem: Integer;
    FMenuAnchorHighLight: Boolean;
    //
    procedure SetControl(Value: TWinControl);
    procedure SetMenu(Value: TMainMenu);
    procedure SetPos(Index: Integer; Value: Integer);
    procedure SetBackColor(Value: TColor);
    procedure SetTransparent(Value: Boolean);
    //
    function  GetButton(Index: Integer): TUMenuButton;
    function  GetButtonCount: Integer;
    procedure GetButtonSize(var AWidth, AHeight: Integer);
    function  ControlCanvas: TCanvas;
    //
    procedure HookWndProc;
    procedure UnHookWndProc;
    procedure MenuChanged(Sender: TObject; Source: TMenuItem; Rebuild: Boolean);
    //
    procedure CreateButtons;
    procedure DestroyButtons;
    procedure RecreateButtons;
    procedure UpdateButtons(RemakeShortCuts: Boolean);
    procedure InsertButton(AControl: TControl);
    procedure RemoveButton(AControl: TControl);
    function  ButtonIndex(OldIndex, ALeft, ATop: Integer): Integer;
    function  ReorderButton(OldIndex, ALeft, ATop: Integer): Integer;
    function  FindButtonFromAccel(Accel: Word): TUMenuButton;
    procedure SetMenuAnchorHighLight(Active: Boolean);
  protected
    procedure InitMenu(Button: TUMenuButton); dynamic;
    function  TrackMenu(Button: TUMenuButton): Boolean; dynamic;
    procedure CancelMenu; dynamic;
    procedure ClearTempMenu; dynamic;
    function  CheckMenuDropdown(Button: TUMenuButton): Boolean; dynamic;
    procedure ClickButton(Button: TUMenuButton; DoubleClick: Boolean); dynamic;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    //
    procedure ControlWndProc(var Message: TMessage); dynamic;
    //
    property ButtonCount: Integer read GetButtonCount;
    property Buttons[Index: Integer]: TUMenuButton read GetButton;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //
    property Control: TWinControl read FControl write SetControl;
    property Menu: TMainMenu read FMenu write SetMenu;
    property PosX: Integer index 0 read FPos.X write SetPos default 0;
    property PosY: Integer index 1 read FPos.Y write SetPos default 0;
    property BackColor: TColor read FBackColor write SetBackColor default clNone;
    property Transparent: Boolean read FTransparent write SetTransparent default True;
    property MenuTriggerMode: TMenuTriggerMode read FMenuTriggerMode;
    property MenuAnchorHighLight: Boolean read FMenuAnchorHighLight;
    property HotItem: Integer read FHotItem;
  end;

  EUMenuAnyWhere = class(Exception);

implementation

uses
  Windows,
  StrUtils,
  Forms,
  ActnList,
  CommCtrl;

type
  TControlAccess = class(TControl);
  TWinControlAccess = class(TWinControl);
  TMenuAccess = class(TMenu);

function GetTimeStamp: String;
begin
  DateTimeToString(Result, {FormatSettings.ShortDateFormat + ' ' + }{$IF CompilerVersion > 29}FormatSettings.{$IFEND}LongTimeFormat + '.zzz', Now);
  Result := Result + ' - ';
end;


{$REGION 'TUMenuButtonActionLink'}
{ TUMenuButtonActionLink }

procedure TUMenuButtonActionLink.AssignClient(AClient: TObject);
begin
  inherited AssignClient(AClient);
  FClient := AClient as TUMenuButton;
end;

function TUMenuButtonActionLink.IsCheckedLinked: Boolean;
begin
  Result := False;
end;

function TUMenuButtonActionLink.IsDropdownMenuLinked: Boolean;
begin
  Result := True;
end;

function TUMenuButtonActionLink.IsEnableDropdownLinked: Boolean;
begin
  Result := False;
end;

function TUMenuButtonActionLink.IsImageIndexLinked: Boolean;
begin
  Result := inherited IsImageIndexLinked and (FClient.ImageIndex = TCustomAction(Action).ImageIndex);
end;

procedure TUMenuButtonActionLink.SetChecked(Value: Boolean);
begin
  FClient.Down := Value;
end;

procedure TUMenuButtonActionLink.SetDropdownMenu(Value: TPopupMenu);
begin
// nothing here
end;

procedure TUMenuButtonActionLink.SetEnableDropdown(Value: Boolean);
begin
// nothing here
end;

procedure TUMenuButtonActionLink.SetImageIndex(Value: Integer);
begin
  if IsImageIndexLinked then
    FClient.ImageIndex := Value;
end;
{$ENDREGION}
{$REGION 'TUMenuButton'}
{ TUMenuButton }

constructor TUMenuButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csCaptureMouse, csSetCaption, csClickEvents];
  Width := 32;
  Height := 21;
  FImageIndex := -1;
end;

procedure TUMenuButton.ActionChange(Sender: TObject; CheckDefaults: Boolean);
begin
  inherited ActionChange(Sender, CheckDefaults);
  if Sender is TCustomAction then begin
    with TCustomAction(Sender) do begin
      if not CheckDefaults or (Self.ImageIndex = -1) then
        Self.ImageIndex := ImageIndex;
    end;
  end;
  if Sender is TControlAction then begin
    with TControlAction(Sender) do begin
      if not CheckDefaults or (Self.PopupMenu = nil) then
        Self.PopupMenu := PopupMenu;
    end;
  end;
end;

procedure TUMenuButton.AssignTo(Dest: TPersistent);
begin
  inherited AssignTo(Dest);
  if Dest is TCustomAction then begin
    with TCustomAction(Dest) do begin
      ImageIndex := Self.ImageIndex;
    end;
  end;
end;

procedure TUMenuButton.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TUMenuButton.EndUpdate;
begin
  Dec(FUpdateCount);
end;

function TUMenuButton.CheckMenuDropdown: Boolean;
begin
  Result := not (csDesigning in ComponentState) and (MenuItem <> Nil) and (FMenuController <> Nil) and FMenuController.CheckMenuDropdown(Self);
end;

function TUMenuButton.GetActionLinkClass: TControlActionLinkClass;
begin
  Result := TUMenuButtonActionLink;
end;

procedure TUMenuButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and Enabled then
    Down := not Down;
  inherited MouseDown(Button, Shift, X, Y);
//  if Down then
//    CheckMenuDropdown;
end;

procedure TUMenuButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if MouseCapture then
    Down := (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight);
end;

procedure TUMenuButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = mbLeft) and (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight) then
    Down := False;
end;

procedure TUMenuButton.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then begin
    if AComponent = MenuItem then
      MenuItem := Nil;
  end;
end;

procedure TUMenuButton.Paint;
const
  XorColor = $00FFD8CE;
  usePrefix: Array[Boolean] of Cardinal = (DT_HIDEPREFIX or DT_NOPREFIX, 0);
var
  R: TRect;
begin
  if FMenuController = Nil then
    Exit;
  //
  if csDesigning in ComponentState then begin
    Canvas.Brush.Style := bsClear;
    Canvas.Brush.Color := XorColor;
    Canvas.Pen.Mode := pmXor;
    Canvas.Pen.Style := psClear;
    Canvas.Pen.Color := XorColor;
    Canvas.Pen.Width := 1;
    Canvas.FillRect(ClientRect);
  end
  else if MouseInClient or Down or (FMenuController.MenuAnchorHighLight and (FMenuController.HotItem = Index)) then begin
    Canvas.Pen.Mode := pmCopy;
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Color := XorColor;
    Canvas.Pen.Width := 1;
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := clHighlight;
    Canvas.FillRect(ClientRect);
    Canvas.Font.Color := clHighlightText;
  end
  else
    Canvas.Font.Color := clWindowText;
  Canvas.Brush.Style := bsClear;
  if not Enabled then
    Canvas.Font.Color := clGrayText;

  Caption := MenuItem.Caption;
  if not FMenuController.MenuAnchorHighLight then
    Caption := StripHotkey(Caption);

  R := Rect(8, 0, Width - 8, Height);
  DrawText(Canvas.Handle, Caption, Length(Caption), R, UsePrefix[FMenuController.MenuAnchorHighLight] or DT_NOCLIP or DT_VCENTER or DT_LEFT or DT_SINGLELINE);
end;

procedure TUMenuButton.Click;
begin
  inherited Click;
end;

function TUMenuButton.GetIndex: Integer;
begin
  Result := -1;
  if FMenuController <> Nil then
    Result := FMenuController.FButtons.IndexOf(Self);
end;

procedure TUMenuButton.SetDown(Value: Boolean);
begin
  if FDown <> Value then begin
    FDown := Value;
    Invalidate;
  end;
end;

procedure TUMenuButton.SetImageIndex(Value: TImageIndex);
begin
  if FImageIndex <> Value then begin
    FImageIndex := Value;
    if FMenuController <> Nil then
      Invalidate;
  end;
end;

procedure TUMenuButton.SetMenuItem(Value: TMenuItem);
begin
  // Copy all appropriate values from menu item
  if Value <> Nil then begin
    if FMenuItem <> Value then
      Value.FreeNotification(Self);
    Action := Value.Action;
    Caption := Value.Caption;
    Down := Value.Checked;
    Enabled := Value.Enabled;
    Hint := Value.Hint;
    ImageIndex := Value.ImageIndex;
    Visible := Value.Visible;
  end;
  FMenuItem := Value;
end;

procedure TUMenuButton.SetParent(AParent: TWinControl);
begin
  if AParent = Nil then ;
  inherited SetParent(AParent);
end;

procedure TUMenuButton.CMHitTest(var Message: TCMHitTest);
begin
  Message.Result := Ord(not (DragKind = dkDock));
end;

procedure TUMenuButton.CMMouseEnter(var Message: TMessage);
begin
  FMouseInClient := True;
  inherited;
  Invalidate;
end;

procedure TUMenuButton.CMMouseLeave(var Message: TMessage);
begin
  FMouseInClient := False;
  inherited;
  Invalidate;
end;
{$ENDREGION}
{$REGION 'TUMenuAnyWhere'}
{ TUMenuAnyWhere }

constructor TUMenuAnyWhere.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FButtons := TList.Create;
  FMenuTriggerMode := mtmUnknown;
  FInMenuLoop := False;
  FCaptureChangeCancels := False;
  FControlWndProcHooked := False;
  FMenuDropped := False;
  FHotItem := -1;
end;

destructor TUMenuAnyWhere.Destroy;
begin
  DestroyButtons;
  FButtons.Free;
  inherited;
end;

procedure TUMenuAnyWhere.SetControl(Value: TWinControl);
begin
  if FControl = Value then
    Exit;
  //
  if Assigned(FControl) then
    UnHookWndProc;
  FControl := Value;
  if Value = Nil then
    Exit;
  HookWndProc;
end;

procedure TUMenuAnyWhere.SetMenu(Value: TMainMenu);
begin
  if FMenu = Value then
    Exit;
  if (FControl = Nil) or not (csAcceptsControls in FControl.ControlStyle) then
    raise EUMenuAnyWhere.Create('Control not set or does not accept other controls as child controls!');
  //
  if not (csDesigning in FControl.ComponentState) then begin
    FControl.ControlStyle := FControl.ControlStyle + [csCaptureMouse, csClickEvents, csDoubleClicks, csMenuEvents{, csSetCaption}, csGestures];
    TWinControlAccess(FControl).RecreateWnd;
  end;
  if Assigned(FMenu) then
    DestroyButtons;
  //
  if Assigned(FMenu) then begin
    FMenu.OnChange := Nil;
    FMenu.RemoveFreeNotification(Self);
  end;
  FMenu := Value;
  if not Assigned(FMenu) then
    Exit;
  FMenu.FreeNotification(Self);
  //
  CreateButtons;
  RecreateButtons;
  FMenu.OnChange := MenuChanged;
end;

procedure TUMenuAnyWhere.SetPos(Index, Value: Integer);
var
  oldPos: TPoint;
begin
  oldPos := FPos;
  case Index of
    0: FPos.X := Value;
    1: FPos.Y := Value;
  end;
  if (oldPos.X <> FPos.X) or (oldPos.Y <> FPos.Y) then
    RecreateButtons;
end;

procedure TUMenuAnyWhere.SetBackColor(Value: TColor);
begin

end;

procedure TUMenuAnyWhere.SetTransparent(Value: Boolean);
begin

end;

function FindButton(Controller: TUMenuAnyWhere; MenuButtonIndex: Integer; AForward: Boolean): TUMenuButton;
var
  I, J, Count: Integer;
begin
  if Controller <> Nil then begin
    J := MenuButtonIndex;
    I := J;
    Count := Controller.ButtonCount;
    if AForward then begin
      repeat
        if I = Count - 1 then
          I := 0
        else
          Inc(I);
        Result := Controller.Buttons[I];
        if Result.Visible and Result.Enabled then
          Exit;
      until I = J;
    end
    else begin
      repeat
        if I = 0 then
          I := Count - 1
        else
          Dec(I);
        Result := Controller.Buttons[I];
        if Result.Visible and Result.Enabled then
          Exit;
      until I = J;
    end;
  end;
  Result := Nil;
end;

function KeyCodeToString(KeyCode: Integer): String;
begin
  SetLength(Result, 128);
  SetLength(Result, GetKeynameText(KeyCode, @Result[1], Length(Result)));
end;

var
  MenuHook: HHOOK;
  MenuController, MenuController2: TUMenuAnyWhere;
  MenuButtonIndex: Integer;
  LastMenuItem: TMenuItem;
  LastMousePos: TPoint;
  StillModal: Boolean;
  InitDone: Boolean = False;

function MenuGetMsgHook(Code: Integer; WParam: Longint; var Msg: TMsg): Longint; stdcall;
const
  RightArrowKey: array[Boolean] of Word = (VK_LEFT, VK_RIGHT);
  LeftArrowKey: array[Boolean] of Word = (VK_RIGHT, VK_LEFT);
var
  P: TPoint;
  Target: TControl;
  Item: Integer;
  FindKind: TFindItemKind;
  ParentMenu: TMenu;

  procedure OpenMenu(AMenuButton: TControl);
  var
    Button: TUMenuButton;
  begin
    if (AMenuButton <> Nil) and (AMenuButton is TUMenuButton) then begin
      Button := TUMenuButton(AMenuButton);
      if (Button.Index <> MenuButtonIndex) and (Button.Parent <> Nil) and Button.Parent.HandleAllocated then begin
        OutputDebugString(PChar(GetTimeStamp + 'MenuGetMsgHook - OpenMenu'));
        StillModal := True;
        MenuController.FCaptureChangeCancels := False;
        MenuController.ClickButton(Button, True);
      end;
    end;
  end;

begin
  if LastMenuItem <> Nil then begin
    ParentMenu := LastMenuItem.GetParentMenu;
    if ParentMenu <> Nil then begin
      if ParentMenu.IsRightToLeft then begin
        if Msg.WParam = VK_LEFT then
          Msg.WParam := VK_RIGHT
        else
          if Msg.WParam = VK_RIGHT then
            Msg.WParam := VK_LEFT;
      end;
    end;
  end;
  Result := CallNextHookEx(MenuHook, Code, WParam, LPARAM(@Msg));
  if Result <> 0 then
    Exit;
  if (Code = MSGF_MENU) then begin
    Target := Nil;
    if not InitDone then begin
      InitDone := True;
      //if MenuController.FInMenuLoop or (MenuController.FMenuTriggerMode = mtmKeyboard) then begin
      if MenuController.FInMenuLoop then begin
        OutputDebugString(PChar(GetTimeStamp + 'MenuGetMsgHook - InitDone 1 (FInMenuLoop: ' + BoolToStr(MenuController.FInMenuLoop, True) + ' / FMenuTriggerMode: ' + IntToStr(Ord(MenuController.FMenuTriggerMode)) + ')'));
        PostMessage(Msg.Hwnd, WM_KEYDOWN, VK_DOWN, 0);
      end;
    end;
    case Msg.Message of
      WM_MENUSELECT: begin
        OutputDebugString(PChar(GetTimeStamp + 'MenuGetMsgHook - WM_MENUSELECT (StillModal: ' + BoolToStr(StillModal, True) + ')'));
        if (HiWord(Msg.WParam) = $FFFF) and (Msg.LParam = 0) then begin
          if not StillModal then
            MenuController.CancelMenu;
          Exit;
        end
        else
          StillModal := False;
        FindKind := fkCommand;
        if HiWord(Msg.WParam) and MF_POPUP <> 0 then
          FindKind := fkHandle;
        if FindKind = fkHandle then
          Item := GetSubMenu(Msg.LParam, LoWord(Msg.WParam))
        else
          Item := LoWord(Msg.WParam);
        LastMenuItem := MenuController.FTempMenu.FindItem(Item, FindKind);
        OutputDebugString(PChar(GetTimeStamp + 'MenuGetMsgHook - WM_MENUSELECT (LastMenuItem: ' + IfThen(LastMenuItem <> Nil, LastMenuItem.Name, 'NULL') + ')'));
      end;
      WM_SYSKEYDOWN: begin
        OutputDebugString(PChar(GetTimeStamp + 'MenuGetMsgHook - WM_SYSKEYDOWN'));
        if Msg.WParam = VK_MENU then begin
          MenuController.CancelMenu;
          Exit;
        end;
      end;
      WM_KEYDOWN: begin
        OutputDebugString(PChar(GetTimeStamp + 'MenuGetMsgHook - WM_KEYDOWN (Key: ''' + KeyCodeToString(Msg.lParam) + ''' / KeyCode: ' + IntToStr(Msg.wParam) + ')'));
        if Msg.WParam = VK_RETURN then
          MenuController.FMenuResult := True
        else if Msg.WParam = VK_ESCAPE then
          StillModal := True
        else begin
          if LastMenuItem <> Nil then begin
            if (Msg.WParam = VK_RIGHT) and (LastMenuItem.Count = 0) then
              Target := FindButton(MenuController, MenuButtonIndex, True)
            else begin
              if (Msg.WParam = VK_LEFT) and (LastMenuItem.GetParentComponent is TPopupMenu) then
                Target := FindButton(MenuController, MenuButtonIndex, False)
              else
                Target := Nil;
            end;
//            if Target <> Nil then
//              P := Target.ClientToScreen(Point(0, 0));
            if Target <> Nil then
              OutputDebugString(PChar(GetTimeStamp + 'MenuGetMsgHook - WM_KEYDOWN (Target)'));
            OpenMenu(Target);
          end
          else if MenuController.FMenuTriggerMode <> mtmKeyboard then begin
            //MenuController.FMenuTriggerMode := mtmKeyboard;
            OutputDebugString(PChar(GetTimeStamp + 'MenuGetMsgHook - InitDone 2 (FInMenuLoop: ' + BoolToStr(MenuController.FInMenuLoop, True) + ' / FMenuTriggerMode: ' + IntToStr(Ord(MenuController.FMenuTriggerMode)) + ')'));
//            if (Msg.WParam = VK_LEFT) or (Msg.WParam = VK_RIGHT) then
//              PostMessage(Msg.Hwnd, WM_KEYDOWN, VK_DOWN, 0);
          end;
//            MenuController.SetMenuAnchorHighLight(True);
//            if MenuController.FMenuDropped and (MenuController.FButtonMenu <> Nil) and (MenuController.FTempMenu <> Nil) then begin
//              ParentMenu := MenuController.FButtonMenu.GetParentMenu;
//              if ParentMenu <> Nil then begin
//                ParentMenu.Items.RethinkHotkeys;
//                //TMenuAccess(ParentMenu).UpdateItems;
//                if TMenuAccess(ParentMenu).WindowHandle <> 0 then
//                  RedrawWindow(TMenuAccess(ParentMenu).WindowHandle, Nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_ALLCHILDREN);
//              end;
//              MenuController.FTempMenu.AutoHotkeys := maAutomatic;
//              MenuController.FTempMenu.Items.RethinkHotkeys;
//              //TMenuAccess(MenuController.FTempMenu).UpdateItems;
//              if TMenuAccess(MenuController.FTempMenu).WindowHandle <> 0 then
//                RedrawWindow(TMenuAccess(MenuController.FTempMenu).WindowHandle, Nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_ALLCHILDREN);
//            end;
//          end;
        end;
      end;
      WM_MOUSEMOVE: begin
        P := Msg.pt;
        if (P.X <> LastMousePos.X) or (P.Y <> LastMousePos.Y) then begin
          LastMousePos := P;
          Target := FindDragTarget(P, False);
          if (Target <> Nil) and (Target is TUMenuButton) then
            OutputDebugString(PChar(GetTimeStamp + 'MenuGetMsgHook - WM_MOUSEMOVE (Target: MenuButton = ' + TUMenuButton(Target).Caption + ')'));
          OpenMenu(Target);
        end;
      end;
    end;
  end;
end;

procedure InitMenuHooks;
begin
  if MenuHook = 0 then begin
    OutputDebugString(PChar(GetTimeStamp + 'InitMenuHooks'));
//    StillModal := False;
    GetCursorPos(LastMousePos);
    MenuHook := SetWindowsHookEx(WH_MSGFILTER, @MenuGetMsgHook, 0, GetCurrentThreadID);
  end;
end;

procedure ReleaseMenuHooks;
begin
  OutputDebugString(PChar(GetTimeStamp + 'ReleaseMenuHooks'));
  if MenuHook <> 0 then
    UnhookWindowsHookEx(MenuHook);
  MenuHook := 0;
  LastMenuItem := Nil;
  MenuController := Nil;
  MenuButtonIndex := -1;
  InitDone := False;
end;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

var
  MenuKeyHook: HHOOK;

procedure ReleaseMenuKeyHooks; forward;

function MenuKeyMsgHook(Code: Integer; WParam: Longint; var Msg: TMsg): Longint; stdcall;
begin
  if (Code = HC_ACTION) then begin
    if Msg.Message = CM_DEACTIVATE then
      MenuController2.CancelMenu
    else
      if Msg.message = WM_COMMAND then
        ReleaseMenuKeyHooks
      else begin
        if (MenuHook = 0) and
           ((Msg.Message = WM_CHAR) or (Msg.Message = WM_KEYDOWN) or (Msg.Message = WM_KEYUP) or (Msg.Message = WM_SYSKEYDOWN) or (Msg.Message = WM_SYSKEYUP)) then
          Msg.hwnd := MenuController2.FControl.Handle;
      end;
  end;
  Result := CallNextHookEx(MenuKeyHook, Code, WParam, LPARAM(@Msg))
end;

procedure InitMenuKeyHooks;
begin
  if MenuKeyHook = 0 then
    MenuKeyHook := SetWindowsHookEx(WH_GETMESSAGE, @MenuKeyMsgHook, 0, GetCurrentThreadID);
end;

procedure ReleaseMenuKeyHooks;
begin
  if MenuKeyHook <> 0 then
    UnhookWindowsHookEx(MenuKeyHook);
  MenuKeyHook := 0;
  MenuController2 := Nil;
end;

procedure TUMenuAnyWhere.InitMenu(Button: TUMenuButton);
begin
  OutputDebugString(PChar(GetTimeStamp + 'InitMenu'));
  MenuController2 := Self;
  TWinControlAccess(FControl).MouseCapture := True;
  InitMenuKeyHooks;
  if Button <> Nil then begin
    FHotItem := Button.Index;
    ClickButton(Button, False);
  end
  else
    FHotItem := 0;
  if Button = Nil then
    FCaptureChangeCancels := True;
  SetMenuAnchorHighLight(True);
end;

function TUMenuAnyWhere.TrackMenu(Button: TUMenuButton): Boolean;
begin
  OutputDebugString(PChar(GetTimeStamp + 'TrackMenu'));
  // Already in menu loop - click button to drop-down menu
  if FInMenuLoop then begin
    if Button <> Nil then begin
      ClickButton(Button, False);
      Result := True;
    end
    else
      Result := False;
    Exit;
  end;

  InitMenu(Button);
  try
    FInMenuLoop := True;
    repeat
      Application.HandleMessage;
      if Application.Terminated then
        FInMenuLoop := False;
    until not FInMenuLoop;
  finally
    CancelMenu;
  end;
  Result := FMenuResult;
end;

procedure TUMenuAnyWhere.CancelMenu;
begin
  OutputDebugString(PChar(GetTimeStamp + 'CancelMenu'));
  if FInMenuLoop then begin
    ReleaseMenuKeyHooks;
    TWinControlAccess(FControl).MouseCapture := False;
    SetMenuAnchorHighLight(False);
  end;
  FMenuTriggerMode := mtmUnknown;
  FInMenuLoop := False;
  StillModal := False;
  FCaptureChangeCancels := False;
  FHotItem := -1;
end;

function TUMenuAnyWhere.CheckMenuDropdown(Button: TUMenuButton): Boolean;
var
  Hook: Boolean;
  Item: TMenuItem;
  I: Integer;
  ParentMenu: TMenu;
  APoint: TPoint;
  LMonitor: TMonitor;
begin
  Result := False;
  if (Button = Nil) or (Button.Parent = Nil){ or (FInMenuLoop and FMenuDropped)} then
    Exit;
  OutputDebugString(PChar(GetTimeStamp + 'CheckMenuDropdown (FMenuDropped: ' + BoolToStr(FMenuDropped, True) + ')'));
  FCaptureChangeCancels := False;
  FMenuDropped := True;
  try
    if Button.MenuItem <> Nil then begin
      Button.MenuItem.Click;
      ClearTempMenu;
      FTempMenu := TPopupMenu.Create(Self);
      ParentMenu := Button.MenuItem.GetParentMenu;
      if ParentMenu <> Nil then
        FTempMenu.BiDiMode := ParentMenu.BiDiMode;
      FTempMenu.HelpContext := Button.MenuItem.HelpContext;
      FTempMenu.TrackButton := tbLeftButton;
      if ParentMenu <> Nil then
        FTempMenu.Images := ParentMenu.Images;
      FButtonMenu := Button.MenuItem;
      for I := FButtonMenu.Count - 1 downto 0 do begin
        Item := FButtonMenu.Items[I];
        FButtonMenu.Delete(I);
        FTempMenu.Items.Insert(0, Item);
      end;
    end
    else begin
      OutputDebugString(PChar(GetTimeStamp + 'CheckMenuDropdown (Button.MenuItem = Nil)'));
      Exit;
    end;
    FTempMenu.PopupComponent := FControl;
    //
    if not FInMenuLoop then
      TWinControlAccess(FControl).SendCancelMode(Nil);
    //
    //ReleaseMenuHooks;
    Hook := (Button.MenuItem <> Nil);
    if Hook then begin
      MenuButtonIndex := Button.Index;
      MenuController := Self;
      InitMenuHooks;
    end;
    FHotItem := -1;
    try
      APoint := Button.ClientToScreen(Point(0, Button.ClientHeight));
      if FTempMenu.IsRightToLeft then
        Inc(APoint.X, Button.Width);
      LMonitor := Screen.MonitorFromPoint(APoint);
      if (LMonitor <> Nil) and ((GetSystemMetrics(SM_CYMENU) * FTempMenu.Items.Count) + APoint.Y > LMonitor.Height) then
        Dec(APoint.Y, Button.Height);
      Button.Down := True;
      Button.Invalidate;
      FTempMenu.Popup(APoint.X, APoint.Y);
    finally
      if Hook then
        ReleaseMenuHooks;
    end;
    FMenuButton := Button;
    if StillModal then
      FHotItem := Button.Index;
    Result := True;
  finally
    PostMessage(FControl.Handle, CN_DROPDOWNCLOSED, 0, 0);
  end;
end;

procedure TUMenuAnyWhere.ClickButton(Button: TUMenuButton; DoubleClick: Boolean);
var
  P: TPoint;
  SmallPt: TSmallPoint;
begin
  OutputDebugString(PChar(GetTimeStamp + 'ClickButton' + IfThen(DoubleClick, ' (DoubleClick)')));
  FCaptureChangeCancels := False;
  P := Button.ClientToScreen(Point(0, 0));
  SmallPt := PointToSmallPoint(FControl.ScreenToClient(P));
  PostMessage(FControl.Handle, WM_LBUTTONDOWN, MK_LBUTTON, MakeLong(SmallPt.X, SmallPt.Y));
  if DoubleClick then begin
    //PostMessage(FControl.Handle, WM_LBUTTONUP, MK_LBUTTON, MakeLong(SmallPt.X, SmallPt.Y));
    PostMessage(FControl.Handle, WM_LBUTTONDOWN, MK_LBUTTON, MakeLong(SmallPt.X, SmallPt.Y));
  end;
end;

procedure TUMenuAnyWhere.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then begin
    if AComponent = FControl then
      Control := Nil;
    if AComponent = FMenu then
      Menu := Nil;
  end;
end;

procedure TUMenuAnyWhere.ControlWndProc(var Message: TMessage);

  procedure DefaultProc;
  begin
    FControlWndProcOld(Message);
  end;

  function IsMenuAvailable: Boolean;
  var
    i: Integer;
  begin
    Result := False;
    for i := 0 to FButtons.Count - 1 do begin
      if Assigned(Buttons[i].MenuItem) then begin
        Result := True;
        Break;
      end;
    end;
  end;

  function ContainsActiveControl: Boolean;
  var
    F: TCustomForm;
  begin
    F := GetParentForm(FControl, False);
    if (F <> Nil) and (Screen.ActiveControl <> Nil) then
      Result := (F = Screen.ActiveControl) or F.ContainsControl(Screen.ActiveControl)
    else
      Result := False;
  end;

var
  LControl: TControl;
  CapControl: TControl;
  Msg: TMsg;

  function IsButtonMouseMsg(var Message: TWMMouse): Boolean;
  begin
    if GetCapture = FControl.Handle then begin
      CapControl := GetCaptureControl;
      if (CapControl <> Nil) and (CapControl.Parent <> FControl) then
        CapControl := Nil;
    end
    else
      CapControl := Nil;
    LControl := FControl.ControlAtPos(SmallPointToPoint(Message.Pos), False);
    Result := (LControl <> Nil) and (LControl is TUMenuButton) and not LControl.Dragging;
  end;

  procedure SendDropdownMsg(Button: TUMenuButton);
  var
    Msg: TNMToolBar;
  begin
    StillModal := True;
    FillChar(Msg, SizeOf(Msg), 0);
    with Msg, hdr do begin
      hwndFrom := FControl.Handle;
      idFrom := FControl.Handle;
      code := TBN_DROPDOWN;
      iItem := Button.Index;
    end;
    SendStructMessage(FControl.Handle, WM_NOTIFY, FControl.Handle, Msg);
  end;

var
  WMKeyDown: TWMKeyDown;
  WMSysCommand: TWMSysCommand;
  WMChar: TWMChar;
  WMNotifyTLB: TWMNotifyTLB;
  CMDialogChar: TCMDialogChar;
  CMControlChange: TCMControlChange;
  Item: Integer;
  Button: TUMenuButton;
  Form: TCustomForm;
begin
  case Message.Msg of
    WM_GETDLGCODE: begin
      OutputDebugString(PChar(GetTimeStamp + 'WM_GETDLGCODE'));
      if FInMenuLoop then
        Message.Result := DLGC_WANTARROWS;
    end;
    WM_MOUSEMOVE: begin
      //OutputDebugString(PChar(GetTimeStamp + 'WM_MOUSEMOVE'));
      // Call default wndproc to get buttons to repaint when Flat = True.
      if not (csDesigning in ComponentState) and IsButtonMouseMsg(TWMMouse(Message)) then begin
        // Prevent painting of flat buttons when they are dock clients }
        if TControlAccess(LControl).DragMode <> dmAutomatic then
          FControl.DefaultHandler(Message);
      end
      else
        FControl.DefaultHandler(Message);
    end;
    WM_LBUTTONUP: begin
      OutputDebugString(PChar(GetTimeStamp + 'WM_LBUTTONUP'));
      // Update button states after a click.
      if not (csDesigning in ComponentState) and IsButtonMouseMsg(TWMMouse(Message)) then begin
        FControl.DefaultHandler(Message);
        if (CapControl = LControl) or (LControl is TUMenuButton) then begin
          Button := TUMenuButton(LControl);
          if Button.Down then
             Button.Down := False;
          Button.Invalidate;
          //UpdateButtonStates;
        end
        else if CapControl is TUMenuButton then
          Exit;
      end;
    end;
    WM_LBUTTONDOWN,
    WM_LBUTTONDBLCLK: begin
      OutputDebugString(PChar(GetTimeStamp + IfThen(Message.Msg <> WM_LBUTTONDBLCLK, 'WM_LBUTTONDOWN', 'WM_LBUTTONDBLCLK')));
      if not (csDesigning in ComponentState) and IsButtonMouseMsg(TWMMouse(Message)) then begin
        if not LControl.Dragging then
          FControl.DefaultHandler(Message);
        //
        if TUMenuButton(LControl).MenuItem <> Nil then begin
          try
            if Message.Msg <> WM_LBUTTONDBLCLK then
              FMenuTriggerMode := mtmMouse;
            SendDropDownMsg(TUMenuButton(LControl));
          finally
            // Here we remove WM_LBUTTONDOWN message sent and instead dispatch it as a WM_LBUTTONUP to get a Click fired.
            Msg.Message := 0;
            if PeekMessage(Msg, FControl.Handle, WM_LBUTTONDOWN, WM_LBUTTONDOWN, PM_REMOVE) and (Msg.Message = WM_QUIT) then
              PostQuitMessage(Msg.WParam)
            else begin
              Message.Msg := WM_LBUTTONUP;
              FControl.Dispatch(Message);
            end;
          end;
        end;
        Exit;
      end;
    end;
    WM_KEYDOWN: begin
      WMKeyDown := TWMKeyDown(Message);
      OutputDebugString(PChar(GetTimeStamp + 'WM_KEYDOWN (Key: ''' + KeyCodeToString(Message.LParam) + ''' / KeyCode: ' + IntToStr(WMKeyDown.CharCode) + ')'));
      if FInMenuLoop then begin
        Item := FHotItem;
        case WMKeyDown.CharCode of
          VK_RETURN, VK_DOWN: begin
            if (Item > -1) and (Item < FButtons.Count) then begin
              Button := TUMenuButton(FButtons[Item]);
              //P := Button.ClientToScreen(Point(1, 1));
              FMenuTriggerMode := mtmKeyboard;
              //ClickButton(Button);
              SendDropDownMsg(Button);
            end;
            // Prevent default processing
            if WMKeyDown.CharCode = VK_DOWN then
              Exit;
          end;
          VK_LEFT,
          VK_RIGHT: begin
            if not FMenuDropped then begin
              Button := FindButton(Self, FHotItem, WMKeyDown.CharCode = VK_RIGHT);
              if Button <> Nil then begin
                FHotItem := Button.Index;
                UpdateButtons(False);
              end;
            end;
          end;
          VK_ESCAPE: CancelMenu;
        end;
      end
      else begin
        if FMenuDropped or (FButtonMenu <> Nil) then begin
          // Prevent default processing
          if WMKeyDown.CharCode = VK_DOWN then
            Exit;
        end;
      end;
    end;
    WM_CAPTURECHANGED: begin
      OutputDebugString(PChar(GetTimeStamp + 'WM_CAPTURECHANGED'));
      DefaultProc;
      if FInMenuLoop and FCaptureChangeCancels then
        CancelMenu;
      Exit;
    end;
    WM_SIZE: begin
    end;
    WM_SYSCHAR: begin
      OutputDebugString(PChar(GetTimeStamp + 'WM_SYSCHAR'));
      // Default wndproc doesn't re-route WM_SYSCHAR messages to parent.
      Form := GetParentForm(FControl);
      if Form <> Nil then begin
        Form.Dispatch(Message);
        Exit;
      end
    end;
    WM_SYSCOMMAND: begin
      OutputDebugString(PChar(GetTimeStamp + 'WM_SYSCOMMAND'));
      // Enter menu loop if only the Alt key is pressed -- ignore Alt-Space and let the default processing show the system menu.
      if not FInMenuLoop and FControl.Enabled and FControl.Showing and IsMenuAvailable then begin
        WMSysCommand := TWMSysCommand(Message);
        if (WMSysCommand.CmdType and $FFF0 = SC_KEYMENU) and (WMSysCommand.Key <> VK_SPACE) and (WMSysCommand.Key <> Word('-')) and (GetCapture = 0) then begin
          if WMSysCommand.Key = 0 then
            Button := Nil
          else
            Button := FindButtonFromAccel(WMSysCommand.Key);
          if (WMSysCommand.Key = 0) or ((Button <> Nil) and (Button.ImageIndex > -1)) then begin
            TrackMenu(Button);
            Message.Result := 1;
            Exit;
          end;
        end;
      end;
    end;
    CM_DIALOGCHAR: begin
      OutputDebugString(PChar(GetTimeStamp + 'CM_DIALOGCHAR'));
      if FControl.Enabled and FControl.Showing and ContainsActiveControl then begin
        CMDialogChar := TCMDialogChar(Message);
        Button := FindButtonFromAccel(CMDialogChar.CharCode);
        if (Button <> Nil) then begin
          if Button.MenuItem <> Nil then
            TrackMenu(Button)
          else
            Button.Click;
          Message.Result := 1;
          Exit;
        end;
      end;
    end;
    CM_FONTCHANGED: begin
    end;
    CM_PARENTCOLORCHANGED: begin
    end;
    CN_CHAR: begin
      OutputDebugString(PChar(GetTimeStamp + 'CN_CHAR'));
      // We got here through the installed MenuKeyHook
      if FInMenuLoop and not (csDesigning in FControl.ComponentState) then begin
        WMChar := TWMChar(Message);
        if FControl.Perform(CM_DIALOGCHAR, WMChar.CharCode, WMChar.KeyData) <> 0 then
          Message.Result := 1;
      end;
    end;
    CN_SYSKEYDOWN: begin
      OutputDebugString(PChar(GetTimeStamp + 'CN_SYSKEYDOWN'));
      if (TWMSysKeyDown(Message).CharCode = VK_MENU) then
        CancelMenu;
    end;
    CN_NOTIFY: begin
      OutputDebugString(PChar(GetTimeStamp + 'CN_NOTIFY'));
      WMNotifyTLB := TWMNotifyTLB(Message);
      case WMNotifyTLB.NMHdr.code of
        TBN_DROPDOWN: begin
          // We can safely assume that a TBN_DROPDOWN message was generated by a TUMenuButton and not any other TControl.
          Item := WMNotifyTLB.NMToolBar^.iItem;
          if (Item > -1) and (Item < FButtons.Count) then begin
            Button := Buttons[Item];
            if Button <> Nil then
              Button.CheckMenuDropDown;
          end;
        end;
      end;
    end;
    CN_DROPDOWNCLOSED: begin
      OutputDebugString(PChar(GetTimeStamp + 'CN_DROPDOWNCLOSED'));
      ClearTempMenu;
      SetMenuAnchorHighLight(False);
      FMenuTriggerMode := mtmUnknown;
      FMenuDropped := False;
      FCaptureChangeCancels := True;
    end;
    CM_CONTROLCHANGE: begin
      CMControlChange := TCMControlChange(Message);
      if CMControlChange.Inserting then
        InsertButton(CMControlChange.Control)
      else
        RemoveButton(CMControlChange.Control);
    end;
  end;
  DefaultProc;
end;

function TUMenuAnyWhere.GetButton(Index: Integer): TUMenuButton;
begin
  Result := TUMenuButton(FButtons[Index]);
end;

function TUMenuAnyWhere.GetButtonCount: Integer;
begin
  Result := FButtons.Count;
end;

procedure TUMenuAnyWhere.GetButtonSize(var AWidth, AHeight: Integer);
var
  i, size: Integer;
  btn: TUMenuButton;
  canvas: TCanvas;
begin
  AWidth := 0;
  AHeight := FControl.Height;
  canvas:=ControlCanvas;
  try
    for i:=0 to FButtons.Count - 1 do begin
      btn := Buttons[i];
      size := 0;
      if (btn <> Nil) and (btn.MenuItem <> Nil) then
        size := canvas.TextWidth(btn.MenuItem.Caption);
      if size > AWidth then
        AWidth := size;
    end;
    Inc(AWidth, 16);
  finally
    canvas.Free;
  end;
end;

function TUMenuAnyWhere.ControlCanvas: TCanvas;
begin
  Result := TControlCanvas.Create;
  if FControl <> Nil then begin
    TControlCanvas(Result).Control := FControl;
    Result.Handle := GetDC(FControl.Handle);
  end;
end;

procedure TUMenuAnyWhere.ClearTempMenu;
var
  i: Integer;
  Item: TMenuItem;
begin
  if (FButtonMenu <> Nil) and (FMenuButton <> Nil) and (FMenuButton.MenuItem <> Nil) and (FTempMenu <> Nil) then begin
    for i:=FTempMenu.Items.Count - 1 downto 0 do begin
      Item := FTempMenu.Items[i];
      FTempMenu.Items.Delete(i);
      FButtonMenu.Insert(0, Item);
    end;
    FTempMenu.Free;
    FTempMenu := Nil;
    if FMenuButton <> Nil then begin
      FMenuButton.Down := False;
      FMenuButton.Invalidate;
      FMenuButton := Nil;
    end;
    FButtonMenu := Nil;
  end;
end;

procedure TUMenuAnyWhere.HookWndProc;
begin
  if FControl = Nil then
    raise EUMenuAnyWhere.Create('Control not set!');
  //
  if FControlWndProcHooked then
    Exit;
  //
  FControlWndProcOld := FControl.WindowProc;
  FControl.WindowProc := ControlWndProc;
  FControlWndProcHooked := True;
end;

procedure TUMenuAnyWhere.UnHookWndProc;
begin
  if (FControl = Nil) or not FControlWndProcHooked then
    Exit;
  //
  FControl.WindowProc := FControlWndProcOld;
  FControlWndProcHooked := True;
end;

procedure TUMenuAnyWhere.MenuChanged(Sender: TObject; Source: TMenuItem; Rebuild: Boolean);
begin
  if FMenuDropped or not (csDesigning in ComponentState) then
    Exit;
  DestroyButtons;
  CreateButtons;
  RecreateButtons;
end;

procedure TUMenuAnyWhere.CreateButtons;
var
  i: Integer;
  btn: TUMenuButton;
begin
  for i:=0 to FMenu.Items.Count - 1 do begin
    btn := TUMenuButton.Create(Self);
    try
      btn.AutoSize := False;
      //btn.Grouped := True;
      btn.Visible := False;
      btn.MenuItem := FMenu.Items[i];
      btn.MenuItem.AutoHotkeys := maManual;
      btn.Parent := FControl;
    except
      btn.Free;
      raise;
    end;
  end;
  GetButtonSize(FButtonWidth, FButtonHeight);
end;

procedure TUMenuAnyWhere.DestroyButtons;
var
  i: Integer;
begin
  for i:=ButtonCount - 1 downto 0 do
    Buttons[i].Free;
end;

procedure TUMenuAnyWhere.RecreateButtons;
var
  i, pos: Integer;
  btn: TUMenuButton;
begin
  pos := 4;
  for i:=0 to FButtons.Count - 1 do begin
    btn := Buttons[i];
    if btn = Nil then
      Continue;
    btn.Visible := False; // hide button
    if (btn.MenuItem = Nil) or not btn.MenuItem.Visible then
      Continue;
    //
    btn.SetBounds(PosX + pos, PosY, FButtonWidth, FButtonHeight);
    btn.Visible := True;
    Inc(pos, FButtonWidth + 4);
  end;
end;

procedure TUMenuAnyWhere.UpdateButtons(RemakeShortCuts: Boolean);
var
  i: Integer;
  menuItem: TMenuItem;
begin
  if RemakeShortCuts and (FMenu.AutoHotkeys = maAutomatic) then begin
    FMenu.Items.RethinkHotkeys;
    FMenu.Items.RethinkLines;
  end;
  for i:=0 to ButtonCount - 1 do begin
    if RemakeShortCuts then begin
      if Buttons[i].MenuItem <> Nil then begin
        Buttons[i].MenuItem.AutoHotkeys := maAutomatic;
        menuItem := FMenu.Items.Find(Buttons[i].MenuItem.Caption);
        Buttons[i].MenuItem := menuItem;
      end;
    end
    else if Buttons[i].MenuItem <> Nil then
      Buttons[i].MenuItem.AutoHotkeys := maManual;
    Buttons[i].Invalidate;
  end;
end;

procedure TUMenuAnyWhere.InsertButton(AControl: TControl);
var
  FromIndex, ToIndex: Integer;
begin
  if AControl is TUMenuButton then
    TUMenuButton(AControl).FMenuController := Self;
  if not (csLoading in AControl.ComponentState) then begin
    FromIndex := FButtons.IndexOf(AControl);
    if FromIndex >= 0 then
      ReorderButton(Fromindex, AControl.Left, AControl.Top)
    else begin
      ToIndex := ButtonIndex(FromIndex, AControl.Left, AControl.Top);
      FButtons.Insert(ToIndex, AControl);
    end;
  end
  else
    FButtons.Add(AControl);
end;

procedure TUMenuAnyWhere.RemoveButton(AControl: TControl);
var
  i: Integer;
begin
  i := FButtons.IndexOf(AControl);
  if i >= 0 then begin
    if AControl is TUMenuButton then
      TUMenuButton(AControl).FMenuController := Nil;
    FButtons.Remove(AControl);
  end;
end;

function TUMenuAnyWhere.ButtonIndex(OldIndex, ALeft, ATop: Integer): Integer;
begin
  Result := FButtons.Count;
end;

function TUMenuAnyWhere.ReorderButton(OldIndex, ALeft, ATop: Integer): Integer;
var
  AControl: TControl;
begin
  Result := ButtonIndex(OldIndex, ALeft, ATop);
  if Result <> OldIndex then begin
    // If we are inserting to the right of our deletion then account for shift
    if OldIndex < Result then Dec(Result);
    AControl := TControl(FButtons[OldIndex]);
    FButtons.Delete(OldIndex);
    FButtons.Insert(Result, AControl);
  end;
end;

function TUMenuAnyWhere.FindButtonFromAccel(Accel: Word): TUMenuButton;
var
  i: Integer;
begin
  for i:=0 to FButtons.Count - 1 do begin
    Result := Buttons[i];
    if Result.Visible and Result.Enabled and IsAccel(Accel, Result.Caption) then
      Exit;
  end;
  Result := Nil;
end;

procedure TUMenuAnyWhere.SetMenuAnchorHighLight(Active: Boolean);
begin
  if FMenuAnchorHighLight <> Active then begin
    FMenuAnchorHighLight := Active;
    UpdateButtons(Active);
  end;
end;
{$ENDREGION}

end.
