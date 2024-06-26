unit UCL.Form;

interface

{$IF CompilerVersion > 29}
  {$LEGACYIFEND ON}
{$IFEND}

uses
  Classes,
  Windows,
  Messages,
  Forms,
  Controls,
  ExtCtrls,
  Graphics,
  UCL.Classes,
  UCL.Colors,
  UCL.Types,
//  UCL.Utils,
  UCL.SystemSettings,
  UCL.ThemeManager,
  UCL.Tooltip,
  UCL.FormOverlay;

type
  TUForm = class(TForm, IUThemedComponent, IUIDEAware)
  public type
    TBorderSide = (bsDefault, bsTop, bsLeft, bsBottom, bsRight);
  public const
    DEFAULT_BORDERCOLOR_ACTIVE_LIGHT = $707070;
    DEFAULT_BORDERCOLOR_ACTIVE_DARK = $242424;
    DEFAULT_BORDERCOLOR_INACTIVE_LIGHT = $9B9B9B;
    DEFAULT_BORDERCOLOR_INACTIVE_DARK = $414141;

  protected var
    BorderColor: TColor;

  protected
    FThemeManager: TUThemeManager;
    FBackColor: TUThemeControlColorSet;
    FCaptionBar: TControl;
    FOverlay: TUFormOverlay;
    FRoundedCorners: TWindowRoundedCornerType;

    FPPI: Integer;
    FIsActive: Boolean;
    FOverlayType: TUOverlayType;
    FFitDesktopSize: Boolean;
    FFullScreen: Boolean;

    // Setters
    procedure SetBackColor(Value: TUThemeControlColorSet);
    procedure SetThemeManager(const Value: TUThemeManager);
    procedure SetFullScreen(const Value: Boolean);
    procedure SetOverlayType(const Value: TUOverlayType);
    procedure SetRoundedCorners(const Value: TWindowRoundedCornerType);

    // Child events
    procedure BackColor_OnChange(Sender: TObject);

    // IUIDEAware
    function IsCreating: Boolean; inline;
    function IsDestroying: Boolean; inline;
    function IsLoading: Boolean; inline;
    function IsDesigning: Boolean; inline;

  private
    procedure DisableWindowPaint(var dwStyle: DWORD);
    procedure EnableWindowPaint(dwStyle: DWORD);
    // Messages
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WMActivate(var Msg: TWMActivate); message WM_ACTIVATE;
    procedure WMSize(var Msg : TWMSize); message WM_SIZE;
    procedure WMNCActivate(var Msg: TWMNCActivate); message WM_NCACTIVATE;
    procedure WMDPIChanged(var Msg: TWMDpi); message WM_DPICHANGED;
    procedure WMDWMColorizationColorChanged(var Msg: TMessage); message WM_DWMCOLORIZATIONCOLORCHANGED;
    //procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMNCPaint(var Msg: TWMNCPaint); message WM_NCPAINT;
    procedure WMNCCalcSize(var Msg: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    //procedure WMNCMouseLeave(var Msg : TMessage); message WM_NCMOUSELEAVE;
    procedure WMSetText(var Msg: TWMSetText); message WM_SETTEXT;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
//    procedure   WM_DWMNCRENDERINGCHANGED

  protected
    // Internal
    function IsLEWin7: Boolean; virtual; // LE - less equal than
    function IsResizeable: Boolean; virtual;
    function IsBorderless: Boolean; virtual;
    function HasBorder: Boolean; virtual;
    function GetBorderSpace(const Side: TBorderSide): Integer; virtual;
    function GetBorderSpaceWin7(const Side: TBorderSide): Integer; virtual;
    procedure SetWindowsCorners; virtual;

    procedure UpdateBorder; virtual;
    function CanDrawBorder: Boolean; virtual;
    procedure UpdateBorderColor; virtual;
    procedure DoDrawBorder; virtual;

  protected
    mulScale: Integer;
  {$IF CompilerVersion < 30}
    FCurrentPPI: Integer;
    FIsScaling: Boolean;
    function GetDesignDpi: Integer; virtual;
    function GetParentCurrentDpi: Integer; virtual;
  {$IFEND}
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure ChangeScale(M, D: Integer{$IF CompilerVersion > 29}; isDpiChange: Boolean{$IFEND}); override;
    procedure DoChangeScale(M, D: Integer); virtual;
    procedure UpdateScale(var Scale: Integer; M, D: Integer); virtual;
    function  GetClientRect: TRect; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Init;
    procedure Paint; override;
    procedure PaintWindow(DC: HDC); override;
    procedure Resize; override;
    procedure Resizing(State: TWindowState); override;

  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateNew(aOwner: TComponent; Dummy: Integer = 0); override;
    destructor Destroy; override;
    procedure AfterConstruction; override;
  {$IF CompilerVersion < 30}
    procedure ScaleForPPI(NewPPI: Integer); virtual;
  {$IFEND}
    procedure FormScale(Value: Integer); // 0 - 4: 0 - 100%; 1 - 125%; 2 - 150%; 3 - 175%; 4 - 200%;

    // IUThemedControl
    procedure UpdateTheme; virtual;
    function IsCustomThemed: Boolean;
    function CustomThemeManager: TUCustomThemeManager;

  published
    property ThemeManager: TUThemeManager read FThemeManager write SetThemeManager;
    property BackColor: TUThemeControlColorSet read FBackColor write SetBackColor;
    property CaptionBar: TControl read FCaptionBar write FCaptionBar;

    property PPI: Integer read FPPI write FPPI default 96;
    property IsActive: Boolean read FIsActive default True;
    property Overlay: TUFormOverlay read FOverlay;
    property OverlayType: TUOverlayType read FOverlayType write SetOverlayType default otNone;
    property FitDesktopSize: Boolean read FFitDesktopSize write FFitDesktopSize default True;
    property FullScreen: Boolean read FFullScreen write SetFullScreen default False;
    property RoundedCorners: TWindowRoundedCornerType read FRoundedCorners write SetRoundedCorners default rctDefault;

    property Padding stored False;
  end;

implementation

uses
  SysUtils,
  Types,
  UxTheme,
  Themes,
  Dwmapi,
  UCL.Utils,
  UCL.CaptionBar;

{ TUForm }

//  MAIN CLASS

constructor TUForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Init;
end;

constructor TUForm.CreateNew(AOwner: TComponent; Dummy: Integer = 0);
begin
  inherited CreateNew(AOwner, Dummy);
  Init;
end;

destructor TUForm.Destroy;
var
  TM: TUCustomThemeManager;
begin
  FOverlay.Free;
  FBackColor.Free;
  TM := SelectThemeManager(Self);
  TM.Disconnect(Self);
  inherited;
end;

procedure TUForm.AfterConstruction;
var
  TM: TUCustomThemeManager;
begin
  inherited;
  TM := SelectThemeManager(Self);
  TM.UpdateTheme;
end;

function TUForm.IsCreating: Boolean;
begin
  Result := (csCreating in ControlState);
end;

function TUForm.IsDestroying: Boolean;
begin
  Result := (csDestroying in ComponentState);
end;

function TUForm.IsLoading: Boolean;
begin
  Result := (csLoading in ComponentState);
end;

function TUForm.IsDesigning: Boolean;
begin
  Result := (csDesigning in ComponentState);
end;

{$REGION 'Internal functions'}
function TUForm.IsLEWin7: Boolean;
begin
  Result := CheckMaxWin32Version(6, 3);
end;

function TUForm.IsResizeable: Boolean;
begin
  Result := BorderStyle in [bsSizeable, bsSizeToolWin];
end;

procedure TUForm.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FThemeManager) then begin
    ThemeManager:=Nil;
    Exit;
  end;
  inherited Notification(AComponent, Operation);
