object FrameWachtest: TFrameWachtest
  Left = 0
  Top = 0
  Width = 1200
  Height = 621
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
      Left = 16
      Top = 21
      Width = 30
      Height = 19
      Caption = 'Jahr'
    end
    object Image1: TImage
      AlignWithMargins = True
      Left = 1151
      Top = 15
      Width = 32
      Height = 32
      Cursor = crHandPoint
      Hint = 'Diese Liste als PDF speichern|Diese Liste als PDF speichern'
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
      OnClick = Image1Click
    end
    object Label2: TLabel
      Left = 220
      Top = 20
      Width = 135
      Height = 19
      Caption = 'Art der Ausbildung'
    end
    object cbJahr: TComboBox
      Left = 52
      Top = 17
      Width = 145
      Height = 27
      Style = csDropDownList
      TabOrder = 0
      OnSelect = cbJahrSelect
    end
    object cbArt: TComboBox
      Left = 372
      Top = 17
      Width = 225
      Height = 27
      Style = csDropDownList
      TabOrder = 1
      Items.Strings = (
        'Wachtest'
        'Waffen-Sachkundestand')
    end
  end
  object lvWachtest: TAdvListView
    Left = 0
    Top = 60
    Width = 1200
    Height = 421
    Align = alClient
    Columns = <
      item
        Caption = 'ID'
        MaxWidth = 1
        MinWidth = 1
        Width = 1
      end
      item
        Caption = 'Name'
        MaxWidth = 150
        MinWidth = 150
        Width = 150
      end
      item
        Caption = 'Jan'
        Width = 78
      end
      item
        Caption = 'Feb'
        Width = 78
      end
      item
        Caption = 'M'#228'r'
        Width = 78
      end
      item
        Caption = 'Apr'
        Width = 78
      end
      item
        Caption = 'Mai'
        Width = 78
      end
      item
        Caption = 'Jun'
        Width = 78
      end
      item
        Caption = 'Jul'
        Width = 78
      end
      item
        Caption = 'Aug'
        Width = 78
      end
      item
        Caption = 'Sep'
        Width = 78
      end
      item
        Caption = 'Okt'
        Width = 78
      end
      item
        Caption = 'Nov'
        Width = 78
      end
      item
        Caption = 'Dez'
        Width = 78
      end
      item
        Caption = 'TSW'
        Width = 108
      end>
    GridLines = True
    HideSelection = False
    OwnerDraw = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnClick = lvWachtestClick
    OnSelectItem = lvWachtestSelectItem
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
    ProgressSettings.ValueFormat = '%d%%'
    SizeWithForm = True
    StretchColumn = True
    ItemHeight = 40
    DetailView.Font.Charset = DEFAULT_CHARSET
    DetailView.Font.Color = clBlue
    DetailView.Font.Height = -11
    DetailView.Font.Name = 'Tahoma'
    DetailView.Font.Style = []
    OnRightClickCell = lvWachtestRightClickCell
    Version = '1.9.1.1'
    ExplicitHeight = 420
  end
  object Panel1: TPanel
    Left = 0
    Top = 561
    Width = 1200
    Height = 60
    Align = alBottom
    Color = 14680053
    ParentBackground = False
    TabOrder = 2
    object lbHinweis: TLabel
      AlignWithMargins = True
      Left = 17
      Top = 6
      Width = 1149
      Height = 48
      Margins.Left = 16
      Margins.Top = 5
      Margins.Right = 10
      Margins.Bottom = 5
      Align = alClient
      Caption = '...'
      ExplicitWidth = 15
      ExplicitHeight = 19
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
  object Panel3: TPanel
    Left = 0
    Top = 481
    Width = 1200
    Height = 80
    Align = alBottom
    TabOrder = 3
    DesignSize = (
      1200
      80)
    object lbDatum: TLabel
      Left = 557
      Top = 33
      Width = 179
      Height = 19
      Caption = 'Wachtest geschrieben am'
      Visible = False
    end
    object cbMitarbeiter: TComboBox
      Left = 16
      Top = 29
      Width = 281
      Height = 27
      Style = csDropDownList
      DropDownCount = 20
      TabOrder = 0
      OnSelect = cbMitarbeiterSelect
    end
    object btnSave: TButton
      Left = 952
      Top = 22
      Width = 231
      Height = 40
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Speichern'
      TabOrder = 1
      Visible = False
      OnClick = btnSaveClick
    end
    object dtpDatum: TDateTimePicker
      Left = 757
      Top = 29
      Width = 186
      Height = 27
      Date = 45233.000000000000000000
      Time = 0.031765925930812950
      TabOrder = 2
      Visible = False
    end
  end
end
