unit uObjekteBearbeiten;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param,
  Vcl.ExtCtrls, Vcl.Imaging.pngimage, System.UITypes;

type
  TfObjekteBearbeiten = class(TForm)
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    Image1: TImage;
    Panel2: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Label1: TLabel;
    Shape1: TShape;
    edObjektname: TEdit;
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
    btnDelete: TButton;
    btnSave: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    EntryID: integer;
  end;

var
  fObjekteBearbeiten: TfObjekteBearbeiten;



implementation

{$R *.dfm}

uses uMain, uObjekte;

procedure TfObjekteBearbeiten.btnDeleteClick(Sender: TObject);
var
  FDQuery: TFDQuery;
begin
  if MessageDlg('Wollen Sie dieses Objekt wirklich löschen?',mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
  begin
    FDQuery := TFDquery.Create(nil);
    try
      with FDQuery do
      begin
        Connection := fMain.FDConnection1;

        SQL.Text := 'DELETE FROM objekte WHERE id = :ID;';
        Params.ParamByName('ID').AsInteger := EntryID;
        ExecSQL;
      end;
    finally
      FDQuery.free;

      fObjekte.lvObjekte.Items[fObjekte.lvObjekte.ItemIndex].Delete;
      close;
    end;
  end;
end;




procedure TfObjekteBearbeiten.btnSaveClick(Sender: TObject);
var
  FDQuery: TFDQuery;
  objektname, strasse, hausnr, plz, ort: string;
  tel1, tel2, tel3, tel1Beschr, tel2Beschr, tel3Beschr: string;
  i: integer;
begin
  objektname := trim(edObjektname.Text);
  strasse    := trim(edStrasse.Text);
  hausnr     := trim(edhausNr.Text);
  plz        := trim(edPLZ.Text);
  ort        := trim(edOrt.Text);
  tel1       := trim(edtel1.Text);
  tel1Beschr := trim(edtel1Beschreibung.Text);
  tel2       := trim(edtel2.Text);
  tel2Beschr := trim(edtel2Beschreibung.Text);
  tel3       := trim(edtel3.Text);
  tel3Beschr := trim(edtel3Beschreibung.Text);


  if(objektname='') OR (ort='') then
  begin
    showmessage('Bitte füllen Sie die Pflichtfelder aus!'+#13#10+'Pflichtfelder sind fett markiert');
    exit;
  end;

  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

//Mitarbeiterdaten in DB Tabelle mitarbeiter updaten
      SQL.Text := 'UPDATE objekte SET objektname = :OBJEKTNAME, strasse = :STRASSE, hausnr = :HAUSNR, ' +
                  'plz = :PLZ, ort = :ORT, tel1 = :TEL1, tel1beschreibung = :TEL1BESCHR, ' +
                  'tel2 = :TEL2, tel2beschreibung = :TEL2BESCHR, tel3 = :TEL3, ' +
                  'tel3beschreibung = :TEL3BESCHR WHERE id = :ID;';

      Params.ParamByName('ID').AsInteger := EntryID;
      Params.ParamByName('OBJEKTNAME').AsString := edObjektname.Text;
      Params.ParamByName('STRASSE').AsString := edStrasse.Text;
      Params.ParamByName('HAUSNR').AsString := edHausNr.Text;
      Params.ParamByName('PLZ').AsString := edPLZ.Text;
      Params.ParamByName('ORT').AsString := edOrt.Text;
      Params.ParamByName('TEL1').AsString := edTel1.Text;
      Params.ParamByName('TEL1BESCHR').AsString := edTel1Beschreibung.Text;
      Params.ParamByName('TEL2').AsString := edTel2.Text;
      Params.ParamByName('TEL2BESCHR').AsString := edTel2Beschreibung.Text;
      Params.ParamByName('TEL3').AsString := edTel3.Text;
      Params.ParamByName('TEL3BESCHR').AsString := edTel3Beschreibung.Text;
      ExecSQL;
    end;
  finally
    FDQuery.free;

    i := fObjekte.lvObjekte.ItemIndex;
    if(i<>-1) then
    begin
      with fObjekte.lvObjekte.Items[i] do
      begin
        Caption := Objektname;
        SubItems[0] := Ort;
      end;
    end;
  end;
  close;
end;





procedure TfObjekteBearbeiten.FormCreate(Sender: TObject);
begin
  EntryID := -1;
end;



procedure TfObjekteBearbeiten.FormShow(Sender: TObject);
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT id, objektname, strasse, hausnr, plz, ort, ' +
                  'tel1, tel1beschreibung, tel2, tel2beschreibung, '+
                  'tel3, tel3beschreibung FROM objekte WHERE id = :ID;';

      Params.ParamByName('ID').AsInteger := EntryID;
      Open;

      while not Eof do
      begin
        edObjektname.Text       := FieldByName('objektname').AsString;
        edStrasse.Text          := FieldByName('strasse').AsString;
        edHausNr.Text           := FieldByName('hausnr').AsString;
        edPLZ.Text              := FieldByName('plz').AsString;
        edOrt.Text              := FieldByName('ort').AsString;
        edTel1.Text             := FieldByName('tel1').AsString;
        edTel1Beschreibung.Text := FieldByName('tel1beschreibung').AsString;
        edTel2.Text             := FieldByName('tel2').AsString;
        edTel2Beschreibung.Text := FieldByName('tel2beschreibung').AsString;
        edTel3.Text             := FieldByName('tel3').AsString;
        edTel3Beschreibung.Text := FieldByName('tel3beschreibung').AsString;

        Next;
      end;
    end;
  finally
    FDQuery.free;
  end;
end;




end.