end;

function TUForm.IsBorderless: Boolean;
begin
  Result := BorderStyle in [bsNone, bsToolWindow, bsSizeToolWin];
end;

function TUForm.HasBorder: Boolean;
begin
  Result := BorderStyle in [bsDialog, bsSingle, bsSizeable];
end;

function TUForm.GetBorderSpace(const Side: TBorderSide): Integer;

  function TopSize: Integer;
  begin
    Result := 0;
    case BorderStyle of
      bsSingle     : Result := GetSystemMetrics(SM_CYFIXEDFRAME);

      bsDialog,
      bsToolWindow : Result := GetSystemMetrics(SM_CYDLGFRAME);

      bsSizeable,
      bsSizeToolWin: Result := GetSystemMetrics(SM_CYSIZEFRAME) + GetSystemMetrics(SM_CXPADDEDBORDER);
    end;
  end;

  function LeftRightSize: Integer;
  begin
    Result := 0;
    case BorderStyle of
      bsSingle     : Result := GetSystemMetrics(SM_CXFIXEDFRAME);

      bsDialog,
      bsToolWindow : Result := GetSystemMetrics(SM_CXDLGFRAME);

      bsSizeable,
      bsSizeToolWin: Result := GetSystemMetrics(SM_CXSIZEFRAME) + GetSystemMetrics(SM_CXPADDEDBORDER);
    end;
  end;

  function BottomSize: Integer;
  begin
    Result := 0;
    case BorderStyle of
      bsSingle     : Result := GetSystemMetrics(SM_CYFIXEDFRAME);

      bsDialog,
      bsToolWindow : Result := GetSystemMetrics(SM_CYDLGFRAME);

      bsSizeable,
      bsSizeToolWin: Result := GetSystemMetrics(SM_CYSIZEFRAME);
    end;
  end;

