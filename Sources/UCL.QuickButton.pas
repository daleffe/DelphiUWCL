﻿unit UCL.QuickButton;

interface

uses
  Classes,
  Types,
  Messages,
  Controls,
  Graphics,
  Forms,
  UCL.Classes,
  UCL.Types,
  UCL.Utils,
  UCL.Graphics,
  UCL.Colors;

type
  TUQuickButtonStyle = (qbsNone, qbsQuit, qbsMax, qbsMin, qbsSysButton, qbsHighlight);

  TUQuickButton = class(TUGraphicControl)
  private var
    BackColor: TColor;
    TextColor: TColor;

  private
    FBackColors: TUThemeControlColorSet;
    FButtonState: TUControlState;
    FButtonStyle: TUQuickButtonStyle;
    FCustomAccentColor: TColor;
    FPressBrightnessDelta: Integer;
    FStickToControl: TControl;
    FUpdatingAlignment: Boolean;
    FHintMinButton: String;
    FHintMaxButton: String;
    FHintRestoreButton: String;
    FHintCloseButton: String;
    FHintHighlightButton: String;
    FHintSysButton: String;

    //  Internal
    procedure UpdateColors;
    function ControlAtPos(ParentControl: TWinControl; const Pos: TPoint; AllowDisabled: Boolean): TControl;

    //  Setters
    procedure SetBackColors(Value: TUThemeControlColorSet);
    procedure SetButtonState(const Value: TUControlState);
    procedure SetButtonStyle(const Value: TUQuickButtonStyle);

    //  Messages
    procedure WMLButtonDown(var Msg: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Msg: TWMLButtonUp); message WM_LBUTTONUP;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;

    // Childs property change events
    procedure ColorsChange(Sender: TObject);

  protected
    procedure StickToControl(AControl: TControl); virtual;

  protected
    procedure Loaded; override;
    procedure Paint; override;
    procedure RequestAlign; override;
    procedure VisibleChanging; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // IUThemedComponent
    procedure UpdateTheme; override;

  published
    property BackColors: TUThemeControlColorSet read FBackColors write SetBackColors;
    property ButtonState: TUControlState read FButtonState write SetButtonState default csNone;
    property ButtonStyle: TUQuickButtonStyle read FButtonStyle write SetButtonStyle default qbsSysButton;

    property HintMinButton: String read FHintMinButton write FHintMinButton;
    property HintMaxButton: String read FHintMaxButton write FHintMaxButton;
    property HintRestoreButton: String read FHintRestoreButton write FHintRestoreButton;
    property HintCloseButton: String read FHintCloseButton write FHintCloseButton;
    property HintHighlightButton: String read FHintHighlightButton write FHintHighlightButton;
    property HintSysButton: String read FHintSysButton write FHintSysButton;

    property CustomAccentColor: TColor read FCustomAccentColor write FCustomAccentColor default $D77800;

    property Caption;
    property Height default 32;
    property Width default 45;
  end;

implementation

uses
  SysUtils,
  Windows,
  UCL.ThemeManager,
  UCL.FontIcons,
  UCL.Form,
  UCL.CaptionBar;

{ TUQuickButton }

//  MAIN CLASS

constructor TUQuickButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csDoubleClicks];

  // New props
  FButtonState := csNone;
  FButtonStyle := qbsSysButton;
  FCustomAccentColor := $D77800;
  FPressBrightnessDelta := 25;
  FStickToControl := Nil;
  FUpdatingAlignment := False;

  FBackColors := TUThemeControlColorSet.Create;
  FBackColors.Assign(QUICKBUTTON_BACK);
  FBackColors.OnChange := ColorsChange;

  // Old props
  Caption := UF_HOME; // Back icon
  Font.Name := 'Segoe MDL2 Assets';
  Font.Size := 10;
  Height := 32;
  Width := 45;
  ParentColor := True;

  UpdateColors;
end;

destructor TUQuickButton.Destroy;
begin
  FBackColors.Free;
  inherited;
end;

procedure TUQuickButton.Loaded;
begin
  case FButtonStyle of
    qbsQuit     : Hint := HintCloseButton;
    qbsMax      : Hint := HintMaxButton;
    qbsMin      : Hint := HintMinButton;
    qbsSysButton: Hint := HintSysButton;
    qbsHighlight: Hint := HintHighlightButton;
  end;
  inherited;
end;

//  THEME

procedure TUQuickButton.UpdateTheme;
begin
  UpdateColors;
  Repaint;
//  Invalidate;
end;

//  INTERNAL

procedure TUQuickButton.UpdateColors;
var
  TM: TUCustomThemeManager;
  IsDark: Boolean;
  BaseColor, AccentColor: TColor;
