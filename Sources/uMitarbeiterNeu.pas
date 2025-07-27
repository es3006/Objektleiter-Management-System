unit uMitarbeiterNeu;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Mask, MaskEdEx, System.UITypes,
  AdvListV, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls;

type
  TfMitarbeiterNeu = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Label3: TLabel;
    Label2: TLabel;
    Label1: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label19: TLabel;
    Label11: TLabel;
    edPersonalNr: TEdit;
    edVorname: TEdit;
    edNachname: TEdit;
    edEintrittsdatum: TMaskEditEx;
    edAustrittsdatum: TMaskEditEx;
    edGeburtsdatum: TMaskEditEx;
    cbObjekt: TComboBox;
    cbWaffennummer: TComboBox;
    Daten: TTabSheet;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    edAusweisNr: TEdit;
    edSonderausweisNr: TEdit;
    edAusweisGueltigkeit: TMaskEditEx;
    edSonderausweisGueltigkeit: TMaskEditEx;
    Adresse: TTabSheet;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    edStrasse: TEdit;
    edHausNr: TEdit;
    edPLZ: TEdit;
    edOrt: TEdit;
    Kontakt: TTabSheet;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    edTelefon: TEdit;
    edHandy: TEdit;
    edEmail: TEdit;
    Aushilfsobjekte: TTabSheet;
    Label20: TLabel;
    lvObjekte: TAdvListView;
    btnSave: TButton;
    Shape2: TShape;
    Shape1: TShape;
    Shape3: TShape;
    Image1: TImage;
    procedure btnSaveClick(Sender: TObject);
    procedure edEintrittsdatumDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PageControl1Changing(Sender: TObject; var AllowChange: Boolean);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  fMitarbeiterNeu: TfMitarbeiterNeu;

implementation

uses uMain, uFunktionen, uDBFunktionen, uMitarbeiter;

{$R *.dfm}

procedure TfMitarbeiterNeu.btnSaveClick(Sender: TObject);
var
  FDQuery: TFDQuery;
  personalnr, nachname, vorname: string;
  dt: TDateTime;
  Erfolg: boolean;
  LastID: integer;
  ERROR: boolean;
  i, ObjektID: integer;
