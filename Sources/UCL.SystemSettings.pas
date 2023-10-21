unit UCL.SystemSettings;

interface

uses
  Registry,
  Windows,
  Graphics;

function GetAccentColor: TColor;
function IsColorOnBorderEnabled: Boolean;
function IsColorOnSurfaceEnabled: Boolean;
function IsAppsUseDarkTheme: Boolean;
function IsSystemUseDarkTheme: Boolean;
function IsTransparencyEnabled: Boolean;
function GetMouseScrollLinesNumber: Integer;

type
  TWindowRoundedCornerType = (
    rctDefault, // Windows default or global app setting
    rctOff,     // disabled
    rctOn,      // active
    rctSmall    // active small size
  );

// More information:
//   https://docs.microsoft.com/en-us/windows/apps/desktop/modernize/apply-rounded-corners
//   https://docs.microsoft.com/en-us/windows/win32/api/dwmapi/ne-dwmapi-dwmwindowattribute
//   https://docs.microsoft.com/en-us/windows/win32/api/dwmapi/nf-dwmapi-dwmsetwindowattribute
const
  DWMWCP_DEFAULT    = 0; // Let the system decide whether or not to round window corners
  DWMWCP_DONOTROUND = 1; // Never round window corners
  DWMWCP_ROUND      = 2; // Round the corners if appropriate
  DWMWCP_ROUNDSMALL = 3; // Round the corners if appropriate, with a small radius

  DWMWA_WINDOW_CORNER_PREFERENCE = 33; // [set] WINDOW_CORNER_PREFERENCE, Controls the policy that rounds top-level window corners

function  GetWindowRoundedCornerPreference(const Value: TWindowRoundedCornerType): Cardinal;
//function  GetWindowRoundedCornerDefaultPreference(const Wnd: HWND): Cardinal;
procedure SetWindowRoundedCorner(const Wnd: HWND; const WindowCornerType: TWindowRoundedCornerType);

implementation

uses
  Dwmapi;

function GetAccentColor: TColor;
var
  R: TRegistry;
  ARGB: Cardinal;
begin
  Result := $D77800;  //  Default value on error

  R := TRegistry.Create;
  try
    R.RootKey := HKEY_CURRENT_USER;

    if R.OpenKeyReadOnly('Software\Microsoft\Windows\DWM\') and R.ValueExists('AccentColor') then begin
      ARGB := R.ReadInteger('AccentColor');
      Result := ARGB mod $FF000000; //  ARGB to RGB
    end;
  finally
    R.Free;
  end;
end;

function IsColorOnBorderEnabled: Boolean;
var
  R: TRegistry;
begin
  Result := False;

  R := TRegistry.Create;
  try
    R.RootKey := HKEY_CURRENT_USER;

    if R.OpenKeyReadOnly('Software\Microsoft\Windows\DWM\') and R.ValueExists('ColorPrevalence') then begin
      Result := R.ReadInteger('ColorPrevalence') <> 0;
    end;
  finally
    R.Free;
  end;
end;

function IsColorOnSurfaceEnabled: Boolean;
var
  R: TRegistry;
begin
  Result := False;

  R := TRegistry.Create;
  try
    R.RootKey := HKEY_CURRENT_USER;

    if R.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\') and R.ValueExists('ColorPrevalence') then begin
      Result := R.ReadInteger('ColorPrevalence') <> 0;
    end;
  finally
    R.Free;
  end;
end;

function IsAppsUseDarkTheme: Boolean;
var
  R: TRegistry;
begin
  Result := False;

  R := TRegistry.Create;
  try
    R.RootKey := HKEY_CURRENT_USER;

    if R.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\') and R.ValueExists('AppsUseLightTheme') then begin
      Result := R.ReadInteger('AppsUseLightTheme') <> 1;
    end;
  finally
    R.Free;
  end;
end;

function IsSystemUseDarkTheme: Boolean;
var
  R: TRegistry;
begin
  Result := False;

  R := TRegistry.Create;
  try
    R.RootKey := HKEY_CURRENT_USER;

    if R.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\') and R.ValueExists('SystemUsesLightTheme') then begin
      Result := R.ReadInteger('SystemUsesLightTheme') <> 1;
    end;
  finally
    R.Free;
  end;
end;

function IsTransparencyEnabled: Boolean;
var
  R: TRegistry;
begin
  Result := False;

  R := TRegistry.Create;
  try
    R.RootKey := HKEY_CURRENT_USER;

    if R.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\') and R.ValueExists('EnableTransparency') then begin
      Result := R.ReadInteger('EnableTransparency') <> 1;
    end;
  finally
    R.Free;
  end;
end;

function GetMouseScrollLinesNumber: Integer;
begin
  SystemParametersInfo(SPI_GETWHEELSCROLLLINES, 0, @Result, 0);
end;

function  GetWindowRoundedCornerPreference(const Value: TWindowRoundedCornerType): Cardinal;
begin
  case Value of
    rctOff  : Result := DWMWCP_DONOTROUND;
    rctOn   : Result := DWMWCP_ROUND;
    rctSmall: Result := DWMWCP_ROUNDSMALL;
  else
    Result := DWMWCP_DEFAULT;
  end;
end;

procedure SetWindowRoundedCorner(const Wnd: HWND; const WindowCornerType: TWindowRoundedCornerType);
var
  DWM_WINDOW_CORNER_PREFERENCE: Cardinal;
begin
  case WindowCornerType of
    rctOff  : DWM_WINDOW_CORNER_PREFERENCE := DWMWCP_DONOTROUND;
    rctOn   : DWM_WINDOW_CORNER_PREFERENCE := DWMWCP_ROUND;
    rctSmall: DWM_WINDOW_CORNER_PREFERENCE := DWMWCP_ROUNDSMALL;
  else
    DWM_WINDOW_CORNER_PREFERENCE := DWMWCP_DEFAULT;
  end;
  Dwmapi.DwmSetWindowAttribute(Wnd, DWMWA_WINDOW_CORNER_PREFERENCE, @DWM_WINDOW_CORNER_PREFERENCE, SizeOf(DWM_WINDOW_CORNER_PREFERENCE));
end;

end.
