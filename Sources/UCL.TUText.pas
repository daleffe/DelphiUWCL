unit UCL.TUText;

interface

uses
  Classes,
  Windows,
  Messages,
  Controls,
  StdCtrls,
  UCL.Classes,
  UCL.TUThemeManager;

type
  TUTextKind = (tkCustom, tkNormal, tkDescription, tkEntry, tkHeading, tkTitle);

  TUText = class(TLabel, IUThemeComponent)
  private
    FThemeManager: TUThemeManager;
    FTextKind: TUTextKind;
    FUseAccentColor: Boolean;

    procedure SetThemeManager; // (const Value: TUThemeManager);
    procedure SetTextKind(const Value: TUTextKind);
    procedure SetUseAccentColor(const Value: Boolean);

  protected
    //procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure UpdateTheme;

  published
    property ThemeManager: TUThemeManager read FThemeManager; // write SetThemeManager;
    property TextKind: TUTextKind read FTextKind write SetTextKind default tkNormal;
    property UseAccentColor: Boolean read FUseAccentColor write SetUseAccentColor default false;
  end;

implementation

uses
  UCL.Colors;

{ TUText }

//  THEME

procedure TUText.SetThemeManager; // (const Value: TUThemeManager);
begin
  FThemeManager := GetCommonThemeManager;
  UpdateTheme;
end;

procedure TUText.UpdateTheme;
begin
  //  Font color
  if TextKind = tkDescription then
    Font.Color := $666666
  else if ThemeManager = Nil then
    Font.Color := $000000
  else begin
    if UseAccentColor then
      Font.Color := ThemeManager.AccentColor
    else if ThemeManager.Theme = utLight then
      Font.Color := $000000
    else
      Font.Color := $FFFFFF;
  end;
end;
{
procedure TUText.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FThemeManager) then
    FThemeManager := nil;
end;
}
//  SETTERS

procedure TUText.SetTextKind(const Value: TUTextKind);
begin
  if Value <> FTextKind then begin
    FTextKind := Value;

    if FTextKind <> tkCustom then begin
      if TextKind = tkEntry then
        Font.Name := 'Segoe UI Semibold'
      else
        Font.Name := 'Segoe UI';

      //  Font size
      case TextKind of
        tkNormal     : Font.Size := 10;
        tkDescription: Font.Size := 9;
        tkEntry      : Font.Size := 10;
        tkHeading    : Font.Size := 15;
        tkTitle      : Font.Size := 21;
      end;
    end;

    UpdateTheme;
  end;
end;

procedure TUText.SetUseAccentColor(const Value: Boolean);
begin
  if Value <> FUseAccentColor then begin
    FUseAccentColor := Value;
    UpdateTheme;
  end;
end;

//  MAIN CLASS

constructor TUText.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FThemeManager := Nil;

  //  New properties
  FTextKind := tkNormal;
  FUseAccentColor := False;

  Font.Name := 'Segoe UI';
  Font.Size := 10;

  if GetCommonThemeManager <> Nil then
    GetCommonThemeManager.Connect(Self);

//  UpdateTheme;
end;

destructor TUText.Destroy;
begin
  if FThemeManager <> Nil then
    FThemeManager.Disconnect(Self);
  inherited;
end;

end.