begin
  ObjektID :=0;
  ERROR    := false;

  personalnr := trim(edPersonalNr.Text);
  nachname   := trim(edNachname.Text);
  vorname    := trim(edVorname.Text);

  if(personalnr='') OR (nachname='') OR (vorname='') OR (cbObjekt.ItemIndex<0) then
  begin
    showmessage('Bitte füllen Sie die Pflichtfelder aus!'+#13#10+'Pflichtfelder sind fett markiert');
    exit;
  end;

  FDQuery := TFDQuery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

//Mitarbeiterdaten in DB Tabelle mitarbeiter speichern
      SQL.Text := 'INSERT INTO mitarbeiter (objektid, personalnr, nachname, vorname, geburtsdatum, '+
                  'eintrittsdatum, austrittsdatum, waffennummer, ausweisnr, ausweisgueltigbis, '+
                  'sonderausweisnr, sonderausweisgueltigbis) VALUES (:OBJEKTID, :PERSONALNR, :NACHNAME, '+
                  ':VORNAME, :GEBURTSDATUM, :EINTRITTSDATUM, :AUSTRITTSDATUM, :WAFFENNUMMER, :AUSWEISNR, '+
                  ':AUSWEISGUELTIGBIS, :SONDERAUSWEISNR, :SONDERAUSWEISGUELTIGBIS);';

      ObjektID := Integer(cbObjekt.Items.Objects[cbObjekt.ItemIndex]);
      if(ObjektID<0) then ObjektID := 0;

      Params.ParamByName('OBJEKTID').AsInteger := ObjektID;
      Params.ParamByName('PERSONALNR').AsString := edPersonalNr.Text;
      Params.ParamByName('NACHNAME').AsString := edNachname.Text;
      Params.ParamByName('VORNAME').AsString := edVorname.Text;

      erfolg := TryStrToDate(edGeburtsdatum.Text, dt);
      if(erfolg) then Params.ParamByName('GEBURTSDATUM').AsString := ConvertGermanDateToSQLDate(edGeburtsdatum.Text, false)
      else Params.ParamByName('GEBURTSDATUM').AsString := '';

      erfolg := TryStrToDate(edEintrittsdatum.Text, dt);
      if(erfolg) then Params.ParamByName('EINTRITTSDATUM').AsString := ConvertGermanDateToSQLDate(edEintrittsdatum.Text, false)
      else Params.ParamByName('EINTRITTSDATUM').AsString := '';

      erfolg := TryStrToDate(edAustrittsdatum.Text, dt);
      if(erfolg) then Params.ParamByName('AUSTRITTSDATUM').AsString := ConvertGermanDateToSQLDate(edAustrittsdatum.Text, false)
      else Params.ParamByName('AUSTRITTSDATUM').AsString := '';

      Params.ParamByName('WAFFENNUMMER').AsString := cbWaffennummer.Text;
      Params.ParamByName('AUSWEISNR').AsString := edAusweisNr.Text;

      erfolg := TryStrToDate(edAusweisGueltigkeit.Text, dt);
      if(erfolg) then Params.ParamByName('AUSWEISGUELTIGBIS').AsString := ConvertGermanDateToSQLDate(edAusweisGueltigkeit.Text, false)
      else Params.ParamByName('AUSWEISGUELTIGBIS').AsString := '';

      Params.ParamByName('SONDERAUSWEISNR').AsString := edSonderAusweisNr.Text;

      erfolg := TryStrToDate(edSonderausweisGueltigkeit.Text, dt);
      if(erfolg) then Params.ParamByName('SONDERAUSWEISGUELTIGBIS').AsString := ConvertGermanDateToSQLDate(edSonderausweisGueltigkeit.Text, false)
      else Params.ParamByName('SONDERAUSWEISGUELTIGBIS').AsString := '';

      ExecSQL;

//ID des zuletzt erzeugten Datensatzes ermitteln (MitarbeiterID)
      SQL.Text := 'SELECT last_insert_rowid() AS LastID';
      Open;
      LastID := FieldByName('LastID').AsInteger;



//Adress- und Kontaktdaten des Mitarbeiters in der DB Tabelle kontakte speichern
      SQL.Text := 'INSERT INTO mitarbeiter_kontaktdaten (mitarbeiterid, telefon, handy, email, strasse, hausnr, plz, ort) ' +
                  'VALUES (:MITARBEITERID, :TELEFON, :HANDY, :EMAIL, :STRASSE, :HAUSNR, :PLZ, :ORT);';
      Params.ParamByName('MITARBEITERID').AsInteger := LastID;
      Params.ParamByName('TELEFON').AsString := edTelefon.Text;
      Params.ParamByName('HANDY').AsString := edHandy.Text;
      Params.ParamByName('EMAIL').AsString := edEmail.Text;
      Params.ParamByName('STRASSE').AsString := edStrasse.Text;
      Params.ParamByName('HAUSNR').AsString := edHausNr.Text;
      Params.ParamByName('PLZ').AsString := edPLZ.Text;
      Params.ParamByName('ORT').AsString := edOrt.Text;
      ExecSQL;



{*******************************************************************************
  Alle Objekte in denen der Mitarbeiter aushelfen darf aktualisieren           *
*******************************************************************************}
      for i := 0 to lvObjekte.Items.Count - 1 do
      begin
        //Jeden Eintrag aus lvObjekte durchgehen
        objektid := StrToInt(lvObjekte.Items[i].SubItems[1]); //Objektid des angehakten Eintrages in ListView

        if(lvObjekte.Items[i].Checked) then
        begin
          SQL.Clear;
          SQL.Text := 'INSERT INTO mitarbeiter_objekte (mitarbeiterid, objektid) ' +
                      'VALUES(:MAID, :OBID)';
          Params.ParamByName('MAID').AsInteger := LastID;
          Params.ParamByName('OBID').AsInteger := objektid;
          ExecSQL;
        end;
      end; //for


    end; //with q
  except
    on E: Exception do
    begin
      ERROR := true;
      ShowMessage('Fehler beim Einfügen der Daten: ' + E.Message);
    end;
  end;


  if(ERROR = true) then
  begin
    showmessage('Fehler beim speichern des Mitarbeiters in der Datenbank');
  end;


  if(ERROR = false) then
  begin
    edPersonalNr.Clear;
    edNachname.Clear;
    edVorname.Clear;
    edAusweisNr.Clear;
    edSonderausweisnr.Clear;
    cbWaffennummer.ItemIndex := -1;
    edTelefon.Clear;
    edHandy.Clear;
    edEmail.Clear;
    edStrasse.Clear;
    edHausNr.Clear;
    edPLZ.Clear;
    edOrt.Clear;

    edGeburtsdatum.Clear;
    edEintrittsdatum.Clear;
    edAustrittsdatum.Clear;
    edAusweisGueltigkeit.Clear;
    edSonderausweisGueltigkeit.Clear;

    FDQuery.Free;

    fMitarbeiter.cbObjektSelect(self);

    close;
  end;
end;


procedure TfMitarbeiterNeu.edEintrittsdatumDblClick(Sender: TObject);
begin
  if(MessageDlg('Wollen Sie wirklich das Datum löschen?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    TMaskEditEx(Sender).Clear;
    TMaskEditEx(Sender).SelectAll;
  end;
end;

procedure TfMitarbeiterNeu.FormShow(Sender: TObject);
begin
  cbWaffenNummer.ItemIndex := -1;

  showSerienNrByNrWBKInCB(cbWaffennummer, 'Alle');
  showObjekteInComboBox(cbObjekt);
  showObjekteInListView(lvObjekte);

  cbObjekt.ItemIndex := -1;

  PageControl1.ActivePageIndex := 0;
  edPersonalNr.SetFocus;

  edPersonalNr.Clear;
  edNachname.Clear;
  edVorname.Clear;
  edAusweisNr.Clear;
  edSonderausweisnr.Clear;
  cbWaffennummer.ItemIndex := -1;
  edTelefon.Clear;
  edHandy.Clear;
  edEmail.Clear;
  edStrasse.Clear;
  edHausNr.Clear;
  edPLZ.Clear;
  edOrt.Clear;

  edGeburtsdatum.Clear;
  edEintrittsdatum.Clear;
  edAustrittsdatum.Clear;
  edAusweisGueltigkeit.Clear;
  edSonderausweisGueltigkeit.Clear;
end;

procedure TfMitarbeiterNeu.PageControl1Changing(Sender: TObject;
  var AllowChange: Boolean);
begin
  if(PageControl1.ActivePageIndex = 0) then
    edPersonalNr.SetFocus;

  if(PageControl1.ActivePageIndex = 1) then
    edAusweisNr.SetFocus;

  if(PageControl1.ActivePageIndex = 2) then
    edStrasse.SetFocus;

  if(PageControl1.ActivePageIndex = 3) then
    edTelefon.SetFocus;
end;

end.
