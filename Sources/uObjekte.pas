unit uObjekte;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, AdvListV, ExtCtrls,
  Vcl.Imaging.pngimage;

type
  TfObjekte = class(TForm)
    Panel1: TPanel;
    Label12: TLabel;
    btnNeueWaffe: TButton;
    Label2: TLabel;
    lvObjekte: TAdvListView;
    procedure FormShow(Sender: TObject);
    procedure btnNeueWaffeClick(Sender: TObject);
    procedure lvObjekteDblClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  fObjekte: TfObjekte;

implementation

uses uMain, uDBFunktionen, uObjekteNeu, uObjekteBearbeiten;

{$R *.dfm}

procedure TfObjekte.btnNeueWaffeClick(Sender: TObject);
begin
  fObjekteNeu.ShowModal;
end;

procedure TfObjekte.FormShow(Sender: TObject);
begin
  showObjekteInListView(lvObjekte);
end;

procedure TfObjekte.lvObjekteDblClick(Sender: TObject);
var
  i: integer;
begin
  i := lvObjekte.ItemIndex;
  if(i<>-1) then
  begin
    with fObjekteBearbeiten do
    begin
      EntryID := StrToInt(lvObjekte.Items[i].SubItems[1]);
      ShowModal;
      PageControl1.ActivePageIndex := 0;
    end;
  end;
end;

end.
