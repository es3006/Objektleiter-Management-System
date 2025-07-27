unit uMitarbeiter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, AdvListV, Vcl.StdCtrls,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TfMitarbeiter = class(TForm)
    Panel1: TPanel;
    Label7: TLabel;
    StatusBar1: TStatusBar;
    Label2: TLabel;
    lvMitarbeiter: TAdvListView;
    Panel2: TPanel;
    Label9: TLabel;
    cbObjekt: TComboBox;
    Panel3: TPanel;
    btnMitarbeiterNeu: TButton;
    procedure FormShow(Sender: TObject);
    procedure cbObjektSelect(Sender: TObject);
    procedure lvMitarbeiterCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure lvMitarbeiterColumnClick(Sender: TObject; Column: TListColumn);
    procedure btnMitarbeiterNeuClick(Sender: TObject);
    procedure lvMitarbeiterDblClick(Sender: TObject);
  private
    procedure showMitarbeiterInListView(LV: TListView; objektid: integer);
  public
    { Public-Deklarationen }
  end;

var
  fMitarbeiter: TfMitarbeiter;

implementation

uses
  uMain, uFunktionen, uMitarbeiterNeu, uMitarbeiterEdit, uDBFunktionen;

{$R *.dfm}




procedure TfMitarbeiter.FormShow(Sender: TObject);
var
  i: integer;
begin
  //Objekte in ComboBox anzeigen (true = Ort auch anzeigen)
  showObjekteInComboBox(cbObjekt, true);

  //Wenn mindestens ein Objekt in der ComboBox steht, dieses selektieren (ALLE)
  if(cbObjekt.Items.Count > 0) then
  begin
    for i := 0 to cbObjekt.Items.Count - 1 do
    begin
      if Integer(cbObjekt.Items.Objects[i]) = OBJEKTID then
      begin
        cbObjekt.ItemIndex := i;
        cbObjektSelect(nil);
        Break;
      end;
    end;
  end;

  showMitarbeiterInListView(lvMitarbeiter, OBJEKTID);
end;





{******************************************************************************************
  Alle Mitarbeiter aus Datenbank-Tabelle mitarbeiter auslesen und in ListView anzeigen    *
******************************************************************************************}
procedure TfMitarbeiter.showMitarbeiterInListView(LV: TListView; objektid: integer);
var
  L: TListItem;
  FDQuery: TFDQuery;
begin
  ClearListView(LV);

  FDQuery := TFDquery.Create(nil);
  try
    FDQuery.Connection := fMain.FDConnection1;

    if(objektid > 0) then
    begin
      FDQuery.SQL.Text := 'SELECT id, personalnr, nachname, vorname, waffennummer, ausweisnr, ' +
                          'ausweisgueltigbis, sonderausweisnr, sonderausweisgueltigbis FROM mitarbeiter ' +
                          'WHERE objektid = :OBJEKTID ' +
                          'ORDER BY nachname ASC;';

      FDQuery.Params.ParamByName('OBJEKTID').AsInteger := objektid;
      FDQuery.Open;
    end
    else
    begin
      exit;
    end;


      while not FDQuery.Eof do
      begin
        l := LV.Items.Add;

        l.Caption := FDQuery.FieldByName('id').AsString;
        l.SubItems.Add(FDQuery.FieldByName('personalnr').AsString);
        l.SubItems.Add(FDQuery.FieldByName('nachname').AsString);
        l.SubItems.Add(FDQuery.FieldByName('vorname').AsString);
        l.SubItems.Add(FDQuery.FieldByName('ausweisnr').AsString);
        l.SubItems.Add(ConvertSQLDateToGermanDate(FDQuery.FieldByName('ausweisgueltigbis').AsString, false));
        l.SubItems.Add(FDQuery.FieldByName('sonderausweisnr').AsString);
        l.SubItems.Add(ConvertSQLDateToGermanDate(FDQuery.FieldByName('sonderausweisgueltigbis').AsString, false));
        l.SubItems.Add(FDQuery.FieldByName('waffennummer').AsString);

        FDQuery.Next;
      end;

  finally
    FDQuery.free;
  end;
end;





procedure TfMitarbeiter.btnMitarbeiterNeuClick(Sender: TObject);
begin
  fMitarbeiterNeu.ShowModal;
end;



procedure TfMitarbeiter.cbObjektSelect(Sender: TObject);
var
  i, objektID: Integer;
begin
  i := cbObjekt.ItemIndex;

  if i <> -1 then
  begin
    objektID := Integer(cbObjekt.Items.Objects[i]);

    showMitarbeiterInListView(lvMitarbeiter, objektID);
  end;
end;




procedure TfMitarbeiter.lvMitarbeiterColumnClick(Sender: TObject; Column: TListColumn);
begin
  lvColumnClickForSort(Sender, Column);
end;





procedure TfMitarbeiter.lvMitarbeiterCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  lvCompareForSort(Sender, Item1, Item2, Data, Compare);
end;







procedure TfMitarbeiter.lvMitarbeiterDblClick(Sender: TObject);
var i: integer;
begin
  i := lvMitarbeiter.ItemIndex;
  if(i<>-1) then
  begin
    with lvMitarbeiter.Items[lvMitarbeiter.ItemIndex] do
    begin
      fMitarbeiterEdit.USERID := caption;
      fMitarbeiterEdit.ShowModal;
    end;
  end;
end;








end.
