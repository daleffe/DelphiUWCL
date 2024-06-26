unit UCL.GraphicSlider;

interface

uses
  Classes,
  Windows,
  Messages,
  Controls,
  Graphics,
  UCL.Classes,
  UCL.Types,
  UCL.Utils,
  UCL.Colors;

type
  TUGraphicSlider = class(TUGraphicControl)
  private var
    LCurWidth: Integer;
    LCurHeight: Integer;
    LCurCorner: Integer;
    LBarHeight: Integer;
    LActiveRect, LNormalRect, LCurRect: TRect;
    LAccentColor, LBackColor, LCurColor: TColor;

  private
    FBackColor: TUThemeFocusableControlStateColors;
    FCurColor: TUThemeFocusableControlStateColors;
    FIsSliding: Boolean;
    FControlState: TUControlState;
    FOrientation: TUOrientation;
    FMin: Integer;
    FMax: Integer;
    FValue: Integer;
    FShowCenter: Boolean;

    // Events
    FOnChange: TNotifyEvent;

    // Internal
    procedure UpdateColors;
    procedure UpdateRects;
    procedure ColorsChange(Sender: TObject);

    // Setters
    procedure SetBackColor(Value: TUThemeFocusableControlStateColors);
    procedure SetCurColor(Value: TUThemeFocusableControlStateColors);
    procedure SetControlState(const Value: TUControlState);
    procedure SetOrientation(const Value: TUOrientation);
    procedure SetMin(const Value: Integer);
    procedure SetMax(const Value: Integer);
    procedure SetValue(const Value: Integer);
    procedure SetShowCenter(const Value: Boolean);

    // Messages
    procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;

    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMLButtonDown(var Msg: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMMouseMove(var Msg: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMLButtonUp(var Msg: TWMLButtonUp); message WM_LBUTTONUP;

  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure DoChangeScale(M, D: Integer); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //
    property IsSliding: Boolean read FIsSliding;

    // IUThemedComponent
    procedure UpdateTheme; override;

  published
    property BackColor: TUThemeFocusableControlStateColors read FBackColor write SetBackColor;
    property CurColor: TUThemeFocusableControlStateColors read FCurColor write SetCurColor;
    property ControlState: TUControlState read FControlState write SetControlState default csNone;
    property Orientation: TUOrientation read FOrientation write SetOrientation default oHorizontal;
    property Min: Integer read FMin write SetMin default 0;
    property Max: Integer read FMax write SetMax default 100;
    property Value: Integer read FValue write SetValue default 0;
    property ShowCenter: Boolean read FShowCenter write SetShowCenter default False;

    // Events
    property OnChange: TNotifyEvent read FOnChange write FOnChange;

    property Height default 25;
    property Width default 100;
  end;

implementation

uses
  SysUtils,
{$IF CompilerVersion > 29}
  UITypes,
{$IFEND}
  UCL.ThemeManager;

{ TUGraphicSlider }

//  MAIN CLASS

constructor TUGraphicSlider.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
//  ControlStyle := ControlStyle - [csDoubleClicks];

  //  New properties
  LCurWidth := 8;
  LCurHeight := 23;
  LCurCorner := 5;
  LBarHeight := 2;

  FIsSliding := False;

  FControlState := csNone;
  FOrientation := oHorizontal;

  FMin := 0;
  FMax := 100;
  FValue := 0;
  FShowCenter := False;

  FBackColor := TUThemeFocusableControlStateColors.Create;
  FBackColor.Assign(SLIDER_BACK);
  FBackColor.OnChange := ColorsChange;
  FCurColor := TUThemeFocusableControlStateColors.Create;
  FCurColor.Assign(SLIDER_CURSOR);
  FCurColor.OnChange := ColorsChange;

  //  Common properties
  Height := 25;
  Width := 100;

  UpdateColors;
  UpdateRects;
end;

destructor TUGraphicSlider.Destroy;
begin
  FBackColor.Free;
  FCurColor.Free;
  inherited;
end;

//  THEME

procedure TUGraphicSlider.UpdateTheme;
begin
  UpdateColors;
  UpdateRects;
  Repaint;
end;

//  INTERNAL

procedure TUGraphicSlider.UpdateColors;
var
  TM: TUCustomThemeManager;
begin
  TM := SelectThemeManager(Self);
  if not Enabled or ((Parent <> Nil) and not Parent.Enabled) then begin
    if TM.ThemeUsed = utLight then
      LAccentColor := $CCCCCC
    else
      LAccentColor := $333333;
    LBackColor := LAccentColor;
    LCurColor := LAccentColor;
    Exit;
  end;
  //
  LAccentColor := SelectAccentColor(TM, clNone);
  LBackColor := BackColor.GetColor(TM.ThemeUsed, ControlState);
  if ControlState = csNone then
    LCurColor := LAccentColor
  else
    LCurColor := CurColor.GetColor(TM.ThemeUsed, ControlState);
end;

procedure TUGraphicSlider.UpdateRects;
begin
  if Orientation = oHorizontal then begin
    LActiveRect.Left := 0;
    LActiveRect.Top := (Height - LBarHeight) div 2;
    LActiveRect.Right := Round((Width - LCurWidth) * (Value - Min) / (Max - Min));
    LActiveRect.Bottom := LActiveRect.Top + LBarHeight;

    LNormalRect.Left := LActiveRect.Right + 1;
    LNormalRect.Top := LActiveRect.Top;
    LNormalRect.Right := Width;
    LNormalRect.Bottom := LActiveRect.Bottom;

    LCurRect.Left := LActiveRect.Right;
    LCurRect.Top := Height div 2 - LCurHeight div 2;
    LCurRect.Right := LCurRect.Left + LCurWidth;
    LCurRect.Bottom := LCurRect.Top + LCurHeight;
  end
  else begin
    LNormalRect.Left := (Width - LBarHeight) div 2;
    LNormalRect.Top := 0;
    LNormalRect.Right := LNormalRect.Left + LBarHeight;
    LNormalRect.Bottom := Round((Height - LCurHeight) * ({Value - Min}Max - Value) / (Max - Min));

    LActiveRect.Left := LNormalRect.Left;
    LActiveRect.Top := LNormalRect.Bottom + 1;
    LActiveRect.Right := LNormalRect.Right;
    LActiveRect.Bottom := Height;

    LCurRect.Left := (Width - LCurWidth) div 2;
    LCurRect.Top := LNormalRect.Bottom;
    LCurRect.Right := LCurRect.Left + LCurWidth;
    LCurRect.Bottom := LCurRect.Top + LCurHeight;
  end;
end;

procedure TUGraphicSlider.ColorsChange(Sender: TObject);
begin
  UpdateTheme;
end;

//  SETTERS

procedure TUGraphicSlider.SetBackColor(Value: TUThemeFocusableControlStateColors);
begin
  FBackColor.Assign(Value);
end;

procedure TUGraphicSlider.SetCurColor(Value: TUThemeFocusableControlStateColors);
begin
  FCurColor.Assign(Value);
end;

procedure TUGraphicSlider.SetControlState(const Value: TUControlState);
begin
  if Value <> FControlState then begin
    FControlState := Value;
    UpdateColors;
    Repaint;
  end;
end;

procedure TUGraphicSlider.SetOrientation(const Value: TUOrientation);
var
  TempSize: Integer;
begin
  if Value <> FOrientation then begin
    FOrientation := Value;

    //  Switch CurWidth and CurHeight
    TempSize := LCurWidth;
    LCurWidth := LCurHeight;
    LCurHeight := TempSize;

    UpdateRects;
    Repaint;
  end;
end;

procedure TUGraphicSlider.SetMin(const Value: Integer);
begin
  if (Value <> FMin) and (Value < FMax) then begin
    FMin := Value;
    UpdateRects;
    Repaint;
  end;
end;

procedure TUGraphicSlider.SetMax(const Value: Integer);
begin
  if (Value <> FMax) and (Value > FMin) then begin
    FMax := Value;
    UpdateRects;
    Repaint;
  end;
end;

procedure TUGraphicSlider.SetValue(const Value: Integer);
begin
  if Value <> FValue then begin
    FValue := Value;
    if FValue < FMin then
      FValue := FMin
    else if FValue > FMax then
      FValue := FMax;
    //
    UpdateRects;
    Repaint;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TUGraphicSlider.SetShowCenter(const Value: Boolean);
begin
  if Value <> FShowCenter then begin
    FShowCenter := Value;
    Repaint;
  end;
end;

procedure TUGraphicSlider.Paint;
var
  LCenter: Integer;
  LSize: Integer;
begin
//  inherited;

  if Orientation = oHorizontal then begin
    LCenter := -1 + (Width div 2);
    LSize := Height div 5;
  end
  else begin
    LCenter := -1 + (Height div 2);
    LSize := Width div 5;
  end;
  if LSize < 2 then
    LSize := 2;

  // Paint active part
  Canvas.Brush.Handle := CreateSolidBrushWithAlpha(LAccentColor, 255);
  Canvas.FillRect(LActiveRect);

  // Paint normal part
  Canvas.Brush.Handle := CreateSolidBrushWithAlpha(LBackColor, 255);
  Canvas.FillRect(LNormalRect);

  // Paint center if enabled
  if ShowCenter then begin
    Canvas.Brush.Handle := CreateSolidBrushWithAlpha(GetTextColorFromBackground(LBackColor), 255);
    if Orientation = oHorizontal then begin
      Canvas.MoveTo(LCenter, 0); // top
      Canvas.LineTo(LCenter, LSize);
      Canvas.MoveTo(LCenter, Height - LSize); // bottom
      Canvas.LineTo(LCenter, Height);
    end
    else begin
      Canvas.MoveTo(0, LCenter); // left
      Canvas.LineTo(LSize, LCenter);
      Canvas.MoveTo(Width - LSize, LCenter); // right
      Canvas.LineTo(Width, LCenter);
    end;
  end;

  // Paint cursor
  Canvas.Pen.Color := LCurColor;
  Canvas.Brush.Handle := CreateSolidBrushWithAlpha(LCurColor, 255);
  Canvas.RoundRect(LCurRect, LCurCorner, LCurCorner);
  Canvas.FloodFill(LCurRect.Left + LCurRect.Width div 2, LCurRect.Top + LCurRect.Height div 2, LCurColor, fsSurface);
end;

procedure TUGraphicSlider.Resize;
begin
  inherited;
  UpdateTheme;
end;

procedure TUGraphicSlider.DoChangeScale(M, D: Integer);
begin
  inherited DoChangeScale(M, D);
  if M = D then
    Exit;
  //
  LCurWidth  := MulDiv(LCurWidth, M, D);
  LCurHeight := MulDiv(LCurHeight, M, D);
  LCurCorner := MulDiv(LCurCorner, M, D);
  LBarHeight := MulDiv(LBarHeight, M, D);
  UpdateTheme;
end;

//  MESSAGES

procedure TUGraphicSlider.CMEnabledChanged(var Msg: TMessage);
begin
  inherited;
  if not Enabled or ((Parent <> Nil) and not Parent.Enabled) then
    ControlState := csDisabled
  else
    ControlState := csNone;
end;

procedure TUGraphicSlider.CMMouseEnter(var Msg: TMessage);
begin
//  if Assigned(Parent) and (Parent is TUCustomControl) then
//    Parent.Perform(Msg.Msg, Msg.WParam, Msg.LParam);

  if not Enabled then
    Exit;
  //
  ControlState := csHover;
  inherited;
end;

procedure TUGraphicSlider.CMMouseLeave(var Msg: TMessage);
begin
  if not Enabled then
    Exit;
  //
  ControlState := csNone;
  inherited;
end;

procedure TUGraphicSlider.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  inherited;
  if IsDesigning then
    Exit;

  if not FIsSliding then
    Msg.Result := HTTRANSPARENT;  //  Send event to parent
end;

procedure TUGraphicSlider.WMLButtonDown(var Msg: TWMLButtonDown);
var
  TempValue: Integer;
begin
  if not Enabled then
    Exit;

  FControlState := csPress;
  UpdateColors;
  FIsSliding := True;

  //  If press in cursor
  if (Msg.XPos < LCurRect.Left) or (Msg.XPos > LCurRect.Right) or (Msg.YPos < LCurRect.Top) or (Msg.YPos > LCurRect.Bottom) then begin
    //  Change Value by click position, click point is center of cursor
    if Orientation = oHorizontal then
      TempValue := Min + Round((Msg.XPos - LCurWidth div 2) * (Max - Min) / (Width - LCurWidth))
    else
      TempValue := Max - Round((Msg.YPos - LCurHeight div 2) * (Max - Min) / (Height - LCurHeight));

    //  Keep value in range [Min..Max]
    if TempValue < Min then
      TempValue := Min
    else if TempValue > Max then
      TempValue := Max;

    Value := TempValue;
  end
  else
    Invalidate;

  inherited;
end;

procedure TUGraphicSlider.WMMouseMove(var Msg: TWMMouseMove);
var
  TempValue: Integer;
begin
  if Assigned(Parent) and (Parent is TUCustomControl) then
    Parent.Invalidate;

  if not Enabled then
    Exit;

  if FIsSliding then begin
    if Orientation = oHorizontal then
      TempValue := Min + Round((Msg.XPos - LCurWidth div 2) * (Max - Min) / (Width - LCurWidth))
    else
      TempValue := Max - Round((Msg.YPos - LCurHeight div 2) * (Max - Min) / (Height - LCurHeight));

    //  Keep value in range [Min..Max]
    if TempValue < Min then
      TempValue := Min
    else if TempValue > Max then
      TempValue := Max;

    Value := TempValue;
  end;

  inherited;
end;

procedure TUGraphicSlider.WMLButtonUp(var Msg: TWMLButtonUp);
begin
  if not Enabled then
    Exit;
  //
  ControlState := csNone;
  FIsSliding := False;
  inherited;
end;

end.
