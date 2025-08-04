object fMitarbeiter: TfMitarbeiter
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Mitarbeiter'
  ClientHeight = 628
  ClientWidth = 1194
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDesktopCenter
  OnShow = FormShow
  TextHeight = 19
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1194
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label7: TLabel
      Left = 10
      Top = 10
      Width = 167
      Height = 32
      Caption = 'Mitarbeiter'
      Font.Charset = ANSI_CHARSET
      Font.Color = 12615680
      Font.Height = -27
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 10
      Top = 38
      Width = 168
      Height = 16
      Caption = '(Stammpersonal + Aushilfen)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 609
    Width = 1194
    Height = 19
    AutoHint = True
    Panels = <
      item
        Width = 50
      end>
  end
  object lvMitarbeiter: TAdvListView
    Left = 0
    Top = 113
    Width = 1194
    Height = 437
    Align = alClient
    Columns = <
      item
        Caption = 'ID'
        MaxWidth = 1
        Tag = 1
        Width = 0
      end
      item
        Caption = 'PersonalNr'
        MinWidth = 120
        Width = 120
      end
      item
        Caption = 'Nachname'
        MinWidth = 150
        Width = 150
      end
      item
        Caption = 'Vorname'
        MinWidth = 150
        Width = 150
      end
      item
        Caption = 'AusweisNr'
        MinWidth = 150
        Width = 150
      end
      item
        Caption = 'G'#252'ltig bis'
        MinWidth = 100
        Tag = 3
        Width = 120
      end
      item
        Caption = 'W+S Nr.'
        MinWidth = 100
        Width = 100
      end
      item
        Caption = 'g'#252'ltig bis'
        MinWidth = 100
        Tag = 3
        Width = 100
      end
      item
        Caption = 'WaffenNr'
        MinWidth = 100
        Width = 299
      end>
    GridLines = True
    HideSelection = False
    OwnerDraw = True
    ReadOnly = True
    RowSelect = True
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    ViewStyle = vsReport
    OnColumnClick = lvMitarbeiterColumnClick
    OnCompare = lvMitarbeiterCompare
    OnDblClick = lvMitarbeiterDblClick
    AutoHint = True
    ColumnSize.Stretch = True
    FilterTimeOut = 0
    PrintSettings.DateFormat = 'dd/mm/yyyy'
    PrintSettings.Font.Charset = DEFAULT_CHARSET
    PrintSettings.Font.Color = clWindowText
    PrintSettings.Font.Height = -11
    PrintSettings.Font.Name = 'Tahoma'
    PrintSettings.Font.Style = []
    PrintSettings.HeaderFont.Charset = DEFAULT_CHARSET
    PrintSettings.HeaderFont.Color = clWindowText
    PrintSettings.HeaderFont.Height = -11
    PrintSettings.HeaderFont.Name = 'Tahoma'
    PrintSettings.HeaderFont.Style = []
    PrintSettings.FooterFont.Charset = DEFAULT_CHARSET
    PrintSettings.FooterFont.Color = clWindowText
    PrintSettings.FooterFont.Height = -11
    PrintSettings.FooterFont.Name = 'Tahoma'
    PrintSettings.FooterFont.Style = []
    PrintSettings.PageNumSep = '/'
    HeaderFont.Charset = DEFAULT_CHARSET
    HeaderFont.Color = clWindowText
    HeaderFont.Height = -16
    HeaderFont.Name = 'Tahoma'
    HeaderFont.Style = []
    HintLargeText = True
    ProgressSettings.ValueFormat = '%d%%'
    ScrollHint = True
    SizeWithForm = True
    StretchColumn = True
    SubItemSelect = True
    ItemHeight = 40
    DetailView.Font.Charset = DEFAULT_CHARSET
    DetailView.Font.Color = clBlue
    DetailView.Font.Height = -11
    DetailView.Font.Name = 'Tahoma'
    DetailView.Font.Style = []
    Version = '1.9.1.1'
    ExplicitHeight = 436
  end
  object Panel2: TPanel
    Left = 0
    Top = 65
    Width = 1194
    Height = 48
    Align = alTop
    TabOrder = 3
    object Label9: TLabel
      Left = 8
      Top = 18
      Width = 47
      Height = 19
      Caption = 'Objekt'
    end
    object cbObjekt: TComboBox
      Left = 61
      Top = 15
      Width = 389
      Height = 27
      Style = csDropDownList
      TabOrder = 0
      OnSelect = cbObjektSelect
      Items.Strings = (
        ''
        'Januar'
        'Februar'
        'M'#228'rz'
        'April'
        'Mai'
        'Juni'
        'Juli'
        'August'
        'September'
        'Oktober'
        'November'
        'Dezember')
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 550
    Width = 1194
    Height = 59
    Align = alBottom
    TabOrder = 4
    DesignSize = (
      1194
      59)
    object btnMitarbeiterNeu: TButton
      Left = 10
      Top = 6
      Width = 239
      Height = 43
      Anchors = [akLeft, akBottom]
      Caption = 'Neuen Mitarbeiter eingeben'
      TabOrder = 0
      OnClick = btnMitarbeiterNeuClick
    end
  end
end
