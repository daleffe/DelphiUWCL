unit Unit2;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ExtCtrls,
  UCL.Classes,
  UCL.CaptionBar,
  UCL.ScrollBox;

type
  TForm2 = class(TForm)
    UCaptionBar1: TUCaptionBar;
    panelRibbon: TUScrollBox;
    Panel1: TPanel;
    ScrollBox1: TScrollBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

end.