begin
  Result := 0;
  case Side of
    bsDefault: Result := LeftRightSize;
    bsTop    : Result := TopSize;
    bsLeft,
    bsRight  : Result := LeftRightSize;
    bsBottom : Result := BottomSize;
  end;
end;

function TUForm.GetBorderSpaceWin7(const Side: TBorderSide): Integer;
begin
  Result := 0;
  case BorderStyle of
    bsSingle     : Result := GetSystemMetrics(SM_CYFIXEDFRAME) - 3;

    bsDialog,
    bsToolWindow : Result := GetSystemMetrics(SM_CYDLGFRAME) - 3;

    bsSizeable,
    bsSizeToolWin: Result := GetSystemMetrics(SM_CYSIZEFRAME) + GetSystemMetrics(SM_CXPADDEDBORDER) - 2;
  end;
end;

procedure TUForm.UpdateBorder;
begin
  //  Redraw border
  if CanDrawBorder{ and not IsLEWin7} then
    DoDrawBorder;

  //  Update cation bar
  if CaptionBar <> Nil then begin
    if not IsDesigning and TUThemeManager.IsThemingAvailable(CaptionBar) then
      (CaptionBar as IUThemedComponent).UpdateTheme;
//    CaptionBar.Repaint; // this is important and it must be repaint and not invalidate
  end;
end;

function TUForm.CanDrawBorder: Boolean;
begin
  Result := HasBorder and (WindowState = wsNormal) and not IsBorderless;
end;

procedure TUForm.UpdateBorderColor;
var
  TM: TUCustomThemeManager;
begin
  TM := SelectThemeManager(Self);
//  if ThemeManager = Nil then
//    BorderColor := DEFAULT_BORDERCOLOR_ACTIVE_LIGHT
//  else
  if IsActive then begin //  Active window
    if TM.UseSytemColorOnBorder then begin
      if TM.UseColorOnBorder then begin
        if TM.UseSytemColorOnBorder then
          BorderColor := GetAccentColor
        else
          BorderColor := TM.ColorOnBorder
      end;
    end
    else if TM.Theme = ttLight then
      BorderColor := DEFAULT_BORDERCOLOR_ACTIVE_LIGHT
    else
      BorderColor := DEFAULT_BORDERCOLOR_ACTIVE_DARK;
  end

  else begin //  In active window
    if TM.Theme = ttLight then
      BorderColor := DEFAULT_BORDERCOLOR_INACTIVE_LIGHT
    else
      BorderColor := DEFAULT_BORDERCOLOR_INACTIVE_DARK;
  end;
end;

procedure TUForm.ChangeScale(M, D: Integer{$IF CompilerVersion > 29}; isDpiChange: Boolean{$IFEND});
begin
  inherited ChangeScale(M, D{$IF CompilerVersion > 29}, isDpiChange{$IFEND});
  DoChangeScale(M, D);
end;

procedure TUForm.DoChangeScale(M, D: Integer);
begin
  UpdateScale(mulScale, M, D);
end;

procedure TUForm.UpdateScale(var Scale: Integer; M, D: Integer);
begin
  if M > D then // up size
    Inc(Scale, (M - D) div 24)
  else // down size
    Dec(Scale, (D - M) div 24);
