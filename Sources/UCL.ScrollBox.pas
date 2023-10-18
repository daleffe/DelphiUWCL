unit UCL.ScrollBox;

interface

uses
  Classes,
  Types,
  TypInfo,
  Windows,
  Messages,
  FlatSB,
  Controls,
  Forms,
  ExtCtrls,
  Graphics,
  UCL.Classes,
  UCL.Types,
  UCL.Colors,
  UCL.ThemeManager,
  UCL.IntAnimation,
  UCL.Utils;

type
  TUScrollBarStyle = (sbsMini, sbsFull, sbsNo);

  TUMiniScrollBar = class(TCustomPanel)
  private
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;

  public
    constructor Create(AOwner: TComponent); override;

  published
    property Visible default False;
  end;

  TUScrollBox = class(TScrollBox, IUThemedComponent, IUIDEAware)
  private var
    MiniSB: TUMiniScrollBar;
    MINI_SB_SIZE: Byte;
    MINI_SB_THICKNESS: Byte;
    MINI_SB_MARGIN: Byte;
    MINI_SB_COLOR: TColor;
    MINI_SB_THICKNESS_HOVERED: Byte;
    MINI_SB_MARGIN_HOVERED: Byte;
    MINI_SB_COLOR_HOVERED: TColor;

  private
    FThemeManager: TUThemeManager;
    FAniSet: TIntAniSet;
    FBackColor: TUThemeControlColorSet;

    FScrollCount: Integer;
    FScrollOrientation: TUOrientation;
    FScrollBarStyle: TUScrollBarStyle;
    FLengthPerStep: Integer;
    FMaxScrollCount: Integer;
    FMouseInControl: Boolean;
    FScrollBarTimer: TTimer;
    //
    // Internally used variables
    Animation: TIntAni;
    ScrollBar: TControlScrollBar;
    ScrollSign: Integer;

    // Setters
    procedure SetBackColor(Value: TUThemeControlColorSet);
    procedure SetThemeManager(const Value: TUThemeManager);
    procedure SetScrollBarStyle(const Value: TUScrollBarStyle); // suppress default scrollbar blinking

    // Child events
    procedure ColorsChange(Sender: TObject);
    procedure ScrollBar_OnTimer(Sender: TObject);

    // Messages
//    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure WMMouseMove(var Msg: TWMMouseMove); message WM_MOUSEMOVE;
//    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMMouseWheel(var Msg: TWMMouseWheel); message CM_MOUSEWHEEL;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
//    procedure WMNCMouseLeave(var Message: TMessage); message WM_NCMOUSELEAVE;
    procedure WMHScroll(var Message: TWMHScroll); message WM_HSCROLL; // suppress default scrollbar blinking
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL; // suppress default scrollbar blinking

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure ChangeScale(M, D: Integer{$IF CompilerVersion > 29}; isDpiChange: Boolean{$IFEND}); override;
    procedure CreateParams(var Params: TCreateParams); override; // suppress default scrollbar blinking
    // IUIDEAware
    function IsCreating: Boolean; inline;
    function IsDestroying: Boolean; inline;
    function IsLoading: Boolean; inline;
    function IsDesigning: Boolean; inline;

    function CanShowMiniSB(var SB: TControlScrollBar): Boolean; virtual;
    procedure CreateAnimationThread(const SyncProc: TAniSyncProc; const DoneProc: TAniDoneProc); virtual;
    function GetClientRect: TRect; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //
    procedure SetOldSBVisible(IsVisible: Boolean);
    procedure UpdateMiniSB;
    procedure SetMiniSBVisible(IsVisible: Boolean);

    // IUThemedComponent
    procedure UpdateTheme;
    function IsCustomThemed: Boolean;
    function CustomThemeManager: TUCustomThemeManager;

  published
    property ThemeManager: TUThemeManager read FThemeManager write SetThemeManager;
    property AniSet: TIntAniSet read FAniSet write FAniSet;
    property BackColor: TUThemeControlColorSet read FBackColor write SetBackColor;

    property ScrollCount: Integer read FScrollCount;
    property ScrollBarStyle: TUScrollBarStyle read FScrollBarStyle write SetScrollBarStyle default sbsMini;
    property ScrollOrientation: TUOrientation read FScrollOrientation write FScrollOrientation default oVertical;
    property LengthPerStep: Integer read FLengthPerStep write FLengthPerStep default 4;
    property MaxScrollCount: Integer read FMaxScrollCount write FMaxScrollCount default 8;

    property BorderStyle default bsNone;
  end;

