unit UCL.Types;

interface

{$IF CompilerVersion > 29}
  {$LEGACYIFEND ON}
{$IFEND}

uses
  Classes,
{$IF CompilerVersion <= 30}
  Windows,
  Forms,
{$IFEND}
  Controls,
  Graphics,
  ImgList,
  Types;

//type
//  // our data types
//  TU_SInt8  = type ShortInt;
//  TU_UInt8  = type Byte;
//  TU_SInt16 = type SmallInt;
//  TU_UInt16 = type Word;
//  TU_SInt32 = type Integer;
//  TU_UInt32 = type LongWord;

{$REGION 'Older Delphi versions'}
{$IF CompilerVersion <= 30}
const
  {$EXTERNALSYM WM_DPICHANGED}
  WM_DPICHANGED       = $02E0;

type
  TDWordFiller = Array[1..4] of Byte; // Pad DWORD to make it 8 bytes (4+4) [x64 only]

  PRect = ^TRect;

  TWMDpi = record
    Msg: Cardinal;
  {$IFDEF CPUX64}
    MsgFiller: TDWordFiller;
  {$ENDIF}
    YDpi: Word;
    XDpi: Word;
  {$IFDEF CPUX64}
    WParamFiller: TDWordFiller;
  {$ENDIF}
    ScaledRect: PRECT;
    Result: LRESULT;
  end;

  TMonitorHelper = class helper for TMonitor
  private
    function GetPixelsPerInch: Integer;
  public
    property PixelsPerInch: Integer read GetPixelsPerInch;
  end;

  TRectHelper = record helper for TRect
  private
    function GetWidth: Integer;
    procedure SetWidth(const Value: Integer);
    function GetHeight: Integer;
    procedure SetHeight(const Value: Integer);
    function GetSize: TSize;
    procedure SetSize(const Value: TSize);
  public
    class function Empty: TRect; inline; static;
    function IsEmpty: Boolean;
    function Contains(const Pt: TPoint): Boolean; overload;
    function Contains(const R: TRect): Boolean; overload;
    function IntersectsWith(const R: TRect): Boolean;
    class function Intersect(const R1: TRect; const R2: TRect): TRect; overload; static;
    procedure Intersect(const R: TRect); overload;
    class function Union(const R1: TRect; const R2: TRect): TRect; overload; static;
    procedure Union(const R: TRect); overload;
    procedure Offset(const DX, DY: Integer); overload;
    procedure Offset(const Point: TPoint); overload;
    procedure Inflate(const DX, DY: Integer); overload;
    procedure Inflate(const DL, DT, DR, DB: Integer); overload;
    function CenterPoint: TPoint;
    //
    property Width: Integer read GetWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;
    property Size: TSize read GetSize write SetSize;
  end;

  TPointHelper = record helper for TPoint
  public
    class function Zero: TPoint; inline; static;

    procedure SetLocation(const X, Y : Integer); overload;
    procedure SetLocation(const P : TPoint); overload;
    procedure Offset(const DX, DY : Integer); overload;
    procedure Offset(const Point: TPoint); overload;
    function Add(const Point: TPoint): TPoint;
    function Subtract(const Point: TPoint): TPoint;
    function IsZero : Boolean;
  end;
{$IFEND}
{$ENDREGION}

const
  EmptyPoint: TPoint = (X: 0; Y: 0);
  EmptyRect: TRect = (Left: 0; Top: 0; Right: 0; Bottom: 0);

type
  TUTheme = (utLight, utDark); // system theme
  TUThemeType = (ttSystem, ttLight, ttDark, ttCustomLight, ttCustomDark); // user selected theme

{$REGION 'TUBaseThemeManager'}
  TUBaseThemeManager = class abstract(TComponent)
  protected
    FTheme: TUThemeType;

    procedure SetTheme(Value: TUThemeType); virtual; abstract;

  public
    function ThemeUsed: TUTheme; virtual; abstract;

    property Theme: TUThemeType read FTheme write SetTheme default ttSystem;
  end;
{$ENDREGION}

  TUOrientation = (oHorizontal, oVertical);

  TUDirection = (dLeft, dTop, dRight, dBottom);

  TUControlState = (csNone, csHover, csPress, csDisabled, csFocused{, csFocusedHover, csFocusedPress});

  //TUButtonState = (ubsNone, ubsHover, ubsPress);
  //TUButtonSelectionState = (ubssNormal, ubssSelected);

  TUImageKind = (ikFontIcon, ikImage);

