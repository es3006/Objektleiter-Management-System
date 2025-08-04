object FrameWochenberichtEdit: TFrameWochenberichtEdit
  Left = 0
  Top = 0
  Width = 1200
  Height = 709
  TabOrder = 0
  object pnlWochenberichtEdit: TPanel
    Left = 0
    Top = 0
    Width = 1200
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    Color = 16707798
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
    DesignSize = (
      1200
      60)
    object Jahr: TLabel
      Left = 19
      Top = 20
      Width = 30
      Height = 19
      Caption = 'Jahr'
    end
    object Label29: TLabel
      Left = 197
      Top = 20
      Width = 106
      Height = 19
      Caption = 'Kalenderwoche'
    end
    object imgPDF: TImage
      AlignWithMargins = True
      Left = 1151
      Top = 15
      Width = 32
      Height = 32
      Cursor = crHandPoint
      Hint = 
        'Den gew'#228'hlten Wochenbericht als PDF speichern|Den gew'#228'hlten Woch' +
        'enbericht als PDF speichern'
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
      OnClick = imgPDFClick
    end
    object lbStartDatumEndDatum: TLabel
      Left = 408
      Top = 19
      Width = 180
      Height = 19
      Caption = '01.01.2024 - 07.01.2024'
    end
    object cbJahr: TComboBox
      Left = 72
      Top = 16
      Width = 89
      Height = 27
      Style = csDropDownList
      TabOrder = 0
      OnSelect = cbJahrSelect
    end
    object cbKalenderwoche: TComboBox
      Left = 315
      Top = 16
      Width = 70
      Height = 27
      Style = csDropDownList
      TabOrder = 1
      OnSelect = cbKalenderwocheSelect
    end
  end
  object PageControl_Wochenbericht: TAdvPageControl
    Left = 0
    Top = 60
    Width = 1200
    Height = 594
    Cursor = crHandPoint
    ActivePage = AdvTabSheet9
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
    LowerActive = 0
    Version = '2.0.5.0'
    PersistPagesState.Location = plRegistry
    PersistPagesState.Enabled = False
    TabHeight = 50
    TabOrder = 1
    TabWidth = 200
    object AdvTabSheet8: TAdvTabSheet
      Caption = 'Informatives'
      Color = clWhite
      ColorTo = clNone
      TabColor = clBtnFace
      TabColorTo = clNone
      object GridPanel1: TGridPanel
        Left = 0
        Top = 0
        Width = 1192
        Height = 534
        Align = alClient
        ColumnCollection = <
          item
            Value = 50.000000000000000000
          end
          item
            Value = 50.000000000000000000
          end>
        ControlCollection = <
          item
            Column = 1
            Control = Panel4
            Row = 0
          end
          item
            Column = 0
            Control = Panel3
            Row = 0
          end>
        RowCollection = <
          item
            Value = 100.000000000000000000
          end>
        ShowCaption = False
        TabOrder = 0
        VerticalAlignment = taAlignTop
        object Panel4: TPanel
          Left = 596
          Top = 1
          Width = 595
          Height = 532
          Align = alClient
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          DesignSize = (
            595
            532)
          object Label27: TLabel
            Left = 20
            Top = 14
            Width = 550
            Height = 19
            Anchors = [akLeft, akTop, akRight]
            AutoSize = False
            Caption = 'Kundenbeschwerden- und Anforderungen'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object Label25: TLabel
            Left = 20
            Top = 137
            Width = 550
            Height = 19
            Anchors = [akLeft, akTop, akRight]
            AutoSize = False
            Caption = 'Ben'#246'tigte Ausbildungen'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object Label23: TLabel
            Left = 20
            Top = 226
            Width = 550
            Height = 19
            Anchors = [akLeft, akTop, akRight]
            AutoSize = False
            Caption = 'Ben'#246'tigte Ausr'#252'stung'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object Label21: TLabel
            Left = 20
            Top = 323
            Width = 550
            Height = 19
            Anchors = [akLeft, akTop, akRight]
            AutoSize = False
            Caption = 'Sonstiges'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object edKB1: TEdit
            Left = 20
            Top = 39
            Width = 550
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            MaxLength = 110
            TabOrder = 0
            Text = '-----'
            OnChange = edKG1Change
            OnExit = edKG1Exit
          end
          object edKB2: TEdit
            Left = 20
            Top = 66
            Width = 550
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            MaxLength = 110
            TabOrder = 1
            OnChange = edKG1Change
            OnExit = edKG1Exit
          end
          object edKB3: TEdit
            Left = 20
            Top = 93
            Width = 550
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            MaxLength = 110
            TabOrder = 2
            OnChange = edKG1Change
            OnExit = edKG1Exit
          end
          object edAu1: TEdit
            Left = 20
            Top = 159
            Width = 550
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            MaxLength = 110
            TabOrder = 3
            Text = '-----'
            OnChange = edKG1Change
            OnExit = edKG1Exit
          end
          object edAu2: TEdit
            Left = 20
            Top = 186
            Width = 550
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            MaxLength = 110
            TabOrder = 4
            OnChange = edKG1Change
            OnExit = edKG1Exit
          end
          object edAr1: TEdit
            Left = 20
            Top = 248
            Width = 550
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            MaxLength = 110
            TabOrder = 5
            Text = '-----'
            OnChange = edKG1Change
            OnExit = edKG1Exit
          end
          object edAr2: TEdit
            Left = 20
            Top = 275
            Width = 550
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            MaxLength = 110
            TabOrder = 6
            OnChange = edKG1Change
            OnExit = edKG1Exit
          end
          object edSo1: TEdit
            Left = 20
            Top = 345
            Width = 550
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            MaxLength = 110
            TabOrder = 7
            Text = '-----'
            OnChange = edKG1Change
            OnExit = edKG1Exit
          end
          object edSo2: TEdit
            Left = 20
            Top = 372
            Width = 550
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            MaxLength = 110
            TabOrder = 8
            OnChange = edKG1Change
            OnExit = edKG1Exit
          end
        end
        object Panel3: TPanel
          Left = 1
          Top = 1
          Width = 595
          Height = 532
          Align = alClient
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 1
          DesignSize = (
            595
            532)
          object Label28: TLabel
            Left = 28
            Top = 15
            Width = 550
            Height = 19
            Anchors = [akLeft, akTop, akRight]
            AutoSize = False
            Caption = 'Kundengespr'#228'che- und Betreuung'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object Label26: TLabel
            Left = 28
            Top = 137
            Width = 550
            Height = 19
            Anchors = [akLeft, akTop, akRight]
            AutoSize = False
            Caption = 'Personalbedarf- und Probleme'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object Label24: TLabel
            Left = 28
            Top = 226
            Width = 550
            Height = 19
            Anchors = [akLeft, akTop, akRight]
            AutoSize = False
            Caption = 'Mehr- und Minderdienste'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object Label22: TLabel
            Left = 28
            Top = 323
            Width = 550
            Height = 19
            Anchors = [akLeft, akTop, akRight]
            AutoSize = False
            Caption = 'Besondere Vorkommnisse'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object edKG1: TEdit
            Left = 28
            Top = 39
            Width = 550
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            MaxLength = 110
            TabOrder = 0
            Text = '-----'
            OnChange = edKG1Change
            OnExit = edKG1Exit
          end
          object edKG2: TEdit
            Left = 28
            Top = 66
            Width = 550
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            MaxLength = 110
            TabOrder = 1
            OnChange = edKG1Change
            OnExit = edKG1Exit
          end
          object edKG3: TEdit
            Left = 28
            Top = 93
            Width = 550
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            MaxLength = 110
            TabOrder = 2
            OnChange = edKG1Change
            OnExit = edKG1Exit
          end
          object edPB1: TEdit
            Left = 28
            Top = 159
            Width = 550
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            MaxLength = 110
            TabOrder = 3
            Text = '-----'
            OnChange = edKG1Change
            OnExit = edKG1Exit
          end
          object edPB2: TEdit
            Left = 28
            Top = 186
            Width = 550
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            MaxLength = 110
            TabOrder = 4
            OnChange = edKG1Change
            OnExit = edKG1Exit
          end
          object edMd1: TEdit
            Left = 28
            Top = 248
            Width = 550
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            MaxLength = 110
            TabOrder = 5
            Text = '-----'
            OnChange = edKG1Change
            OnExit = edKG1Exit
          end
          object edMd2: TEdit
            Left = 28
            Top = 275
            Width = 550
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            MaxLength = 110
            TabOrder = 6
            OnChange = edKG1Change
            OnExit = edKG1Exit
          end
          object edVk1: TEdit
            Left = 28
            Top = 345
            Width = 550
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            MaxLength = 110
            TabOrder = 7
            Text = '-----'
            OnChange = edKG1Change
            OnExit = edKG1Exit
          end
          object edVk2: TEdit
            Left = 28
            Top = 372
            Width = 550
            Height = 27
            Anchors = [akLeft, akTop, akRight]
            MaxLength = 110
            TabOrder = 8
            OnChange = edKG1Change
            OnExit = edKG1Exit
          end
        end
      end
    end
    object AdvTabSheet9: TAdvTabSheet
      Caption = 'Kontrollen'
      Color = clWhite
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
        Left = 139
        Top = 259
        Width = 529
        Height = 38
        Caption = 
          'Wenn eine Tag- und eine Nachtkontrolle am selben Tag erfolgen, d' +
          'ie zwei Datumswerte bitte durch / trennen!'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
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
        MaxLength = 100
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
        MaxLength = 100
        TabOrder = 3
        OnChange = edKG1Change
      end
      object edMiWer: TEdit
        Left = 408
        Top = 92
        Width = 120
        Height = 27
        Alignment = taCenter
        MaxLength = 100
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
        MaxLength = 100
        TabOrder = 7
        OnChange = edKG1Change
      end
      object edFrWer: TEdit
        Left = 675
        Top = 92
        Width = 120
        Height = 27
        Alignment = taCenter
        MaxLength = 100
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
        MaxLength = 100
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
        Left = 274
        Top = 213
        Width = 120
        Height = 27
        Alignment = taCenter
        MaxLength = 100
        TabOrder = 13
        OnChange = edKG1Change
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 654
    Width = 1200
    Height = 55
    Align = alBottom
    BevelOuter = bvNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ShowCaption = False
    TabOrder = 2
    DesignSize = (
      1200
      55)
    object btnUpdateWochenbericht: TButton
      Left = 939
      Top = 6
      Width = 231
      Height = 40
      Anchors = [akTop, akRight]
      Caption = #196'nderungen speichern'
      Enabled = False
      TabOrder = 0
      OnClick = btnUpdateWochenberichtClick
    end
    object btnNeuerWochenbericht: TButton
      Left = 33
      Top = 6
      Width = 293
      Height = 40
      Caption = 'Neuen Wochenbericht erstellen'
      TabOrder = 1
      OnClick = btnNeuerWochenberichtClick
    end
  end
  object SaveDialog1: TSaveDialog
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 493
    Top = 547
  end
end
