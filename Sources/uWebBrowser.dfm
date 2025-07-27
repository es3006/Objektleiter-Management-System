object fWebBrowser: TfWebBrowser
  Left = 0
  Top = 0
  Caption = 'Dokumentenansicht / Drucken'
  ClientHeight = 650
  ClientWidth = 987
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object AdvWebBrowser2: TAdvWebBrowser
    Left = 0
    Top = 0
    Width = 987
    Height = 650
    Align = alClient
    ParentDoubleBuffered = False
    DoubleBuffered = True
    TabOrder = 0
    Settings.EnableContextMenu = True
    Settings.EnableShowDebugConsole = True
    Settings.EnableAcceleratorKeys = True
    Settings.UsePopupMenuAsContextMenu = False
    ExplicitLeft = 96
    ExplicitTop = 200
    ExplicitWidth = 500
    ExplicitHeight = 350
  end
  object PrintDialog1: TPrintDialog
    Left = 432
    Top = 168
  end
  object PrinterSetupDialog1: TPrinterSetupDialog
    Left = 312
    Top = 160
  end
  object OpenDialog1: TOpenDialog
    Left = 184
    Top = 88
  end
end