end;

procedure TUForm.DoDrawBorder;
begin
  UpdateBorderColor;
  Canvas.Brush.Handle := CreateSolidBrushWithAlpha(Color, 255);
  Canvas.Pen.Color := BorderColor;
  Canvas.MoveTo(0, 0);
//  Canvas.LineTo(ClientWidth, 0);
  Canvas.LineTo(Width - 1, 0);  //  Paint top border
  if IsLEWin7 then begin // paint other borders
    //Canvas.MoveTo(Width, 0);
    Canvas.LineTo(Width - 1, Height - 1);
    //Canvas.MoveTo(Width - 1, Height - 1);
    Canvas.LineTo(0, Height - 1);
    Canvas.LineTo(0, 0);
  end;
end;

procedure TUForm.FormScale(Value: Integer);
var
  NewPPI: Integer;
begin
  // 24 ppi intervals
  case Value of
    0: NewPPI :=  96;
    1: NewPPI := 120;
    2: NewPPI := 144;
    3: NewPPI := 168;
    4: NewPPI := 192;
    else
      Exit;
  end;

  Self.PPI := NewPPI;
  Self.ScaleForPPI(NewPPI);
end;

procedure TUForm.DisableWindowPaint(var dwStyle: DWORD);
begin
  dwStyle := GetWindowLong(Self.Handle, GWL_STYLE);
  // turn OFF WS_VISIBLE
  SetWindowLong(Self.Handle, GWL_STYLE, dwStyle and not WS_VISIBLE);
end;

procedure TUForm.EnableWindowPaint(dwStyle: DWORD);
begin
  // turn ON WS_VISIBLE
  SetWindowLong(Self.Handle, GWL_STYLE, dwStyle);
end;
{$ENDREGION}

//  SETTERS

procedure TUForm.SetBackColor(Value: TUThemeControlColorSet);
begin
  FBackColor.Assign(Value);
end;

procedure TUForm.SetFullScreen(const Value: Boolean);
begin
  if Value <> FFullScreen then begin
    FFullScreen := Value;

    LockWindowUpdate(Handle);
    // Go full screen
    if Value then begin
      BorderStyle := bsNone;
      if WindowState = wsMaximized then
        WindowState := wsNormal;
      WindowState := wsMaximized;
      FormStyle := fsStayOnTop;
    end
    // Exit full screen
    else begin
      BorderStyle := bsSizeable;
      WindowState := wsNormal;
      FormStyle := fsNormal;
    end;
    LockWindowUpdate(0);
  end;
end;

procedure TUForm.SetOverlayType(const Value: TUOverlayType);
begin
  if Value <> FOverlayType then begin
    FOverlayType := Value;
    FOverlay.OverlayType := Value;
    if CanDrawBorder and not IsLEWin7 then
      FOverlay.Top := 1
    else
      FOverlay.Top := 0;
  end;
end;

procedure TUForm.SetRoundedCorners(const Value: TWindowRoundedCornerType);
begin
  if FRoundedCorners <> Value then begin
    FRoundedCorners := Value;
    SetWindowsCorners;
  end;
end;

procedure TUForm.SetWindowsCorners;
begin
  if HandleAllocated then
    SetWindowRoundedCorner(Handle, FRoundedCorners);
end;

//  CUSTOM METHODS

procedure TUForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  //
  //Params.style := Params.style or 200000;
  //Params.Style := Params.Style or WS_OVERLAPPEDWINDOW;  //  Enabled aerosnap
{.$IF CompilerVersion < 30}
//  with Params do
//    WindowClass.Style := WindowClass.Style or CS_DROPSHADOW;
{.$IFEND}
  //
  Params.WindowClass.style := Params.WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TUForm.CreateWnd;
begin
  inherited;
  SetWindowsCorners;
end;