implementation

uses
  SysUtils,
  UCL.Form;

type
  TUFormAccess = class(TUForm);

{ TUMiniScrollBar }

constructor TUMiniScrollBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

{$IF CompilerVersion > 29}
  StyleElements :=[];
{$IFEND}
  BevelOuter := bvNone;
  BevelInner := bvNone;
  FullRepaint := False;
  DoubleBuffered := True;
  ParentBackground := False;
  ParentColor := False;

  Visible := False;
end;

procedure TUMiniScrollBar.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  Msg.Result := HTTRANSPARENT;
end;

{ TUScrollBox }

//  MAIN CLASS

constructor TUScrollBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
//  ControlStyle := ControlStyle - [csNeedsBorderPaint];
  FThemeManager := Nil;

  //  Internal
  MINI_SB_SIZE := 6;

  MINI_SB_THICKNESS := 2;
  MINI_SB_MARGIN := 3;
  MINI_SB_COLOR := $7A7A7A;

  MINI_SB_THICKNESS_HOVERED := 4;
  MINI_SB_MARGIN_HOVERED := 1;
  MINI_SB_COLOR_HOVERED := $EAEAEA;

  //  Parent properties
  BevelEdges:=[];
  BevelInner:=bvNone;
  BevelOuter:=bvNone;
  BevelKind:=bkNone;
  BorderStyle := bsNone;
{$IF CompilerVersion > 29}
  StyleElements:=[];
{$IFEND}
  VertScrollBar.ButtonSize:=0;
  VertScrollBar.Increment:=8;
  VertScrollBar.Margin:=0;
  VertScrollBar.Position:=0;
  VertScrollBar.Range:=0;
  VertScrollBar.Size:=0;
  VertScrollBar.ThumbSize:=0;
  VertScrollBar.Tracking := True;
  //
  HorzScrollBar.ButtonSize:=0;
  HorzScrollBar.Increment:=8;
  HorzScrollBar.Margin:=0;
  HorzScrollBar.Position:=0;
  HorzScrollBar.Range:=0;
  HorzScrollBar.Size:=0;
  HorzScrollBar.ThumbSize:=0;
  HorzScrollBar.Tracking := True;

  //  Fields
  FScrollCount := 0;
  FScrollOrientation := oVertical;
  FScrollBarStyle := sbsMini;
  FLengthPerStep := 4;
  FMaxScrollCount := 8;
  FMouseInControl := False;

  //  Mini scrollbar
  MiniSB := TUMiniScrollBar.Create(Self);
  MiniSB.Parent := Self;
  MiniSB.SetSubComponent(True);
  MiniSB.Visible := False;
  MiniSB.Width := 0;
  MiniSB.Height := 0;
  MiniSB.Color := MINI_SB_COLOR;

  //  Custom AniSet
  FAniSet := TIntAniSet.Create;
  FAniSet.QuickAssign(akOut, afkCubic, 0, 120, 10, True);
  // Internal variables
  Animation:= Nil;
  ScrollBar:=Nil;
  ScrollSign:=0;

  FBackColor := TUThemeControlColorSet.Create;
  FBackColor.Assign(SCROLLBOX_BACK);
  FBackColor.OnChange := ColorsChange;

  FScrollBarTimer := TTimer.Create(Nil);
  FScrollBarTimer.Enabled := False;
  FScrollBarTimer.Interval := 5000;
  FScrollBarTimer.OnTimer := ScrollBar_OnTimer;

  if GetCommonThemeManager <> Nil then
    GetCommonThemeManager.Connect(Self);

