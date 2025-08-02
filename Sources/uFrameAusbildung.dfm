object FrameAusbildung: TFrameAusbildung
  Left = 0
  Top = 0
  Width = 1200
  Height = 650
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
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
    object Label10: TLabel
      Left = 240
      Top = 21
      Width = 29
      Height = 21
      Caption = 'Jahr'
    end
    object Label3: TLabel
      Left = 16
      Top = 21
      Width = 45
      Height = 21
      Caption = 'Monat'
    end
    object cbJahr: TComboBox
      Left = 276
      Top = 17
      Width = 145
      Height = 29
      Style = csDropDownList
      TabOrder = 0
      OnSelect = cbMonatSelect
    end
    object cbMonat: TComboBox
      Left = 70
      Top = 16
      Width = 145
      Height = 29
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
  object GridPanel1: TGridPanel
    Left = 0
    Top = 60
    Width = 1200
    Height = 530
    Align = alClient
    Caption = 'GridPanel1'
    ColumnCollection = <
      item
        Value = 33.627222885084620000
      end
      item
        Value = 33.186388557457690000
      end
      item
        Value = 33.186388557457690000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = Panel3
        Row = 0
      end
      item
        Column = 1
        Control = Panel4
        Row = 0
      end
      item
        Column = 2
        Control = Panel5
        Row = 0
      end
      item
        Column = 0
        Control = lvAusbildung1
        Row = 1
      end
      item
        Column = 1
        Control = lvAusbildung2
        Row = 1
      end
      item
        Column = 2
        Control = lvAusbildung3
        Row = 1
      end
      item
        Column = 0
        Control = Panel6
        Row = 2
      end
      item
        Column = 1
        Control = Panel7
        Row = 2
      end
      item
        Column = 2
        Control = Panel8
        Row = 2
      end>
    RowCollection = <
      item
        SizeStyle = ssAbsolute
        Value = 50.000000000000000000
      end
      item
        Value = 100.000000000000000000
      end
      item
        SizeStyle = ssAbsolute
        Value = 70.000000000000000000
      end>
    TabOrder = 1
    object Panel3: TPanel
      Left = 1
      Top = 1
      Width = 403
      Height = 50
      Cursor = crHandPoint
      Hint = 'Waffenhandhabung'#13'Sachkundestand'#13'Wachschie'#223'en'
      Align = alClient
      Caption = 'Waffenhandhabung / Sachkundestand'
      Color = 14277119
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentBackground = False
      ParentFont = False
      TabOrder = 0
    end
    object Panel4: TPanel
      Left = 404
      Top = 1
      Width = 397
      Height = 50
      Cursor = crHandPoint
      Hint = 'Wachtest,'#13'Theorie Ausbildung'
      Align = alClient
      Caption = 'UzwGBw theoretisch'
      Color = 13369252
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentBackground = False
      ParentFont = False
      TabOrder = 1
    end
    object Panel5: TPanel
      Left = 801
      Top = 1
      Width = 398
      Height = 50
      Cursor = crHandPoint
      Hint = 
        'Wachausbildung'#13'Szenarioausbildung'#13'Szenarioausbildung mit Schutza' +
        'usr'#252'stung'#13'Fahrzeugkontrolle (Spiegelung)'
      Align = alClient
      Caption = 'Wachausbildung / Szenarioausbildung'
      Color = 15910086
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentBackground = False
      ParentFont = False
      TabOrder = 2
    end
    object lvAusbildung1: TAdvListView
      Tag = 1
      Left = 1
      Top = 51
      Width = 403
      Height = 408
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
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = []
      FlatScrollBars = True
      GridLines = True
      HideSelection = False
      OwnerDraw = True
      ReadOnly = True
      RowSelect = True
      ParentFont = False
      TabOrder = 3
      ViewStyle = vsReport
      OnSelectItem = lvAusbildung1SelectItem
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
      ScrollHint = True
      SizeWithForm = True
      StretchColumn = True
      ItemHeight = 40
      DetailView.Font.Charset = DEFAULT_CHARSET
      DetailView.Font.Color = clBlue
      DetailView.Font.Height = -11
      DetailView.Font.Name = 'Tahoma'
      DetailView.Font.Style = []
      OnRightClickCell = lvAusbildung1RightClickCell
      Version = '1.9.1.1'
    end
    object lvAusbildung2: TAdvListView
      Tag = 2
      Left = 404
      Top = 51
      Width = 397
      Height = 408
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
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = []
      FlatScrollBars = True
      GridLines = True
      HideSelection = False
      OwnerDraw = True
      ReadOnly = True
      RowSelect = True
      ParentFont = False
      TabOrder = 4
      ViewStyle = vsReport
      OnSelectItem = lvAusbildung2SelectItem
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
      ScrollHint = True
      SizeWithForm = True
      StretchColumn = True
      ItemHeight = 40
      DetailView.Font.Charset = DEFAULT_CHARSET
      DetailView.Font.Color = clBlue
      DetailView.Font.Height = -11
      DetailView.Font.Name = 'Tahoma'
      DetailView.Font.Style = []
      OnRightClickCell = lvAusbildung1RightClickCell
      Version = '1.9.1.1'
    end
    object lvAusbildung3: TAdvListView
      Tag = 3
      Left = 801
      Top = 51
      Width = 398
      Height = 408
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
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = []
      FlatScrollBars = True
      GridLines = True
      HideSelection = False
      OwnerDraw = True
      ReadOnly = True
      RowSelect = True
      ParentFont = False
      TabOrder = 5
      ViewStyle = vsReport
      OnSelectItem = lvAusbildung3SelectItem
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
      ScrollHint = True
      SizeWithForm = True
      StretchColumn = True
      ItemHeight = 40
      DetailView.Font.Charset = DEFAULT_CHARSET
      DetailView.Font.Color = clBlue
      DetailView.Font.Height = -11
      DetailView.Font.Name = 'Tahoma'
      DetailView.Font.Style = []
      OnRightClickCell = lvAusbildung1RightClickCell
      Version = '1.9.1.1'
    end
    object Panel6: TPanel
      Left = 1
      Top = 459
      Width = 403
      Height = 70
      Align = alClient
      ShowCaption = False
      TabOrder = 6
      object Label1: TLabel
        Left = 240
        Top = 4
        Width = 130
        Height = 21
        Caption = 'Datum Ausbildung'
      end
      object Label4: TLabel
        Left = 16
        Top = 4
        Width = 158
        Height = 21
        Caption = 'Name des Mitarbeiters'
      end
      object sbSaveWaffenhandhabung: TSpeedButton
        Left = 350
        Top = 30
        Width = 30
        Height = 30
        Caption = 'ok'
        OnClick = sbSaveWaffenhandhabungClick
      end
      object cbPersonal1: TComboBox
        Left = 16
        Top = 30
        Width = 217
        Height = 29
        Style = csDropDownList
        DropDownCount = 20
        TabOrder = 0
        OnSelect = cbPersonal1Select
      end
      object dtpDatum1: TDateTimePicker
        Left = 240
        Top = 30
        Width = 107
        Height = 29
        Date = 45470.000000000000000000
        Time = 0.453240439812361700
        TabOrder = 1
      end
    end
    object Panel7: TPanel
      Left = 404
      Top = 459
      Width = 397
      Height = 70
      Align = alClient
      ShowCaption = False
      TabOrder = 7
      object Label5: TLabel
        Left = 240
        Top = 4
        Width = 130
        Height = 21
        Caption = 'Datum Ausbildung'
      end
      object Label6: TLabel
        Left = 16
        Top = 4
        Width = 158
        Height = 21
        Caption = 'Name des Mitarbeiters'
      end
      object sbSaveTheorie: TSpeedButton
        Left = 350
        Top = 30
        Width = 30
        Height = 30
        Caption = 'ok'
        OnClick = sbSaveTheorieClick
      end
      object cbPersonal2: TComboBox
        Left = 16
        Top = 30
        Width = 217
        Height = 29
        Style = csDropDownList
        DropDownCount = 20
        TabOrder = 0
        OnSelect = cbPersonal2Select
      end
      object dtpDatum2: TDateTimePicker
        Left = 240
        Top = 30
        Width = 107
        Height = 29
        Date = 45470.000000000000000000
        Time = 0.453240439812361700
        TabOrder = 1
      end
    end
    object Panel8: TPanel
      Left = 801
      Top = 459
      Width = 398
      Height = 70
      Align = alClient
      ShowCaption = False
      TabOrder = 8
      object Label7: TLabel
        Left = 240
        Top = 4
        Width = 130
        Height = 21
        Caption = 'Datum Ausbildung'
      end
      object Label8: TLabel
        Left = 16
        Top = 4
        Width = 158
        Height = 21
        Caption = 'Name des Mitarbeiters'
      end
      object sbSaveSzenario: TSpeedButton
        Left = 350
        Top = 30
        Width = 30
        Height = 30
        Caption = 'ok'
        OnClick = sbSaveSzenarioClick
      end
      object cbPersonal3: TComboBox
        Left = 16
        Top = 30
        Width = 217
        Height = 29
        Style = csDropDownList
        DropDownCount = 20
        TabOrder = 0
        OnSelect = cbPersonal3Select
      end
      object dtpDatum3: TDateTimePicker
        Left = 240
        Top = 30
        Width = 107
        Height = 29
        Date = 45470.000000000000000000
        Time = 0.453240439812361700
        TabOrder = 1
      end
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
      ExplicitWidth = 9
      ExplicitHeight = 21
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
  object BalloonHint1: TBalloonHint
    Left = 568
    Top = 300
  end
end
