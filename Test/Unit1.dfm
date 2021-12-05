object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 319
  ClientWidth = 805
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object UCaptionBar1: TUCaptionBar
    Left = 0
    Top = 0
    Width = 805
    Height = 32
    ThemeManager = UThemeManager1
    Caption = ' Caption bar'
    DoubleBuffered = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 0
    BackColors.Enabled = False
    BackColors.Color = clBlack
    BackColors.LightColor = 15921906
    BackColors.DarkColor = 2829099
    BackColors.FocusedLightColor = 14120960
    BackColors.FocusedDarkColor = 1525760
    Menu = MainMenu1
    MenuOffset = 120
    UseSystemCaptionColor = True
  end
  object panelRibbon: TUScrollBox
    Left = 0
    Top = 32
    Width = 805
    Height = 60
    HorzScrollBar.Tracking = True
    VertScrollBar.Tracking = True
    Align = alTop
    BevelEdges = []
    BevelInner = bvNone
    BevelOuter = bvNone
    Color = 3355443
    ParentColor = False
    TabOrder = 1
    StyleElements = []
    ThemeManager = UThemeManager1
    AniSet.AniKind = akOut
    AniSet.AniFunctionKind = afkQuartic
    AniSet.DelayStartTime = 0
    AniSet.Duration = 120
    AniSet.Step = 6
    AniSet.Queue = True
    BackColor.Enabled = True
    BackColor.Color = clBlack
    BackColor.LightColor = 14342874
    BackColor.DarkColor = 3355443
    ScrollOrientation = oHorizontal
  end
  object UThemeManager1: TUThemeManager
    Theme = ttDark
    AccentColor = 6318152
    Left = 408
    Top = 112
  end
  object MainMenu1: TMainMenu
    Left = 248
    Top = 128
    object File1: TMenuItem
      Caption = 'File'
      object Open1: TMenuItem
        Caption = 'Open file'
      end
      object Close1: TMenuItem
        Caption = 'Close file'
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
      object Cut1: TMenuItem
        Caption = 'Cut'
      end
      object Copy1: TMenuItem
        Caption = 'Copy'
      end
      object Paste1: TMenuItem
        Caption = 'Paste'
      end
      object Delete1: TMenuItem
        Caption = 'Delete'
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Selectall1: TMenuItem
        Caption = 'Select all'
      end
    end
    object Search1: TMenuItem
      Caption = 'Search'
      object Find1: TMenuItem
        Caption = 'Find'
      end
      object Replace1: TMenuItem
        Caption = 'Replace'
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object Repeataction1: TMenuItem
        Caption = 'Repeat action'
      end
    end
    object View1: TMenuItem
      Caption = 'View'
      object Source1: TMenuItem
        Caption = 'Source'
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object Fullscreen1: TMenuItem
        Caption = 'Full screen'
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object About1: TMenuItem
        Caption = 'About'
      end
    end
  end
end
