object fDiensthunde: TfDiensthunde
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Diensthunde'
  ClientHeight = 391
  ClientWidth = 591
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  OnShow = FormShow
  TextHeight = 19
  object Label1: TLabel
    Left = 8
    Top = 320
    Width = 119
    Height = 19
    Caption = 'Diensthundname'
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 591
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 587
    object Label12: TLabel
      Left = 10
      Top = 10
      Width = 190
      Height = 32
      Caption = 'Diensthunde'
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
      Width = 296
      Height = 16
      Caption = 'Geben Sie hier alle Diensthunde in Ihrem Objekt ein'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object lvDiensthunde: TAdvListView
    Left = 8
    Top = 71
    Width = 571
    Height = 234
    Columns = <
      item
        Caption = 'Diensthundname'
        MinWidth = 300
        Width = 520
      end
      item
        Caption = 'ID'
        MaxWidth = 1
        Width = 0
      end>
    GridLines = True
    HideSelection = False
    OwnerDraw = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnSelectItem = lvDiensthundeSelectItem
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
    ItemHeight = 30
    DetailView.Font.Charset = DEFAULT_CHARSET
    DetailView.Font.Color = clBlue
    DetailView.Font.Height = -11
    DetailView.Font.Name = 'Tahoma'
    DetailView.Font.Style = []
    Version = '1.9.1.1'
  end
  object edDiensthundname: TEdit
    Left = 8
    Top = 345
    Width = 442
    Height = 27
    ImeName = 'German'
    TabOrder = 2
  end
  object btnAddUpdate: TButton
    Left = 456
    Top = 340
    Width = 123
    Height = 37
    Caption = 'Hinzuf'#252'gen'
    TabOrder = 3
    OnClick = btnAddUpdateClick
  end
end