//  UpdateTheme;
end;

procedure TUScrollBox.CreateAnimationThread(const SyncProc: TAniSyncProc; const DoneProc: TAniDoneProc);
begin
  if Animation = Nil then begin
    Animation := TIntAni.Create(1, +LengthPerStep, SyncProc, DoneProc);
    Animation.AniSet.Assign(Self.AniSet);
  end;
end;

procedure TUScrollBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if FScrollBarStyle = sbsMini then begin
    if not IsDesigning then
      Params.ExStyle := Params.ExStyle or WS_CLIPCHILDREN;
    Params.WindowClass.style := Params.WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;

destructor TUScrollBox.Destroy;
var
  TM: TUCustomThemeManager;
begin
  FScrollBarTimer.Enabled := False;
  MiniSB.Free;
  if Assigned(Animation) then
    Animation.Free;
  FAniSet.Free;
  FBackColor.Free;
  FScrollBarTimer.Free;
  TM:=SelectThemeManager(Self);
  TM.Disconnect(Self);
  inherited;
end;

function TUScrollBox.IsCreating: Boolean;
begin
  Result := (csCreating in ControlState);
end;

function TUScrollBox.IsDestroying: Boolean;
begin
  Result := (csDestroying in ComponentState);
end;

function TUScrollBox.IsLoading: Boolean;
begin
  Result := (csLoading in ComponentState);
end;

function TUScrollBox.IsDesigning: Boolean;
begin
  Result := (csDesigning in ComponentState);
end;

//  THEME

procedure TUScrollBox.SetBackColor(Value: TUThemeControlColorSet);
begin
  FBackColor.Assign(Value);
end;

procedure TUScrollBox.SetThemeManager(const Value: TUThemeManager);
begin
  if (Value <> Nil) and (FThemeManager = Nil) then
    GetCommonThemeManager.Disconnect(Self);

  if (Value = Nil) and (FThemeManager <> Nil) then
    FThemeManager.Disconnect(Self);

  FThemeManager := Value;

  if FThemeManager <> Nil then
    FThemeManager.Connect(Self);

  if FThemeManager = Nil then
    GetCommonThemeManager.Connect(Self);

  UpdateTheme;
end;

procedure TUScrollBox.SetScrollBarStyle(const Value: TUScrollBarStyle);
begin
  if FScrollBarStyle <> Value then begin
    FScrollBarStyle := Value;
    RecreateWnd;
  end;
end;

procedure TUScrollBox.UpdateTheme;
var
  TM: TUCustomThemeManager;
  ColorSet: TUThemeControlColorSet;
begin
  TM:=SelectThemeManager(Self);
  // Select default or custom style
  if BackColor.Enabled then
    ColorSet := BackColor
  else
    ColorSet := SCROLLBOX_BACK;

  Color := ColorSet.GetColor(TM);
  if TM.ThemeUsed = utLight then
    MiniSB.Color := MINI_SB_COLOR_LIGHT
  else
    MiniSB.Color := MINI_SB_COLOR_DARK;
  Invalidate;
end;

function TUScrollBox.IsCustomThemed: Boolean;
begin
  Result:=(FThemeManager <> Nil);
end;

function TUScrollBox.CustomThemeManager: TUCustomThemeManager;
begin
  Result:=FThemeManager;
end;

procedure TUScrollBox.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FThemeManager) then begin
    ThemeManager:=Nil;
    Exit;
  end;
  inherited Notification(AComponent, Operation);
end;

//  CUSTOM METHODS

function TUScrollBox.CanShowMiniSB(var SB: TControlScrollBar): Boolean;
var
  ControlSize: Integer;
