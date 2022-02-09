object formLoginDialog: TformLoginDialog
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Login'
  ClientHeight = 560
  ClientWidth = 410
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 17
  object boxMain: TUScrollBox
    Left = 0
    Top = 32
    Width = 410
    Height = 476
    HorzScrollBar.Tracking = True
    VertScrollBar.Tracking = True
    Align = alClient
    BevelEdges = []
    BevelInner = bvNone
    BevelOuter = bvNone
    Color = 2039583
    Padding.Left = 40
    Padding.Right = 40
    Padding.Bottom = 50
    ParentColor = False
    TabOrder = 0
    AniSet.AniKind = akOut
    AniSet.AniFunctionKind = afkQuartic
    AniSet.DelayStartTime = 0
    AniSet.Duration = 250
    AniSet.Step = 25
    AniSet.Queue = True
    BackColor.Enabled = False
    BackColor.Color = clBlack
    BackColor.LightColor = 15132390
    BackColor.DarkColor = 2039583
    MaxScrollCount = 6
    object titleSignin: TUText
      AlignWithMargins = True
      Left = 40
      Top = 50
      Width = 330
      Height = 38
      Margins.Left = 0
      Margins.Top = 50
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alTop
      Alignment = taCenter
      Caption = 'Hello, John'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -28
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TextKind = tkTitle
      UseAccentColor = True
      ExplicitWidth = 137
    end
    object headingSignin: TUText
      AlignWithMargins = True
      Left = 40
      Top = 88
      Width = 330
      Height = 28
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 20
      Align = alTop
      Alignment = taCenter
      Caption = 'Log in to your account'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -20
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TextKind = tkHeading
      ExplicitWidth = 197
    end
    object entryPassword: TUText
      Left = 40
      Top = 208
      Width = 330
      Height = 17
      Align = alTop
      Caption = 'Password'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI Semibold'
      Font.Style = []
      ParentFont = False
      TextKind = tkEntry
      ExplicitWidth = 58
    end
    object entryEmail: TUText
      Left = 40
      Top = 136
      Width = 330
      Height = 17
      Align = alTop
      Caption = 'Email'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI Semibold'
      Font.Style = []
      ParentFont = False
      TextKind = tkEntry
      ExplicitWidth = 32
    end
    object textShowMoreOptions: TUText
      AlignWithMargins = True
      Left = 40
      Top = 352
      Width = 330
      Height = 15
      Cursor = crHandPoint
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 5
      Align = alTop
      Caption = 'Show more options'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      OnClick = textShowMoreOptionsClick
      TextKind = tkDescription
      ExplicitWidth = 103
    end
    object entryDescription: TUText
      Left = 40
      Top = 280
      Width = 330
      Height = 17
      Align = alTop
      Caption = 'Description (optional)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI Semibold'
      Font.Style = []
      ParentFont = False
      TextKind = tkEntry
      ExplicitWidth = 130
    end
    object panelMoreOptions: TUPanel
      Left = 40
      Top = 372
      Width = 330
      Height = 80
      Align = alTop
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ShowCaption = False
      TabOrder = 3
      Visible = False
      BackColor.Enabled = False
      BackColor.Color = clBlack
      BackColor.LightColor = 15132390
      BackColor.DarkColor = 2039583
      object checkSendMeNews: TUCheckBox
        Left = 0
        Top = 30
        Width = 330
        Align = alTop
        TabOrder = 1
        IconFont.Charset = DEFAULT_CHARSET
        IconFont.Color = clWindowText
        IconFont.Height = -20
        IconFont.Name = 'Segoe MDL2 Assets'
        IconFont.Style = []
        Caption = 'Send me news about offers'
      end
      object checkKeepLogin: TUCheckBox
        Left = 0
        Top = 0
        Width = 330
        Align = alTop
        TabOrder = 0
        IconFont.Charset = DEFAULT_CHARSET
        IconFont.Color = clWindowText
        IconFont.Height = -20
        IconFont.Name = 'Segoe MDL2 Assets'
        IconFont.Style = []
        Checked = True
        State = cbsChecked
        Caption = 'Keep me logged in'
      end
    end
    object editEmail: TUEdit
      AlignWithMargins = True
      Left = 40
      Top = 158
      Width = 330
      Margins.Left = 0
      Margins.Top = 5
      Margins.Right = 0
      Margins.Bottom = 20
      Align = alTop
      ParentColor = False
      ParentFont = False
      BevelOuter = bvNone
      Color = clBlack
      TabOrder = 0
      BorderThickness = 1
      BackColor.Enabled = False
      BackColor.Color = clWhite
      BackColor.LightColor = clWhite
      BackColor.DarkColor = clBlack
      BackColor.FocusedLightColor = clBlack
      BackColor.FocusedDarkColor = clBlack
      BorderColor.Enabled = False
      BorderColor.Color = clBlack
      BorderColor.LightColor = 10066329
      BorderColor.DarkColor = 6710886
      BorderColor.FocusedLightColor = 14120960
      BorderColor.FocusedDarkColor = 14120960
    end
    object editPassword: TUEdit
      AlignWithMargins = True
      Left = 40
      Top = 230
      Width = 330
      Margins.Left = 0
      Margins.Top = 5
      Margins.Right = 0
      Margins.Bottom = 20
      Align = alTop
      ParentColor = False
      ParentFont = False
      BevelOuter = bvNone
      Color = clBlack
      TabOrder = 1
      BorderThickness = 1
      BackColor.Enabled = False
      BackColor.Color = clWhite
      BackColor.LightColor = clWhite
      BackColor.DarkColor = clBlack
      BackColor.FocusedLightColor = clBlack
      BackColor.FocusedDarkColor = clBlack
      BorderColor.Enabled = False
      BorderColor.Color = clBlack
      BorderColor.LightColor = 10066329
      BorderColor.DarkColor = 6710886
      BorderColor.FocusedLightColor = 14120960
      BorderColor.FocusedDarkColor = 14120960
    end
    object editDescription: TUEdit
      AlignWithMargins = True
      Left = 40
      Top = 302
      Width = 330
      Margins.Left = 0
      Margins.Top = 5
      Margins.Right = 0
      Margins.Bottom = 20
      Align = alTop
      ParentFont = False
      BevelOuter = bvNone
      TabOrder = 2
      BorderThickness = 1
      BackColor.Enabled = False
      BackColor.Color = clWhite
      BackColor.LightColor = clWhite
      BackColor.DarkColor = clBlack
      BackColor.FocusedLightColor = clBlack
      BackColor.FocusedDarkColor = clBlack
      BorderColor.Enabled = False
      BorderColor.Color = clBlack
      BorderColor.LightColor = 10066329
      BorderColor.DarkColor = 6710886
      BorderColor.FocusedLightColor = 14120960
      BorderColor.FocusedDarkColor = 14120960
      Transparent = True
    end
  end
  object captionBarMain: TUCaptionBar
    Left = 0
    Top = 0
    Width = 410
    Caption = '   Login'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    BackColors.Enabled = False
    BackColors.Color = clBlack
    BackColors.LightColor = 15921906
    BackColors.DarkColor = 2829099
    BackColors.FocusedLightColor = 14120960
    BackColors.FocusedDarkColor = clBlue
    object buttonAppQuit: TUQuickButton
      Left = 365
      Top = 0
      Hint = 'Close'
      Align = alRight
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe MDL2 Assets'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      ButtonStyle = qbsQuit
      Caption = #57606
    end
    object buttonAppMinimized: TUQuickButton
      Left = 320
      Top = 0
      Hint = 'Minimize'
      Align = alRight
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe MDL2 Assets'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      ButtonStyle = qbsMin
      Caption = #59192
    end
    object buttonAppTheme: TUQuickButton
      Left = 275
      Top = 0
      Hint = 'Switch theme'
      Align = alRight
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe MDL2 Assets'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = buttonAppThemeClick
      Caption = #59144
    end
  end
  object panelAction: TUPanel
    Left = 0
    Top = 508
    Width = 410
    Height = 52
    Align = alBottom
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    Padding.Left = 10
    Padding.Top = 10
    Padding.Right = 10
    Padding.Bottom = 10
    ParentFont = False
    ShowCaption = False
    TabOrder = 2
    BackColor.Enabled = False
    BackColor.Color = clBlack
    BackColor.LightColor = 15132390
    BackColor.DarkColor = 2039583
    object buttonOk: TUButton
      Left = 270
      Top = 10
      Width = 130
      Height = 32
      Align = alRight
      TabOrder = 0
      OnClick = buttonOkClick
      BackColors.Enabled = False
      BackColors.LightColor = 13421772
      BackColors.LightHover = 13421772
      BackColors.LightPress = 10066329
      BackColors.LightDisabled = 13421772
      BackColors.LightFocused = 13421772
      BackColors.DarkColor = 3355443
      BackColors.DarkHover = 3355443
      BackColors.DarkPress = 6710886
      BackColors.DarkDisabled = 3355443
      BackColors.DarkFocused = 3355443
      BorderColors.Enabled = False
      BorderColors.LightColor = 13421772
      BorderColors.LightHover = 8026746
      BorderColors.LightPress = 10066329
      BorderColors.LightDisabled = 8026746
      BorderColors.LightFocused = 8026746
      BorderColors.DarkColor = 3355443
      BorderColors.DarkHover = 8750469
      BorderColors.DarkPress = 6710886
      BorderColors.DarkDisabled = 8750469
      BorderColors.DarkFocused = 8750469
      TextColors.Enabled = False
      TextColors.LightColor = clBlack
      TextColors.LightHover = clBlack
      TextColors.LightPress = clBlack
      TextColors.LightDisabled = clGray
      TextColors.LightFocused = clBlack
      TextColors.DarkColor = clWhite
      TextColors.DarkHover = clWhite
      TextColors.DarkPress = clWhite
      TextColors.DarkDisabled = clGray
      TextColors.DarkFocused = clWhite
      Highlight = True
      Caption = 'Ok'
    end
    object buttonCancel: TUButton
      AlignWithMargins = True
      Left = 130
      Top = 10
      Width = 130
      Height = 32
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 10
      Margins.Bottom = 0
      Align = alRight
      TabOrder = 1
      OnClick = buttonCancelClick
      BackColors.Enabled = False
      BackColors.LightColor = 13421772
      BackColors.LightHover = 13421772
      BackColors.LightPress = 10066329
      BackColors.LightDisabled = 13421772
      BackColors.LightFocused = 13421772
      BackColors.DarkColor = 3355443
      BackColors.DarkHover = 3355443
      BackColors.DarkPress = 6710886
      BackColors.DarkDisabled = 3355443
      BackColors.DarkFocused = 3355443
      BorderColors.Enabled = False
      BorderColors.LightColor = 13421772
      BorderColors.LightHover = 8026746
      BorderColors.LightPress = 10066329
      BorderColors.LightDisabled = 8026746
      BorderColors.LightFocused = 8026746
      BorderColors.DarkColor = 3355443
      BorderColors.DarkHover = 8750469
      BorderColors.DarkPress = 6710886
      BorderColors.DarkDisabled = 8750469
      BorderColors.DarkFocused = 8750469
      TextColors.Enabled = False
      TextColors.LightColor = clBlack
      TextColors.LightHover = clBlack
      TextColors.LightPress = clBlack
      TextColors.LightDisabled = clGray
      TextColors.LightFocused = clBlack
      TextColors.DarkColor = clWhite
      TextColors.DarkHover = clWhite
      TextColors.DarkPress = clWhite
      TextColors.DarkDisabled = clGray
      TextColors.DarkFocused = clWhite
      Caption = 'Cancel'
    end
  end
  object popupEdit: TUPopupMenu
    AniSet.AniKind = akOut
    AniSet.AniFunctionKind = afkQuartic
    AniSet.DelayStartTime = 0
    AniSet.Duration = 120
    AniSet.Step = 20
    OnItemClick = popupEditItemClick
    Left = 40
    Top = 102
    object CutCtrlX1: TMenuItem
      Caption = #57707'Cut|Ctrl+X'
      Hint = 'Remove the selected content and put it on the clipboard'
    end
    object CopyCtrlC1: TMenuItem
      Caption = #57711'Copy|Ctrl+C'
      Hint = 'Copy the selected content to the clipboard'
    end
    object PasteCtrlV1: TMenuItem
      Caption = #57709'Paste|Ctrl+V'
      Hint = 'Insert the contents of the clipboard at the current location'
    end
  end
end
