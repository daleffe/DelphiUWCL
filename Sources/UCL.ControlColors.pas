unit UCL.ControlColors;

interface

uses
  SysUtils,
  Classes,
  Controls,
  Graphics,
  UCL.Types,
  UCL.Colors,
  UCL.ColorTypes;

type
  TUControlColorSet = class(TUCustomControlColors)
  private
    FUseCustomColors: Boolean;
    FUpdating: Boolean;
    FOnChange: TNotifyEvent;
    //
    procedure SetUseCustomColors(Value: Boolean);

  protected
    procedure Changed(Sender: TObject); virtual;
    //
    procedure SaveTo(const SetName: String; const List: TStrings); virtual; abstract;
    procedure LoadFrom(const SetName: String; const List: TStrings); virtual; abstract;

  public
    constructor Create(const Owner: TComponent); override;
    procedure AfterConstruction; override;

    procedure Assign(Source: TPersistent); overload; override;

  published
    property UseCustomColors: Boolean read FUseCustomColors write SetUseCustomColors default False;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

//  TUButtonColors = packed record
//    BackColors: TUStateHoverPressDisableFocusColor;
//    BorderColors: TUStateHoverPressDisableFocusColor;
//    TextColors: TUStateHoverPressDisableFocusColor;
//  end;

  TUButtonColorSet = class(TUControlColorSet)
  private
    FBackColors: TUThemeButtonStateColorSet;
    FBorderColors: TUThemeButtonStateColorSet;
    FTextColors: TUThemeButtonStateColorSet;

    procedure SetBackColors(Value: TUThemeButtonStateColorSet);
    procedure SetBorderColors(Value: TUThemeButtonStateColorSet);
    procedure SetTextColors(Value: TUThemeButtonStateColorSet);

  protected
    procedure SaveTo(const SetName: String; const List: TStrings); override;
    procedure LoadFrom(const SetName: String; const List: TStrings); override;

  public
    constructor Create(const Owner: TComponent); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); overload; override;
    procedure Assign(Source: TUButtonControlColors); overload;

    procedure GetColors(const ButtonState: TUControlState; const CustomColors: TUButtonColorSet; var BackColor, BorderColor, TextColor: TColor);

  published
    property BackColors: TUThemeButtonStateColorSet read FBackColors write SetBackColors;
    property BorderColors: TUThemeButtonStateColorSet read FBorderColors write SetBorderColors;
    property TextColors: TUThemeButtonStateColorSet read FTextColors write SetTextColors;
  end;

  TUItemButtonColorSet = class(TUButtonColorSet)
  private
    FDetailColors: TUThemeButtonStateColorSet;
    FActiveColors: TUThemeButtonStateColorSet;

    procedure SetDetailColors(Value: TUThemeButtonStateColorSet);
    procedure SetActiveColors(Value: TUThemeButtonStateColorSet);

  protected
    procedure SaveTo(const SetName: String; const List: TStrings); override;
    procedure LoadFrom(const SetName: String; const List: TStrings); override;

  public
    constructor Create(const Owner: TComponent); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); overload; override;
    procedure Assign(Source: TUItemButtonControlColors); reintroduce; overload;

    procedure GetColors(const ButtonState: TUControlState; const CustomColors: TUItemButtonColorSet; var BackColor, BorderColor, TextColor, DetailColor, ActiveColor: TColor);

  published
    property DetailColors: TUThemeButtonStateColorSet read FDetailColors write SetDetailColors;
    property ActiveColors: TUThemeButtonStateColorSet read FActiveColors write SetActiveColors;
  end;

implementation

uses
//  TypInfo,
  UCL.ThemeManager;

{ TUControlColorSet }

constructor TUControlColorSet.Create(const Owner: TComponent);
begin
  inherited Create(Owner);
  FUpdating := False;
  FOnChange := Nil;
end;

procedure TUControlColorSet.AfterConstruction;
begin
  inherited;
  Changed(Self);
