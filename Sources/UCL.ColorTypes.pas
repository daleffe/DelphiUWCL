unit UCL.ColorTypes;

interface

uses
  SysUtils,
  Classes,
  Graphics;

type
  TUCustomControlColors = class(TPersistent)
  private
    FOwner: TComponent;
    FFormat: TFormatSettings;

  protected
    function IsThemingAvailable(const Comp: TComponent): Boolean; // check if Owner supports theming
    procedure SetPropertyValue(const PropertyName, Value: String); virtual;

  public
    constructor Create(const Owner: TComponent); virtual;

    procedure LoadProperty(const List: TStrings; SetName, PropertyName: String); virtual;

  published
    property Owner: TComponent read FOwner;
    property Format: TFormatSettings read FFormat write FFormat;
  end;

  // manager colors and sets
  TUColors_Hovered_Disabled = packed record
    Color: TColor;
    Hover: TColor;
    Disabled: TColor;
  end;

  TUColors_Hovered_Disabled_Sets = packed record
    LightSet: TUColors_Hovered_Disabled;
    DarkSet : TUColors_Hovered_Disabled;
  end;

  TUColors_Hover_Press_With_Select = packed record
    Color: TColor;
    Hover: TColor;
    Press: TColor;
    SelectedColor: TColor;
    SelectedHover: TColor;
    SelectedPress: TColor;
  end;

  TUColors_Hover_Press_With_Select_Sets = packed record
    LightSet: TUColors_Hover_Press_With_Select;
    DarkSet : TUColors_Hover_Press_With_Select;
  end;

  TUColors_Hover_Press_Disable_Focus = packed record
    Color: TColor;
    Hover: TColor;
    Press: TColor;
    Disabled: TColor;
    Focused: TColor;
  end;

  TUColors_Hover_Press_Disable_Focus_Sets = packed record
    LightSet: TUColors_Hover_Press_Disable_Focus;
    DarkSet : TUColors_Hover_Press_Disable_Focus;
  end;

// controls colors and sets
  TUButtonControlColors = packed record
    BackColors  : TUColors_Hover_Press_Disable_Focus_Sets;
    BorderColors: TUColors_Hover_Press_Disable_Focus_Sets;
    TextColors  : TUColors_Hover_Press_Disable_Focus_Sets;
  end;

  TUItemButtonControlColors = packed record
    BackColors  : TUColors_Hover_Press_Disable_Focus_Sets;
    BorderColors: TUColors_Hover_Press_Disable_Focus_Sets;
    TextColors  : TUColors_Hover_Press_Disable_Focus_Sets;
    DetailColors: TUColors_Hover_Press_Disable_Focus_Sets;
    ActiveColors: TUColors_Hover_Press_Disable_Focus_Sets;
  end;

const
  Button_Colors: TUButtonControlColors = (
    BackColors: (
      LightSet: (Color: $CCCCCC; Hover: $CCCCCC; Press: $999999; Disabled: $CCCCCC; Focused: $CCCCCC);
      DarkSet : (Color: $333333; Hover: $333333; Press: $666666; Disabled: $333333; Focused: $333333);
    );

    BorderColors: (
      LightSet: (Color: $CCCCCC; Hover: $7A7A7A; Press: $999999; Disabled: $7A7A7A; Focused: $7A7A7A);
      DarkSet : (Color: $333333; Hover: $858585; Press: $666666; Disabled: $858585; Focused: $858585);
    );

    TextColors: (
      LightSet: (Color: clBlack; Hover: clBlack; Press: clBlack; Disabled: clGray;  Focused: clBlack);
      DarkSet : (Color: clWhite; Hover: clWhite; Press: clWhite; Disabled: clGray;  Focused: clWhite);
    );
  );

  Item_Button_Colors: TUItemButtonControlColors = (
    BackColors: (
      LightSet: (Color: $CCCCCC; Hover: $CCCCCC; Press: $999999; Disabled: $CCCCCC; Focused: $CCCCCC);
      DarkSet : (Color: $333333; Hover: $333333; Press: $666666; Disabled: $333333; Focused: $333333);
    );

    BorderColors: (
      LightSet: (Color: $CCCCCC; Hover: $AAAAAA; Press: $999999; Disabled: $7A7A7A; Focused: $AAAAAA);
      DarkSet : (Color: $333333; Hover: $AAAAAA; Press: $666666; Disabled: $858585; Focused: $AAAAAA);
    );

    TextColors: (
      LightSet: (Color: clBlack; Hover: clBlack; Press: clBlack; Disabled: clGray;  Focused: clBlack);
      DarkSet : (Color: clWhite; Hover: clWhite; Press: clWhite; Disabled: clGray;  Focused: clWhite);
    );

    DetailColors: (
      LightSet: (Color: $808080; Hover: clSilver; Press: clSilver; Disabled: clSilver; Focused: clSilver);
      DarkSet : (Color: $333333; Hover: $333333; Press: $666666; Disabled: $333333; Focused: $333333);
    );

    ActiveColors: (
      LightSet: (Color: $CCCCCC; Hover: $CCCCCC; Press: $999999; Disabled: $CCCCCC; Focused: $CCCCCC);
      DarkSet : (Color: $333333; Hover: $333333; Press: $666666; Disabled: $333333; Focused: $333333);
    );
  );


