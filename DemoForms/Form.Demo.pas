﻿unit Form.Demo;

interface

uses
  //  UCL units
  UCL.TUThemeManager,
  UCL.IntAnimation, UCL.IntAnimation.Helpers,
  UCL.Utils, UCL.Classes, UCL.SystemSettings,
  UCL.TUForm, UCL.TUScrollBox, UCL.TUCheckBox, UCL.TUProgressBar, UCL.TUHyperLink,
  UCL.TUPanel, UCL.TUSymbolButton, UCL.TUButton, UCL.TUText, UCL.TUCaptionBar,
  UCL.TUSlider, UCL.TUSeparator, UCL.TUEdit, UCL.TUItemButton, UCL.TUQuickButton,
  UCL.TUPopupMenu, UCL.TURadioButton, UCL.TUShadow, UCL.TUSmoothBox,

  //  Winapi units
  Windows, Messages,

  //  System units
  SysUtils, Variants, Classes, Types,
{$IF CompilerVersion > 29}
  ImageList,
{$IFEND}

  //  VCL units
  Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  Menus, Buttons, ImgList, pngimage, jpeg;

type
  TformDemo = class(TUForm)
    drawerNavigation: TUPanel;
    buttonOpenMenu: TUSymbolButton;
    buttonMenuSettings: TUSymbolButton;
    buttonMenuProfile: TUSymbolButton;
    buttonMenuSave: TUSymbolButton;
    buttonMenuOpen: TUSymbolButton;
    buttonMenuRate: TUSymbolButton;
    captionbarNewStyle: TUCaptionBar;
    dialogSelectColor: TColorDialog;
    panelRibbon: TUSmoothBox;
    buttonGoBack: TUSymbolButton;
    separator1: TUSeparator;
    buttonGoHome: TUSymbolButton;
    buttonNewDoc: TUSymbolButton;
    buttonOpenDoc: TUSymbolButton;
    buttonLoginForm: TUSymbolButton;
    buttonSaveDoc: TUSymbolButton;
    separator2: TUSeparator;
    linkConnected: TUHyperLink;
    linkCustomColor: TUHyperLink;
    linkDisabled: TUHyperLink;
    buttonNoFocus: TUButton;
    buttonCanFocus: TUButton;
    buttonCustomColor: TUButton;
    buttonReloadSettings: TUSymbolButton;
    buttonHighlight: TUButton;
    buttonDisabled: TUButton;
    buttonToggle: TUButton;
    radioA1: TURadioButton;
    radioA2: TURadioButton;
    radioA3: TURadioButton;
    radioB1: TURadioButton;
    radioB2: TURadioButton;
    check2State: TUCheckBox;
    check3State: TUCheckBox;
    itembuttonImage: TUItemButton;
    itembuttonFontIcon: TUItemButton;
    symbolButtonOpenDisabled: TUSymbolButton;
    symbolbuttonSaveHorz: TUSymbolButton;
    symbolbuttonSaveVert: TUSymbolButton;
    progressVert: TUProgressBar;
    buttonRandomProgress: TUButton;
    progressCustomColor: TUProgressBar;
    progressConnected: TUProgressBar;
    textDescription: TUText;
    textNormal: TUText;
    textEntry: TUText;
    textHeading: TUText;
    textTitle: TUText;
    buttonRunning: TButton;
    buttonAniStart: TButton;
    buttonAniInverse: TButton;
    buttonWithImage: TUButton;
    sliderHorz: TUSlider;
    sliderDisabled: TUSlider;
    sliderVert: TUSlider;
    buttonAppBack: TUQuickButton;
    buttonWinClose: TUQuickButton;
    buttonWinMax: TUQuickButton;
    buttonWinMin: TUQuickButton;
    comboAppDPI: TComboBox;
    boxSmoothScrolling: TUSmoothBox;
    headingSettings: TUText;
    entryAppTheme: TUText;
    radioSystemTheme: TURadioButton;
    radioLightTheme: TURadioButton;
    radioDarkTheme: TURadioButton;
    panelSelectAccentColor: TUPanel;
    checkColorBorder: TUCheckBox;
    entryUserProfile: TUText;
    imgAvatar: TImage;
    checkAutoSync: TUCheckBox;
    checkKeepEmailPrivate: TUCheckBox;
    checkSendEmail: TUCheckBox;
    buttonDeleteAccount: TUButton;
    entryAccountType: TUText;
    radioFreeAccount: TURadioButton;
    radioProAccount: TURadioButton;
    radioDevAccount: TURadioButton;
    desAccountHint: TUText;
    buttonUpgradeAccount: TUButton;
    entryStorage: TUText;
    desStorageHint: TUText;
    progressStorageUsed: TUProgressBar;
    headingAbout: TUText;
    buttonCheckUpdate: TUButton;
    desAppVersion: TUText;
    desFlashVersion: TUText;
    desChromiumVersion: TUText;
    linkEmbarcadero: TUHyperLink;
    separatorLastBox: TUSeparator;
    editAccountName: TUEdit;
    comboAppBorderStyle: TComboBox;
    buttonImageForm: TUSymbolButton;
    popupEdit: TUPopupMenu;
    CutCtrlX1: TMenuItem;
    CopyCtrlC1: TMenuItem;
    PasteCtrlV1: TMenuItem;
    buttonAppListForm: TUSymbolButton;
    procedure buttonReloadSettingsClick(Sender: TObject);
    procedure buttonAniStartClick(Sender: TObject);
    procedure buttonRandomProgressClick(Sender: TObject);
    procedure buttonAniInverseClick(Sender: TObject);
    procedure buttonOpenMenuClick(Sender: TObject);
    procedure radioSystemThemeClick(Sender: TObject);
    procedure radioLightThemeClick(Sender: TObject);
    procedure radioDarkThemeClick(Sender: TObject);
    procedure panelSelectAccentColorClick(Sender: TObject);
    procedure buttonMenuSettingsClick(Sender: TObject);
    procedure sliderHorzChange(Sender: TObject);
    procedure comboAppDPIChange(Sender: TObject);
    procedure itembuttonImageClick(Sender: TObject);
    procedure buttonLoginFormClick(Sender: TObject);
    procedure comboAppBorderStyleChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure popupEditItemClick(Sender: TObject; Index: Integer);
    procedure buttonImageFormClick(Sender: TObject);
    procedure buttonHighlightClick(Sender: TObject);
    procedure buttonAppListFormClick(Sender: TObject);
    procedure buttonNoFocusClick(Sender: TObject);

  private

  public
    procedure FocusControl(const Control: TControl);

  end;