end;

procedure TUControlColorSet.Assign(Source: TPersistent);
begin
  if Source is TUControlColorSet then begin
    Changed(Source);
  end
  else
    inherited;
end;

procedure TUControlColorSet.SetUseCustomColors(Value: Boolean);
begin
  if FUseCustomColors <> Value then begin
    FUseCustomColors := Value;
    Changed(Self);
  end;
end;

procedure TUControlColorSet.Changed(Sender: TObject);
begin
  if Assigned(FOnChange) and not FUpdating then
    FOnChange(Sender);
end;

{ TUButtonColorSet }

constructor TUButtonColorSet.Create(const Owner: TComponent);
begin
  inherited Create(Owner);

  FBackColors := TUThemeButtonStateColorSet.Create;
  //FBackColors.SetColors(utLight, $F2F2F2, $E6E6E6, $CCCCCC, $F2F2F2, $F2F2F2);
//  FBackColors.Assign(BUTTON_BACK);

  FBorderColors := TUThemeButtonStateColorSet.Create;
//  FBorderColors.SetColors(utLight, $F2F2F2, $E6E6E6, $CCCCCC, $F2F2F2, $F2F2F2);
//  FBorderColors.Assign(BUTTON_BORDER);

  FTextColors := TUThemeButtonStateColorSet.Create;
  FTextColors.SetColors(utLight, clBlack, clBlack, clBlack, clGray, clBlack);
  FTextColors.SetColors(utDark, clWhite, clWhite, clWhite, clGray, clWhite);

  FBackColors.OnChange   := Changed;
  FBorderColors.OnChange := Changed;
  FTextColors.OnChange   := Changed;
end;

destructor TUButtonColorSet.Destroy;
begin
  FBackColors.Free;
  FBorderColors.Free;
  FTextColors.Free;
  inherited;
end;

procedure TUButtonColorSet.Assign(Source: TPersistent);
var
  SourceObject: TUButtonColorSet;
begin
  if Source is TUButtonColorSet then begin
    SourceObject:=TUButtonColorSet(Source);
    //
    FBackColors.Assign(SourceObject.BackColors);
    FBorderColors.Assign(SourceObject.BorderColors);
    FTextColors.Assign(SourceObject.TextColors);
  end;
  inherited Assign(Source); // must be last - changed is called here
end;

procedure TUButtonColorSet.Assign(Source: TUButtonControlColors);
begin
  FUpdating := True;
  try
    FBackColors.Assign(Source.BackColors);
    FBorderColors.Assign(Source.BorderColors);
    FTextColors.Assign(Source.TextColors);
  finally
    FUpdating := False;
  end;
  //
  Changed(Self);
end;

procedure TUButtonColorSet.GetColors(const ButtonState: TUControlState; const CustomColors: TUButtonColorSet; var BackColor, BorderColor, TextColor: TColor);
var
  ThemeManager: TUBaseThemeManager;
  ThemedComponent: IUThemedComponent;
begin
  ThemeManager := Nil;
  if Owner is TUBaseThemeManager then
    ThemeManager := TUBaseThemeManager(Owner)
  else if (Owner is TComponent) and IsThemingAvailable(Owner) then begin
    if Supports(Owner, IUThemedComponent, ThemedComponent) and (ThemedComponent <> Nil) then
      ThemeManager := SelectThemeManager(TComponent(ThemedComponent));
  end;
  //
  BackColor := clNone;
  BorderColor := clNone;
  TextColor := clNone;
  //
  if ThemeManager <> Nil then begin
    if ThemeManager.Theme in [ttCustomLight, ttCustomDark] then begin
      BackColor   := CustomColors.BackColors.GetColor(ThemeManager.ThemeUsed, ButtonState);
      BorderColor := CustomColors.BorderColors.GetColor(ThemeManager.ThemeUsed, ButtonState);
      TextColor   := CustomColors.TextColors.GetColor(ThemeManager.ThemeUsed, ButtonState);
    end
    else begin
      BackColor   := BackColors.GetColor(ThemeManager.ThemeUsed, ButtonState);
      BorderColor := BorderColors.GetColor(ThemeManager.ThemeUsed, ButtonState);
      TextColor   := TextColors.GetColor(ThemeManager.ThemeUsed, ButtonState);
    end;
  end;
