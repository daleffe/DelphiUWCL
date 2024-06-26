unit UCL.Edit;

interface

uses
  SysUtils,
  Classes,
  Windows,
  Messages,
  Controls,
  StdCtrls,
  ExtCtrls,
  Graphics,
  Forms,
  UCL.Classes,
  UCL.Types,
  UCL.Colors,
  UCL.Utils;

type
//  private const
//    DefBorderColor: TDefColor = (
//      ($999999, $666666, $D77800, $CCCCCC, $D77800),
//      ($666666, $999999, $D77800, $CCCCCC, $D77800));

  TUEdit = class(TUCustomEdit)
  private
    LBorderColor: TColor;
    LBackColor: TColor;
    LTextColor: TColor;

  private
    FBorderThickness: Byte;
    FBackColor: TUThemeControlWithFocusColorSet;
    FBorderColor: TUThemeControlWithFocusColorSet;
    FControlState: TUControlState;
    //
    FTransparent: Boolean;

    // Internal
    procedure UpdateColors;

    // Setters
    procedure SetBackColor(Value: TUThemeControlWithFocusColorSet);
    procedure SetBorderColor(Value: TUThemeControlWithFocusColorSet);
    procedure SetBorderThickness(const Value: Byte);
    procedure SetControlState(const Value: TUControlState);
    procedure SetTransparent(const Value: Boolean);

    // Child events
    procedure ColorsChange(Sender: TObject);

    // Messages
    procedure WMNCPaint(var Msg: TWMNCPaint); message WM_NCPAINT;
    procedure WMLButtonDown(var Msg: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Msg: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;

    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
    //procedure Paint;

    //procedure UMSubEditSetFocus(var Msg: TMessage); message UM_SUBEDIT_SETFOCUS;
    //procedure UMSubEditKillFocus(var Msg: TMessage); message UM_SUBEDIT_KILLFOCUS;

  protected
    //procedure Paint; override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure DoChangeScale(M, D: Integer); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // IUThemedComponent
    procedure UpdateTheme; override;

  published
    property BorderThickness: Byte read FBorderThickness write SetBorderThickness;
    property BackColor: TUThemeControlWithFocusColorSet read FBackColor write SetBackColor;
    property BorderColor: TUThemeControlWithFocusColorSet read FBorderColor write SetBorderColor;
    //property Edit: TUSubEdit read FEdit write FEdit;
    property ControlState: TUControlState read FControlState write SetControlState default csNone;

    property Transparent: Boolean read FTransparent write SetTransparent default False;
  end;

implementation

uses
{$IF CompilerVersion > 29}
  UITypes,
{$IFEND}
  UCL.ThemeManager,
  UCL.Graphics;

{ TUEdit }

//  MAIN CLASS

constructor TUEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FBorderThickness := 1;
  FControlState := csNone;
  FTransparent := False;

  Alignment := taLeftJustify;
  BevelOuter := bvNone;
//  Font.Name := 'Segoe UI';
//  Font.Size := 10;
  //  Modify default props
  AutoSize := False;
  BorderStyle := bsNone;
  BevelKind := bkFlat;
  BorderWidth := 4;
  Ctl3D := False;
  Height := 30;

  FBackColor := TUThemeControlWithFocusColorSet.Create;
  FBackColor.Assign(EDIT_BACK);
  FBackColor.OnChange := ColorsChange;

  FBorderColor := TUThemeControlWithFocusColorSet.Create;
  FBorderColor.Assign(EDIT_BORDER);
  FBorderColor.OnChange := ColorsChange;

  UpdateColors;
end;

procedure TUEdit.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited;
  UpdateColors;
end;

destructor TUEdit.Destroy;
begin
  FBackColor.Free;
  FBorderColor.Free;
  inherited;
end;

//  THEME

procedure TUEdit.UpdateTheme;
begin
  UpdateColors;

  if Color <> LBackColor then
    Color := LBackColor;

  ParentFont := True;
  if Font.Color <> LTextColor then
    Font.Color := LTextColor;

  Repaint;
end;

//  INTERNAL

procedure TUEdit.UpdateColors;
var
  TM: TUCustomThemeManager;
  AccentColor: TColor;
  BackColorSet: TUThemeControlWithFocusColorSet;
  BorderColorSet: TUThemeControlWithFocusColorSet;
begin
  TM:=SelectThemeManager(Self);
  AccentColor := SelectAccentColor(TM, $D77800);
  //
  // Disabled edit
  if ControlState = csDisabled then begin
    LBorderColor := $CCCCCC;
    LBackColor := $D8D8D8;
    LTextColor := clGray;
    Exit;
  end;
  //
  // Transparent edit
  if Transparent and (ControlState = csNone) then begin
    ParentColor := True;
    LBackColor := Color;
  end
  else begin
    BackColorSet := BackColor;
    case ControlState of
      csHover, csFocused: begin
        if BackColor.Enabled then
          LBackColor := BackColor.Color
        else
          LBackColor := BackColorSet.GetColor(TM, Focused);
      end
    else
      LBorderColor := BackColorSet.GetColor(TM, Focused);
    end;
  end;
  //
  BorderColorSet := BorderColor;
  case ControlState of
    csHover, csFocused: begin
      if BorderColor.Enabled then
        LBorderColor := BorderColor.Color
      else
        LBorderColor := AccentColor;
    end
  else
    LBorderColor := BorderColorSet.GetColor(TM, Focused);
  end;
  //
  // Text color
  LTextColor := GetTextColorFromBackground(LBackColor);
end;

//  SETTERS

procedure TUEdit.SetBackColor(Value: TUThemeControlWithFocusColorSet);
begin
  FBackColor.Assign(Value);
end;

procedure TUEdit.SetBorderColor(Value: TUThemeControlWithFocusColorSet);
begin
  FBorderColor.Assign(Value);
end;

procedure TUEdit.SetBorderThickness(const Value: Byte);
begin
  if FBorderThickness <> Value then begin
    FBorderThickness := Value;
    UpdateTheme;
  end;
end;

procedure TUEdit.SetControlState(const Value: TUControlState);
begin
  if Value <> FControlState then begin
    FControlState := Value;
    UpdateTheme;
  end;
end;

procedure TUEdit.SetTransparent(const Value: Boolean);
begin
  if Value <> FTransparent then begin
    FTransparent := Value;
    UpdateTheme;
  end;
end;

procedure TUEdit.ColorsChange(Sender: TObject);
begin
  UpdateTheme;
end;

//  CUSTOM METHODS
{
procedure TUEdit.Paint;
var
  Space: Integer;
begin
  inherited;

  //  Paint border
  Canvas.Brush.Handle := CreateSolidBrushWithAlpha(Border_Color, 255);
  Canvas.FillRect(Rect(0, 0, Width, Height));

  //  Paint background
  Canvas.Brush.Handle := CreateSolidBrushWithAlpha(BackColor, 255);
  Canvas.FillRect(Rect(BorderThickness, BorderThickness, Width - BorderThickness, Height - BorderThickness));

  //  Fit subedit
  Space := (Height - FEdit.Height) div 2;
  Padding.Top := Space + 1;
  Padding.Left := Space + 1;
  Padding.Bottom := Space;
  Padding.Right := Space;

  //  Subedit color
  FEdit.Color := BackColor;
  FEdit.Font.Color := TextColor;
end;
}
procedure TUEdit.DoChangeScale(M, D: Integer);
begin
  BorderThickness := MulDiv(BorderThickness, M, D);
  BorderWidth := MulDiv(BorderWidth, M, D);
  Font.Height := MulDiv(Font.Height, M, D);
end;

//  MESSAGES

procedure TUEdit.WMNCPaint(var Msg: TWMNCPaint);
var
  Canvas: TCanvas;
  DC: HDC;
begin
  inherited;

  DC:= GetWindowDC(Handle);
  SaveDC(DC);
  try
    Canvas:= TCanvas.Create;
    try
      Canvas.Handle := DC;
      Canvas.Brush.Style := bsClear;

      DrawBorder(Canvas, Rect(0, 0, Width, Height), LBorderColor, BorderThickness);
    finally
      Canvas.free;
    end;
  finally
    RestoreDC(DC, -1);
    ReleaseDC(Handle, DC);
  end;
end;

procedure TUEdit.WMLButtonDown(var Msg: TWMLButtonDown);
begin
  if not Enabled then
    Exit;
  //
  ControlState := csPress;
  inherited;
end;

procedure TUEdit.WMLButtonUp(var Msg: TWMLButtonUp);
var
  MousePoint: TPoint;
begin
  if not Enabled then
    Exit;
  //
  MousePoint := ScreenToClient(Mouse.CursorPos);
  if PtInRect(GetClientRect, MousePoint) then
    ControlState := csFocused
  else
    ControlState := csNone;
  inherited;
end;

procedure TUEdit.WMSetFocus(var Msg: TWMSetFocus);
begin
  if not Enabled then
    Exit;
  //
  ControlState := csFocused;
  inherited;
end;

procedure TUEdit.WMKillFocus(var Msg: TWMKillFocus);
begin
  if not Enabled then
    Exit;
  //
  ControlState := csNone;
  inherited;
end;

procedure TUEdit.CMMouseEnter(var Msg: TMessage);
begin
  if not Enabled then
    Exit;
  //
  ControlState := csHover;
  inherited;
end;

procedure TUEdit.CMMouseLeave(var Msg: TMessage);
begin
  if not Enabled then
    Exit;
  //
  if Focused then
    ControlState := csFocused
  else
    ControlState := csNone;
  inherited;
end;

procedure TUEdit.CMEnabledChanged(var Msg: TMessage);
begin
  inherited;
  if not Enabled then
    ControlState := csDisabled
  else
    ControlState := csNone;
  UpdateTheme;
end;

end.
