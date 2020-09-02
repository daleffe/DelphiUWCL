﻿unit UCL.TUCheckBox;

interface

{$IF CompilerVersion > 29}
  {$LEGACYIFEND ON}
{$IFEND}

uses
  Classes,
  Messages,
  Windows,
  Controls,
  Graphics,
  UCL.Classes,
  UCL.TUThemeManager,
  UCL.Utils,
  UCL.Graphics;

type
  TUCheckBoxState = (cbsChecked, cbsUnchecked, cbsGrayed);

  TUCustomCheckBox = class(TGraphicControl, IUThemeComponent)
    const
      ICON_CHECKED = '';
      ICON_UNCHECKED = '';
      ICON_GRAYED = '';

    private
      var ActiveColor, TextColor: TColor;
      var IconRect, TextRect: TRect;

      FThemeManager: TUThemeManager;
      FIconFont: TFont;

      FAutoSize: Boolean;
      FAllowGrayed: Boolean;
      FTextOnGlass: Boolean;

      FState: TUCheckBoxState;
      FCustomActiveColor: TColor;

      //  Internal
      procedure UpdateColors;
      procedure UpdateRects;

      //  Setters
      procedure SetThemeManager; // (const Value: TUThemeManager);
      procedure SetAutoSize(const Value: Boolean); reintroduce;
      procedure SetTextOnGlass(const Value: Boolean);
      procedure SetAllowGrayed(const Value: Boolean);
      procedure SetState(const Value: TUCheckBoxState);

      //  Messages
      procedure WMLButtonUp(var Msg: TWMLButtonUp); message WM_LBUTTONUP;
      procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;

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
      property IconFont: TFont read FIconFont write FIconFont;

      property AutoSize: Boolean read FAutoSize write SetAutoSize default false;
      property AllowGrayed: Boolean read FAllowGrayed write SetAllowGrayed default false;
      property TextOnGlass: Boolean read FTextOnGlass write SetTextOnGlass default false;

      property State: TUCheckBoxState read FState write SetState default cbsUnchecked;
      property CustomActiveColor: TColor read FCustomActiveColor write FCustomActiveColor default $D77800;

      property ParentColor default True;
      property Height default 30;
      property Width default 180;
  end;

  TUCheckBox = class(TUCustomCheckBox)
    published
      property Align;
      property Anchors;
      property AutoSize;
      property BiDiMode;
      property Caption;
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

{ TUCustomCheckBox }

//  THEME

procedure TUCustomCheckBox.SetThemeManager; // (const Value: TUThemeManager);
begin
  FThemeManager := GetCommonThemeManager;
  UpdateTheme;
end;

procedure TUCustomCheckBox.UpdateTheme;
begin
  UpdateColors;
  UpdateRects;
  Repaint;
end;
{
procedure TUCustomCheckBox.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FThemeManager) then
    FThemeManager := nil;
end;
}
//  INTERNAL

procedure TUCustomCheckBox.UpdateColors;
begin
  if ThemeManager = Nil then begin
    ActiveColor := CustomActiveColor;
    TextColor := $000000;
  end
  else if ThemeManager.Theme = utLight then begin
    ActiveColor := ThemeManager.AccentColor;
    TextColor := $000000;
  end
  else begin
    ActiveColor := ThemeManager.AccentColor;
    TextColor := $FFFFFF;
  end;

  //  Disabled
  if not Enabled then begin
    ActiveColor := $808080;
    TextColor := $808080;
  end;
end;

procedure TUCustomCheckBox.UpdateRects;
begin
  IconRect := Rect(0, 0, Height, Height);
  TextRect := Rect(Height, 0, Width, Height);
end;

//  SETTERS

procedure TUCustomCheckBox.SetState(const Value: TUCheckBoxState);
begin
  if Value <> FState then begin
    if (not AllowGrayed) and (Value = cbsGrayed) then
      FState := cbsUnchecked
    else
      FState := Value;
    Repaint;
  end;
end;

procedure TUCustomCheckBox.SetAllowGrayed(const Value: Boolean);
begin
  if Value <> FAllowGrayed then begin
    FAllowGrayed := Value;
    if (not FAllowGrayed) and (FState = cbsGrayed) then
      FState := cbsUnchecked;
    Repaint;
  end;
end;