end;

// Color definitions - https://docwiki.embarcadero.com/RADStudio/Athens/en/Colors_in_the_VCL
procedure TUButtonColorSet.SaveTo(const SetName: String; const List: TStrings);
begin
  // BackColors
  List.AddPair(SetName + '.BackColors.LightColor'   , ColorToString(BackColors.LightColor));
  List.AddPair(SetName + '.BackColors.LightHover'   , ColorToString(BackColors.LightHover));
  List.AddPair(SetName + '.BackColors.LightPress'   , ColorToString(BackColors.LightPress));
  List.AddPair(SetName + '.BackColors.LightDisabled', ColorToString(BackColors.LightDisabled));
  List.AddPair(SetName + '.BackColors.LightFocused' , ColorToString(BackColors.LightFocused));
  List.AddPair(SetName + '.BackColors.DarkColor'    , ColorToString(BackColors.DarkColor));
  List.AddPair(SetName + '.BackColors.DarkHover'    , ColorToString(BackColors.DarkHover));
  List.AddPair(SetName + '.BackColors.DarkPress'    , ColorToString(BackColors.DarkPress));
  List.AddPair(SetName + '.BackColors.DarkDisabled' , ColorToString(BackColors.DarkDisabled));
  List.AddPair(SetName + '.BackColors.DarkFocused'  , ColorToString(BackColors.DarkFocused));
  // BorderColors
  List.AddPair(SetName + '.BorderColors.LightColor'   , ColorToString(BorderColors.LightColor));
  List.AddPair(SetName + '.BorderColors.LightHover'   , ColorToString(BorderColors.LightHover));
  List.AddPair(SetName + '.BorderColors.LightPress'   , ColorToString(BorderColors.LightPress));
  List.AddPair(SetName + '.BorderColors.LightDisabled', ColorToString(BorderColors.LightDisabled));
  List.AddPair(SetName + '.BorderColors.LightFocused' , ColorToString(BorderColors.LightFocused));
  List.AddPair(SetName + '.BorderColors.DarkColor'    , ColorToString(BorderColors.DarkColor));
  List.AddPair(SetName + '.BorderColors.DarkHover'    , ColorToString(BorderColors.DarkHover));
  List.AddPair(SetName + '.BorderColors.DarkPress'    , ColorToString(BorderColors.DarkPress));
  List.AddPair(SetName + '.BorderColors.DarkDisabled' , ColorToString(BorderColors.DarkDisabled));
  List.AddPair(SetName + '.BorderColors.DarkFocused'  , ColorToString(BorderColors.DarkFocused));
  // TextColors
  List.AddPair(SetName + '.TextColors.LightColor'   , ColorToString(TextColors.LightColor));
  List.AddPair(SetName + '.TextColors.LightHover'   , ColorToString(TextColors.LightHover));
  List.AddPair(SetName + '.TextColors.LightPress'   , ColorToString(TextColors.LightPress));
  List.AddPair(SetName + '.TextColors.LightDisabled', ColorToString(TextColors.LightDisabled));
  List.AddPair(SetName + '.TextColors.LightFocused' , ColorToString(TextColors.LightFocused));
  List.AddPair(SetName + '.TextColors.DarkColor'    , ColorToString(TextColors.DarkColor));
  List.AddPair(SetName + '.TextColors.DarkHover'    , ColorToString(TextColors.DarkHover));
  List.AddPair(SetName + '.TextColors.DarkPress'    , ColorToString(TextColors.DarkPress));
  List.AddPair(SetName + '.TextColors.DarkDisabled' , ColorToString(TextColors.DarkDisabled));
  List.AddPair(SetName + '.TextColors.DarkFocused'  , ColorToString(TextColors.DarkFocused));