begin
  TM := SelectThemeManager(Self);
  IsDark := (TM <> Nil) and (TM.ThemeUsed = utDark);
  AccentColor := SelectAccentColor(TM, CustomAccentColor);

  if ButtonState = csNone then begin
    ParentColor := True;
    BackColor := Color;
  end
  else begin
    // select base color
    case ButtonStyle of
      qbsQuit: BaseColor := $002311E8;
      qbsHighlight: BaseColor := AccentColor;
      qbsMax,
      qbsMin,
      qbsSysButton: BaseColor := Color;
    else
      BaseColor := FBackColors.GetColor(TM);
    end;
    //
    // change BaseColor to BackColor
    case ButtonState of
      csHover: begin
        if ButtonStyle in [qbsNone, qbsMax, qbsMin, qbsSysButton] then begin
          BackColor := BrightenColor(BaseColor, FPressBrightnessDelta);
        end
        else
          BackColor := BaseColor;
      end;
      csPress: begin
        if ButtonStyle in [qbsQuit, qbsHighlight] then begin
          BackColor := BrightenColor(BaseColor, FPressBrightnessDelta);
        end
        else begin
          if IsDark then
            BackColor := ColorChangeLightness(BaseColor, 180)
          else
            BackColor := ColorChangeLightness(BaseColor, 100);
        end;
      end;
    end;
  end;
  TextColor := GetTextColorFromBackground(BackColor);
end;

procedure TUQuickButton.ColorsChange(Sender: TObject);
begin
  UpdateColors;
  Invalidate;
end;

function TUQuickButton.ControlAtPos(ParentControl: TWinControl; const Pos: TPoint; AllowDisabled: Boolean): TControl;
var
  LControl: TControl;

  function GetControlAtPos(AControl: TControl): Boolean;
  var
    P: TPoint;
  begin
    with AControl do begin
      P := Point(Pos.X - Left, Pos.Y - Top);
      Result := PointInRect(P, ClientRect) and (((csDesigning in ComponentState) or (Enabled or AllowDisabled)) and (Perform(CM_HITTEST, 0, PointToLParam(P)) <> 0));
      if Result then
        LControl := AControl;
    end;
  end;

var
  I: Integer;
begin
  LControl := Nil;
  for I := ParentControl.ControlCount - 1 downto 0 do
    if (ParentControl.Controls[I] <> Self) and GetControlAtPos(TControl(ParentControl.Controls[I])) then
      Break;
  Result := LControl;
end;

//  SETTERS

procedure TUQuickButton.SetBackColors(Value: TUThemeControlColorSet);
begin
  FBackColors.Assign(Value);
end;

procedure TUQuickButton.SetButtonState(const Value: TUControlState);
begin
  if Value <> FButtonState then begin
    FButtonState := Value;
    UpdateColors;
    Repaint;
  end;
end;

procedure TUQuickButton.SetButtonStyle(const Value: TUQuickButtonStyle);
//var
//  TM: TUCustomThemeManager;
begin
//  TM := SelectThemeManager(Self);
  if Value <> FButtonStyle then begin
    FButtonStyle := Value;

    case FButtonStyle of
      qbsQuit: begin
        FCustomAccentColor := clNone;
        FPressBrightnessDelta := 32;
        Caption := UF_CLOSE; // Close icon
        Hint := HintCloseButton;
      end;
      qbsSysButton,
      qbsMax,
      qbsMin: begin
        FCustomAccentColor := clNone;
        FPressBrightnessDelta := 32;
        case FButtonStyle of
          qbsMax: begin
            Caption := UF_MAXIMIZE;
            Hint := HintMaxButton;
          end;
          qbsMin: begin
            Caption := UF_MINIMIZE;
            Hint := HintMinButton;
          end;
          qbsSysButton: begin
            Caption := UF_HOME;
            Hint := HintSysButton;
          end;
        end;
      end;
      qbsHighlight: begin
        FCustomAccentColor := $D77800;
        FPressBrightnessDelta := 25;
        //Caption := UF_BACK;
        Hint := HintHighlightButton;
      end;
    end;

    UpdateTheme;
  end;
end;

procedure TUQuickButton.StickToControl(AControl: TControl);

  function GetWallPosition(C1: TControl; AAlign: TAlign): TPoint;
  begin
    Result := EmptyPoint;
    case AAlign of
      alTop   : Result := Point(C1.Margins.ControlLeft, C1.Margins.ControlTop{ - 1});
      alBottom: Result := Point(C1.Margins.ControlLeft, C1.Margins.ControlTop + C1.Margins.ControlHeight{ + 1});
      alLeft  : Result := Point(C1.Margins.ControlLeft{ - 1}, C1.Margins.ControlTop);
      alRight : Result := Point(C1.Margins.ControlLeft + C1.Margins.ControlWidth{ + 1}, C1.Margins.ControlTop);
    end;
  end;

