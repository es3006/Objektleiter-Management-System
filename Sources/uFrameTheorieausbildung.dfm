object FrameTheorieausbildung: TFrameTheorieausbildung
  Left = 0
  Top = 0
  Width = 1200
  Height = 650
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
    TabOrder = 0
    object Label10: TLabel
      Left = 240
      Top = 21
      Width = 30
      Height = 19
      Caption = 'Jahr'
    end
    object Label3: TLabel
      Left = 21
      Top = 21
      Width = 43
      Height = 19
      Caption = 'Monat'
    end
    object Label2: TLabel
      Left = 448
      Top = 20
      Width = 135
      Height = 19
      Caption = 'Art der Ausbildung'
    end
    object cbJahr: TComboBox
      Left = 276
      Top = 17
      Width = 145
      Height = 27
      Style = csDropDownList
      TabOrder = 0
      OnSelect = cbMonatSelect
    end
    object cbMonat: TComboBox
      Left = 70
      Top = 17
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
    object cbAusbildungsart: TComboBox
      Left = 600
      Top = 17
      Width = 345
      Height = 27
      Style = csDropDownList
      TabOrder = 2
      OnSelect = cbMonatSelect
      Items.Strings = (
        'Waffenhandhabung / Sachkundestand'
        'UzwGBw theoretisch'
        'Wachausbildung / Szenarioausbildung')
    end
  end
  object lvTheorieausbildung: TAdvListView
    Left = 0
    Top = 60
    Width = 1200
    Height = 450
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
        Caption = 'Datum'
        Width = 100
      end
      item
        Caption = 'Datum'
        Width = 100
      end
      item
        Caption = 'Datum'
        Width = 100
      end
      item
        Caption = 'Datum'
        Width = 100
      end
      item
        Caption = 'Datum'
        Width = 100
      end
      item
        Caption = 'Datum'
        Width = 100
      end
      item
        Caption = 'Datum'
        Width = 100
      end
      item
        Caption = 'Datum'
        Width = 100
      end
      item
        Caption = 'Datum'
        Width = 100
      end
      item
        Caption = 'Datum'
        Width = 144
      end>
    GridLines = True
    HideSelection = False
    OwnerDraw = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnSelectItem = lvTheorieausbildungSelectItem
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
    OnRightClickCell = lvTheorieausbildungRightClickCell
    Version = '1.9.1.1'
    ExplicitHeight = 449
  end
  object Panel3: TPanel
    Left = 0
    Top = 510
    Width = 1200
    Height = 80
    Align = alBottom
    TabOrder = 2
    DesignSize = (
      1200
      80)
    object Label4: TLabel
      Left = 16
      Top = 15
      Width = 157
      Height = 19
      Caption = 'Name des Mitarbeiters'
    end
    object Label1: TLabel
      Left = 717
      Top = 15
      Width = 132
      Height = 19
      Caption = 'Datum Ausbildung'
    end
    object Label5: TLabel
      Left = 384
      Top = 15
      Width = 66
      Height = 19
      Caption = 'Aushilfen'
    end
    object cbStammpersonal: TComboBox
      Left = 12
      Top = 40
      Width = 318
      Height = 27
      Style = csDropDownList
      DropDownCount = 20
      TabOrder = 0
      OnSelect = cbStammpersonalSelect
    end
    object btnInsert: TButton
      Left = 952
      Top = 30
      Width = 231
      Height = 40
      Anchors = [akTop, akRight]
      Caption = 'Hinzuf'#252'gen'
      TabOrder = 1
      OnClick = btnInsertClick
    end
    object dtpDatum: TDateTimePicker
      Left = 717
      Top = 40
      Width = 186
      Height = 27
      Date = 45470.000000000000000000
      Time = 0.453240439812361700
      TabOrder = 2
    end
    object cbAushilfen: TComboBox
      Left = 384
      Top = 40
      Width = 318
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
      TabOrder = 3
      OnSelect = cbStammpersonalSelect
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 590
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
end