end;

procedure TUButtonColorSet.LoadFrom(const SetName: String; const List: TStrings);
begin
  // BackColors
  LoadProperty(List, SetName, SetName + '.BackColors.LightColor');
  LoadProperty(List, SetName, SetName + '.BackColors.LightHover');
  LoadProperty(List, SetName, SetName + '.BackColors.LightPress');
  LoadProperty(List, SetName, SetName + '.BackColors.LightDisabled');
  LoadProperty(List, SetName, SetName + '.BackColors.LightFocused');
  LoadProperty(List, SetName, SetName + '.BackColors.DarkColor');
  LoadProperty(List, SetName, SetName + '.BackColors.DarkHover');
  LoadProperty(List, SetName, SetName + '.BackColors.DarkPress');
  LoadProperty(List, SetName, SetName + '.BackColors.DarkDisabled');
  LoadProperty(List, SetName, SetName + '.BackColors.DarkFocused');
  // BorderColors
  LoadProperty(List, SetName, SetName + '.BorderColors.LightColor');
  LoadProperty(List, SetName, SetName + '.BorderColors.LightHover');
  LoadProperty(List, SetName, SetName + '.BorderColors.LightPress');
  LoadProperty(List, SetName, SetName + '.BorderColors.LightDisabled');
  LoadProperty(List, SetName, SetName + '.BorderColors.LightFocused');
  LoadProperty(List, SetName, SetName + '.BorderColors.DarkColor');
  LoadProperty(List, SetName, SetName + '.BorderColors.DarkHover');
  LoadProperty(List, SetName, SetName + '.BorderColors.DarkPress');
  LoadProperty(List, SetName, SetName + '.BorderColors.DarkDisabled');
  LoadProperty(List, SetName, SetName + '.BorderColors.DarkFocused');
  // TextColors
  LoadProperty(List, SetName, SetName + '.TextColors.LightColor');
  LoadProperty(List, SetName, SetName + '.TextColors.LightHover');
  LoadProperty(List, SetName, SetName + '.TextColors.LightPress');
  LoadProperty(List, SetName, SetName + '.TextColors.LightDisabled');
  LoadProperty(List, SetName, SetName + '.TextColors.LightFocused');
  LoadProperty(List, SetName, SetName + '.TextColors.DarkColor');
  LoadProperty(List, SetName, SetName + '.TextColors.DarkHover');
  LoadProperty(List, SetName, SetName + '.TextColors.DarkPress');
  LoadProperty(List, SetName, SetName + '.TextColors.DarkDisabled');
  LoadProperty(List, SetName, SetName + '.TextColors.DarkFocused');
end;

procedure TUButtonColorSet.SetBackColors(Value: TUThemeButtonStateColorSet);
begin
  FBackColors.Assign(Value);
end;

procedure TUButtonColorSet.SetBorderColors(Value: TUThemeButtonStateColorSet);
begin
  FBorderColors.Assign(Value);
end;

procedure TUButtonColorSet.SetTextColors(Value: TUThemeButtonStateColorSet);
begin
  FTextColors.Assign(Value);
end;

{ TUItemButtonColorSet }

constructor TUItemButtonColorSet.Create(const Owner: TComponent);
begin
  inherited Create(Owner);

  FDetailColors := TUThemeButtonStateColorSet.Create;

  FActiveColors := TUThemeButtonStateColorSet.Create;

  FDetailColors.OnChange  := Changed;
  FActiveColors.OnChange  := Changed;
end;

destructor TUItemButtonColorSet.Destroy;
begin
  FDetailColors.Free;
  FActiveColors.Free;
  inherited;
end;

procedure TUItemButtonColorSet.Assign(Source: TPersistent);
var
  SourceObject: TUItemButtonColorSet;
