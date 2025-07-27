object fZugangsdaten: TfZugangsdaten
  Left = 0
  Top = 0
  ActiveControl = lvZugangsdaten
  BorderStyle = bsDialog
  Caption = 'Zugangsdaten'
  ClientHeight = 436
  ClientWidth = 845
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 19
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 845
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label7: TLabel
      Left = 10
      Top = 10
      Width = 215
      Height = 32
      Caption = 'Zugangsdaten'
      Font.Charset = ANSI_CHARSET
      Font.Color = 12615680
      Font.Height = -27
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 10
      Top = 45
      Width = 462
      Height = 16
      Caption = 
        '(Verwaltung der Zugangsdaten f'#252'r Objektleiter und Stellvertreten' +
        'de Objektleiter)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object lvZugangsdaten: TAdvListView
    Left = 0
    Top = 65
    Width = 845
    Height = 311
    Align = alClient
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
        Caption = 'Mitarbeitername'
        Width = 200
      end
      item
        Caption = 'Username'
        Width = 640
      end
      item
        Caption = 'Passwort'
        Width = 0
      end>
    GridLines = True
    HideSelection = False
    OwnerDraw = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnClick = lvZugangsdatenClick
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
    ProgressSettings.ValueFormat = '%d%%'
    SizeWithForm = True
    StretchColumn = True
    ItemHeight = 40
    ReArrangeItems = True
    DetailView.Font.Charset = DEFAULT_CHARSET
    DetailView.Font.Color = clBlue
    DetailView.Font.Height = -11
    DetailView.Font.Name = 'Tahoma'
    DetailView.Font.Style = []
    OnRightClickCell = lvZugangsdatenRightClickCell
    Version = '1.9.0.0'
    ExplicitHeight = 310
  end
  object Panel2: TPanel
    Left = 0
    Top = 376
    Width = 845
    Height = 60
    Align = alBottom
    ShowCaption = False
    TabOrder = 2
    object Label1: TLabel
      Left = 10
      Top = 4
      Width = 110
      Height = 19
      Caption = 'Stammpersonal'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object edPasswort: TLabeledEdit
      Left = 462
      Top = 25
      Width = 177
      Height = 27
      EditLabel.Width = 63
      EditLabel.Height = 19
      EditLabel.Caption = 'Passwort'
      PasswordChar = '*'
      TabOrder = 2
    end
    object btnSpeichern: TButton
      Left = 645
      Top = 14
      Width = 188
      Height = 40
      Caption = 'Hinzuf'#252'gen'
      TabOrder = 3
      OnClick = btnSpeichernClick
    end
    object cbMitarbeiter: TComboBox
      Left = 10
      Top = 25
      Width = 247
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
    object edUsername: TLabeledEdit
      Left = 270
      Top = 25
      Width = 177
      Height = 27
      EditLabel.Width = 71
      EditLabel.Height = 19
      EditLabel.Caption = 'Username'
      TabOrder = 1
    end
  end
end