//  TDefColor = array [TUTheme, TUControlState] of TColor;

  AccentPolicy = packed record
    AccentState: Integer;
    AccentFlags: Integer;
    GradientColor: Integer;
    AnimationId: Integer;
  end;

  WindowCompositionAttributeData = packed record
    Attribute: Cardinal;
    Data: Pointer;
    SizeOfData: Integer;
  end;

  TQuadColor = packed record
    case Boolean of
      True: (Blue, Green, Red, Alpha: Byte);
      False: (Quad: Cardinal);
  end;

  PQuadColor = ^TQuadColor;
  PPQuadColor = ^PQuadColor;

  TCustomImageListHelper = class helper for TCustomImageList
  public
    procedure Draw(Index: Integer; Canvas: TCanvas; X, Y: Integer; Enabled: Boolean = True); overload;
    procedure Draw(Index: Integer; Canvas: TCanvas; X, Y: Integer; Style: Cardinal; Enabled: Boolean = True); overload;
    procedure Draw(Index: Integer; Canvas: TCanvas; X, Y: Integer; ADrawingStyle: TDrawingStyle; AImageType: TImageType; Enabled: Boolean = True); overload;
  end;

implementation

{$REGION 'Older Delphi versions'}
{$IF CompilerVersion <= 30}
uses
  SysUtils,
  CommCtrl,
  UCL.ShellUIScaling;

{ TMonitorHelper }

function TMonitorHelper.GetPixelsPerInch: Integer;
var
  Ydpi: Cardinal;
  Xdpi: Cardinal;
  DC: HDC;
begin
  if CheckWin32Version(6, 3) then begin
    if GetDpiForMonitor(Handle, TMonitorDpiType.MDT_EFFECTIVE_DPI, Ydpi, Xdpi) = S_OK then
      Result := Ydpi
    else
      Result := 0;
  end
  else begin
    DC := GetDC(0);
    Result := GetDeviceCaps(DC, LOGPIXELSY);
    ReleaseDC(0, DC);
  end;
end;

{ TRectHelper }

function TRectHelper.GetWidth: Integer;
begin
  Result := Self.Right - Self.Left;
end;

procedure TRectHelper.SetWidth(const Value: Integer);
begin
  Self.Right := Self.Left + Value;
end;

function TRectHelper.GetHeight: Integer;
begin
  Result := Self.Bottom - Self.Top;
end;

procedure TRectHelper.SetHeight(const Value: Integer);
begin
  Self.Bottom := Self.Top + Value;
end;

function TRectHelper.GetSize: TSize;
begin
  Result.cx := Width;
  Result.cy := Height;
end;

procedure TRectHelper.SetSize(const Value: TSize);
begin
  Width := Value.cx;
  Height := Value.cy;
end;

class function TRectHelper.Empty: TRect;
begin
  Result := Rect(0, 0, 0, 0);
end;

function TRectHelper.IsEmpty: Boolean;
begin
  Result := IsRectEmpty(Self);
end;

function PtInRect(const Rect: TRect; const P: TPoint): Boolean;
begin
  Result := (P.X >= Rect.Left) and (P.X < Rect.Right) and (P.Y >= Rect.Top) and (P.Y < Rect.Bottom);
end;

function TRectHelper.Contains(const PT: TPoint): Boolean;
begin
  Result := PtInRect(self, PT);
end;

function TRectHelper.Contains(const R: TRect): Boolean;
begin
  Result := (Self.Left <= R.Left)
        and (Self.Right >= R.Right)
        and (Self.Top <= R.Top)
        and (Self.Bottom >= R.Bottom);
end;

function TRectHelper.IntersectsWith(const R: TRect): Boolean;
begin
  Result := (Self.Left < R.Right)
        and (Self.Right > R.Left)
        and (Self.Top < R.Bottom)
        and (Self.Bottom > R.Top);
end;

class function TRectHelper.Intersect(const R1: TRect; const R2: TRect): TRect;
begin
  IntersectRect(Result, R1, R2);
end;

procedure TRectHelper.Intersect(const R: TRect);
begin
  Self := Intersect(Self, R);
end;

class function TRectHelper.Union(const R1: TRect; const R2: TRect): TRect;
begin
  UnionRect(Result, R1, R2);
end;

procedure TRectHelper.Union(const R: TRect);
begin
  Self := Union(Self, R);
