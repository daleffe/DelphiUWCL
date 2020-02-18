unit UCL.TUSlider;

interface

{$IF CompilerVersion > 29}
  {$LEGACYIFEND ON}
{$IFEND}

uses
  Classes,
  Windows,
  Messages,
  Controls,
  Graphics,
  UCL.Classes,
  UCL.TUThemeManager,
  UCL.Utils;

type
  TUCustomSlider = class(TGraphicControl, IUThemeComponent)
  private const
    DefActiveColor: TDefColor = (
      ($D77800, $D77800, $D77800, $CCCCCC, $D77800),
      ($D77800, $D77800, $D77800, $333333, $D77800));
    DefBackColor: TDefColor = (
      ($999999, $666666, $999999, $CCCCCC, $999999),
      ($666666, $999999, $666666, $333333, $666666));
    DefCurColor: TDefColor = (
      ($D77800, $171717, $CCCCCC, $CCCCCC, $D77800),
      ($D77800, $F2F2F2, $767676, $333333, $D77800));

  private var
    CurWidth: Integer;
    CurHeight: Integer;
    CurCorner: Integer;
    BarHeight: Integer;
    ActiveRect, NormalRect, CurRect: TRect;
    ActiveColor, BackColor, CurColor: TColor;

  private
    FIsSliding: Boolean;

    FThemeManager: TUThemeManager;
    FControlState: TUControlState;
    FOrientation: TUOrientation;
    FMin: Integer;
    FMax: Integer;
    FValue: Integer;

    //  Events
    FOnChange: TNotifyEvent;

    //  Internal
    procedure UpdateColors;
    procedure UpdateRects;

    //  Setters
    procedure SetThemeManager; // (const Value: TUThemeManager);
    procedure SetControlState(const Value: TUControlState);
    procedure SetOrientation(const Value: TUOrientation);
    procedure SetMin(const Value: Integer);
    procedure SetMax(const Value: Integer);
    procedure SetValue(const Value: Integer);

    //  Messages
    procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;

    procedure WMLButtonDown(var Msg: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMMouseMove(var Msg: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMLButtonUp(var Msg: TWMLButtonUp); message WM_LBUTTONUP;

  protected
    //procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    procedure Resize; override;
    procedure ChangeScale(M, D: Integer{$IF CompilerVersion > 29}; isDpiChange: Boolean{$IFEND}); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure UpdateTheme;

  published
    property ThemeManager: TUThemeManager read FThemeManager; // write SetThemeManager;
    property ControlState: TUControlState read FControlState write SetControlState default csNone;

    property Orientation: TUOrientation read FOrientation write SetOrientation default oHorizontal;
    property IsSliding: Boolean read FIsSliding;
    property Min: Integer read FMin write SetMin default 0;
    property Max: Integer read FMax write SetMax default 100;
    property Value: Integer read FValue write SetValue default 0;

    //  Events
    property OnChange: TNotifyEvent read FOnChange write FOnChange;

    property Height default 25;
    property Width default 100;
  end;

  TUSlider = class(TUCustomSlider)
  published
    property Align;
    property Anchors;
    property AutoSize;
    property BiDiMode;
    //property Caption;
    property Color;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Touch;
    property Visible;
  {$IF CompilerVersion > 29}
    property StyleElements;
  {$IFEND}

    property OnCanResize;
    property OnClick;
    property OnConstrainedResize;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnGesture;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
  end;

implementation

uses
  UCL.Types;

{ TUCustomSlider }

//  THEME

procedure TUCustomSlider.SetThemeManager; // (const Value: TUThemeManager);
begin
  FThemeManager := GetCommonThemeManager;
  UpdateTheme;
end;

procedure TUCustomSlider.UpdateTheme;
begin
  UpdateColors;
  UpdateRects;
  Repaint;
end;
{
procedure TUCustomSlider.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FThemeManager) then
    FThemeManager := nil;
end;
}
//  INTERNAL

procedure TUCustomSlider.UpdateColors;
begin
  if ThemeManager = Nil then begin
    ActiveColor := DefActiveColor[utLight, ControlState];
    BackColor := DefBackColor[utLight, ControlState];
    CurColor := DefCurColor[utLight, ControlState];
  end
  else begin
    if Enabled then
      ActiveColor := ThemeManager.AccentColor
    else
      ActiveColor := DefActiveColor[ThemeManager.Theme, ControlState];
    BackColor := DefBackColor[ThemeManager.Theme, ControlState];
    if ControlState = csNone then
      CurColor := ThemeManager.AccentColor
    else
      CurColor := DefCurColor[ThemeManager.Theme, ControlState];
  end;
end;

procedure TUCustomSlider.UpdateRects;
begin
  if Orientation = oHorizontal then begin
    ActiveRect.Left := 0;
    ActiveRect.Top := (Height - BarHeight) div 2;
    ActiveRect.Right := Round((Width - CurWidth) * (Value - Min) / (Max - Min));
    ActiveRect.Bottom := ActiveRect.Top + BarHeight;

    NormalRect.Left := ActiveRect.Right + 1;
    NormalRect.Top := ActiveRect.Top;
    NormalRect.Right := Width;
    NormalRect.Bottom := ActiveRect.Bottom;

    CurRect.Left := ActiveRect.Right;
    CurRect.Top := Height div 2 - CurHeight div 2;
    CurRect.Right := CurRect.Left + CurWidth;
    CurRect.Bottom := CurRect.Top + CurHeight;
  end
  else begin
    NormalRect.Left := (Width - BarHeight) div 2;
    NormalRect.Top := 0;
    NormalRect.Right := NormalRect.Left + BarHeight;
    NormalRect.Bottom := Round((Height - CurHeight) * ({Value - Min}Max - Value) / (Max - Min));

    ActiveRect.Left := NormalRect.Left;
    ActiveRect.Top := NormalRect.Bottom + 1;
    ActiveRect.Right := NormalRect.Right;
    ActiveRect.Bottom := Height;

    CurRect.Left := (Width - CurWidth) div 2;
    CurRect.Top := NormalRect.Bottom;
    CurRect.Right := CurRect.Left + CurWidth;
    CurRect.Bottom := CurRect.Top + CurHeight;
  end;
end;

//  SETTERS

procedure TUCustomSlider.SetControlState(const Value: TUControlState);
begin
  if Value <> FControlState then begin
    FControlState := Value;
    UpdateColors;
    Repaint;
  end;
end;

procedure TUCustomSlider.SetOrientation(const Value: TUOrientation);
var
  TempSize: Integer;
begin
  if Value <> FOrientation then begin
    FOrientation := Value;

    //  Switch CurWidth and CurHeight
    TempSize := CurWidth;
    CurWidth := CurHeight;
    CurHeight := TempSize;

    UpdateRects;
    Repaint;
  end;
end;

procedure TUCustomSlider.SetMin(const Value: Integer);
begin
  if Value <> FMin then begin
    FMin := Value;
    UpdateRects;
    Repaint;
  end;
end;

procedure TUCustomSlider.SetMax(const Value: Integer);
begin
  if Value <> FMax then begin
    FMax := Value;
    UpdateRects;
    Repaint;
  end;
end;

procedure TUCustomSlider.SetValue(const Value: Integer);
begin
  if Value <> FValue then begin
    FValue := Value;
    if Assigned(FOnChange) then
      FOnChange(Self);
    UpdateRects;
    Repaint;
  end;
end;

//  MAIN CLASS

constructor TUCustomSlider.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FThemeManager := Nil;

  //  New properties
  CurWidth := 8;
  CurHeight := 23;
  CurCorner := 5;
  BarHeight := 2;

  FIsSliding := false;

  FControlState := csNone;
  FOrientation := oHorizontal;

  FMin := 0;
  FMax := 100;
  FValue := 0;

  //  Common properties
  Height := 25;
  Width := 100;

  if GetCommonThemeManager <> Nil then
    GetCommonThemeManager.Connect(Self);

  UpdateColors;
  UpdateRects;
end;

destructor TUCustomSlider.Destroy;
begin
  if FThemeManager <> Nil then
    FThemeManager.Disconnect(Self);
  inherited;
end;

procedure TUCustomSlider.Paint;
begin
  inherited;

  //  Paint active part
  Canvas.Brush.Handle := CreateSolidBrushWithAlpha(ActiveColor, 255);
  Canvas.FillRect(ActiveRect);

  //  Paint normal part
  Canvas.Brush.Handle := CreateSolidBrushWithAlpha(BackColor, 255);
  Canvas.FillRect(NormalRect);

  //  Paint cursor
  Canvas.Pen.Color := CurColor;
  Canvas.Brush.Handle := CreateSolidBrushWithAlpha(CurColor, 255);
  Canvas.RoundRect(CurRect, CurCorner, CurCorner);
  Canvas.FloodFill(CurRect.Left + CurRect.Width div 2, CurRect.Top + CurRect.Height div 2, CurColor, fsSurface);
end;

procedure TUCustomSlider.Resize;
begin
  inherited;
  UpdateRects;
end;

procedure TUCustomSlider.ChangeScale(M, D: Integer{$IF CompilerVersion > 29}; isDpiChange: Boolean{$IFEND});
begin
  inherited;
  CurWidth := MulDiv(CurWidth, M, D);
  CurHeight := MulDiv(CurHeight, M, D);
  CurCorner := MulDiv(CurCorner, M, D);
  BarHeight := MulDiv(BarHeight, M, D);
  UpdateRects;
end;

//  MESSAGES

procedure TUCustomSlider.CMEnabledChanged(var Msg: TMessage);
begin
  inherited;
  if not Enabled then
    ControlState := csDisabled
  else
    ControlState := csNone;
end;

procedure TUCustomSlider.CMMouseEnter(var Msg: TMessage);
begin
  if Enabled then begin
    ControlState := csHover;
    inherited;
  end;
end;

procedure TUCustomSlider.CMMouseLeave(var Msg: TMessage);
begin
  if Enabled then begin
    ControlState := csNone;
    inherited;
  end;
end;

procedure TUCustomSlider.WMLButtonDown(var Msg: TWMLButtonDown);
var
  TempValue: Integer;
begin
  if not Enabled then
    Exit;

  FControlState := csPress;
  UpdateColors;
  FIsSliding := true;

  //  If press in cursor
  if (Msg.XPos < CurRect.Left) or (Msg.XPos > CurRect.Right) or (Msg.YPos < CurRect.Top) or (Msg.YPos > CurRect.Bottom) then begin
    //  Change Value by click position, click point is center of cursor
    if Orientation = oHorizontal then
      TempValue := Min + Round((Msg.XPos - CurWidth div 2) * (Max - Min) / (Width - CurWidth))
    else
      TempValue := Max - Round((Msg.YPos - CurHeight div 2) * (Max - Min) / (Height - CurHeight));

    //  Keep value in range [Min..Max]
    if TempValue < Min then
      TempValue := Min
    else if TempValue > Max then
      TempValue := Max;

    FValue := TempValue;
    UpdateRects;
    Repaint;
  end;

  inherited;
end;

procedure TUCustomSlider.WMMouseMove(var Msg: TWMMouseMove);
var
  TempValue: Integer;
begin
  if not Enabled then
    Exit;

  if FIsSliding then begin
    if Orientation = oHorizontal then
      TempValue := Min + Round((Msg.XPos - CurWidth div 2) * (Max - Min) / (Width - CurWidth))
    else
      TempValue := Max - Round((Msg.YPos - CurHeight div 2) * (Max - Min) / (Height - CurHeight));

    //  Keep value in range [Min..Max]
    if TempValue < Min then
      TempValue := Min
    else if TempValue > Max then
      TempValue := Max;

    Value := TempValue;
  end;

  inherited;
end;

procedure TUCustomSlider.WMLButtonUp(var Msg: TWMLButtonUp);
begin
  if Enabled then begin
    ControlState := csNone;
    FIsSliding := False;
    inherited;
  end;
end;

end.
