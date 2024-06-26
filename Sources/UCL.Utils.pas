unit UCL.Utils;

interface

uses
  SysUtils,
  Types,
  Windows,
  Controls,
  Graphics,
  GraphUtil,
  Themes,
  UCL.Classes,
  UCL.Types;

// Form
function BlurAvailable: Boolean;
function EnableBlur(FormHandle: HWND): Integer;

// Glass support
function CreatePreMultipliedRGBQuad(Color: TColor; Alpha: Byte = $FF): TRGBQuad;
function CreateSolidBrushWithAlpha(Color: TColor; Alpha: Byte = $FF): HBRUSH;

// Color
function BrightenColor(AColor: TColor; Delta: Integer): TColor;
function ColorChangeLightness(AColor: TColor; Value: Integer): TColor;
function GetTextColorFromBackground(BackColor: TColor): TColor;
function MulColor(AColor: TColor; Base: Single): TColor;

// Blend support
function CreateBlendFunc(Alpha: Byte; Gradient: Boolean): BLENDFUNCTION;
procedure AssignBlendBitmap(const Bmp: TBitmap; Color: TColor);
procedure AssignGradientBlendBitmap(const Bmp: TBitmap; Color: TColor; A1, A2: Byte; Direction: TUDirection);
procedure PaintBlendBitmap(const Canvas: TCanvas; DestRect: TRect; const BlendBitmap: TBitmap; BlendFunc: BLENDFUNCTION);

// OS
function CheckMaxWin32Version(AMajor: Integer; AMinor: Integer = 0): Boolean;
function GetTimeStamp: String;

// RTTI
function IsPropAvailable(Instance: TObject; Name: String): Boolean;

// Internal
function LoadResourceFontByName(const ResourceName: String; ResType: PChar): Boolean;
function LoadResourceFontByID(ResourceID: Integer; ResType: PChar): Boolean;
procedure IncludeControlState(const Control: TControl; const State: TControlState); inline;
procedure ExcludeControlState(const Control: TControl; const State: TControlState); inline;

implementation

uses
  Classes,
  TypInfo,
  RTTI;

var
  SetWindowCompositionAttribute: function (hWnd: HWND; var data: WindowCompositionAttributeData):integer; stdcall;

// FORM

function BlurAvailable: Boolean;
var
  apiHandle: THandle;
begin
  apiHandle := GetModuleHandle(User32);
//  if apiHandle = 0 then
//    apiHandle := LoadLibrary(User32);
  if apiHandle = 0 then
    Exit(False);
  try
    if @SetWindowCompositionAttribute = Nil then
      @SetWindowCompositionAttribute := GetProcAddress(apiHandle, 'SetWindowCompositionAttribute');
    Result := (@SetWindowCompositionAttribute <> Nil);
  except
    Result := False;
  end;
end;

function EnableBlur(FormHandle: HWND): Integer;
const
  WCA_ACCENT_POLICY = 19;
  ACCENT_ENABLE_BLURBEHIND = 3;
var
  apiHandle: THandle;
  Accent: AccentPolicy;
  Data: WindowCompositionAttributeData;
begin
  apiHandle := GetModuleHandle(User32);
//  if apiHandle = 0 then
//    apiHandle := LoadLibrary(User32);
  if apiHandle = 0 then
    Exit(0);

  try
    if @SetWindowCompositionAttribute = Nil then
      @SetWindowCompositionAttribute := GetProcAddress(apiHandle, 'SetWindowCompositionAttribute');
    if @SetWindowCompositionAttribute = Nil then
      Result := -1
    else begin
      FillChar(Accent, SizeOf(Accent), 0);
      Accent.AccentState := ACCENT_ENABLE_BLURBEHIND;

      Data.Attribute := WCA_ACCENT_POLICY;
      Data.SizeOfData := SizeOf(Accent);
      Data.Data := @Accent;

      Result := SetWindowCompositionAttribute(FormHandle, Data);
    end;
  //finally
  //  FreeLibrary(apiHandle);
  except
    Result := 0;
  end;