//    LightSet: (
//      Color: ;
//      Hover: ;
//      Press: ;
//      SelectedColor: ;
//      SelectedHover: ;
//      SelectedPress: ;
//    );
//    DarkSet : (
//      Color: ;
//      Hover: ;
//      Press: ;
//      SelectedColor: ;
//      SelectedHover: ;
//      SelectedPress: ;
//    )
//  );

implementation

uses
  TypInfo,
  UCL.ThemeManager;

function GetPropertyName(const name, start_with: String): String;
begin
  Result := name;
  if Result.StartsWith(start_with) then
    Delete(Result, Low(String), Length(start_with));
end;

{ TUCustomControlColors }

constructor TUCustomControlColors.Create(const Owner: TComponent);
begin
  inherited Create;
  FOwner := Owner;
  FFormat := TFormatSettings.Create;
  FFormat.DecimalSeparator := '.';
  FFormat.ThousandSeparator := #0;
end;

function TUCustomControlColors.IsThemingAvailable(const Comp: TComponent): Boolean;
begin
  Result := (Comp <> Nil) and Supports(Comp, IUThemedComponent) and IsPublishedProp(Comp, 'ThemeManager');
end;

procedure TUCustomControlColors.SetPropertyValue(const PropertyName, Value: String);
type
  TGetNameResult = packed record
    nameOffset: Integer;
    name: String;
  end;

  function GetName(const Value: String; StartOffset: Integer): TGetNameResult;
  var
    i, j, ilen: Integer;
  begin
    Result.nameOffset:=0;
    Result.name:='';
    //
    ilen := Length(Value);
    i := Low(String);
    Inc(i, StartOffset);
    j:=i;
    while (i <= ilen) and (Value[i] <> '.') do
      Inc(i);
    Result.nameOffset := i;
    Result.name := Value.Substring(j - Low(String), i - j);
  end;

  function SetIntIdent(const Instance: TPersistent; PropInfo: PPropInfo; const Ident: String): Boolean;
  var
    V: FixedInt;
    IdentToInt: TIdentToInt;
  begin
    IdentToInt := FindIdentToInt(PropInfo^.PropType^);
    Result := Assigned(IdentToInt) and IdentToInt(Ident, V);
    if Result then
      SetOrdProp(Instance, PropInfo, V);
  end;

  function SetSetValue(const Instance: TPersistent; PropInfo: PPropInfo; const SetValue: String): Integer;
//  var
//    EnumType: PTypeInfo;
//    EnumName: string;
  begin
//    EnumType := GetTypeData(SetType)^.CompType^;
//    Result := 0;
//    while True do begin
//      EnumName := ReadStr;
//      if EnumName = '' then Break;
//      Include(TIntegerSet(Result), SetElementValue(EnumType, EnumName));
//    end;
  end;