begin
  Result := True;
  //  Get orientation values
  if ScrollOrientation = oVertical then begin
    SB := VertScrollBar;
    ControlSize := Height;
  end
  else begin
    SB := HorzScrollBar;
    ControlSize := Width;
  end;

  if (SB.Range = 0) or (SB.Range <= ControlSize) then
    Result := False;
end;

function TUScrollBox.GetClientRect: TRect;
//var
//  scroll_size_x, scroll_size_y: Integer;
//  SB: TControlScrollBar;
begin
  Result.Left := 0;
  Result.Top := 0;
  Result.Right := Width;
  Result.Bottom := Height;
(*
  if FScrollBarStyle = sbsMini then begin
//    scroll_size_x := GetSystemMetrics(SM_CXVSCROLL); // get system scrolls size for vertical scroll
//    scroll_size_y := GetSystemMetrics(SM_CYHSCROLL); // get system scrolls size for horizontal scroll

    // reserve space for scroll - allways
    if (ScrollOrientation = oVertical){ and CanShowMiniSB(SB)} then
      Dec(Result.Right, MINI_SB_SIZE)
    else if (ScrollOrientation = oHorizontal){ and CanShowMiniSB(SB)} then
      Dec(Result.Bottom, MINI_SB_SIZE);
  end;
*)  
end;

procedure TUScrollBox.ChangeScale(M, D: Integer{$IF CompilerVersion > 29}; isDpiChange: Boolean{$IFEND});
begin
  inherited;
  MINI_SB_SIZE              := MulDiv(MINI_SB_SIZE, M, D);
  MINI_SB_THICKNESS         := MulDiv(MINI_SB_THICKNESS, M, D);
  MINI_SB_MARGIN            := MulDiv(MINI_SB_MARGIN, M, D);
  MINI_SB_THICKNESS_HOVERED := MulDiv(MINI_SB_THICKNESS_HOVERED, M, D);
  MINI_SB_MARGIN_HOVERED    := MulDiv(MINI_SB_MARGIN_HOVERED, M, D);
  FLengthPerStep            := MulDiv(FLengthPerStep, M, D);
end;
//  UTILS

procedure TUScrollBox.SetOldSBVisible(IsVisible: Boolean);
begin
  if not IsDesigning then
    FlatSB_ShowScrollBar(Handle, SB_BOTH, IsVisible);
end;

procedure TUScrollBox.UpdateMiniSB;
var
  SB: TControlScrollBar;
  ControlSize: Integer;
  ThumbPos, ThumbSize: Integer;
begin
  if not CanShowMiniSB(SB) then
    Exit;

  if ScrollOrientation = oVertical then
    ControlSize := Height
  else
    ControlSize := Width;

  if SB.Range = 0 then
    Exit;

  ThumbSize := Round(ControlSize * ControlSize / SB.Range);
  ThumbPos := Round(ControlSize * SB.Position / SB.Range);

  if ScrollOrientation = oVertical then
    (MiniSB as TControl).SetBounds(Width - MINI_SB_SIZE + 1, ThumbPos, MINI_SB_THICKNESS, ThumbSize)
  else
    (MiniSB as TControl).SetBounds(ThumbPos, Height - MINI_SB_SIZE + 1, ThumbSize, MINI_SB_THICKNESS);
end;

procedure TUScrollBox.SetMiniSBVisible(IsVisible: Boolean);
var
  SB: TControlScrollBar;
begin
  MiniSB.Visible := IsVisible and CanShowMiniSB(SB);
  if IsVisible then begin
    UpdateMiniSB;
    if MiniSB.Visible then
      MiniSB.BringToFront;
  end;
end;

//  MESSAGES

//procedure TUScrollBox.WMEraseBkgnd(var Message: TWmEraseBkgnd);
//begin
//  // simplified version of TWinControl.WMEraseBkgnd
//  if Assigned(Parent) and (csParentBackground in ControlStyle) then
//    inherited
//  else begin
//    if not FDoubleBuffered or (TMessage(Message).wParam = TMessage(Message).lParam) then
//      FillRect(Message.DC, Rect(0, 0, Width, Height), Brush.Handle);
//  end;
//
//  Message.Result := 1;
//end;

