object FrameErsteHilfe: TFrameErsteHilfe
  Left = 0
  Top = 0
  Width = 1200
  Height = 800
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object Panel3: TPanel
    Left = 0
    Top = 660
    Width = 1200
    Height = 80
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      1200
      80)
    object Label4: TLabel
      Left = 16
      Top = 15
      Width = 198
      Height = 19
      Caption = 'Stammpersonal + Aushilfen'
    end
    object Label1: TLabel
      Left = 344
      Top = 15
      Width = 132
      Height = 19
      Caption = 'Datum Ausbildung'
    end
    object cbMitarbeiter: TComboBox
      Left = 16
      Top = 40
      Width = 311
      Height = 27
      Style = csDropDownList
      DropDownCount = 20
      TabOrder = 0
      OnSelect = cbMitarbeiterSelect
    end
    object dtpDatum: TDateTimePicker
      Left = 344
      Top = 40
      Width = 186
      Height = 27
      Date = 45470.000000000000000000
      Time = 0.453240439812361700
      TabOrder = 1
    end
    object bnSaveInDB: TButton
      Left = 952
      Top = 30
      Width = 231
      Height = 40
      Anchors = [akTop, akRight]
      Caption = 'Speichern'
      TabOrder = 2
      OnClick = bnSaveInDBClick
    end
  end
  object lvErsteHilfe: TAdvListView
    Left = 0
    Top = 60
    Width = 1200
    Height = 600
    Align = alClient
    Columns = <
      item
        Caption = 'MitarbeiterID'
        MaxWidth = 1
        Width = 0
      end
      item
        Caption = 'ID'
        MaxWidth = 1
        Width = 0
      end
      item
        Caption = 'Name'
        MinWidth = 250
        Width = 250
      end
      item
        Caption = 'Ausbildung am'
        Tag = 3
        Width = 150
      end
      item
        Caption = 'G'#252'ltig bis'
        MinWidth = 150
        Tag = 3
        Width = 150
      end
      item
        Caption = 'Abgelaufen'
        MinWidth = 150
        Width = 645
      end>
    GridLines = True
    HideSelection = False
    OwnerDraw = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnClick = lvErsteHilfeClick
    OnColumnClick = lvErsteHilfeColumnClick
    OnCompare = lvErsteHilfeCompare
    OnSelectItem = lvErsteHilfeSelectItem
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
    OnRightClickCell = lvErsteHilfeRightClickCell
    Version = '1.9.1.1'
    ExplicitWidth = 1199
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 1200
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    Color = 16707798
    ParentBackground = False
    TabOrder = 2
    object Image1: TImage
      Left = 1152
      Top = 0
      Width = 48
      Height = 48
      Cursor = crHandPoint
      Hint = 'Diese Liste als PDF speichern|Diese Liste als PDF speichern'
      Align = alRight
      AutoSize = True
      Center = True
      Enabled = False
      ParentShowHint = False
      Picture.Data = {
        0954506E67496D61676589504E470D0A1A0A0000000D49484452000000300000
        003008060000005702F98700000006624B474400FF00FF00FFA0BDA793000002
        6B4944415478DAED993D4BC34018C793B65604055F2A6AC4165C74737072D18A
        74168562DB940E7572717150275F064107FD046E69ED22F8093A88B8F882B808
        2E0E2A0AA2830E566C8DFF40901A9BA63697DC45FBC0C3736FBDFBFFC8DDE5AE
        E139871B4F5B400D80B6005B002291488FC7E3D990657908D9008981D1D7423A
        9D5EB71C20168B05789E3F43B2998470D2108600A2286610A6488B27055109C0
        2D8260158059884A00E4E27C2A9532B5F095FE3025DF20BA9E0404150035F90A
        6FF82686E75724495A760A001108DA00A62158003005C10A40D5102C0170A576
        27A3F198022865CC01901EEF6F022412097FA150D8427218EEB352B091FD1A40
        15AF9C3E5B680AAF1A008F70176192B6703300CF084DB4859B01D05D44EAE526
        8AE42ABC4E5B9F4C269B72B95C27DA4C203B0F6F351262B4AD1205286AB388B0
        566E00C0F602E400C92E26009472581667F6312CF46E2CF41B6D3DC20BFC02C2
        67700438455912F9ED12ED2A36A20008FBC88FE0922FB8DDEE5B3D6100BD0468
        5F341AED70B95CF74C0068DAFC98429ADFC9287729FDA3FCA34C3FC70883B601
        84C3E176AFD73BCD9558C43A005FE5D401F41EBD4EFD15CA7B31857C98420F95
        F4C30AC03BFC043E8BF223EC442216B4E40800ADA90BFD9053FFC97304403018
        F40882E0C7B40961275AE2D47780DD00CA5EDEF89B41ACB46A00F610C6690BAF
        1A003B473FA68032779D799C56ACE84213E2289F4CFFE795B2065003200B7087
        D069A5E832760780B21F570C01E2F1B884B7AA4809600700315300EA99E61CC9
        369BC53FC1070070630A4085E801C42692A336803CE2049BCDE7F373994CE6DA
        A8F1FFF8D0CDB2D50068DB271219CA40AFFCF0FB0000000049454E44AE426082}
      Proportional = True
      ShowHint = True
      ExplicitLeft = 1151
      ExplicitTop = 1
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 740
    Width = 1200
    Height = 60
    Align = alBottom
    Color = 14680053
    ParentBackground = False
    TabOrder = 3
    object lbHinweis: TLabel
      AlignWithMargins = True
      Left = 17
      Top = 6
      Width = 15
      Height = 19
      Margins.Left = 16
      Margins.Top = 5
      Margins.Right = 10
      Margins.Bottom = 5
      Align = alClient
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
end
