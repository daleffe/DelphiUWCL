unit UCL.TUEdit;

interface

{$IF CompilerVersion > 29}
  {$LEGACYIFEND ON}
{$IFEND}

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
  UCL.TUThemeManager,
  UCL.Utils;

const
  UM_SUBEDIT_SETFOCUS = WM_USER + 1;
  UM_SUBEDIT_KILLFOCUS = WM_USER + 2;

type
  TUSubEdit = class(TEdit)
  private
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
  end;

  TUEdit = class(TPanel, IUThemeComponent)
    private const
      DefBorderColor: TDefColor = (
        ($999999, $666666, $D77800, $CCCCCC, $D77800),
        ($666666, $999999, $D77800, $CCCCCC, $D77800));

    private
      var BorderThickness: Integer;
      var BorderColor: TColor;
      var BackColor: TColor;
      var TextColor: TColor;

      FThemeManager: TUThemeManager;
      FControlState: TUControlState;
      FEdit: TUSubEdit;

      FHitTest: Boolean;
      FTransparent: Boolean;

      //  Internal
      procedure UpdateColors;

      //  Setters
      procedure SetThemeManager; // (const Value: TUThemeManager);
      procedure SetControlState(const Value: TUControlState);
      procedure SetTransparent(const Value: Boolean);

      //  Messages
      procedure WMLButtonDown(var Msg: TWMLButtonDown); message WM_LBUTTONDOWN;
      procedure WMLButtonUp(var Msg: TWMLButtonUp); message WM_LBUTTONUP;
      procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
      procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;

      procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
      procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
      procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;

      procedure UMSubEditSetFocus(var Msg: TMessage); message UM_SUBEDIT_SETFOCUS;
      procedure UMSubEditKillFocus(var Msg: TMessage); message UM_SUBEDIT_KILLFOCUS;

    protected
      //procedure Notification(AComponent: TComponent; Operation: TOperation); override;
      procedure Paint; override;
      procedure CreateWindowHandle(const Params: TCreateParams); override;
      procedure ChangeScale(M, D: Integer{$IF CompilerVersion > 29}; isDpiChange: Boolean{$IFEND}); override;

    public
      constructor Create(aOwner: TComponent); override;
      destructor Destroy; override;

      procedure UpdateTheme;

    published
      property ThemeManager: TUThemeManager read FThemeManager; // write SetThemeManager;
      property Edit: TUSubEdit read FEdit write FEdit;
      property ControlState: TUControlState read FControlState write SetControlState default csNone;

      property HitTest: Boolean read FHitTest write FHitTest default true;
      property Transparent: Boolean read FTransparent write SetTransparent default false;
  end;

implementation

{ TUSubEdit }

//  MESSAGES

procedure TUSubEdit.WMSetFocus(var Msg: TWMSetFocus);
begin
  PostMessage(Parent.Handle, UM_SUBEDIT_SETFOCUS, 0, 0);
  inherited;
end;

procedure TUSubEdit.WMKillFocus(var Msg: TWMKillFocus);
begin
  PostMessage(Parent.Handle, UM_SUBEDIT_KILLFOCUS, 0, 0);
  inherited;
end;

{ TUCustomEdit }

//  THEME

procedure TUEdit.SetThemeManager; // (const Value: TUThemeManager);
begin
  FThemeManager := GetCommonThemeManager;
  UpdateTheme;
end;

procedure TUEdit.UpdateTheme;
begin
  UpdateColors;
  Repaint;
end;
{
procedure TUEdit.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FThemeManager) then
    FThemeManager := nil;
end;
}
//  INTERNAL

procedure TUEdit.UpdateColors;
begin
  //  Border & background color
  if ThemeManager = Nil then begin
    BorderColor := DefBorderColor[utLight, ControlState];
    BackColor := $FFFFFF;
  end
  else begin
    case ControlState of
      csPress, csFocused:
        BorderColor := ThemeManager.AccentColor;
    else
      BorderColor := DefBorderColor[ThemeManager.Theme, ControlState];
    end;

    if (ThemeManager.Theme = utLight) or (ControlState in [csPress, csFocused]) then
      BackColor := $FFFFFF
    else
      BackColor := $000000;
  end;

  //  Transparent edit
  if Transparent and (ControlState = csNone) then begin
    ParentColor := true;
    BackColor := Color;
  end;

  //  Text color
  TextColor := GetTextColorFromBackground(BackColor);

  //  Disabled edit
  if ControlState = csDisabled then begin
    BackColor := $CCCCCC;
    BorderColor := $CCCCCC;
    TextColor := clGray;
  end;
