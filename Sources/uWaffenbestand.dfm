object fWaffenbestand: TfWaffenbestand
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Waffenbestand'
  ClientHeight = 571
  ClientWidth = 581
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDesktopCenter
  OnShow = FormShow
  DesignSize = (
    581
    571)
  TextHeight = 19
  object Label5: TLabel
    Left = 488
    Top = 430
    Width = 32
    Height = 19
    Caption = 'Fach'
  end
  object Label4: TLabel
    Left = 320
    Top = 430
    Width = 104
    Height = 19
    Caption = 'Seriennummer'
  end
  object Label3: TLabel
    Left = 200
    Top = 430
    Width = 71
    Height = 19
    Caption = 'Waffentyp'
  end
  object Label2: TLabel
    Left = 56
    Top = 430
    Width = 59
    Height = 19
    Caption = 'Nr. WBK'
  end
  object Label6: TLabel
    Left = 10
    Top = 430
    Width = 25
    Height = 19
    Caption = 'Pos'
  end
  object Bevel1: TBevel
    Left = 0
    Top = 65
    Width = 581
    Height = 14
    Align = alTop
    Shape = bsTopLine
    ExplicitLeft = -360
    ExplicitWidth = 941
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 581
    Height = 65
    Align = alTop
    Alignment = taLeftJustify
    BevelOuter = bvNone
    TabOrder = 0
    object Label7: TLabel
      Left = 10
      Top = 10
      Width = 228
      Height = 32
      Caption = 'Waffenbestand'
      Font.Charset = ANSI_CHARSET
      Font.Color = 12615680
      Font.Height = -27
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label8: TLabel
      Left = 10
      Top = 42
      Width = 209
      Height = 16
      Caption = 'Bestand aller Waffen im Hauptobjekt'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object lvWaffenbestand: TAdvListView
    Left = 8
    Top = 71
    Width = 564
    Height = 353
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = 'Pos'
        MaxWidth = 50
        MinWidth = 50
        Tag = 1
      end
      item
        Caption = 'Nr. WBK'
        Width = 140
      end
      item
        Caption = 'Waffentyp'
        Width = 130
      end
      item
        Caption = 'Seriennummer'
        Width = 150
      end
      item
        Alignment = taCenter
        Caption = 'Fach'
        Tag = 1
        Width = 60
      end
      item
        Caption = 'ID'
        MaxWidth = 1
        MinWidth = 1
        Tag = 1
        Width = 1
      end>
    GridLines = True
    HideSelection = False
    OwnerDraw = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnColumnClick = lvWaffenbestandColumnClick
    OnCompare = lvWaffenbestandCompare
    OnKeyDown = lvWaffenbestandKeyDown
    OnKeyPress = lvWaffenbestandKeyPress
    OnSelectItem = lvWaffenbestandSelectItem
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
    ItemHeight = 40
    DetailView.Font.Charset = DEFAULT_CHARSET
    DetailView.Font.Color = clBlue
    DetailView.Font.Height = -11
    DetailView.Font.Name = 'Tahoma'
    DetailView.Font.Style = []
    Version = '1.9.1.1'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 552
    Width = 581
    Height = 19
    AutoHint = True
    Panels = <
      item
        Width = 50
      end>
    ParentShowHint = False
    ShowHint = True
  end
  object edPos: TEdit
    Left = 8
    Top = 449
    Width = 42
    Height = 27
    Color = cl3DLight
    TabOrder = 3
  end
  object edNrWBK: TEdit
    Left = 56
    Top = 449
    Width = 138
    Height = 27
    Color = cl3DLight
    TabOrder = 4
  end
  object edWaffentyp: TEdit
    Left = 200
    Top = 449
    Width = 114
    Height = 27
    Color = cl3DLight
    TabOrder = 5
  end
  object edSeriennummer: TEdit
    Left = 320
    Top = 449
    Width = 162
    Height = 27
    Color = cl3DLight
    TabOrder = 6
  end
  object edFach: TEdit
    Left = 488
    Top = 449
    Width = 85
    Height = 27
    Color = cl3DLight
    TabOrder = 7
  end
  object btnSpeichern: TButton
    Left = 358
    Top = 498
    Width = 215
    Height = 36
    Caption = 'Speichern'
    TabOrder = 8
    OnClick = btnSpeichernClick
  end
  object btnNeueWaffe: TButton
    Left = 8
    Top = 498
    Width = 186
    Height = 36
    Caption = 'Neue Waffe eingeben'
    TabOrder = 9
    OnClick = btnNeueWaffeClick
  end
  object btnEntferneWaffe: TButton
    Left = 200
    Top = 498
    Width = 152
    Height = 36
    Caption = 'Waffe l'#246'schen'
    TabOrder = 10
    OnClick = btnEntferneWaffeClick
  end
  object SaveDialog1: TSaveDialog
    Left = 296
    Top = 272
  end
  object OpenDialog1: TOpenDialog
    Left = 296
    Top = 216
  end
end