var
  formDemo: TformDemo;

implementation

uses
  DataModule.Main,
  Form.LoginDialog, Form.ImageBackground, Form.AppList;

{$R *.dfm}

//  MAIN FORM

procedure TformDemo.FormCreate(Sender: TObject);
begin
//  EnableBlur(Handle, 3);

  ThemeManager := dmMain.AppTheme;
end;

//  ANIMATION TESTING

procedure TformDemo.buttonAniStartClick(Sender: TObject);
var
  AniLength: Integer;
begin
  AniLength := 210;
  AniLength := Round(AniLength * PPI / 96); //  Scale animation length
  buttonRunning.AnimationFromCurrent(apLeft, +AniLength, 25, 250, akOut, afkQuartic,
    procedure
    begin
      buttonRunning.SetFocus;
    end
  );
end;

procedure TformDemo.buttonAniInverseClick(Sender: TObject);
var
  AniLength: Integer;
begin
  AniLength := 210;
  AniLength := Round(AniLength * PPI / 96); //  Scale animation length
  buttonRunning.AnimationFromCurrent(apLeft, -AniLength, 25, 250, akOut, afkQuartic,
    procedure
    begin
      buttonRunning.SetFocus;
    end
  );
end;

procedure TformDemo.buttonOpenMenuClick(Sender: TObject);
var
  DPI: Single;
  Ani: TIntAni;

  AniWidth: Integer;
begin
  DPI := PPI / 96;
  AniWidth := Round((225 - 45 ) * DPI);
  if drawerNavigation.Width <> Trunc(45 * DPI) then
    AniWidth := - AniWidth;

  Ani := TIntAni.Create(true, akOut, afkQuintic, drawerNavigation.Width, AniWidth,
    procedure (V: Integer)
    begin
      drawerNavigation.Width := V;
    end);
  Ani.Step := 30;
  Ani.Duration := 200;
  Ani.Start;
end;

procedure TformDemo.buttonMenuSettingsClick(Sender: TObject);
var
  DPI: Single;
  AniDelta: Integer;
begin
  DPI := Self.PPI / 96;

  boxSmoothScrolling.DisableAlign;
  boxSmoothScrolling.SetOldSBVisible(false);

  if boxSmoothScrolling.Width = 0 then
    AniDelta := Round(DPI * 250)
  else
    AniDelta := - boxSmoothScrolling.Width;

  boxSmoothScrolling.AnimationFromCurrent(apWidth, AniDelta, 30, 200, akOut, afkQuartic,
    procedure begin boxSmoothScrolling.EnableAlign end);
end;

procedure TformDemo.FocusControl(const Control: TControl);
var
  f: TForm;
begin
  f := TUFocusForm.CreateNew(Self);
  f.Parent := Self;
  f.BorderStyle := bsNone;
  f.Color := clFuchsia;
  f.TransparentColor := true;
  f.TransparentColorValue := clFuchsia;

  f.Width := 7 + Control.Width;
  f.Height := 7 + Control.Height;
  f.Show;
  f.Top := Control.Top - 3;
  f.Left := Control.Left - 3;
end;

procedure TformDemo.buttonNoFocusClick(Sender: TObject);
begin
  FocusControl(radioA1);