end;

// GLASS SUPPORT

function CreatePreMultipliedRGBQuad(Color: TColor; Alpha: Byte = $FF): TRGBQuad;
begin
  Color := ColorToRGB(Color);
  Result.rgbBlue := MulDiv(GetBValue(Color), Alpha, $FF);
  Result.rgbGreen := MulDiv(GetGValue(Color), Alpha, $FF);
  Result.rgbRed := MulDiv(GetRValue(Color), Alpha, $FF);
  Result.rgbReserved := Alpha;
end;

function CreateSolidBrushWithAlpha(Color: TColor; Alpha: Byte = $FF): HBRUSH;
var
  Info: TBitmapInfo;
begin
  FillChar(Info, SizeOf(Info), 0);
  with Info.bmiHeader do begin
    biSize := SizeOf(Info.bmiHeader);
    biWidth := 1;
    biHeight := 1;
    biPlanes := 1;
    biBitCount := 32;
    biCompression := BI_RGB;
  end;
  Info.bmiColors[0] := CreatePreMultipliedRGBQuad(Color, Alpha);
  Result := CreateDIBPatternBrushPt(@Info, 0);
end;

// COLOR

function BrightenColor(aColor: TColor; Delta: Integer): TColor;
var
  H, S, L: Word;
begin
  ColorRGBToHLS(aColor, H, L, S);   //  VCL.GraphUtil
  L := L + Delta;
  Result := ColorHLSToRGB(H, L, S);
end;

function ColorChangeLightness(AColor: TColor; Value: Integer): TColor;
var
  H, S, L: Word;
begin
  ColorRGBToHLS(AColor, H, L, S);
  Result := ColorHLSToRGB(H, Value, S);
end;

function GetTextColorFromBackground(BackColor: TColor): TColor;
var
  C: Integer;
  R, G, B: Byte;
begin
  C := ColorToRGB(BackColor);
  R := GetRValue(C);
  G := GetGValue(C);
  B := GetBValue(C);

  if (R = G) and (G = B) then begin //  Black white colors
    if C < $808080 then
      Result := $FFFFFF
    else
      Result := $000000;
  end
  else begin //  Other colors
    if 0.299 * R + 0.587 * G + 0.114 * B > 156 then
      Result := $000000
    else
      Result := $FFFFFF;
  end;
end;

function MulColor(aColor: TColor; Base: Single): TColor;
var
  C: Integer;
  R, G, B: Byte;
begin
  C := ColorToRGB(aColor);
  R := Round(GetRValue(C) * Base);
  G := Round(GetGValue(C) * Base);
  B := Round(GetBValue(C) * Base);
  Result := RGB(R, G, B);
end;

// BLEND SUPPORT

function CreateBlendFunc(Alpha: Byte; Gradient: Boolean): BLENDFUNCTION;
begin
  Result.BlendOp := AC_SRC_OVER;
  Result.BlendFlags := 0;
  Result.SourceConstantAlpha := Alpha;

  if Gradient then
    Result.AlphaFormat := AC_SRC_ALPHA
  else
    Result.AlphaFormat := 0;
end;

procedure AssignBlendBitmap(const Bmp: TBitmap; Color: TColor);
begin
  if Bmp <> Nil then begin
    Bmp.PixelFormat := pf32Bit;
    Bmp.Width := 1;
    Bmp.Height := 1;
    Bmp.Canvas.Brush.Color := Color;
    Bmp.Canvas.FillRect(Rect(0, 0, 1, 1));
  end;
end;

procedure AssignGradientBlendBitmap(const Bmp: TBitmap; Color: TColor; A1, A2: Byte; Direction: TUDirection);
var
  Alpha, Percent: Single;
  R, G, B, A: Byte;
  X, Y, W, H: Integer;
  Pixel: PQuadColor;