function TUForm.GetClientRect: TRect;
begin
  if (Menu <> Nil) then begin
    SetRect(Result, 0, 0, 0, 0);
    AdjustWindowRectEx(Result, GetWindowLong(Handle, GWL_STYLE), Menu <> Nil, GetWindowLong(Handle, GWL_EXSTYLE));
    SetRect(Result, 1, 1, Width - Result.Right + Result.Left, Height - Result.Bottom + Result.Top);
  end
  else if IsIconic(Handle) then begin
    SetRect(Result, 1, 1, Width - 1, Height - 1);
    //AdjustWindowRectEx(Result, GetWindowLong(Handle, GWL_STYLE), Menu <> nil, GetWindowLong(Handle, GWL_EXSTYLE));
    //SetRect(Result, 0, 0, Width - Result.Right + Result.Left, Height - Result.Bottom + Result.Top);
  end
  else
    Windows.GetClientRect(Handle, Result);
end;

procedure TUForm.Init;
var
  CurrentScreen: TMonitor;
  wta: WTA_OPTIONS;
  Flag: LongInt;
  TM: TUCustomThemeManager;
begin
  //  New props
  mulScale := 1;
  FThemeManager:=Nil;
  FIsActive := True;

  //  Get PPI from current screen
  CurrentScreen := Screen.MonitorFromWindow(Handle);
  FPPI := CurrentScreen.PixelsPerInch;
{$IF CompilerVersion < 30}
  FIsScaling := False;
  FCurrentPPI := FPPI;
{$IFEND}
  FOverlayType := otNone;
  FFitDesktopSize := True;
  FFullScreen := False;
  FRoundedCorners := rctDefault;

  //  Common props
  Font.Name := 'Segoe UI';
  Font.Size := 10;

  FOverlay := TUFormOverlay.CreateNew(Self);
  FOverlay.AssignToForm(Self);

  FBackColor := TUThemeControlColorSet.Create;
  FBackColor.OnChange := BackColor_OnChange;
  FBackColor.Assign(FORM_BACK);

  TM := SelectThemeManager(Self);
  TM.Connect(Self);
  TM.CollectAndConnectControls(Self);

  // TIP: how to maintain DWM shadow
  // Source: https://stackoverflow.com/a/50580016/2111514

{$IF CompilerVersion < 30}
  if HandleAllocated and ThemeServices.ThemesEnabled and DwmCompositionEnabled and IsLEWin7 then begin
{$ELSE}
  if HandleAllocated and StyleServices.Enabled and DwmCompositionEnabled and IsLEWin7 then begin
{$IFEND}
    wta.dwFlags := WTNCA_NODRAWCAPTION or WTNCA_NODRAWICON or WTNCA_NOSYSMENU;
    wta.dwMask  := WTNCA_NODRAWCAPTION or WTNCA_NODRAWICON or WTNCA_NOSYSMENU;
    SetWindowThemeAttribute(Self.Handle, WTA_NONCLIENT, @wta, SizeOf(WTA_OPTIONS));

    Flag := DWMNCRP_DISABLED;
    DwmSetWindowAttribute(Self.Handle, DWMWA_ALLOW_NCPAINT, @Flag, SizeOf(Flag));
    SetWindowPos(Self.Handle, 0, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOSENDCHANGING or SWP_FRAMECHANGED);
  end;
end;

procedure TUForm.Paint;
begin
  inherited;

  if CanDrawBorder{ and not IsLEWin7} then
    DoDrawBorder;

  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := Self.Color;
  Canvas.FillRect(ClientRect);
end;

procedure TUForm.PaintWindow(DC: HDC);
begin
//  with GetClientRect do
//    ExcludeClipRect(DC, Left, Top, Right, Bottom);
  inherited;
end;

procedure TUForm.Resize;
var
  Space, Space2: Integer;
  CurrentScreen: TMonitor;