var
  control: TControl;
begin
  if (Parent = Nil) or FUpdatingAlignment then
    Exit;
  //
  if AControl = Nil then begin // determine which control is next to us according to our alignment
    control := ControlAtPos(Parent, GetWallPosition(Self, Align), True);
    if control <> Nil then
      FStickToControl := control;
  end
  else begin
    FUpdatingAlignment := True;
    try
      case Align of
        alTop   : SetBounds(FStickToControl.Margins.ControlLeft, FStickToControl.Margins.ControlTop + FStickToControl.Margins.ControlHeight + 1, Width, Height);
        alBottom: SetBounds(FStickToControl.Margins.ControlLeft, FStickToControl.Margins.ControlTop - 1, Width, Height);
        alLeft  : SetBounds(FStickToControl.Margins.ControlLeft + FStickToControl.Margins.ControlWidth + 1, FStickToControl.Margins.ControlTop, Width, Height);
        alRight : SetBounds(FStickToControl.Margins.ControlLeft - 1, FStickToControl.Margins.ControlTop, Width, Height);
      end;
    finally
      FStickToControl := Nil;
      FUpdatingAlignment := False;
    end;
  end;
end;

//  CUSTOM METHODS

procedure TUQuickButton.Paint;
var
  TextRect: TRect;
begin
  if ButtonState <> csNone then begin // Paint background
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Handle := CreateSolidBrushWithAlpha(BackColor, 255);
    Canvas.FillRect(Rect(0, 0, Width, Height));
  end;

  //  Draw text
  Canvas.Brush.Style := bsClear;
  Canvas.Font.Assign(Font);
  Canvas.Font.Color := TextColor;

  TextRect := Rect(0, 0, Width, Height);
  DrawTextRect(Canvas, taCenter, taVerticalCenter, TextRect, Caption, True);
end;

procedure TUQuickButton.RequestAlign;
begin
  inherited;
  if IsDesigning then
    Exit;
  //
  if (Parent <> Nil) and (Parent is TUCaptionBar) then begin
    if Visible and (FStickToControl <> Nil) then
      StickToControl(FStickToControl);
  end;
end;

procedure TUQuickButton.VisibleChanging;
begin
  if Visible and (Parent <> Nil) and (Parent is TUCaptionBar) then
    StickToControl(Nil);
  //
  inherited;
end;

//  MESSAGES

procedure TUQuickButton.WMLButtonDown(var Msg: TWMLButtonDown);
begin
  if Enabled then begin
    ButtonState := csPress;
    inherited;
  end;
end;

procedure TUQuickButton.WMLButtonUp(var Msg: TWMLButtonUp);
var
  ParentForm: TCustomForm;
  FullScreen: Boolean;
  MousePoint: TPoint;
  Restore: Boolean;
begin
  if not Enabled then
    Exit;
  //
  ParentForm := GetParentForm(Self, True);
  MousePoint := ScreenToClient(Mouse.CursorPos);
  if PtInRect(GetClientRect, MousePoint) then begin
    //  Default actions for Quit, Max, Min sysbutton
    if ButtonStyle in [qbsQuit, qbsMax, qbsMin] then begin
      if ParentForm is TUForm then
        FullScreen := (ParentForm as TUForm).FullScreen
      else
        FullScreen := False;
      //
      case ButtonStyle of
        qbsQuit: begin
          if ParentForm <> Nil then
            ParentForm.Close;
        end;

        qbsMax: begin
          if (ParentForm <> Nil) and not FullScreen then begin
            ReleaseCapture;
            Restore:=(ParentForm.WindowState <> wsNormal);
            if Restore then begin
              Caption := UF_MAXIMIZE;
              Hint := HintMaxButton;
            end
            else begin
              Caption := UF_RESTORE;
              Hint := HintRestoreButton;
            end;
            //
            if Restore then
              SendMessage(ParentForm.Handle, WM_SYSCOMMAND, SC_RESTORE, 0)
            else
              SendMessage(ParentForm.Handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
          end;
        end;

        qbsMin: begin
          if ParentForm <> Nil then
            ParentForm.WindowState := wsMinimized;
        end;
      end;
    end;
  end;

  ButtonState := csHover;
  inherited;
end;

procedure TUQuickButton.CMMouseEnter(var Msg: TMessage);
begin
  if Enabled then begin
    ButtonState := csHover;
    inherited;
  end;
end;

procedure TUQuickButton.CMMouseLeave(var Msg: TMessage);
begin
  if Enabled then begin
    ButtonState := csNone;
    inherited;
  end;
end;

end.
