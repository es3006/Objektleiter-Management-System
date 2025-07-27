object fDatumMeldender: TfDatumMeldender
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  ClientHeight = 216
  ClientWidth = 321
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  OnShow = FormShow
  TextHeight = 19
  object Label1: TLabel
    Left = 24
    Top = 15
    Width = 47
    Height = 19
    Caption = 'Datum'
  end
  object Label2: TLabel
    Left = 24
    Top = 80
    Width = 73
    Height = 19
    Caption = 'Meldender'
  end
  object dtpDatum: TDateTimePicker
    Left = 24
    Top = 40
    Width = 137
    Height = 27
    Date = 45475.000000000000000000
    Time = 0.518522025478887400
    TabOrder = 0
  end
  object cbMitarbeiter: TComboBox
    Left = 24
    Top = 105
    Width = 273
    Height = 27
    Style = csDropDownList
    DropDownCount = 20
    TabOrder = 1
  end
  object Button1: TButton
    Left = 24
    Top = 152
    Width = 273
    Height = 41
    Caption = 'Speichern'
    TabOrder = 2
    OnClick = Button1Click
  end
end