//  procedure SetCollection(const Collection: TCollection; CollectionValue: String);
//  var
//    Item: TPersistent;
//  begin
//    Collection.BeginUpdate;
//    try
//      if Length(CollectionValue) > 0 then
//        Collection.Clear;
//      while Length(CollectionValue) > 0 do begin
//        if NextValue in [vaInt8, vaInt16, vaInt32] then
//          ReadInteger;
//        Item := Collection.Add;
//        while Length(CollectionValue) > 0 do
//          ReadProperty(Item);
//      end;
//    finally
//      Collection.EndUpdate;
//    end;
//  end;

  procedure SetPropValue(const Instance: TPersistent; PropInfo: PPropInfo);
  var
    ordProp: NativeInt;
    PropType: PTypeInfo;
    EnumValue: Integer;
  begin
    if PropInfo^.SetProc = Nil then begin
      ordProp:=GetOrdProp(Instance, PropInfo);
      if not ((PropInfo^.PropType^.Kind = tkClass) and (TObject(ordProp) is TComponent) and (csSubComponent in TComponent(ordProp).ComponentStyle)) then
        Exit;
    end;
    //
    PropType := PropInfo^.PropType^;
    case PropType^.Kind of
      tkInteger: begin
        if not SetIntIdent(Instance, PropInfo, Value) then
          SetOrdProp(Instance, PropInfo, StrToInt(Value));
      end;
      //
      tkInt64: begin
        SetInt64Prop(Instance, PropInfo, StrToInt64(Value));
      end;
      //
      tkFloat: begin
        SetFloatProp(Instance, PropInfo, StrToFloat(Value, FFormat));
      end;
      //
      tkEnumeration: begin
          EnumValue := GetEnumValue(PropType, Value);

          if EnumValue <> -1 then
            SetOrdProp(Instance, PropInfo, EnumValue);
      end;
      //
      tkSet: begin
        SetOrdProp(Instance, PropInfo, SetSetValue(Instance, PropInfo, Value));
      end;
      //
      tkChar, tkWChar: begin
        SetOrdProp(Instance, PropInfo, Ord(Value[Low(String)]));
      end;
      //
      tkString, tkLString, tkWString, tkUString: begin
        SetStrProp(Instance, PropInfo, Value);
      end;
      //
//      tkClass: begin
//        if Length(Value) = 0 then
//          SetOrdProp(Instance, PropInfo, 0)
//        else if Something(Value) = vaCollection then
//          ReadCollection(TCollection(GetOrdProp(Instance, PropInfo)))
//        else
//          SetObjectIdent(Instance, PropInfo, Value);
//      end;
//      tkMethod: begin
//        if Length(Value) = 0 then
//          SetMethodProp(Instance, PropInfo, NilMethod)
//        else begin
//          LMethod := FindMethodInstance(Root, ReadIdent);
//          if LMethod.Code <> nil then SetMethodProp(Instance, PropInfo, LMethod);
//        end;
//      end;
//      tkVariant:
//        SetVariantReference;
//      tkInterface:
//        SetInterfaceReference;
    end;
  end;

var
  Instance: TPersistent;
  PropInfo: PPropInfo;
  PropValue: TObject;
  offset: Integer;
  propName: TGetNameResult;
begin
  Instance:=Self;
  offset:=0;
  while True do begin
    propName:=GetName(PropertyName, offset);
    if Length(propName.name) = 0 then
      Break;
    PropInfo := GetPropInfo(Instance.ClassInfo, propName.name);
    if PropInfo = Nil then
      Exit;
    PropValue := Nil;
    if PropInfo^.PropType^.Kind = tkClass then
      PropValue := TObject(GetOrdProp(Instance, PropInfo));
    if not (PropValue is TPersistent) then
      Break;
    Instance := TPersistent(PropValue);
    Inc(offset, propName.nameOffset);
  end;
  PropInfo := GetPropInfo(Instance.ClassInfo, propName.name);
  if PropInfo <> Nil then
    SetPropValue(Instance, PropInfo)
end;

procedure TUCustomControlColors.LoadProperty(const List: TStrings; SetName, PropertyName: String);
var
  i: Integer;
  value, prop_name: String;
begin
  i:=List.IndexOfName(PropertyName);
  if i > -1 then begin
    value := List.ValueFromIndex[i];
    prop_name := GetPropertyName(PropertyName, SetName + '.');
    SetPropertyValue(prop_name, value);
    prop_name := '';
    value := '';
  end;
end;

end.
