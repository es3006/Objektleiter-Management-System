unit uWebBrowser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, StdCtrls, ExtCtrls, AdvCustomControl,
  AdvWebBrowser;

type
  TfWebBrowser = class(TForm)
    PrintDialog1: TPrintDialog;
    PrinterSetupDialog1: TPrinterSetupDialog;
    OpenDialog1: TOpenDialog;
    AdvWebBrowser2: TAdvWebBrowser;
  private

  public

  end;





var
  fWebBrowser: TfWebBrowser;

implementation

{$R *.dfm}














end.
