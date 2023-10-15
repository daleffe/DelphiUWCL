unit Unit1;

interface

uses
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  UCL.Form,
  UCL.ThemeManager,
  ExtCtrls,
  UCL.CaptionBar,
  UCL.QuickButton,
  StdCtrls,
  UCL.Button,
  UCL.SymbolButton,
  UCL.Separator,
  UCL.ScrollBox,
  Menus,
  ImgList,
  ImageList,
  ActnList,
  Actions,
  UCL.ItemButton;

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
    ActImgLst: TImageList;
    ActList: TActionList;
    NewAct: TAction;
    OpenAct: TAction;
    SaveAct: TAction;
    SaveAsAct: TAction;
    PrintPagesAct: TAction;
    CopyAct: TAction;
    CutAct: TAction;
    PasteNewAct: TAction;
    PasteReplaceAct: TAction;
    CloseAct: TAction;
    FirstPageAct: TAction;
    NextPageAct: TAction;
    PrevPageAct: TAction;
    LastPageAct: TAction;
    AddPgScanAct: TAction;
    AddPgFileAct: TAction;
    AddPgsElsAct: TAction;
    InsertPgScanAct: TAction;
    InsertPgFileAct: TAction;
    InsertPgsElsAct: TAction;
    DeletePageAct: TAction;
    RotateLeftAct: TAction;
    RotateRightAct: TAction;
    Rotate180Act: TAction;
    MirrorHAct: TAction;
    MirrorVAct: TAction;
    EffectsAct: TAction;
    SortPagesAct: TAction;
    ExportPgsElsAct: TAction;
    ExportPgsJpgAct: TAction;
    ExportPgsPdfAct: TAction;
    ZoomWidthAct: TAction;
    ZoomAutoAct: TAction;
    ZoomActualAct: TAction;
    ZoomInAct: TAction;
    ZoomOutAct: TAction;
    OptionsAct: TAction;
    InfoAct: TAction;
    FullScreenAct: TAction;
    ShowThumbsAct: TAction;
    ImgFilterAct: TAction;
    ShowScrollAct: TAction;
    ImportPDFAct: TAction;
    RunOCRAct: TAction;
    MainMenu2: TMainMenu;
    PlikMenu: TMenuItem;
    NowyMenu: TMenuItem;
    OtworzMenu: TMenuItem;
    ZapiszMenu: TMenuItem;
    ZapiszjakoMenu: TMenuItem;
    DrukujStroneMenu: TMenuItem;
    Rozpoznajtekst1: TMenuItem;
    ImportujdokumentPDF1: TMenuItem;
    MenuItem1: TMenuItem;
    ExitMenu: TMenuItem;
    EdycjaMenu: TMenuItem;
    KopiujMenu: TMenuItem;
    WytnijMenu: TMenuItem;
    WklejMenu: TMenuItem;
    WklejNowaMenu: TMenuItem;
    WklejZastapMenu: TMenuItem;
    N6: TMenuItem;
    UstawDomyslnMenu: TMenuItem;
    StronaMenu: TMenuItem;
    PierwszaMenu: TMenuItem;
    PoprzedniaMenu: TMenuItem;
    NastepnaMenu: TMenuItem;
    OstatniaMenu: TMenuItem;
    MenuItem2: TMenuItem;
    DodajStroneMenu: TMenuItem;
    AddPageScanMnu: TMenuItem;
    DodajZPlikuMenu: TMenuItem;
    Dodajzplikuskanu1: TMenuItem;
    WstawStroneMenu: TMenuItem;
    WstawSkanujMenu: TMenuItem;
    WstawZPlikuMenu: TMenuItem;
    Wstawzplikuskanu1: TMenuItem;
    UsunStroneMenu: TMenuItem;
    ZamienMiejscMenu: TMenuItem;
    N5: TMenuItem;
    ObrotMenu: TMenuItem;
    ObrocWPrawoMenu: TMenuItem;
    ObrocWLewoMenu: TMenuItem;
    Obroc180Menu: TMenuItem;
    MirrorHorMenu: TMenuItem;
    MirrorVertMenu: TMenuItem;
    EfektyStrMenu: TMenuItem;
    N8: TMenuItem;
    ZapiszStroneMenu: TMenuItem;
    Eksportujstrony1: TMenuItem;
    EksportujJPG: TMenuItem;
    EkportujPDF: TMenuItem;
    WidokMenu: TMenuItem;
    ZoomNaturalMnu: TMenuItem;
    AutoZoomMenu: TMenuItem;
    ZoomSzerMenu: TMenuItem;
    ZoomPlusMenu: TMenuItem;
    ZoomMinusMenu: TMenuItem;
    MenuItem3: TMenuItem;
    ImgFilterMnu: TMenuItem;
    ScrollMnu: TMenuItem;
    MenuItem4: TMenuItem;
    Miniatury1: TMenuItem;
    FullScreenMnu: TMenuItem;
    N7: TMenuItem;
    mnuLanguage: TMenuItem;
    PomocMenu: TMenuItem;
    Oprogramie1: TMenuItem;
    UScrollBox1: TUScrollBox;
    UItemButton1: TUItemButton;
    UItemButton2: TUItemButton;
    UItemButton3: TUItemButton;
    UItemButton4: TUItemButton;
    UItemButton5: TUItemButton;
    UItemButton6: TUItemButton;
    UItemButton7: TUItemButton;
    UItemButton8: TUItemButton;
    UItemButton9: TUItemButton;
    UItemButton10: TUItemButton;
    UItemButton11: TUItemButton;
    UItemButton12: TUItemButton;
    UItemButton13: TUItemButton;
    UItemButton14: TUItemButton;
    UItemButton15: TUItemButton;
    UItemButton16: TUItemButton;
    UItemButton17: TUItemButton;
    UItemButton18: TUItemButton;
    UItemButton19: TUItemButton;
    UItemButton20: TUItemButton;
    procedure FormCreate(Sender: TObject);
  private
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  UCL.SystemSettings;

procedure TForm1.FormCreate(Sender: TObject);
var
  TM: TUCustomThemeManager;
begin
  RoundedCorners := rctOff;
  CaptionBar := UCaptionBar1;
  TM := SelectThemeManager(Self);
//  TM.Theme := ttDark;
  TM.UseColorOnBorder := True;
end;

end.