procedure TUCustomCheckBox.SetAutoSize(const Value: Boolean);
begin
  if Value <> FAutoSize then begin
    FAutoSize := Value;
    Resize;
  end;
end;

procedure TUCustomCheckBox.SetTextOnGlass(const Value: Boolean);
begin
  if Value <> FTextOnGlass then begin
    FTextOnGlass := Value;
    Repaint;
  end;
end;

//  MAIN CLASS

constructor TUCustomCheckBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FThemeManager := Nil;

  FIconFont := TFont.Create;
  FIconFont.Name := 'Segoe MDL2 Assets';
  FIconFont.Size := 15;

  FAutoSize := false;
  FAllowGrayed := false;
  FTextOnGlass := false;
  FState := cbsUnchecked;
  FCustomActiveColor := $D77800;  //  Default blue

  ParentColor := true;
  //Font.Name := 'Segoe UI';
  //Font.Size := 10;

  Height := 30;
  Width := 180;

  if GetCommonThemeManager <> Nil then
    GetCommonThemeManager.Connect(Self);

  UpdateColors;
  UpdateRects;
end;

destructor TUCustomCheckBox.Destroy;
begin
  FIconFont.Free;
  if FThemeManager <> Nil then
    FThemeManager.Disconnect(Self);
  inherited;
end;

//  CUSTOM METHODS

procedure TUCustomCheckBox.Paint;
begin
  inherited;

  //  Paint background
  if not TextOnGlass then begin
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Handle := CreateSolidBrushWithAlpha(Color, 255);
    Canvas.FillRect(Rect(0, 0, Width, Height));
  end;

  //  Paint text
  Canvas.Brush.Style := bsClear;
  Canvas.Font := Font;
  Canvas.Font.Color := TextColor;
  DrawTextRect(Canvas, taLeftJustify, taVerticalCenter, TextRect, Caption, TextOnGlass);

  //  Paint icon
  Canvas.Font := IconFont;
  case State of
    cbsChecked: begin
      Canvas.Font.Color := ActiveColor;
      DrawTextRect(Canvas, taLeftJustify, taVerticalCenter, IconRect, ICON_CHECKED, TextOnGlass);
    end;

    cbsUnchecked: begin
      Canvas.Font.Color := TextColor;
      DrawTextRect(Canvas, taLeftJustify, taVerticalCenter, IconRect, ICON_UNCHECKED, TextOnGlass);
    end;

    cbsGrayed: begin
      Canvas.Font.Color := ActiveColor;
      DrawTextRect(Canvas, taLeftJustify, taVerticalCenter, IconRect, ICON_UNCHECKED, TextOnGlass);

      Canvas.Font.Color := TextColor;
      DrawTextRect(Canvas, taLeftJustify, taVerticalCenter, IconRect, ICON_GRAYED, TextOnGlass);
    end;
  end;
end;

procedure TUCustomCheckBox.Resize;
var
  Space: Integer;
begin
  if AutoSize and (Align = alNone) then begin
    Space := 5;
    Canvas.Font := IconFont;
    Height := 2 * Space + Canvas.TextHeight(ICON_UNCHECKED);
    Canvas.Font := Font;
    Width := Height + Canvas.TextWidth(Text) + (Height - Canvas.TextHeight(Text)) div 2;
  end
  else
    inherited;
  UpdateRects;
end;

procedure TUCustomCheckBox.ChangeScale(M, D: Integer{$IF CompilerVersion > 29}; isDpiChange: Boolean{$IFEND});
begin
  inherited;
  IconFont.Height := MulDiv(IconFont.Height, M, D);
  Resize;   //  Autosize
  //UpdateRects;  //  Do not update rects, resize already do that
end;

//  MESSAGES

procedure TUCustomCheckBox.WMLButtonUp(var Msg: TWMLButtonUp);
begin
  if Enabled then
    if AllowGrayed then   //  Unchecked > Checked > Grayed > ...
      case State of
        cbsUnchecked: State := cbsChecked;
        cbsChecked  : State := cbsGrayed;
        cbsGrayed   : State := cbsUnchecked;
      end
    else
      case State of
        cbsUnchecked: State := cbsChecked;
        cbsChecked  : State := cbsUnchecked;
        cbsGrayed   : State := cbsUnchecked;
      end;

  inherited;
end;

procedure TUCustomCheckBox.CMEnabledChanged(var Msg: TMessage);
begin
  UpdateColors;
  Repaint;
end;

end.
