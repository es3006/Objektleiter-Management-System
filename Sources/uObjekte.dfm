object fObjekte: TfObjekte
  Left = 366
  Top = 235
  BorderStyle = bsDialog
  Caption = #220'bersicht aller Objekte (Stammobjekt und Aushilfsobjekte)'
  ClientHeight = 422
  ClientWidth = 587
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDesktopCenter
  OnShow = FormShow
  DesignSize = (
    587
    422)
  TextHeight = 19
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 587
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label12: TLabel
      Left = 10
      Top = 10
      Width = 119
      Height = 32
      Caption = 'Objekte'
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
      Width = 188
      Height = 16
      Caption = '(Stammobjekt + Aushilfsobjekte)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object btnNeueWaffe: TButton
    Left = 8
    Top = 371
    Width = 201
    Height = 38
    Anchors = [akLeft, akBottom]
    Caption = 'Neues Objekt anlegen'
    TabOrder = 1
    OnClick = btnNeueWaffeClick
  end
  object lvObjekte: TAdvListView
    Left = 8
    Top = 71
    Width = 571
    Height = 294
    Columns = <
      item
        Caption = 'Objektname'
        MinWidth = 300
        Width = 300
      end
      item
        AutoSize = True
        Caption = 'Ort'
        MinWidth = 220
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
    TabOrder = 2
    ViewStyle = vsReport
    OnDblClick = lvObjekteDblClick
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
end