begin
  inherited;

  if CanDrawBorder{ and not IsLEWin7} then begin
    if Padding.Top = 0 then begin
      Padding.Top := 1;
      if IsLEWin7 then begin
        Padding.Left := 1;
        Padding.Right := 1;
        Padding.Bottom := 1;
      end;
    end;
  end
  else if (Padding.Top > 0){ and (WindowState = wsMaximized)} then begin
    Padding.Top := 0;
    if IsLEWin7 then begin
      Padding.Left := 0;
      Padding.Right := 0;
      Padding.Bottom := 0;
    end;
  end;

  // Update cation bar
  if CaptionBar <> Nil then begin
    if not IsDesigning and (CaptionBar is TUCaptionBar) then
      TUCaptionBar(CaptionBar).UpdateButtons;
  end;

  CurrentScreen := Screen.MonitorFromWindow(Handle);
  if CurrentScreen = Nil then
    Exit;

  // Full screen
  if FullScreen and (WindowState = wsMaximized) then begin
    Top := CurrentScreen.Top;
    Left := CurrentScreen.Left;
    Width := CurrentScreen.Width;
    Height := CurrentScreen.Height;
    Exit;
  end;

  //  Fit window to desktop - for WS_POPUP window style
  //  If not, window fill full screen when maximized
  if FitDesktopSize and (WindowState = wsMaximized) and (BorderStyle in [bsDialog, bsSizeToolWin, bsToolWindow]) then begin
    Space := GetBorderSpace(bsTop);
    Space2 := Space * 2;
    //
    Top := CurrentScreen.Top - Space;
    Left := CurrentScreen.Left - Space;
    Width := CurrentScreen.WorkareaRect.Width + Space2;
    Height := CurrentScreen.WorkareaRect.Height + Space2;
  end;
end;

procedure TUForm.Resizing(State: TWindowState);
var
  CurrentScreen: TMonitor;
begin
  if State = wsMaximized then begin
    CurrentScreen := Screen.MonitorFromWindow(Handle);
    SetBounds(CurrentScreen.Left, CurrentScreen.Top, CurrentScreen.Width, CurrentScreen.Height);
  end;

  inherited;
end;

procedure TUForm.SetThemeManager(const Value: TUThemeManager);
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

procedure TUForm.UpdateTheme;
var
  TM: TUCustomThemeManager;
  ColorSet: TUThemeControlColorSet;
begin
  TM := SelectThemeManager(Self);
  //  Update tooltip style
  HintWindowClass := THintWindow;
  if TM.Theme = ttLight then
    HintWindowClass := TULightTooltip
  else
    HintWindowClass := TUDarkTooltip;
  //  Select default or custom style
  if BackColor.Enabled then
    ColorSet := BackColor
  else
    ColorSet := FORM_BACK;

  Color := ColorSet.GetColor(TM);
  if TM.Theme = ttLight then
    HintWindowClass := TULightTooltip
  else
    HintWindowClass := TUDarkTooltip;

  Font.Color := GetTextColorFromBackground(Color);

  UpdateBorderColor;
  Invalidate;
end;

function TUForm.IsCustomThemed: Boolean;
begin
  Result:=(FThemeManager <> Nil);
end;

function TUForm.CustomThemeManager: TUCustomThemeManager;
begin
  Result:=FThemeManager;
end;

//  MESSAGES

{$REGION 'Messages handling'}
procedure TUForm.WMSysCommand(var Msg: TWMSysCommand);
begin
  // Prevent move and restore
  if FullScreen then begin
    case Msg.CmdType and $FFF0 of
      SC_MOVE,
      SC_RESTORE: Exit;
    end;
  end
  else if (CaptionBar <> Nil) and not IsDesigning and TUThemeManager.IsThemingAvailable(CaptionBar) then begin
    if Msg.CmdType and $FFF0 = SC_RESTORE then
      (CaptionBar as IUThemedComponent).UpdateTheme;
  end;

  inherited;
end;

procedure TUForm.WMActivate(var Msg: TWMActivate);
begin
  inherited;
  FIsActive := (Msg.Active <> WA_INACTIVE);
  UpdateBorder;
end;

procedure TUForm.WMSize(var Msg: TWMSize);
begin
  inherited;
end;

procedure TUForm.WMNCActivate(var Msg: TWMNCActivate);
var
  dwStyle: DWORD;
begin
  DisableWindowPaint(dwStyle);
  inherited;
  EnableWindowPaint(dwStyle);
//  if Msg.Active then

  UpdateBorder;
  Msg.Result := 1;
end;

procedure TUForm.WMDPIChanged(var Msg: TWMDpi);
begin
  //PixelsPerInch := Msg.XDpi;
  PPI := Msg.XDpi;
  inherited;
  ScaleForPPI(PPI);
end;

procedure TUForm.WMDWMColorizationColorChanged(var Msg: TMessage);
var
  TM: TUCustomThemeManager;
begin
  TM := SelectThemeManager(Self);
  TM.Reload;
  inherited;
end;

//procedure TUForm.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
//begin
//  Msg.Result := 0;
//end;