begin
  if Source is TUItemButtonColorSet then begin
    SourceObject:=TUItemButtonColorSet(Source);
    //
    FDetailColors.Assign(SourceObject.DetailColors);
    FActiveColors.Assign(SourceObject.ActiveColors);
  end;
  inherited Assign(Source); // must be last - changed is called here
end;

procedure TUItemButtonColorSet.Assign(Source: TUItemButtonControlColors);
begin
  FUpdating := True;
  try
    FBackColors.Assign(Source.BackColors);
    FBorderColors.Assign(Source.BorderColors);
    FTextColors.Assign(Source.TextColors);
    FDetailColors.Assign(Source.DetailColors);
    FActiveColors.Assign(Source.ActiveColors);
  finally
    FUpdating := False;
  end;
  //
  Changed(Self);
end;

procedure TUItemButtonColorSet.GetColors(const ButtonState: TUControlState; const CustomColors: TUItemButtonColorSet; var BackColor, BorderColor, TextColor,
  DetailColor, ActiveColor: TColor);
var
  ThemeManager: TUBaseThemeManager;
  ThemedComponent: IUThemedComponent;
begin
  ThemeManager := Nil;
  if Owner is TUBaseThemeManager then
    ThemeManager := TUBaseThemeManager(Owner)
  else if (Owner is TComponent) and IsThemingAvailable(Owner) then begin
    if Supports(Owner, IUThemedComponent, ThemedComponent) and (ThemedComponent <> Nil) then
      ThemeManager := SelectThemeManager(TComponent(ThemedComponent));
  end;
  //
  BackColor   := clNone;
  BorderColor := clNone;
  TextColor   := clNone;
  DetailColor := clNone;
  ActiveColor := clNone;
  //
  if ThemeManager <> Nil then begin
    if ThemeManager.Theme in [ttCustomLight, ttCustomDark] then begin
      BackColor   := CustomColors.BackColors.GetColor(ThemeManager.ThemeUsed, ButtonState);
      BorderColor := CustomColors.BorderColors.GetColor(ThemeManager.ThemeUsed, ButtonState);
      TextColor   := CustomColors.TextColors.GetColor(ThemeManager.ThemeUsed, ButtonState);
      DetailColor := CustomColors.DetailColors.GetColor(ThemeManager.ThemeUsed, ButtonState);
      ActiveColor := CustomColors.ActiveColors.GetColor(ThemeManager.ThemeUsed, ButtonState);
    end
    else begin
      BackColor   := BackColors.GetColor(ThemeManager.ThemeUsed, ButtonState);
      BorderColor := BorderColors.GetColor(ThemeManager.ThemeUsed, ButtonState);
      TextColor   := TextColors.GetColor(ThemeManager.ThemeUsed, ButtonState);
      DetailColor := DetailColors.GetColor(ThemeManager.ThemeUsed, ButtonState);
      ActiveColor := ActiveColors.GetColor(ThemeManager.ThemeUsed, ButtonState);
    end;
  end;
end;