end;

//  CONTROLS EVENTS

procedure TformDemo.itembuttonImageClick(Sender: TObject);
var
  ObjName: string;
begin
  case itembuttonImage.ObjectSelected of
    iokNone:
      ObjName := 'Background';
    iokCheckBox:
      ObjName := 'Checkbox';
    iokLeftIcon:
      ObjName := 'Left icon';
    iokText:
      ObjName := 'Text';
    iokDetail:
      ObjName := 'Detail';
    iokRightIcon:
      ObjName := 'Right icon';
  end;

  itembuttonImage.Detail := ObjName;
end;

procedure TformDemo.buttonHighlightClick(Sender: TObject);
begin
  ThemeManager.Disconnect(buttonNoFocus);
end;

procedure TformDemo.sliderHorzChange(Sender: TObject);
begin
  //  Change progress bar value
  progressConnected.Value := sliderHorz.Value;
end;

procedure TformDemo.buttonRandomProgressClick(Sender: TObject);
begin
  Randomize;
  progressCustomColor.GoToValue(Random(101));
  progressConnected.GoToValue(Random(101));
  progressVert.GoToValue(Random(101));
end;

//  OPEN FORM

procedure TformDemo.buttonLoginFormClick(Sender: TObject);
begin
  if formLoginDialog = nil then
    Application.CreateForm(TformLoginDialog, formLoginDialog);
  formLoginDialog.Show;
end;

procedure TformDemo.buttonImageFormClick(Sender: TObject);
begin
  if formImageBackground = nil then
    Application.CreateForm(TformImageBackground, formImageBackground);
  formImageBackground.Show;
end;

procedure TformDemo.buttonAppListFormClick(Sender: TObject);
begin
  if formAppList = nil then
    Application.CreateForm(TformAppList, formAppList);
  formAppList.Show;
end;

//  THEME

procedure TformDemo.buttonReloadSettingsClick(Sender: TObject);
begin
  ThemeManager.Reload;
end;

procedure TformDemo.comboAppBorderStyleChange(Sender: TObject);
begin
  case comboAppBorderStyle.ItemIndex of
    0:  BorderStyle := bsDialog;
    1:  BorderStyle := bsSingle;
    2:  BorderStyle := bsSizeable;
    3:  BorderStyle := bsToolWindow;
    4:  BorderStyle := bsSizeToolWin;
  end;
end;

procedure TformDemo.comboAppDPIChange(Sender: TObject);
var
  NewPPI: Integer;
begin
  case comboAppDPI.ItemIndex of
    1: NewPPI := 120;
    2: NewPPI := 144;
    3: NewPPI := 168;
    else
      NewPPI := 96;
  end;

  Self.PPI := NewPPI;
  Self.ScaleForPPI(NewPPI);

  if formAppList <> nil then
    begin
      formAppList.PPI := NewPPI;
      formAppList.ScaleForPPI(NewPPI);
    end;

  if formLoginDialog <> nil then
    begin
      formLoginDialog.PPI := NewPPI;
      formLoginDialog.ScaleForPPI(NewPPI);
    end;

  if formImageBackground <> nil then
    begin
      formImageBackground.PPI := NewPPI;
      formImageBackground.ScaleForPPI(NewPPI);
    end;
end;

procedure TformDemo.panelSelectAccentColorClick(Sender: TObject);
var
  NewColor: TColor;
begin
  //  Open dialog
  if dialogSelectColor.Execute then
    begin
      NewColor := dialogSelectColor.Color;

      //  Change accent color
      ThemeManager.UseSystemAccentColor := false;
      ThemeManager.CustomAccentColor := NewColor;
      ThemeManager.Reload;
    end;
end;

procedure TformDemo.radioSystemThemeClick(Sender: TObject);
begin
  ThemeManager.UseSystemTheme := true;
  ThemeManager.Reload;
end;

procedure TformDemo.radioLightThemeClick(Sender: TObject);
begin
  ThemeManager.CustomTheme := utLight;
  ThemeManager.UseSystemTheme := false;
  ThemeManager.Reload;
end;

procedure TformDemo.radioDarkThemeClick(Sender: TObject);
begin
  ThemeManager.CustomTheme := utDark;
  ThemeManager.UseSystemTheme := false;
  ThemeManager.Reload;
end;

//  POPUP MENU

procedure TformDemo.popupEditItemClick(Sender: TObject; Index: Integer);
var
  Edit: TCustomEdit;
begin
  Self.SetFocus;  //  Close popup
  if popupEdit.PopupComponent is TCustomEdit then
    begin
      Edit := popupEdit.PopupComponent as TCustomEdit;
      case Index of
        0:  //  Cut
          Edit.CutToClipboard;
        1:  //  Copy
          Edit.CopyToClipboard;
        2:  //  Paste
          Edit.PasteFromClipboard;
      end;
    end;
end;

end.