procedure TUScrollBox.WMNCHitTest(var Msg: TWMNCHitTest);

//  procedure SendLeavingMsg;
//  begin
//    PostMessage(Self.Handle, CM_MOUSELEAVE, 0, 1);
//  end;

var
  P: TPoint;
  ParentForm: TCustomForm;
  BorderSpace: Integer;
begin
  inherited;

  ParentForm := GetParentForm(Self, True);
  if (ParentForm.WindowState = wsNormal) and (Align <> alNone) then begin
    if Align = alCustom then
      Exit;
    //
    P := Point(Msg.Pos.x, Msg.Pos.y);
    P := ScreenToClient(P);
    BorderSpace:=5;
    if MiniSB.Visible then
      BorderSpace := MINI_SB_MARGIN + 1
    else if ParentForm is TUForm then
      BorderSpace:=TUFormAccess(ParentForm).GetBorderSpace(bsDefault);
    //  Send event to parent
    case Align of
      alTop: begin
        // we need to check top, left and right borders
        if (Self.Top + P.Y < BorderSpace) or (Self.Left + P.X < BorderSpace) or (Self.Width - P.X < BorderSpace) then begin
//          SendLeavingMsg;
          Msg.Result := HTTRANSPARENT;
        end;
      end;

      alBottom: begin
        // we need to check bottom, left and right borders
        if (Self.Height - P.Y < BorderSpace) or (Self.Left + P.X < BorderSpace) or (Self.Width - P.X < BorderSpace) then begin
//          SendLeavingMsg;
          Msg.Result := HTTRANSPARENT;
        end;
      end;

      alLeft: begin
        // we need to check left, top and bottom borders
        if (Self.Left + P.X < BorderSpace) or (Self.Top + P.Y < BorderSpace) or (Self.Height - P.Y < BorderSpace) then begin
//          SendLeavingMsg;
          Msg.Result := HTTRANSPARENT;
        end;
      end;

      alRight: begin
        // we need to check right, top and bottom borders
        if (Self.Width - P.X < BorderSpace) or (Self.Top + P.Y < BorderSpace) or (Self.Height - P.Y < BorderSpace) then begin
//          SendLeavingMsg;
          Msg.Result := HTTRANSPARENT;
        end;
      end;
    end;
  end;
end;

procedure TUScrollBox.WMSize(var Msg: TWMSize);
begin
  inherited;
  if ScrollBarStyle <> sbsFull then
    SetOldSBVisible(False);
  Invalidate;
end;

procedure TUScrollBox.WMMouseMove(var Msg: TWMMouseMove);
begin
  if FMouseInControl and (ScrollBarStyle = sbsMini) and not MiniSB.Visible then begin
    FScrollBarTimer.Enabled := False;
    if ScrollBarStyle <> sbsFull then
      SetOldSBVisible(False);
    if ScrollBarStyle = sbsMini then
      SetMiniSBVisible(True);
    FScrollBarTimer.Enabled := MiniSB.Visible;
  end;

  inherited;
end;
{
procedure TUScrollBox.CMColorChanged(var Message: TMessage);
begin
  // switch off this message, it calls Invalidate after Color property is modified
  Message.Result := 1;
end;
}
procedure TUScrollBox.CMMouseEnter(var Msg: TMessage);
begin
//  if (Win32MajorVersion <> 10) and CanFocus then
//    SetFocus;

//  if not FMouseInControl and PtInRect(GetClientRect, ScreenToClient(Mouse.CursorPos)) then
  FMouseInControl := True;
  FScrollBarTimer.Enabled := True;

  if ScrollBarStyle <> sbsFull then
    SetOldSBVisible(False);
  if ScrollBarStyle = sbsMini then
    SetMiniSBVisible(True);

  inherited;
end;

