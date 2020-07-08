unit UCL.Graphics;

interface

{$IF CompilerVersion > 29}
  {$LEGACYIFEND ON}
{$IFEND}

uses
  Classes,
  Types,
  Windows,
  Graphics,
  Themes;

{$REGION 'Older Delphi version'}
{$IF CompilerVersion <= 30}
type
  // Note: tfComposited only supported by ThemeServices.DrawText
  TTextFormats = (tfBottom, tfCalcRect, tfCenter, tfEditControl, tfEndEllipsis,
    tfPathEllipsis, tfExpandTabs, tfExternalLeading, tfLeft, tfModifyString,
    tfNoClip, tfNoPrefix, tfRight, tfRtlReading, tfSingleLine, tfTop,
    tfVerticalCenter, tfWordBreak, tfHidePrefix, tfNoFullWidthCharBreak,
    tfPrefixOnly, tfTabStop, tfWordEllipsis, tfComposited);
  TTextFormat = set of TTextFormats;

const
  DT_NOFULLWIDTHCHARBREAK = $0080000;
  // MASK for tfComposited
  MASK_TF_COMPOSITED      = $00800000;
{$IFEND}  
{$ENDREGION}

function PointInRect(const X, Y: Integer; const Rect: TRect): Boolean; overload;
function PointInRect(const p: TPoint; const Rect: TRect): Boolean; overload;
function PointInRect(const p: TSmallPoint; const Rect: TRect): Boolean; overload;
procedure GetCenterPos(Width, Height: Integer; Rect: TRect; out X, Y: Integer);
procedure DrawTextRect(const Canvas: TCanvas; HAlign: TAlignment; VAlign: TVerticalAlignment; Rect: TRect; Text: string; TextOnGlass: Boolean);
procedure DrawBorder(const Canvas: TCanvas; R: TRect; Color: TColor; Thickness: Byte);
procedure InitBumpMap;
procedure DrawBumpMap(const Canvas: TCanvas; X, Y: Integer);

var
  DEFAULT_GLASSTEXT_GLOWSIZE: Byte;

implementation

uses
  // delphi stuff first
  SysUtils,
  DwmApi,
  UxTheme,
  // library stuff last
  UCL.Classes,
  UCL.Types;

{$REGION 'Older Delphi version'}
{$IF CompilerVersion <= 30}
type
  TStyleTextFlag = (stfTextColor, stfBorderColor, stfBorderSize, stfShadowColor, stfShadowOffset, stfGlowSize);
  TStyleTextFlags = set of TStyleTextFlag;

  TStyleTextOptions = record
    Flags: TStyleTextFlags;
    TextColor: TColor;
    BorderColor: TColor;
    BorderSize: Integer;
    ShadowColor: TColor;
    ShadowOffset: TPoint;
    GlowSize: Integer;
  end;

const
  COptions: Array[TStyleTextFlag] of Cardinal = (DTT_TEXTCOLOR, DTT_BORDERCOLOR, DTT_BORDERSIZE, DTT_SHADOWCOLOR, DTT_SHADOWOFFSET, DTT_GLOWSIZE);
{$IFEND}
{$ENDREGION}

const
  HAlignments: Array[TAlignment] of Longint = (DT_LEFT, DT_RIGHT, DT_CENTER);
  VAlignments: Array[TVerticalAlignment] of Longint = (DT_TOP, DT_BOTTOM, DT_VCENTER);
{$IF CompilerVersion > 29}
  CStates: Array[Boolean] of TThemedTextLabel = (ttlTextLabelDisabled, ttlTextLabelNormal);
{$IFEND}
  BumpMapSize = 320;

var
  BumpMap: Array [0..BumpMapSize - 1, 0..BumpMapSize - 1] of Byte;
  BumpMapInited: Boolean;

function PointInRect(const X, Y: Integer; const Rect: TRect): Boolean;
begin
  Result := (X >= Rect.Left) and (X <= Rect.Right) and
            (Y >= Rect.Top ) and (Y <= Rect.Bottom);
end;

function PointInRect(const p: TPoint; const Rect: TRect): Boolean;
begin
  Result := PointInRect(p.X, p.Y, Rect);
end;

function PointInRect(const p: TSmallPoint; const Rect: TRect): Boolean;
begin
  Result := PointInRect(p.x, p.y, Rect);
end;

procedure GetCenterPos(Width, Height: Integer; Rect: TRect; out X, Y: Integer);
begin
  X := Rect.Left + (Rect.Width - Width) div 2;
  Y := Rect.Top + (Rect.Height - Height) div 2;
end;