end;

procedure TRectHelper.Offset(const DX, DY: Integer);
begin
  TopLeft.Offset(DX, DY);
  BottomRight.Offset(DX, DY);
end;

procedure TRectHelper.Offset(const Point: TPoint);
begin
  TopLeft.Offset(Point);
  BottomRight.Offset(Point);
end;

procedure TRectHelper.Inflate(const DX, DY: Integer);
begin
  TopLeft.Offset(-DX, -DY);
  BottomRight.Offset(DX, DY);
end;

procedure TRectHelper.Inflate(const DL, DT, DR, DB: Integer);
begin
  TopLeft.Offset(-DL, -DT);
  BottomRight.Offset(DR, DB);
end;

function TRectHelper.CenterPoint: TPoint;
begin
  Result.X := (Right - Left) div 2 + Left;
  Result.Y := (Bottom - Top) div 2 + Top;
end;

{ TPointHelper }

class function TPointHelper.Zero: TPoint;
begin
  Result.X := 0;
  Result.Y := 0;
end;

procedure TPointHelper.SetLocation(const X, Y: Integer);
begin
  Self.X := X;
  Self.Y := Y;
end;

procedure TPointHelper.SetLocation(const P: TPoint);
begin
  Self := P;
end;

procedure TPointHelper.Offset(const DX, DY: Integer);
begin
  Inc(Self.X, DX);
  Inc(Self.Y, DY);
end;

procedure TPointHelper.Offset(const Point: TPoint);
begin
  Self.Offset(Point.X, Point.Y);
end;

function TPointHelper.Add(const Point: TPoint): TPoint;
begin
  Result.SetLocation(Self.X + Point.X, Self.Y + Point.Y);
end;

function TPointHelper.Subtract(const Point: TPoint): TPoint;
begin
  Result.SetLocation(Self.X - Point.X, Self.Y - Point.Y);
end;

function TPointHelper.IsZero: Boolean;
begin
  Result := (X = 0) and (Y = 0);
end;

{$IFEND}
{$ENDREGION}
{$IF CompilerVersion > 30}
uses
  SysUtils,
  CommCtrl;
{$IFEND}

{ TCustomImageListHelper }

procedure TCustomImageListHelper.Draw(Index: Integer; Canvas: TCanvas; X, Y: Integer; Enabled: Boolean);
begin
  Draw(Index, Canvas, X, Y, DrawingStyle, ImageType, Enabled);
end;

procedure TCustomImageListHelper.Draw(Index: Integer; Canvas: TCanvas; X, Y: Integer; Style: Cardinal; Enabled: Boolean);

  function GetRGBColor(Value: TColor): Cardinal;
  begin
    Result := ColorToRGB(Value);
    case Result of
      clNone: Result := CLR_NONE;
      clDefault: Result := CLR_DEFAULT;
    end;
  end;

var
  Options: TImageListDrawParams;
begin
  if Enabled or (ColorDepth <> cd32Bit) then
    Draw(Canvas, X, Y, Index, Enabled)
  else if HandleAllocated then begin
    FillChar(Options, SizeOf(Options), 0);
    Options.cbSize := SizeOf(Options);
    Options.himl := Self.Handle;
    Options.i := Index;
    Options.hdcDst := Canvas.Handle;
    Options.x := X;
    Options.y := Y;
    Options.cx := 0;
    Options.cy := 0;
    Options.xBitmap := 0;
    Options.yBitmap := 0;
    Options.rgbBk := GetRGBColor(BkColor);
    Options.rgbFg := GetRGBColor(BlendColor);
    Options.fStyle := Style;
    Options.fState := ILS_SATURATE; // Grayscale for 32bit images

    ImageList_DrawIndirect(@Options);
  end;
end;

procedure TCustomImageListHelper.Draw(Index: Integer; Canvas: TCanvas; X, Y: Integer; ADrawingStyle: TDrawingStyle; AImageType: TImageType; Enabled: Boolean);
const
  DrawingStyles: Array[TDrawingStyle] of Longint = (ILD_FOCUS, ILD_SELECTED, ILD_NORMAL, ILD_TRANSPARENT);
  Images: Array[TImageType] of Longint = (0, ILD_MASK);
begin
  Draw(Index, Canvas, X, Y, DrawingStyles[ADrawingStyle] or Images[AImageType], Enabled);
end;

end.