procedure TUScrollBox.CMMouseLeave(var Msg: TMessage);
begin
  if not PtInRect(GetClientRect, ScreenToClient(Mouse.CursorPos)) then begin
    FMouseInControl := False;
    FScrollBarTimer.Enabled := False;
  end;

  if (ScrollBarStyle = sbsMini) and not FMouseInControl then begin
    if Msg.LParam = 1 then
      Msg.LParam := 0;
    SetMiniSBVisible(False);
  end;

  inherited;
end;

procedure TUScrollBox.CMMouseWheel(var Msg: TWMMouseWheel);
begin
  inherited;

//  if not PtInRect(GetClientRect, ScreenToClient(Mouse.CursorPos)) then
  if not FMouseInControl then
    Exit;

  FScrollBarTimer.Enabled := False;
  if (ScrollBarStyle = sbsMini) and not MiniSB.Visible then begin
    if ScrollBarStyle <> sbsFull then
      SetOldSBVisible(False);
    if ScrollBarStyle = sbsMini then
      SetMiniSBVisible(True);
  end;

  if ScrollOrientation = oVertical then
    ScrollBar := VertScrollBar
  else
    ScrollBar := HorzScrollBar;
  
  //  Scroll by touchpad
  if (Abs(Msg.WheelDelta) < 100) or IsDesigning then begin
    if IsDesigning then
      Msg.WheelDelta := 10 * Msg.WheelDelta div Abs(Msg.WheelDelta);

    DisableAlign;
    ScrollBar.Position := ScrollBar.Position - Msg.WheelDelta;
    if ScrollBarStyle = sbsMini then
      UpdateMiniSB;
    EnableAlign;
    FScrollBarTimer.Enabled := True;
  end
  //  Scroll by mouse
  else begin
    if FScrollCount >= MaxScrollCount then 
      Exit;

    if FScrollCount = 0 then begin
      DisableAlign;
      Mouse.Capture := Handle;
    end;

    Inc(FScrollCount);
    ScrollSign := Msg.WheelDelta div Abs(Msg.WheelDelta);

    CreateAnimationThread(
      procedure (V: Integer)
      begin
        ScrollBar.Position := ScrollBar.Position - V * ScrollSign;
        if ScrollBarStyle = sbsMini then
          UpdateMiniSB;
      end
    ,
      procedure
      begin
        if ScrollBarStyle <> sbsFull then
          SetOldSBVisible(False);
        Dec(FScrollCount);
        if FScrollCount <= 0 then begin
          Animation.WaitFor;
          Animation.Suspend;
          FScrollCount := 0;
          EnableAlign;
          Mouse.Capture := 0;
          FScrollBarTimer.Enabled := True;
        end
        else begin
          Animation.WaitFor;
          Animation.Suspend;
          Animation.Start;
        end;
      end
    );

    if Animation.Suspended then
      Animation.Start;
  end;
end;

procedure TUScrollBox.WMHScroll(var Message: TWMHScroll);
begin
  inherited;
  if ScrollBarStyle <> sbsFull then
    SetOldSBVisible(False);
end;

procedure TUScrollBox.WMVScroll(var Message: TWMVScroll);
begin
  inherited;
  if ScrollBarStyle <> sbsFull then
    SetOldSBVisible(False);
end;

//  CHILD EVENTS

procedure TUScrollBox.ColorsChange(Sender: TObject);
begin
  UpdateTheme;
end;

procedure TUScrollBox.ScrollBar_OnTimer(Sender: TObject);
var
  LForm: TCustomForm;
begin
  LForm := GetParentForm(Self);
  if (LForm <> Nil) and (LForm is TUForm) and not TUForm(LForm).IsActive then begin
    FScrollBarTimer.Enabled := False;
    Exit;
  end;

  if FMouseInControl and (ScrollBarStyle = sbsMini) and MiniSB.Visible then
    SetMiniSBVisible(False);
  FScrollBarTimer.Enabled := False;
end;

end.