end;

//  SETTERS

procedure TUEdit.SetControlState(const Value: TUControlState);
begin
  if Value <> FControlState then begin
    FControlState := Value;
    UpdateColors;
    Repaint;
  end;
end;

procedure TUEdit.SetTransparent(const Value: Boolean);
begin
  if Value <> FTransparent then begin
    FTransparent := Value;
    Repaint;
  end;
end;

//  MAIN CLASS

constructor TUEdit.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FThemeManager := Nil;

  BorderThickness := 2;

  FControlState := csNone;
  FHitTest := true;
  FTransparent := false;

  Alignment := taLeftJustify;
  ShowCaption := false;
  Height := 29;
  BevelOuter := bvNone;
  Caption := '';
  Font.Name := 'Segoe UI';
  Font.Size := 10;

  FEdit := TUSubEdit.Create(Self);
  FEdit.Parent := Self;
  FEdit.Name := 'SubEdit';
  FEdit.Text := '';

  FEdit.Font := Self.Font;
  FEdit.BorderStyle := bsNone;
  FEdit.AutoSize := true;
  FEdit.ParentColor := true;

  Padding.Left := 5;
  Padding.Right := 5;
  Padding.Bottom := (Height - FEdit.Height) div 2 - 1;
  Padding.Top := (Height - FEdit.Height) - Padding.Bottom;

  FEdit.Align := alClient;
  FEdit.SetSubComponent(true);

  if GetCommonThemeManager <> Nil then
    GetCommonThemeManager.Connect(Self);
end;

//  CUSTOM METHODS

procedure TUEdit.Paint;
var
  Space: Integer;
begin
  inherited;

  //  Paint border
  Canvas.Brush.Handle := CreateSolidBrushWithAlpha(BorderColor, 255);
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

procedure TUEdit.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited;
  UpdateColors;
end;

destructor TUEdit.Destroy;
begin
  if FThemeManager <> Nil then
    FThemeManager.Disconnect(Self);
  inherited;
end;

procedure TUEdit.ChangeScale(M, D: Integer{$IF CompilerVersion > 29}; isDpiChange: Boolean{$IFEND});
begin
  inherited;
  BorderThickness := MulDiv(BorderThickness, M, D);
end;

//  MESSAGES

procedure TUEdit.WMLButtonDown(var Msg: TWMLButtonDown);
begin
  if Enabled and HitTest then begin
    FEdit.SetFocus;
    ControlState := csPress;
    inherited;
  end;
end;

procedure TUEdit.WMLButtonUp(var Msg: TWMLButtonUp);
begin
  if Enabled and HitTest then begin
    if (Focused) or (FEdit.Focused) then
      ControlState := csFocused
    else
      ControlState := csNone;
    inherited;
  end;
end;

procedure TUEdit.WMSetFocus(var Msg: TWMSetFocus);
begin
  if Enabled and HitTest then begin
    ControlState := csFocused;
    inherited;
  end;
end;

procedure TUEdit.WMKillFocus(var Msg: TWMKillFocus);
begin
  if Enabled and HitTest then begin
    ControlState := csNone;
    inherited;
  end;
end;

procedure TUEdit.UMSubEditSetFocus(var Msg: TMessage);
begin
  if Enabled and HitTest then
    ControlState := csFocused;
end;

procedure TUEdit.UMSubEditKillFocus(var Msg: TMessage);
begin
  if Enabled and HitTest then
    ControlState := csNone;
end;

procedure TUEdit.CMMouseEnter(var Msg: TMessage);
begin
  if Enabled and HitTest then begin
    if (Focused) or (FEdit.Focused) then
      ControlState := csFocused
    else
      ControlState := csHover;
    inherited;
  end;
end;

procedure TUEdit.CMMouseLeave(var Msg: TMessage);
begin
  if Enabled and HitTest then begin
    if (Focused) or (FEdit.Focused) then
      ControlState := csFocused
    else
      ControlState := csNone;
    inherited;
  end;
end;

procedure TUEdit.CMEnabledChanged(var Msg: TMessage);
begin
  inherited;
  if not Enabled then
    FControlState := csDisabled
  else
    FControlState := csNone;
  FEdit.Enabled := Enabled;
  UpdateTheme;
end;

end.
