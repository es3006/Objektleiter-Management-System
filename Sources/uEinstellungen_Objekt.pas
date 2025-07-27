unit uEinstellungen_Objekt;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, DateUtils,
  Vcl.Imaging.pngimage, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TfEinstellungen_Objekt = class(TForm)
    Panel1: TPanel;
    Image2: TImage;
    cbObjekt: TComboBox;
    Label4: TLabel;
    cbObjektleiter: TComboBox;
    Label1: TLabel;
    cbStellvObjektleiter: TComboBox;
    Label2: TLabel;
    btnSaveWaffenMunition: TButton;
    Shape5: TShape;
    Shape1: TShape;
    procedure FormShow(Sender: TObject);
    procedure btnSaveWaffenMunitionClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  fEinstellungen_Objekt: TfEinstellungen_Objekt;

implementation

{$R *.dfm}


uses
  uMain, uDBFunktionen;



procedure TfEinstellungen_Objekt.btnSaveWaffenMunitionClick(Sender: TObject);
var
  SelOLID, SelSOLID: integer;
  FDQuery: TFDQuery;
begin
  SelOLID  := Integer(cbObjektleiter.Items.Objects[cbObjektleiter.ItemIndex]);
  SelSOLID := Integer(cbStellvObjektleiter.Items.Objects[cbStellvObjektleiter.ItemIndex]);

  if(SELOLID <> 0) AND (SELSOLID <> 0) then
  begin
    FDQuery := TFDquery.Create(nil);
    try
      with FDQuery do
      begin
        Connection := fMain.FDConnection1;

        SQL.Text := 'UPDATE einstellungen SET ObjektleiterID = :OLID, StellvObjektleiterID = :SOLID;';
        Params.ParamByName('OLID').AsInteger := SelOLID;
        Params.ParamByName('SOLID').AsInteger := SelSOLID;

        try
          ExecSQL;
        except
          on E: Exception do
          begin
            ShowMessage('Fehler beim speichern der Änderung in die Tabelle einstellungen: ' + E.Message);
          end;
        end;
      end;
    finally
      FDQuery.free;
      ReadSettingsFromDB; //Objekt, Objektleiter, Waffen und Munition
      ReadObjektleiterObjektSettings;
      close;
    end;
  end;
end;







procedure TfEinstellungen_Objekt.FormShow(Sender: TObject);
var
  i: integer;
begin
  //Objekt
  showObjekteInComboBox(cbObjekt, true);

  //Gespeichertes Objekt selektieren
  for i := 0 to cbObjekt.Items.Count - 1 do
  begin
    if Integer(cbObjekt.Items.Objects[i]) = OBJEKTID then
    begin
      cbObjekt.ItemIndex := i;
      Break;
    end;
  end;

  //Objektleiter
  showMitarbeiterInComboBox(cbObjektleiter, MonthOf(now), YearOf(now), false, OBJEKTID, 3);

  //Gespeicherten Objektleiter selektieren
  for i := 0 to cbObjektleiter.Items.Count - 1 do
  begin
    if Integer(cbObjektleiter.Items.Objects[i]) = OBJEKTLEITERID then
    begin
      cbObjektleiter.ItemIndex := i;
      Break;
    end;
  end;


  //Stellvertretender Objektleiter
  showMitarbeiterInComboBox(cbStellvObjektleiter, MonthOf(now), YearOf(now), false, OBJEKTID, 3);

  //Gespeicherten Stellvertretenden Objektleiter selektieren
  for i := 0 to cbStellvObjektleiter.Items.Count - 1 do
  begin
    if Integer(cbStellvObjektleiter.Items.Objects[i]) = STELLVOBJEKTLEITERID then
    begin
      cbStellvObjektleiter.ItemIndex := i;
      Break;
    end;
  end;
end;

end.
