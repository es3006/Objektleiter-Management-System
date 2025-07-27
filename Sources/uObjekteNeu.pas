unit uObjekteNeu;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param,
  Vcl.ExtCtrls, Vcl.Imaging.pngimage;

type
  TfObjekteNeu = class(TForm)
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    Panel2: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Label1: TLabel;
    Shape1: TShape;
    edObjektname: TEdit;
    btnWeiter1: TButton;
    Anschrift: TTabSheet;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label3: TLabel;
    Shape2: TShape;
    edStrasse: TEdit;
    edPLZ: TEdit;
    edOrt: TEdit;
    edHausNr: TEdit;
    Kontakt: TTabSheet;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label11: TLabel;
    Label10: TLabel;
    Label9: TLabel;
    edTel1: TEdit;
    edTel2: TEdit;
    edTel3: TEdit;
    edTel3Beschreibung: TEdit;
    edTel2Beschreibung: TEdit;
    edTel1Beschreibung: TEdit;
    btnSave: TButton;
    Image1: TImage;
    procedure btnSaveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  fObjekteNeu: TfObjekteNeu;

implementation

{$R *.dfm}

uses uMain, uObjekte;

procedure TfObjekteNeu.btnSaveClick(Sender: TObject);
var
  objektname, ort: string;
  l: TListItem;
  LastInsertID: Integer;
  FDQuery: TFDQuery;
begin
  LastInsertID := 0;
  objektname   := trim(edobjektname.Text);
  ort          := trim(edOrt.Text);

  if(objektname='') OR (ort='') then
  begin
    showmessage('Bitte füllen Sie die Pflichtfelder aus!'+#13#10+'Pflichtfelder sind fett markiert');
    exit;
  end;


  FDQuery := TFDQuery.Create(nil);
  with FDQuery do
  begin
    Connection := fMain.FDConnection1;

//Mitarbeiterdaten in DB Tabelle mitarbeiter speichern
    SQL.Text := 'INSERT INTO objekte (objektname, strasse, hausnr, plz, ort, ' +
                'tel1beschreibung, tel1, tel2beschreibung, tel2, tel3beschreibung, tel3) ' +
                'VALUES(:OBJEKTNAME, :STRASSE, :HAUSNR, :PLZ, :ORT, ' +
                ':TEL1BESCHREIBUNG, :TEL1, :TEL2BESCHREIBUNG, :TEL2, :TEL3BESCHREIBUNG, :TEL3);';
    Params.ParamByName('OBJEKTNAME').AsString := edObjektname.Text;
    Params.ParamByName('STRASSE').AsString := edStrasse.Text;
    Params.ParamByName('HAUSNR').AsString := edHausNr.Text;
    Params.ParamByName('PLZ').AsString := edPLZ.Text;
    Params.ParamByName('ORT').AsString := edOrt.Text;
    Params.ParamByName('TEL1BESCHREIBUNG').AsString := edTel1Beschreibung.Text;
    Params.ParamByName('TEL1').AsString := edTel1.Text;
    Params.ParamByName('TEL2BESCHREIBUNG').AsString := edTel2Beschreibung.Text;
    Params.ParamByName('TEL2').AsString := edTel2.Text;
    Params.ParamByName('TEL3BESCHREIBUNG').AsString := edTel3Beschreibung.Text;
    Params.ParamByName('TEL3').AsString := edTel3.Text;
    try
      ExecSQL;
    except
      on E: Exception do
        ShowMessage('Fehler beim Speichern des neuen Objektes: ' + E.Message);
    end;

    SQL.Text := 'SELECT last_insert_rowid() AS LastID';
    Open;
    LastInsertID := FieldByName('LastID').AsInteger;
  end;


  //Eintrag in ListView lvObjekte auf Form Objekte eintragen
  with fObjekte.lvObjekte do
  begin
    l := Items.Add;
    l.Caption := edObjektname.Text; //Objektname
    l.SubItems.Add(edOrt.Text); //Objektort
    l.SubItems.Add(IntToStr(LastInsertID)); //ID
  end;


  edObjektname.Clear;
  edStrasse.Clear;
  edHausNr.Clear;
  edPLZ.Clear;
  edOrt.Clear;
  edTel1Beschreibung.Clear;
  edTel1.Clear;
  edTel2Beschreibung.Clear;
  edTel2.Clear;
  edTel3Beschreibung.Clear;
  edTel3.Clear;

  FDQuery.Free;

  close;
end;



procedure TfObjekteNeu.FormShow(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 0;
end;

end.