procedure TUForm.WMNCPaint(var Msg: TWMNCPaint);
var
  DC: HDC;
  R: TRect;
  WindowStyle: Integer;
  TM: TUCustomThemeManager;
begin
  inherited;
  TM := SelectThemeManager(Self);
  //
  if CanDrawBorder{ and not IsLEWin7} then
    DoDrawBorder;
  if IsLEWin7 then begin
    DC := GetWindowDC(Handle);
    try
      R := ClientRect;
//      Brush.Color := Self.Color;
//      FillRect(DC, R, Brush.Handle);
      //OffsetRect(R, 1, 1);
      ExcludeClipRect(DC, R.Left, R.Top, R.Right, R.Bottom);
      WindowStyle := GetWindowLong(Handle, GWL_STYLE);
      if WindowStyle and WS_VSCROLL <> 0 then
        ExcludeClipRect(DC, R.Right, R.Top, R.Right + GetSystemMetrics(SM_CXVSCROLL), R.Bottom);
      if WindowStyle and WS_HSCROLL <> 0 then
        ExcludeClipRect(DC, R.Left, R.Bottom, R.Right, R.Bottom + GetSystemMetrics(SM_CXHSCROLL));
      if TM.UseColorOnBorder then begin
        UpdateBorderColor;
        Brush.Color := BorderColor;
      end
      else
        Brush.Color := Self.Color;
      SetRect(R, 0, 0, Width + BorderWidth, Height + BorderWidth);
      FillRect(DC, R, Brush.Handle);
    finally
      ReleaseDC(Handle, DC);
    end;
  end;
  Msg.Result := 0;
end;

//  if IsLEWin7 then begin
//    dc := GetWindowDc(Handle);
//    try
//      if Msg.RGN = 1 then begin
//        FillRect(dc, Rect(0, 0, Width, Height), GetStockObject(BLACK_BRUSH));
//      end
//      else begin
//        OffsetRgn(Msg.RGN, -Left, -Top);
//        FillRgn(dc, Msg.RGN, GetStockObject(BLACK_BRUSH));
//        OffsetRgn(Msg.RGN, Left, Top);
//      end;
//    finally
//      ReleaseDC(Handle, dc);
//    end;
//  end;

procedure TUForm.WMNCCalcSize(var Msg: TWMNCCalcSize);
var
  CaptionBarHeight: Integer;
  BorderWidth: Integer;
  BorderHeight: Integer;
  defMargin: Integer;
  R: TRect;
begin
  inherited;

  if (BorderStyle = bsNone) or not Msg.CalcValidRects then
    Exit;

  CaptionBarHeight := GetSystemMetrics(SM_CYCAPTION);
  defMargin:=0;
  // for Win 7 and less leave 1 pixel border to be filled by NCPaint to simulate Win10 look
{$IF CompilerVersion < 30}
  if ThemeServices.ThemesEnabled and DwmCompositionEnabled and IsLEWin7 then
{$ELSE}
  if StyleServices.Enabled and DwmCompositionEnabled and IsLEWin7 then
{$IFEND}
    defMargin:=-1;

  if WindowState = wsNormal then
    Inc(CaptionBarHeight, GetBorderSpace(bsTop) + defMargin);

  R:=Msg.CalcSize_Params.rgrc[0]; // store values

  Dec(R.Top, CaptionBarHeight); //  Hide caption bar
  if IsLEWin7 and not (WindowState = wsMaximized) then begin
    BorderWidth := GetBorderSpace(bsDefault);
    BorderHeight := GetBorderSpace(bsBottom);
    //
    Dec(R.Left, BorderWidth + defMargin); //  Hide borders
    Inc(R.Right, BorderWidth + defMargin); //  Hide borders
    Inc(R.Bottom, BorderHeight + defMargin); //  Hide borders
  end;

  Msg.CalcSize_Params.rgrc[0]:=R;
end;

procedure TUForm.WMNCHitTest(var Msg: TWMNCHitTest);
var
  ResizeSpace: Integer;
  ClientPos: TPoint;
  AllowResize: Boolean;
