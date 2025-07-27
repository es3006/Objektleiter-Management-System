object fWachpersonal: TfWachpersonal
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Wachpersonal'
  ClientHeight = 628
  ClientWidth = 1194
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 19
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1194
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      1194
      65)
    object Label7: TLabel
      Left = 10
      Top = 10
      Width = 214
      Height = 32
      Caption = 'Wachpersonal'
      Font.Charset = ANSI_CHARSET
      Font.Color = 12615680
      Font.Height = -27
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Image1: TImage
      Left = 1129
      Top = 11
      Width = 48
      Height = 48
      Cursor = crHandPoint
      Hint = 
        'Wachpersonalliste als PDF speichern|Wachpersonalliste als PDF sp' +
        'eichern'
      Anchors = [akTop, akRight]
      AutoSize = True
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
      OnClick = Image1Click
    end
    object Label8: TLabel
      Left = 10
      Top = 38
      Width = 285
      Height = 16
      Caption = 'Monatlich auszuf'#252'llen und an die Firma zu senden'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object lvWachpersonal: TAdvListView
    Left = 0
    Top = 105
    Width = 1194
    Height = 431
    Align = alClient
    Columns = <
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
        Width = 155
      end
      item
        Caption = 'ID'
        MaxWidth = 1
        Width = 0
      end
      item
        Caption = 'MitarbeiterID'
        MaxWidth = 1
        Width = 0
      end>
    GridLines = True
    HideSelection = False
    OwnerDraw = True
    ReadOnly = True
    RowSelect = True
    ParentShowHint = False
    PopupMenu = pmWachpersonal
    ShowHint = True
    TabOrder = 1
    ViewStyle = vsReport
    OnColumnClick = lvWachpersonalColumnClick
    OnCompare = lvWachpersonalCompare
    OnKeyDown = lvWachpersonalKeyDown
    OnKeyPress = lvWachpersonalKeyPress
    AutoHint = True
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
    SubItemSelect = True
    ItemHeight = 30
    DetailView.Font.Charset = DEFAULT_CHARSET
    DetailView.Font.Color = clBlue
    DetailView.Font.Height = -11
    DetailView.Font.Name = 'Tahoma'
    DetailView.Font.Style = []
    Version = '1.9.0.0'
    ExplicitWidth = 1193
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
  object Panel2: TPanel
    Left = 0
    Top = 65
    Width = 1194
    Height = 40
    Align = alTop
    TabOrder = 3
    DesignSize = (
      1194
      40)
    object Label10: TLabel
      Left = 216
      Top = 10
      Width = 30
      Height = 19
      Caption = 'Jahr'
    end
    object Label9: TLabel
      Left = 16
      Top = 10
      Width = 43
      Height = 19
      Caption = 'Monat'
    end
    object Label2: TLabel
      Left = 946
      Top = 10
      Width = 48
      Height = 19
      Anchors = [akTop, akRight]
      Caption = 'Suche:'
    end
    object cbJahr: TComboBox
      Left = 252
      Top = 6
      Width = 145
      Height = 27
      Style = csDropDownList
      TabOrder = 0
      OnSelect = cbMonatSelect
    end
    object cbMonat: TComboBox
      Left = 65
      Top = 6
      Width = 145
      Height = 27
      Style = csDropDownList
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
    object edSuche: TEdit
      Left = 1000
      Top = 6
      Width = 177
      Height = 27
      Anchors = [akTop, akRight]
      TabOrder = 2
      OnKeyPress = edSucheKeyPress
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 536
    Width = 1194
    Height = 73
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 4
    object Label1: TLabel
      Left = 16
      Top = 14
      Width = 318
      Height = 19
      Caption = 'Neuen Mitarbeiter einf'#252'gen (Stammpersonal)'
    end
    object cbMitarbeiter: TComboBox
      Left = 16
      Top = 33
      Width = 318
      Height = 26
      AutoDropDown = True
      Style = csOwnerDrawVariable
      DropDownCount = 20
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemHeight = 20
      ParentFont = False
      TabOrder = 0
      OnSelect = cbMitarbeiterSelect
    end
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
    object acDelMaFromMitarbeiter: TAction
      Caption = 'Mitarbeiter l'#246'schen'
    end
    object acDelMaFromWachpersonal: TAction
      Caption = 'Mitarbeiter aus der Liste entfernen'
      OnExecute = acDelMaFromWachpersonalExecute
      OnUpdate = acDelMaFromWachpersonalUpdate
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
end