{$REGION 'Compatible code'}
{$IF CompilerVersion <= 30}
function TextFlagsToTextFormat(Value: Cardinal): TTextFormat;
begin
  Result := [];
  if (Value and DT_BOTTOM) = DT_BOTTOM then
    Include(Result, tfBottom);
  if (Value and DT_CALCRECT) = DT_CALCRECT then
    Include(Result, tfCalcRect);
  if (Value and DT_CENTER) = DT_CENTER then
    Include(Result, tfCenter);
  if (Value and DT_EDITCONTROL) = DT_EDITCONTROL then
    Include(Result, tfEditControl);
  if (Value and DT_END_ELLIPSIS) = DT_END_ELLIPSIS then
    Include(Result, tfEndEllipsis);
  if (Value and DT_PATH_ELLIPSIS) = DT_PATH_ELLIPSIS then
    Include(Result, tfPathEllipsis);
  if (Value and DT_EXPANDTABS) = DT_EXPANDTABS then
    Include(Result, tfExpandTabs);
  if (Value and DT_EXTERNALLEADING) = DT_EXTERNALLEADING then
    Include(Result, tfExternalLeading);
  if (Value and DT_LEFT) = DT_LEFT then
    Include(Result, tfLeft);
  if (Value and DT_MODIFYSTRING) = DT_MODIFYSTRING then
    Include(Result, tfModifyString);
  if (Value and DT_NOCLIP) = DT_NOCLIP then
    Include(Result, tfNoClip);
  if (Value and DT_NOPREFIX) = DT_NOPREFIX then
    Include(Result, tfNoPrefix);
  if (Value and DT_RIGHT) = DT_RIGHT then
    Include(Result, tfRight);
  if (Value and DT_RTLREADING) = DT_RTLREADING then
    Include(Result, tfRtlReading);
  if (Value and DT_SINGLELINE) = DT_SINGLELINE then
    Include(Result, tfSingleLine);
  if (Value and DT_TOP) = DT_TOP then
    Include(Result, tfTop);
  if (Value and DT_VCENTER) = DT_VCENTER then
    Include(Result, tfVerticalCenter);
  if (Value and DT_WORDBREAK) = DT_WORDBREAK then
    Include(Result, tfWordBreak);
  if (Value and DT_HIDEPREFIX) = DT_HIDEPREFIX then
    Include(Result, tfHidePrefix);
  if (Value and DT_NOFULLWIDTHCHARBREAK) = DT_NOFULLWIDTHCHARBREAK then
    Include(Result, tfNoFullWidthCharBreak);
  if (Value and DT_PREFIXONLY) = DT_PREFIXONLY then
    Include(Result, tfPrefixOnly);
  if (Value and DT_TABSTOP) = DT_TABSTOP then
    Include(Result, tfTabStop);
  if (Value and DT_WORD_ELLIPSIS) = DT_WORD_ELLIPSIS then
    Include(Result, tfWordEllipsis);
  if (Value and MASK_TF_COMPOSITED) = MASK_TF_COMPOSITED then
    Include(Result, tfComposited);
end;

function StyleTextOptionsToDTTOpts(Options: TStyleTextOptions; Flags: TTextFormat): TDTTOpts;
var
  LTextOption: TStyleTextFlag;
begin
  FillChar(Result, SizeOf(TDTTOpts), 0);
  Result.dwSize := SizeOf(TDTTOpts);
  //
  for LTextOption := Low(TStyleTextFlag) to High(TStyleTextFlag) do begin
    if (LTextOption in Options.Flags) then
      Result.dwFlags := Result.dwFlags or COptions[LTextOption];
  end;
  //
  Result.crText         := Graphics.ColorToRGB(Options.TextColor);
  Result.crBorder       := Graphics.ColorToRGB(Options.BorderColor);
  Result.iBorderSize    := Options.BorderSize;
  Result.crShadow       := Graphics.ColorToRGB(Options.ShadowColor);
  Result.ptShadowOffset := Options.ShadowOffset;
  Result.iGlowSize      := Options.GlowSize;
  if (tfComposited in Flags) then
    Result.dwFlags := Result.dwFlags or DTT_COMPOSITED;
  if (tfCalcRect in Flags) then
    Result.dwFlags := Result.dwFlags or DTT_CALCRECT;
end;

procedure DrawGlassText(Canvas: TCanvas; GlowSize: Integer; var Rect: TRect; var Text: String; Format: DWORD; Options: TStyleTextOptions); overload;
var
  DTTOpts: TDTTOpts;
begin
  if Win32MajorVersion < 6 then begin
    DrawTextW(Canvas.Handle, PWideChar(Text), Length(Text), Rect, Format);
    Exit;
  end;
  DTTOpts:=StyleTextOptionsToDTTOpts(Options, TextFlagsToTextFormat(Format));
  with ThemeServices.GetElementDetails(teEditTextNormal) do
    DrawThemeTextEx(ThemeServices.Theme[teEdit], Canvas.Handle, Part, State, PWideChar(Text), Length(Text), Format, @Rect, DTTOpts);
end;

procedure DrawGlassText(Canvas: TCanvas; GlowSize: Integer; var Rect: TRect; var Text: String; TextFormat: TTextFormat; Options: TStyleTextOptions); overload;
const
  cTextFormats: array[TTextFormats] of DWORD = (
    DT_BOTTOM, DT_CALCRECT, DT_CENTER, DT_EDITCONTROL, DT_END_ELLIPSIS, DT_PATH_ELLIPSIS, DT_EXPANDTABS, DT_EXTERNALLEADING, DT_LEFT,
    DT_MODIFYSTRING, DT_NOCLIP, DT_NOPREFIX, DT_RIGHT, DT_RTLREADING, DT_SINGLELINE, DT_TOP, DT_VCENTER, DT_WORDBREAK, DT_HIDEPREFIX,
    DT_NOFULLWIDTHCHARBREAK, DT_PREFIXONLY, DT_TABSTOP, DT_WORD_ELLIPSIS, MASK_TF_COMPOSITED {tfComposited}
  );