begin
  inherited;

  ClientPos := ScreenToClient(Point(Msg.XPos, Msg.YPos));

  case Msg.Result of
    HTCLIENT,
    HTTRANSPARENT: {to be dealt with below};
    HTMINBUTTON,
    HTMAXBUTTON,
    HTCLOSE: begin
      if ControlAtPos(ClientPos, True) <> Nil then begin
        Msg.Result := HTTRANSPARENT; //
        Exit;
      end;
      Msg.Result := HTNOWHERE; // prevent ghost buttons showing when there is no caption bar on form
      Exit;
    end;
  else
    Exit;
  end;

  ResizeSpace := GetBorderSpace(bsDefault);
  AllowResize := (WindowState = wsNormal) and IsResizeable;

//  if ClientPos.Y > ResizeSpace then
//    Exit;

  if AllowResize then begin
    if (ClientPos.Y <= ResizeSpace) then begin
      if ClientPos.X <= 2 * ResizeSpace then
        Msg.Result := HTTOPLEFT
      else if Width - ClientPos.X <= 2 * ResizeSpace then
        Msg.Result := HTTOPRIGHT
      else
        Msg.Result := HTTOP;
    end
    else if (ClientPos.Y >= Height - ResizeSpace) then begin
      if ClientPos.X <= 2 * ResizeSpace then
        Msg.Result := HTBOTTOMLEFT
      else if Width - ClientPos.X <= 2 * ResizeSpace then
        Msg.Result := HTBOTTOMRIGHT
      else
        Msg.Result := HTBOTTOM;
    end
    else if (ClientPos.X <= ResizeSpace) then begin
      if ClientPos.Y <= 2 * ResizeSpace then
        Msg.Result := HTTOPLEFT
      else if Height - ClientPos.Y <= 2 * ResizeSpace then
        Msg.Result := HTBOTTOMLEFT
      else
        Msg.Result := HTLEFT;
    end
    else if (Width - ClientPos.X <= 2 * ResizeSpace) then begin
      if ClientPos.Y <= 2 * ResizeSpace then
        Msg.Result := HTTOPRIGHT
      else if Height - ClientPos.Y <= 2 * ResizeSpace then
        Msg.Result := HTBOTTOMRIGHT
      else
        Msg.Result := HTRIGHT;
    end;
  end;
  if Msg.Result = HTTRANSPARENT then
    Msg.Result := HTCLIENT;
end;

procedure TUForm.WMSetText(var Msg: TWMSetText);
var
  dwStyle: DWORD;
begin
  DisableWindowPaint(dwStyle);
  inherited;
  EnableWindowPaint(dwStyle);

  UpdateBorder;
  Msg.Result := 1;
end;

procedure TUForm.CMMouseEnter(var Msg: TMessage);
begin
  inherited;

  if Parent <> Nil then
    Msg.Result := Parent.Perform(Msg.Msg, Msg.WParam, Msg.LParam);

  UpdateBorder;
end;

procedure TUForm.CMMouseLeave(var Msg: TMessage);
begin
  inherited;

  if Parent <> Nil then
    Msg.Result := Parent.Perform(Msg.Msg, Msg.WParam, Msg.LParam);

  UpdateBorder;
end;
{$ENDREGION}

//  CHILD EVENTS

procedure TUForm.BackColor_OnChange(Sender: TObject);
begin
  UpdateTheme;
end;

//  DPI

{$REGION 'Compatibility with older Delphi'}
{$IF CompilerVersion < 30}
function TUForm.GetDesignDpi: Integer;
var
  LForm: TCustomForm;
begin
  LForm := GetParentForm(Self);

  if (LForm <> Nil) and (LForm is TForm) then
    Result := TForm(LForm).PixelsPerInch
  else
    Result := Windows.USER_DEFAULT_SCREEN_DPI;
end;

function TUForm.GetParentCurrentDpi: Integer;
begin
//  if Parent <> nil then
//    Result := Parent.GetParentCurrentDpi
//  else
    Result := FCurrentPPI;
end;

procedure TUForm.ScaleForPPI(NewPPI: Integer);
begin
  if not FIsScaling and (NewPPI > 0) then begin
    FIsScaling := True;
    try
      if FCurrentPPI = 0 then
        FCurrentPPI := GetDesignDpi;

      if NewPPI <> FCurrentPPI then begin
        ChangeScale(NewPPI, FCurrentPPI);
        FCurrentPPI := NewPPI;
      end
    finally
      FIsScaling := False;
    end;
  end;
end;
{$IFEND}
{$ENDREGION}

end.
