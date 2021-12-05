unit Unit1;

interface

uses
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  UCL.Form, UCL.ThemeManager, Vcl.ExtCtrls, UCL.CaptionBar, UCL.QuickButton, Vcl.StdCtrls, UCL.Button, UCL.SymbolButton, UCL.Separator, UCL.ScrollBox, Vcl.Menus;

type
  TForm1 = class(TUForm)
    UCaptionBar1: TUCaptionBar;
    UThemeManager1: TUThemeManager;
    panelRibbon: TUScrollBox;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    Close1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    Edit1: TMenuItem;
    Search1: TMenuItem;
    View1: TMenuItem;
    Help1: TMenuItem;
    Copy1: TMenuItem;
    Cut1: TMenuItem;
    Paste1: TMenuItem;
    Delete1: TMenuItem;
    N2: TMenuItem;
    Selectall1: TMenuItem;
    Find1: TMenuItem;
    Replace1: TMenuItem;
    N3: TMenuItem;
    Repeataction1: TMenuItem;
    Source1: TMenuItem;
    About1: TMenuItem;
    N4: TMenuItem;
    Fullscreen1: TMenuItem;
  private
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

end.