var
  Format: DWORD;
  F: TTextFormats;
begin
  Format := 0;
  for F in TextFormat do
    Format := Format or cTextFormats[F];
  DrawGlassText(Canvas, GlowSize, Rect, Text, Format, Options);
end;
{$IFEND}
{$ENDREGION}

procedure DrawTextRect(const Canvas: TCanvas; HAlign: TAlignment; VAlign: TVerticalAlignment; Rect: TRect; Text: string; TextOnGlass: Boolean);
var
  Flags: Cardinal;
  LFormat: TTextFormat;
  LOptions: TStyleTextOptions;
begin
  Flags := DT_EXPANDTABS or DT_SINGLELINE or HAlignments[HAlign] or VAlignments[VAlign];

  if not TextOnGlass then
    DrawText(Canvas.Handle, Text, Length(Text), Rect, Flags)
  else begin
  {$IF CompilerVersion <= 30}
    LFormat := TextFlagsToTextFormat(Flags);
  {$ELSE}
    LFormat := TTextFormatFlags(Flags);
  {$IFEND}

    LOptions.Flags := [stfTextColor, stfGlowSize];
    LOptions.TextColor := Canvas.Font.Color;
    LOptions.GlowSize := DEFAULT_GLASSTEXT_GLOWSIZE;

  {$IF CompilerVersion <= 30}
    //GetThemeInt() // TMT_TEXTGLOWSIZE
    DrawGlassText(Canvas, DEFAULT_GLASSTEXT_GLOWSIZE, Rect, Text, LFormat, LOptions);
  {$ELSE}
    Include(LFormat, tfComposited);
    StyleServices.DrawText(Canvas.Handle, StyleServices.GetElementDetails(ttlTextLabelNormal), Text, Rect, LFormat, LOptions);
  {$IFEND}
  end;
end;

procedure DrawBorder(const Canvas: TCanvas; R: TRect; Color: TColor; Thickness: Byte);
var
  TL, BR: Byte;
begin
  if Thickness <> 0 then begin
    TL := Thickness div 2;
    if Thickness mod 2 = 0 then
      BR := TL - 1
    else
      BR := TL;

    Canvas.Pen.Color := Color;
    Canvas.Pen.Width := Thickness;
    Canvas.Rectangle(Rect(TL, TL, R.Width - BR, R.Height - BR));
  end;
end;

function Mix(A, B: Byte): Byte;
var
  C: Integer;
begin
  C:=A + B;
  if C > 255 then
    C:=255;
  Result:=C;
end;

procedure MulColor(var AColor: PQuadColor; Base: Byte); inline;
begin
  AColor.Blue  := Mix(AColor.Blue,  Base);
  AColor.Green := Mix(AColor.Green, Base);
  AColor.Red   := Mix(AColor.Red,   Base);
  //AColor.Alpha := AColor.Alpha;
end;

procedure InitBumpMap;
var
  x, y: Integer;
  cx, cy: Integer;
  half_size: Integer;
  sq: Real;
begin
  if BumpMapInited then
    Exit;

  half_size:=BumpMapSize div 2;
  for y:=0 to BumpMapSize - 1 do begin
    for x:=0 to BumpMapSize - 1 do begin
      cx:=x - half_size;
      cy:=y - half_size;
      sq:=Round(sqrt((cx*cx) + (cy*cy)));
      if sq > 120 then
        sq:=120;
      sq:=120 - sq;
      //sq:=sq / 1.75;
      BumpMap[y, x]:=Trunc(sq);
    end;
  end;

  BumpMapInited := True;
end;

procedure DrawBumpMap(const Canvas: TCanvas; X, Y: Integer);
var
  bmp: TBitmap;
  ax, ay, half_size: Integer;
  Pixel: PQuadColor;
begin
  bmp:=TBitmap.Create;
  try
    half_size:=BumpMapSize div 2;
    bmp.PixelFormat:=pf32bit;
    bmp.SetSize(BumpMapSize, BumpMapSize);
    bmp.Canvas.CopyMode:=SRCCOPY;
    bmp.Canvas.CopyRect(Rect(0, 0, BumpMapSize, BumpMapSize), Canvas, Rect(X - half_size, Y - half_size, X + half_size, Y + half_size));

    for ay:=0 to BumpMapSize - 1 do begin
      Pixel := bmp.ScanLine[ay];
      for ax:=0 to BumpMapSize - 1 do begin
        MulColor(Pixel, BumpMap[ay, ax]);
        Inc(Pixel);
      end;
    end;

    Canvas.Draw(X - half_size, Y - half_size, bmp);
  finally
    bmp.Free;
  end;
end;

initialization
  DEFAULT_GLASSTEXT_GLOWSIZE := 0;
  BumpMapInited := False;

end.
