object FrameWachpersonal: TFrameWachpersonal
  Left = 0
  Top = 0
  Width = 1200
  Height = 672
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 1200
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    Color = 16707798
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      1200
      60)
    object Label10: TLabel
      Left = 232
      Top = 20
      Width = 30
      Height = 19
      Caption = 'Jahr'
    end
    object Label9: TLabel
      Left = 16
      Top = 20
      Width = 43
      Height = 19
      Caption = 'Monat'
    end
    object btnSavePDF: TImage
      AlignWithMargins = True
      Left = 1151
      Top = 15
      Width = 32
      Height = 32
      Cursor = crHandPoint
      Hint = 
        'Wachpersonalliste als PDF speichern|Wachpersonalliste als PDF sp' +
        'eichern'
      Anchors = [akTop, akRight]
      Center = True
      ParentShowHint = False
      Picture.Data = {
        0954506E67496D61676589504E470D0A1A0A0000000D49484452000000200000
        00200806000000737A7AF4000000097048597300000B1300000B1301009A9C18
        0000026F4944415478DA63641860C038E81CC01FD8F39F2213FF33747EDC5052
        31700E20D111B47100098EA09D0388740441077C5C5F425242C5F0000147D0DE
        01041C411F07E07104FD1C80C311643940D0BF47F61F13C38EFF0CFFDF7D62F9
        E2CCB0BAF117B10E42378F2C07F005F6A63332FC9F0162FF6360B4FCBCBEF804
        5D1DC01FD4E5C2F09F693798C3C460F4716DC979BA3A8021B49E8DFF37CF03A0
        6ED68F2CF2120CABC3FED2D701A06808E8DEC8C8C068F18FE197D6E70D556FE9
        1E027C7F785E031DC00754BCEE93DEE75086C6C67F0C6400F2D2404077100323
        E35A24A119C0C4B890E9FF5F5D10E7CF5FB64D5F3717BCA48D03EAEB99F82EF2
        9C636464D4C765E8FFFF0C0F3F6D285100B1DF3278A29827CCB09D9228F8CFC8
        1FD85B0C647483ACF9FF9F1194FA0F3132FE3F0AB4D41718256140133980523B
        3E6E28F5A4AA030402BAFCFF313236032DD10516401B9898FED77F585B760945
        73DA4C56A1D7EFC5DFADAF780213A28A0390E31C68F9033E1626AD27AB8BBF13
        8C60AA3920B0BB10A8B40F18B4CF1999FF7B60F89CD60E00C53D8F5F8F26EFBF
        2F0F9E6F69FC46ACE5547400F960643A0068E90220158F4F0DD092A5220CDB63
        A8DA28059605F3810550D27306576E3606E6D340FF69E2B0FC310B0393BE00C3
        D6F7546F1503CB89F80FEB8B17BD65F0D66160F87B1228C2856AF9FF7F40EC2C
        CAB0F300443D951D00D4FCF5DF7F66D32F1B0AAFBF65F048035A31134D458B30
        C38E5A8483A9EC00B015FF19AE70FFF96C0ECAB26F183C97002D8986CA9C1562
        786DC9C870F6374E07501BBC64B0E76161E03A0364CA005B2D46620CDB6F21CB
        D3A577FC8AC1DD888981490798EA17A1CB0100776570308991C7610000000049
        454E44AE426082}
      Proportional = True
      ShowHint = True
      Visible = False
      OnClick = btnSavePDFClick
    end
    object cbJahr: TComboBox
      Left = 268
      Top = 16
      Width = 145
      Height = 27
      Style = csDropDownList
      TabOrder = 0
      OnSelect = cbMonatSelect
    end
    object cbMonat: TComboBox
      Left = 70
      Top = 16
      Width = 145
      Height = 27
      Style = csDropDownList
      DropDownCount = 13
      TabOrder = 1
      OnSelect = cbMonatSelect
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
    Top = 532
    Width = 1200
    Height = 80
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      1200
      80)
    object lbWaffennummer: TLabel
      Left = 462
      Top = 31
      Width = 76
      Height = 19
      Caption = 'Waffen Nr.'
      Visible = False
    end
    object lbHinzufügen: TLabel
      Left = 256
      Top = 32
      Width = 80
      Height = 19
      Caption = 'Hinzuf'#252'gen'
    end
    object cbAushilfen: TComboBox
      Left = 16
      Top = 27
      Width = 233
      Height = 27
      AutoDropDown = True
      Style = csDropDownList
      DropDownCount = 20
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ImeName = 'German'
      ParentFont = False
      TabOrder = 0
      Visible = False
      OnSelect = cbAushilfenSelect
    end
    object btnDelWachpersonalListe: TButton
      Left = 952
      Top = 20
      Width = 231
      Height = 40
      Anchors = [akRight, akBottom]
      Caption = 'Wachpersonalliste l'#246'schen'
      TabOrder = 1
      Visible = False
      OnClick = btnDelWachpersonalListeClick
    end
    object cbWaffennummer: TComboBox
      Left = 544
      Top = 27
      Width = 201
      Height = 27
      AutoDropDown = True
      Style = csDropDownList
      DropDownCount = 20
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      Visible = False
      OnSelect = cbWaffennummerSelect
    end
    object btnInsertAllStamm: TButton
      Left = 16
      Top = 20
      Width = 337
      Height = 40
      Caption = 'Komplettes Stammpersonal hinzuf'#252'gen'
      TabOrder = 3
      Visible = False
      OnClick = btnInsertAllStammClick
    end
    object btnSaveEntryInDB: TButton
      Left = 760
      Top = 20
      Width = 121
      Height = 40
      Caption = 'Speichern'
      TabOrder = 4
      Visible = False
      OnClick = btnSaveEntryInDBClick
    end
  end
  object lvWachpersonal: TAdvListView
    Left = 0
    Top = 60
    Width = 1200
    Height = 472
    Align = alClient
    Color = clWhite
    Columns = <
      item
        Caption = 'ID'
        MaxWidth = 1
        Width = 0
      end
      item
        Caption = 'MitarbeiterID'
        MaxWidth = 1
        Width = 0
      end
      item
        Caption = 'Sortierung'
        MaxWidth = 65
        MinWidth = 65
        Tag = 1
        Width = 65
      end
      item
        Caption = 'Nachname'
        Width = 100
      end
      item
        Caption = 'Vorname'
        Width = 100
      end
      item
        Caption = 'Eintrittsdatum'
        Tag = 3
        Width = 110
      end
      item
        Caption = 'Geburtsdatum'
        Tag = 3
        Width = 110
      end
      item
        Caption = 'Pass-Nr'
        Width = 100
      end
      item
        Caption = 'Pass g'#252'ltig bis'
        Tag = 3
        Width = 100
      end
      item
        Alignment = taCenter
        Caption = 'W+S Nr.'
        Width = 100
      end
      item
        Caption = 'W+S g'#252'ltig bis'
        Tag = 3
        Width = 100
      end
      item
        Caption = 'Waffen Nr.'
        Width = 100
      end
      item
        Alignment = taCenter
        Caption = 'DH-Name'
        Width = 210
      end>
    GridLines = True
    HideSelection = False
    OwnerDraw = True
    ReadOnly = True
    RowSelect = True
    ParentShowHint = False
    PopupMenu = pmWachpersonal
    ShowHint = True
    TabOrder = 2
    ViewStyle = vsReport
    OnClick = lvWachpersonalClick
    OnColumnClick = lvWachpersonalColumnClick
    OnCompare = lvWachpersonalCompare
    OnKeyDown = lvWachpersonalKeyDown
    OnKeyPress = lvWachpersonalKeyPress
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
    HeaderFont.Height = -13
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
    ExplicitHeight = 471
  end
  object Panel1: TPanel
    Left = 0
    Top = 612
    Width = 1200
    Height = 60
    Margins.Left = 16
    Margins.Top = 5
    Margins.Right = 10
    Margins.Bottom = 5
    Align = alBottom
    Color = 14680053
    ParentBackground = False
    TabOrder = 3
    object lbHinweis: TLabel
      Left = 16
      Top = 6
      Width = 15
      Height = 19
      Caption = '...'
    end
    object sbWeiter: TSpeedButton
      Left = 1176
      Top = 1
      Width = 23
      Height = 58
      Cursor = crHandPoint
      Hint = 'N'#228'chsten Tipp anzeigen'
      Align = alRight
      Caption = '>'
      ParentShowHint = False
      ShowHint = True
      OnClick = sbWeiterClick
      ExplicitLeft = 1152
      ExplicitTop = 16
      ExplicitHeight = 33
    end
  end
  object AdvInputTaskDialog1: TAdvInputTaskDialog
    AutoClose = True
    ApplicationIsParent = True
    CommonButtons = [cbOK, cbCancel]
    DefaultButton = 0
    DialogPosition = dpOwnerFormCenter
    Footer = 
      'Bitte geben Sie das Erstellungs-Datum f'#252'r die Wachpersonalliste ' +
      'an!'
    FooterColor = 15790320
    FooterIcon = tfiInformation
    FooterTextColor = clWindowText
    Icon = tiQuestion
    InputType = itDate
    InputText = 
      'Bitte geben Sie das Erstellungs-Datum f'#252'r die Waffenbestandsmeld' +
      'ung an!'
    Title = 'Erstellungsdatum'
    Content = 
      'Bitte w'#228'hlen Sie hier das Datum das unter dem Dokument stehen so' +
      'll (Stand)'
    OnDialogButtonClick = AdvInputTaskDialog1DialogButtonClick
    Left = 192
    Top = 320
  end
  object pmWachpersonal: TPopupMenu
    Left = 200
    Top = 208
    object Mitarbeiterentfernen1: TMenuItem
      Action = acDelMaFromWachpersonal
    end
  end
  object ActionList1: TActionList
    Left = 192
    Top = 264
    object acDelMaFromWachpersonal: TAction
      Caption = 'Mitarbeiter aus der Liste entfernen'
      OnExecute = acDelMaFromWachpersonalExecute
      OnUpdate = acDelMaFromWachpersonalUpdate
    end
  end
end
