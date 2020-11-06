unit UCL.Panel;

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
  ExtCtrls,
  Graphics,
  UCL.Classes,
  UCL.Colors,
  UCL.Utils,
  UCL.SystemSettings,
  UCL.ThemeManager;

type
  TUPanel = class(TPanel, IUThemedComponent)
  private
    FThemeManager: TUThemeManager;
    FBackColor: TUThemeControlColorSet;

    //  Child events
    procedure BackColor_OnChange(Sender: TObject);
      
    //  Setters
    procedure SetThemeManager(const Value: TUThemeManager);

    //  Messages
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Canvas;

    // IUThemedComponent
    procedure UpdateTheme;
    function IsCustomThemed: Boolean;
    function CustomThemeManager: TUCustomThemeManager;

  published
    property ThemeManager: TUThemeManager read FThemeManager write SetThemeManager;
    property BackColor: TUThemeControlColorSet read FBackColor write FBackColor;

    property BevelOuter default bvNone;
    property ParentColor default false;
    property ParentBackground default false;
  end;

implementation

uses
  Types,
  Forms,
  UCL.Form;

type
  TUFormAccess = class(TUForm);

{ TUPanel }

//  MAIN CLASS

constructor TUPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FThemeManager := Nil;

  //  Old properties
  BevelOuter := bvNone;
  ParentColor := false;
  ParentBackground := false;
//  Font.Name := 'Segoe UI';
//  Font.Size := 9;

  //  Objects
  FBackColor := TUThemeControlColorSet.Create;
  FBackColor.OnChange := BackColor_OnChange;
  FBackColor.Assign(PANEL_BACK);

  if GetCommonThemeManager <> Nil then
    GetCommonThemeManager.Connect(Self);

//  UpdateTheme;
end;

destructor TUPanel.Destroy;
var
  TM: TUCustomThemeManager;
begin
  FBackColor.Free;
  TM:=SelectThemeManager(Self);
  TM.Disconnect(Self);
  inherited;
end;

//  THEME

procedure TUPanel.SetThemeManager(const Value: TUThemeManager);
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

procedure TUPanel.UpdateTheme;
var
  TM: TUCustomThemeManager;
  ColorSet: TUThemeControlColorSet;
begin
  TM:=SelectThemeManager(Self);
  // Select default or custom style
  if BackColor.Enabled then
    ColorSet := BackColor
  else
    ColorSet := PANEL_BACK;

  Color := ColorSet.GetColor(TM);
  Font.Color := GetTextColorFromBackground(Color);

  //  Repaint
  //  Do not repaint, because it does not override Paint method
end;

function TUPanel.IsCustomThemed: Boolean;
begin
  Result:=(FThemeManager <> Nil);
end;

function TUPanel.CustomThemeManager: TUCustomThemeManager;
begin
  Result:=FThemeManager;
end;

procedure TUPanel.WMNCHitTest(var Msg: TWMNCHitTest);
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
    if ParentForm is TUForm then
      BorderSpace:=TUFormAccess(ParentForm).GetBorderSpace(bsDefault);
    //  Send event to parent
    case Align of
      alTop: begin
        // we need to check top, left and right borders
        if (P.Y < BorderSpace) or (P.X < BorderSpace) or (Width - P.X < BorderSpace) then
          Msg.Result := HTTRANSPARENT;
      end;
      alBottom: begin
        // we need to check bottom, left and right borders
        if (Height - P.Y < BorderSpace) or (P.X < BorderSpace) or (Width - P.X < BorderSpace) then
          Msg.Result := HTTRANSPARENT;
      end;
      alLeft: begin
        // we need to check left, top and bottom borders
        if (P.X < BorderSpace) or (P.Y < BorderSpace) or (Height - P.Y < BorderSpace) then
          Msg.Result := HTTRANSPARENT;
      end;
      alRight: begin
        // we need to check right, top and bottom borders
        if (Width - P.X < BorderSpace) or (P.Y < BorderSpace) or (Height - P.Y < BorderSpace) then
          Msg.Result := HTTRANSPARENT;
      end;
    end;
  end;
end;

procedure TUPanel.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FThemeManager) then begin
    ThemeManager:=Nil;
    Exit;
  end;
  inherited Notification(AComponent, Operation);
end;

//  CHILD EVENTS

procedure TUPanel.BackColor_OnChange(Sender: TObject);
begin
  UpdateTheme;
end;

end.