begin
  if Bmp = nil then exit;
  Bmp.PixelFormat := pf32Bit;

  R := GetRValue(Color);
  G := GetGValue(Color);
  B := GetBValue(Color);
  
  W := Bmp.Width;
  H := Bmp.Height;

  for Y := 0 to H - 1 do begin
    Pixel := Bmp.ScanLine[Y];
    for X := 0 to W - 1 do begin
      Percent := 0; // satisfy compiler
      case Direction of
        dTop   : Percent := 1 - Y / H;
        dLeft  : Percent := 1 - X / W;
        dRight : Percent := X / W;
        dBottom: Percent := Y / H;
      end;

      A := A1 + Trunc(Percent * (A2 - A1));
      Alpha := A / 255;

      Pixel.Alpha := A;
      Pixel.Red := Trunc(R * Alpha);
      Pixel.Green := Trunc(G * Alpha);
      Pixel.Blue := Trunc(B * Alpha);
      Inc(Pixel);
    end;
  end;
end;

procedure PaintBlendBitmap(const Canvas: TCanvas; DestRect: TRect; const BlendBitmap: TBitmap; BlendFunc: BLENDFUNCTION);
begin
  AlphaBlend(Canvas.Handle,
    DestRect.Left, DestRect.Top, DestRect.Width, DestRect.Height,
    BlendBitmap.Canvas.Handle, 0, 0, BlendBitmap.Width, BlendBitmap.Height,
    BlendFunc);
end;

// OS

function CheckMaxWin32Version(AMajor: Integer; AMinor: Integer = 0): Boolean;
begin
  Result := (Win32MajorVersion <= AMajor) or
            ((Win32MajorVersion = AMajor) and (Win32MinorVersion <= AMinor));
end;

function GetTimeStamp: String;
begin
  DateTimeToString(Result, {FormatSettings.ShortDateFormat + ' ' + }{$IF CompilerVersion > 29}FormatSettings.{$IFEND}LongTimeFormat + '.zzz', Now);
  Result := Result + ' - ';
end;

function IsPropAvailable(Instance: TObject; Name: String): Boolean;
var
  Ctx: TRttiContext;
  Prop: TRttiProperty;
begin
  Prop := Ctx.GetType(Instance.ClassType).GetProperty(Name);
  Result := (Prop <> Nil) and (Prop.Visibility in [mvProtected, mvPublic, mvPublished]);
end;

// INTERNAL

function LoadResourceFontByName(const ResourceName: String; ResType: PChar): Boolean;
var
  ResStream: TResourceStream;
  FontsCount: DWORD;
begin
  try
    ResStream := TResourceStream.Create(hInstance, ResourceName, ResType);
    try
      Result := (AddFontMemResourceEx(ResStream.Memory, ResStream.Size, Nil, @FontsCount) <> 0);
    finally
      ResStream.Free;
    end;
  except
    Result := False;
  end;
end;

function LoadResourceFontByID(ResourceID: Integer; ResType: PChar): Boolean;
var
  ResStream: TResourceStream;
  FontsCount: DWORD;
begin
  try
    ResStream := TResourceStream.CreateFromID(hInstance, ResourceID, ResType);
    try
      Result := (AddFontMemResourceEx(ResStream.Memory, ResStream.Size, Nil, @FontsCount) <> 0);
    finally
      ResStream.Free;
    end;
  except
    Result := False;
  end;
end;

procedure IncludeControlState(const Control: TControl; const State: TControlState);
var
  cState: TControlState;
begin
  if Control <> Nil then begin
    cState:=Control.ControlState;
    cState:=cState + State;
    Control.ControlState:=cState;
  end;
end;

procedure ExcludeControlState(const Control: TControl; const State: TControlState);
var
  cState: TControlState;
begin
  if Control <> Nil then begin
    cState:=Control.ControlState;
    cState:=cState - State;
    Control.ControlState:=cState;
  end;
end;

initialization
  @SetWindowCompositionAttribute := Nil;

end.