procedure TUItemButtonColorSet.SaveTo(const SetName: String; const List: TStrings);
begin
  inherited;
  // BackColors
  List.AddPair(SetName + '.DetailColors.LightColor'   , ColorToString(DetailColors.LightColor));
  List.AddPair(SetName + '.DetailColors.LightHover'   , ColorToString(DetailColors.LightHover));
  List.AddPair(SetName + '.DetailColors.LightPress'   , ColorToString(DetailColors.LightPress));
  List.AddPair(SetName + '.DetailColors.LightDisabled', ColorToString(DetailColors.LightDisabled));
  List.AddPair(SetName + '.DetailColors.LightFocused' , ColorToString(DetailColors.LightFocused));
  List.AddPair(SetName + '.DetailColors.DarkColor'    , ColorToString(DetailColors.DarkColor));
  List.AddPair(SetName + '.DetailColors.DarkHover'    , ColorToString(DetailColors.DarkHover));
  List.AddPair(SetName + '.DetailColors.DarkPress'    , ColorToString(DetailColors.DarkPress));
  List.AddPair(SetName + '.DetailColors.DarkDisabled' , ColorToString(DetailColors.DarkDisabled));
  List.AddPair(SetName + '.DetailColors.DarkFocused'  , ColorToString(DetailColors.DarkFocused));
  // BorderColors
  List.AddPair(SetName + '.ActiveColors.LightColor'   , ColorToString(ActiveColors.LightColor));
  List.AddPair(SetName + '.ActiveColors.LightHover'   , ColorToString(ActiveColors.LightHover));
  List.AddPair(SetName + '.ActiveColors.LightPress'   , ColorToString(ActiveColors.LightPress));
  List.AddPair(SetName + '.ActiveColors.LightDisabled', ColorToString(ActiveColors.LightDisabled));
  List.AddPair(SetName + '.ActiveColors.LightFocused' , ColorToString(ActiveColors.LightFocused));
  List.AddPair(SetName + '.ActiveColors.DarkColor'    , ColorToString(ActiveColors.DarkColor));
  List.AddPair(SetName + '.ActiveColors.DarkHover'    , ColorToString(ActiveColors.DarkHover));
  List.AddPair(SetName + '.ActiveColors.DarkPress'    , ColorToString(ActiveColors.DarkPress));
  List.AddPair(SetName + '.ActiveColors.DarkDisabled' , ColorToString(ActiveColors.DarkDisabled));
  List.AddPair(SetName + '.ActiveColors.DarkFocused'  , ColorToString(ActiveColors.DarkFocused));
end;

procedure TUItemButtonColorSet.LoadFrom(const SetName: String; const List: TStrings);
begin
  inherited;
  // BackColors
  LoadProperty(List, SetName, SetName + '.DetailColors.LightColor');
  LoadProperty(List, SetName, SetName + '.DetailColors.LightHover');
  LoadProperty(List, SetName, SetName + '.DetailColors.LightPress');
  LoadProperty(List, SetName, SetName + '.DetailColors.LightDisabled');
  LoadProperty(List, SetName, SetName + '.DetailColors.LightFocused');
  LoadProperty(List, SetName, SetName + '.DetailColors.DarkColor');
  LoadProperty(List, SetName, SetName + '.DetailColors.DarkHover');
  LoadProperty(List, SetName, SetName + '.DetailColors.DarkPress');
  LoadProperty(List, SetName, SetName + '.DetailColors.DarkDisabled');
  LoadProperty(List, SetName, SetName + '.DetailColors.DarkFocused');
  // BorderColors
  LoadProperty(List, SetName, SetName + '.ActiveColors.LightColor');
  LoadProperty(List, SetName, SetName + '.ActiveColors.LightHover');
  LoadProperty(List, SetName, SetName + '.ActiveColors.LightPress');
  LoadProperty(List, SetName, SetName + '.ActiveColors.LightDisabled');
  LoadProperty(List, SetName, SetName + '.ActiveColors.LightFocused');
  LoadProperty(List, SetName, SetName + '.ActiveColors.DarkColor');
  LoadProperty(List, SetName, SetName + '.ActiveColors.DarkHover');
  LoadProperty(List, SetName, SetName + '.ActiveColors.DarkPress');
  LoadProperty(List, SetName, SetName + '.ActiveColors.DarkDisabled');
  LoadProperty(List, SetName, SetName + '.ActiveColors.DarkFocused');
end;

procedure TUItemButtonColorSet.SetDetailColors(Value: TUThemeButtonStateColorSet);
begin
  FDetailColors.Assign(Value);
end;

procedure TUItemButtonColorSet.SetActiveColors(Value: TUThemeButtonStateColorSet);
begin
  FActiveColors.Assign(Value);
end;

end.
