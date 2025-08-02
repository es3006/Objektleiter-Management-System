object fWochenberichtNeu: TfWochenberichtNeu
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Neuen Wochenbericht anlegen'
  ClientHeight = 621
  ClientWidth = 856
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  OnShow = FormShow
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 561
    Width = 856
    Height = 60
    Align = alBottom
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ShowCaption = False
    TabOrder = 0
    DesignSize = (
      856
      60)
    object lbVonBisDatum: TLabel
      Left = 336
      Top = 21
      Width = 5
      Height = 19
    end
    object btnSaveNewWochenbericht: TButton
      Left = 528
      Top = 12
      Width = 301
      Height = 36
      Anchors = [akTop, akRight]
      Caption = 'Neuen Wochenbericht speichern'
      TabOrder = 0
      OnClick = btnSaveNewWochenberichtClick
    end
  end
  object PageControl_Wochenbericht: TAdvPageControl
    Left = 0
    Top = 60
    Width = 856
    Height = 501
    Cursor = crHandPoint
    ActivePage = AdvTabSheet8
    ActiveFont.Charset = DEFAULT_CHARSET
    ActiveFont.Color = clWindowText
    ActiveFont.Height = -16
    ActiveFont.Name = 'Tahoma'
    ActiveFont.Style = []
    Align = alClient
    DoubleBuffered = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ActiveColor = 12615680
    TabBorder3D = True
    TabHoverColor = 12615680
    TabBackGroundColor = clBtnFace
    TabMargin.RightMargin = 0
    TabOverlap = 0
    Version = '2.0.5.0'
    PersistPagesState.Location = plRegistry
    PersistPagesState.Enabled = False
    TabHeight = 50
    TabOrder = 1
    TabWidth = 200
    object AdvTabSheet8: TAdvTabSheet
      Caption = 'Informatives'
      Color = clBtnFace
      ColorTo = clNone
      TabColor = clBtnFace
      TabColorTo = clNone
      object Label28: TLabel
        Left = 14
        Top = 31
        Width = 239
        Height = 19
        Caption = 'Kundengespr'#228'che- und Betreuung'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label26: TLabel
        Left = 14
        Top = 153
        Width = 215
        Height = 19
        Caption = 'Personalbedarf- und Probleme'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label24: TLabel
        Left = 14
        Top = 242
        Width = 176
        Height = 19
        Caption = 'Mehr- und Minderdienste'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label22: TLabel
        Left = 14
        Top = 339
        Width = 183
        Height = 19
        Caption = 'Besondere Vorkommnisse'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label21: TLabel
        Left = 433
        Top = 339
        Width = 67
        Height = 19
        Caption = 'Sonstiges'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label23: TLabel
        Left = 433
        Top = 242
        Width = 152
        Height = 19
        Caption = 'Ben'#246'tigte Ausr'#252'stung'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label25: TLabel
        Left = 433
        Top = 153
        Width = 168
        Height = 19
        Caption = 'Ben'#246'tigte Ausbildungen'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label27: TLabel
        Left = 433
        Top = 30
        Width = 295
        Height = 19
        Caption = 'Kundenbeschwerden- und Anforderungen'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object edKG1: TEdit
        Left = 14
        Top = 55
        Width = 400
        Height = 27
        TabOrder = 0
        Text = '-----'
        OnChange = edKG1Change
      end
      object edKG2: TEdit
        Left = 14
        Top = 82
        Width = 400
        Height = 27
        TabOrder = 1
        OnChange = edKG1Change
      end
      object edKG3: TEdit
        Left = 14
        Top = 109
        Width = 400
        Height = 27
        TabOrder = 2
        OnChange = edKG1Change
      end
      object edPB1: TEdit
        Left = 14
        Top = 175
        Width = 400
        Height = 27
        TabOrder = 3
        Text = '-----'
        OnChange = edKG1Change
      end
      object edPB2: TEdit
        Left = 14
        Top = 202
        Width = 400
        Height = 27
        TabOrder = 4
        OnChange = edKG1Change
      end
      object edMd1: TEdit
        Left = 14
        Top = 264
        Width = 400
        Height = 27
        TabOrder = 5
        Text = '-----'
        OnChange = edKG1Change
      end
      object edMd2: TEdit
        Left = 14
        Top = 291
        Width = 400
        Height = 27
        TabOrder = 6
        OnChange = edKG1Change
      end
      object edVk1: TEdit
        Left = 14
        Top = 361
        Width = 400
        Height = 27
        TabOrder = 7
        Text = '-----'
        OnChange = edKG1Change
      end
      object edVk2: TEdit
        Left = 14
        Top = 388
        Width = 400
        Height = 27
        TabOrder = 8
        OnChange = edKG1Change
      end
      object edSo2: TEdit
        Left = 433
        Top = 388
        Width = 400
        Height = 27
        TabOrder = 17
        OnChange = edKG1Change
      end
      object edSo1: TEdit
        Left = 433
        Top = 361
        Width = 400
        Height = 27
        TabOrder = 16
        Text = '-----'
        OnChange = edKG1Change
      end
      object edAr2: TEdit
        Left = 433
        Top = 291
        Width = 400
        Height = 27
        TabOrder = 15
        OnChange = edKG1Change
      end
      object edAr1: TEdit
        Left = 433
        Top = 264
        Width = 400
        Height = 27
        TabOrder = 14
        Text = '-----'
        OnChange = edKG1Change
      end
      object edAu2: TEdit
        Left = 433
        Top = 202
        Width = 400
        Height = 27
        TabOrder = 13
        OnChange = edKG1Change
      end
      object edAu1: TEdit
        Left = 433
        Top = 175
        Width = 400
        Height = 27
        TabOrder = 12
        Text = '-----'
        OnChange = edKG1Change
      end
      object edKB3: TEdit
        Left = 433
        Top = 109
        Width = 400
        Height = 27
        TabOrder = 11
        OnChange = edKG1Change
      end
      object edKB2: TEdit
        Left = 433
        Top = 82
        Width = 400
        Height = 27
        TabOrder = 10
        OnChange = edKG1Change
      end
      object edKB1: TEdit
        Left = 433
        Top = 55
        Width = 400
        Height = 27
        TabOrder = 9
        Text = '-----'
        OnChange = edKG1Change
      end
    end
    object AdvTabSheet9: TAdvTabSheet
      Caption = 'Kontrollen'
      Color = clBtnFace
      ColorTo = clNone
      TabColor = clBtnFace
      TabColorTo = clNone
      object Label10: TLabel
        Left = 21
        Top = 68
        Width = 50
        Height = 19
        Caption = 'Uhrzeit'
      end
      object Label11: TLabel
        Left = 21
        Top = 95
        Width = 108
        Height = 19
        Caption = 'Kontrolle durch'
      end
      object lbMoDatum: TLabel
        Left = 139
        Top = 48
        Width = 56
        Height = 13
        Alignment = taCenter
        Caption = '01.01.2024'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label1: TLabel
        Left = 139
        Top = 28
        Width = 52
        Height = 19
        Alignment = taCenter
        Caption = 'Montag'
      end
      object Label2: TLabel
        Left = 274
        Top = 28
        Width = 61
        Height = 19
        Alignment = taCenter
        Caption = 'Dienstag'
      end
      object lbDiDatum: TLabel
        Left = 274
        Top = 48
        Width = 56
        Height = 13
        Alignment = taCenter
        Caption = '02.01.2024'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lbMiDatum: TLabel
        Left = 408
        Top = 48
        Width = 56
        Height = 13
        Alignment = taCenter
        Caption = '03.01.2024'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label3: TLabel
        Left = 408
        Top = 28
        Width = 63
        Height = 19
        Alignment = taCenter
        Caption = 'Mittwoch'
      end
      object lbFrDatum: TLabel
        Left = 675
        Top = 48
        Width = 56
        Height = 13
        Alignment = taCenter
        Caption = '05.01.2024'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label5: TLabel
        Left = 675
        Top = 28
        Width = 48
        Height = 19
        Alignment = taCenter
        Caption = 'Freitag'
      end
      object Label4: TLabel
        Left = 542
        Top = 28
        Width = 81
        Height = 19
        Alignment = taCenter
        Caption = 'Donnerstag'
      end
      object lbDoDatum: TLabel
        Left = 541
        Top = 48
        Width = 56
        Height = 13
        Alignment = taCenter
        Caption = '04.01.2024'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label32: TLabel
        Left = 21
        Top = 189
        Width = 50
        Height = 19
        Caption = 'Uhrzeit'
      end
      object Label33: TLabel
        Left = 21
        Top = 216
        Width = 108
        Height = 19
        Caption = 'Kontrolle durch'
      end
      object lbSaDatum: TLabel
        Left = 141
        Top = 170
        Width = 56
        Height = 13
        Alignment = taCenter
        Caption = '06.01.2024'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label6: TLabel
        Left = 141
        Top = 151
        Width = 60
        Height = 19
        Alignment = taCenter
        Caption = 'Samstag'
      end
      object Label9: TLabel
        Left = 275
        Top = 151
        Width = 58
        Height = 19
        Alignment = taCenter
        Caption = 'Sonntag'
      end
      object lbSoDatum: TLabel
        Left = 274
        Top = 170
        Width = 56
        Height = 13
        Alignment = taCenter
        Caption = '07.01.2024'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label12: TLabel
        Left = 141
        Top = 259
        Width = 529
        Height = 38
        Caption = 
          'Wenn eine Tag- und eine Nachtkontrolle am selben Tag erfolgen, d' +
          'ie zwei Datumswerte bitte durch / trennen!'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
      object edMoWer: TEdit
        Left = 140
        Top = 92
        Width = 120
        Height = 27
        Alignment = taCenter
        TabOrder = 1
        OnChange = edKG1Change
      end
      object edMoWann: TEdit
        Left = 140
        Top = 65
        Width = 120
        Height = 27
        Alignment = taCenter
        MaxLength = 13
        TabOrder = 0
        OnChange = edKG1Change
      end
      object edDiWann: TEdit
        Left = 274
        Top = 65
        Width = 120
        Height = 27
        Alignment = taCenter
        MaxLength = 13
        TabOrder = 2
        OnChange = edKG1Change
      end
      object edDiWer: TEdit
        Left = 274
        Top = 92
        Width = 120
        Height = 27
        Alignment = taCenter
        TabOrder = 3
        OnChange = edKG1Change
      end
      object edMiWer: TEdit
        Left = 408
        Top = 92
        Width = 120
        Height = 27
        Alignment = taCenter
        TabOrder = 5
        OnChange = edKG1Change
      end
      object edMiWann: TEdit
        Left = 408
        Top = 65
        Width = 120
        Height = 27
        Alignment = taCenter
        MaxLength = 13
        TabOrder = 4
        OnChange = edKG1Change
      end
      object edDoWer: TEdit
        Left = 541
        Top = 92
        Width = 120
        Height = 27
        Alignment = taCenter
        TabOrder = 7
        OnChange = edKG1Change
      end
      object edFrWer: TEdit
        Left = 675
        Top = 92
        Width = 120
        Height = 27
        Alignment = taCenter
        TabOrder = 9
        OnChange = edKG1Change
      end
      object edFrWann: TEdit
        Left = 675
        Top = 65
        Width = 120
        Height = 27
        Alignment = taCenter
        MaxLength = 13
        TabOrder = 8
        OnChange = edKG1Change
      end
      object edDoWann: TEdit
        Left = 541
        Top = 65
        Width = 120
        Height = 27
        Alignment = taCenter
        MaxLength = 13
        TabOrder = 6
        OnChange = edKG1Change
      end
      object edSaWer: TEdit
        Left = 140
        Top = 213
        Width = 120
        Height = 27
        Alignment = taCenter
        TabOrder = 11
        OnChange = edKG1Change
      end
      object edSaWann: TEdit
        Left = 140
        Top = 186
        Width = 120
        Height = 27
        Alignment = taCenter
        MaxLength = 13
        TabOrder = 10
        OnChange = edKG1Change
      end
      object edSoWann: TEdit
        Left = 274
        Top = 186
        Width = 120
        Height = 27
        Alignment = taCenter
        MaxLength = 13
        TabOrder = 12
        OnChange = edKG1Change
      end
      object edSoWer: TEdit
        Left = 275
        Top = 213
        Width = 120
        Height = 27
        Alignment = taCenter
        TabOrder = 13
        OnChange = edKG1Change
      end
    end
  end
  object pnlWochenberichtNeu: TPanel
    Left = 0
    Top = 0
    Width = 856
    Height = 60
    Align = alTop
    Color = 16707798
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 2
    object Label18: TLabel
      Left = 19
      Top = 20
      Width = 47
      Height = 19
      Caption = 'Datum'
    end
    object lbKW: TLabel
      Left = 239
      Top = 19
      Width = 18
      Height = 19
      Caption = '00'
    end
    object Label7: TLabel
      Left = 208
      Top = 20
      Width = 23
      Height = 19
      Caption = 'KW'
    end
    object lbSchonDa: TLabel
      Left = 328
      Top = 19
      Width = 346
      Height = 19
      Caption = 'Der Wochenbericht f'#252'r kw0 wurde bereits erstellt'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      Visible = False
    end
    object SpeedButton1: TSpeedButton
      Left = 814
      Top = 20
      Width = 23
      Height = 22
      Caption = '?'
      OnClick = SpeedButton1Click
    end
    object dtpDatum: TDateTimePicker
      Left = 72
      Top = 16
      Width = 119
      Height = 27
      Date = 45233.000000000000000000
      Time = 0.031765925930812950
      TabOrder = 0
      OnChange = dtpDatumChange
    end
  end
end
