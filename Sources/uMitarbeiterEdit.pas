unit uMitarbeiterEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Mask, MaskEdEx, DateUtils, Menus, System.UITypes,
  AdvListV, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls;

type
  TfMitarbeiterEdit = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    Panel2: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label19: TLabel;
    Label11: TLabel;
    edPersonalNr: TEdit;
    edNachname: TEdit;
    edVorname: TEdit;
    edEintrittsdatum: TMaskEditEx;
    edAustrittsdatum: TMaskEditEx;
    edGeburtsdatum: TMaskEditEx;
    cbObjekt: TComboBox;
    cbWaffennummer: TComboBox;
    TabSheet2: TTabSheet;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    edAusweisNr: TEdit;
    edSonderausweisNr: TEdit;
    edAusweisGueltigkeit: TMaskEditEx;
    edSonderausweisGueltigkeit: TMaskEditEx;
    Adressen: TTabSheet;
    Label12: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label13: TLabel;
    edStrasse: TEdit;
    edPLZ: TEdit;
    edOrt: TEdit;
    edHausNr: TEdit;
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
    btnDel: TButton;
    StatusBar1: TStatusBar;
    Label21: TLabel;
    cbDiensthund: TComboBox;
    Label22: TLabel;
    cbGutscheinart: TComboBox;
    procedure btnSaveClick(Sender: TObject);
    procedure edAustrittsdatumDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
    procedure cbDiensthundChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
   function UsereintraegeInDBTablesGefunden(USERID: string): Boolean;
  public
    USERID, ABSENDER: string;
  end;

var
  fMitarbeiterEdit: TfMitarbeiterEdit;


const
  Tabellen: array[0..2] of string = ('ausbildung', 'ausbildung_wachtest_tsw', 'wachpersonal');


  
implementation

uses uMain, uFunktionen, uDBFunktionen, uMitarbeiter;

{$R *.dfm}

function TfMitarbeiterEdit.UsereintraegeInDBTablesGefunden(USERID: string): Boolean;
var
  FDQuery: TFDQuery;
  i: Integer;
begin
  Result := False;
  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := fMain.FDConnection1; // Deine bestehende Datenbankverbindung

    // Schleife durch die Tabellen
    for i := 0 to High(Tabellen) do
    begin
      FDQuery.SQL.Text := 'SELECT id FROM ' + Tabellen[i] + ' WHERE mitarbeiterid = :MAID;';
      FDQuery.Params.ParamByName('MAID').AsInteger := StrToInt(USERID);
      FDQuery.Open;

      if FDQuery.RecordCount > 0 then
      begin
        Result := True;
        Exit; // Sobald ein Eintrag gefunden wird, kann die Funktion beendet werden.
      end;
    end;
  finally
    FDQuery.Free;
  end;
end;











procedure TfMitarbeiterEdit.btnDelClick(Sender: TObject);
var
  FDQuery: TFDQuery;
begin
  if(MessageDlg('Wollen Sie diesen Mitarbeiter wirklich löschen?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    FDQuery := TFDquery.Create(nil);
    try
      FDQuery.Connection := fMain.FDConnection1;

      with FDQuery do
      begin
        SQL.Text := 'DELETE FROM mitarbeiter WHERE id = :ID;';
        Params.ParamByName('ID').AsString := USERID;

        try
          ExecSQL;
        except
          on E: Exception do
            ShowMessage('Fehler beim löschen des Mitarbeiters aus der Tabelle "mitarbeiter": ' + E.Message);
        end;

        SQL.Text := 'DELETE FROM mitarbeiter_kontaktdaten WHERE mitarbeiterID = :ID;';
        Params.ParamByName('ID').AsString := USERID;

        try
          ExecSQL;
        except
          on E: Exception do
            ShowMessage('Fehler beim löschen des Mitarbeiters aus der Tabelle "mitarbeiter_kontaktdaten": ' + E.Message);
        end;



        SQL.Text := 'DELETE FROM admins WHERE mitarbeiterid = :ID;';
        Params.ParamByName('ID').AsString := USERID;

        try
          ExecSQL;
        except
          on E: Exception do
            ShowMessage('Fehler beim löschen des Mitarbeiters aus der Tabelle admins: ' + E.Message);
        end;
      end;
    finally
      fMitarbeiter.lvMitarbeiter.DeleteSelected;
      FDQuery.Free;
      close;
    end;
  end;
end;













procedure TfMitarbeiterEdit.btnSaveClick(Sender: TObject);
var
  FDQuery: TFDQuery;
  personalnr, nachname, vorname: string;
  dt: TDateTime;
  Erfolg: boolean;
  i, a, objektid: integer;
  ObjektFound: boolean;
  dhindex, dhid: integer;
begin
  ObjektFound := false;
  personalnr  := trim(edPersonalNr.Text);
  nachname    := trim(edNachname.Text);
  vorname     := trim(edVorname.Text);

  if(personalnr='') OR (nachname='') OR (vorname='') then
  begin
    showmessage('Bitte füllen Sie die Pflichtfelder aus!'+#13#10+'Pflichtfelder sind fett markiert');
    exit;
  end;

  FDQuery := TFDquery.Create(nil);
  try
    FDQuery.Connection := fMain.FDConnection1;

    with FDQuery do
    begin

{*******************************************************************************
  Mitarbeiterdaten in DB-Tabelle "mitarbeiter" updaten                         *
*******************************************************************************}
      SQL.Clear;
      SQL.Text := 'UPDATE mitarbeiter SET objektid = :OBJEKTID, personalnr = :PERSONALNR, ' +
                  'nachname = :NACHNAME, vorname = :VORNAME, geburtsdatum = :GEBURTSDATUM, ' +
                  'eintrittsdatum = :EINTRITTSDATUM, austrittsdatum = :AUSTRITTSDATUM, ' +
                  'waffennummer = :WAFFENNUMMER, ausweisnr = :AUSWEISNR, ' +
                  'ausweisgueltigbis = :AUSWEISGUELTIGBIS, sonderausweisnr = :SONDERAUSWEISNR, ' +
                  'sonderausweisgueltigbis = :SONDERAUSWEISGUELTIGBIS, tankgutscheinart = :GUTSCHEINART, diensthundID = :DIENSTHUNDID WHERE id = :ID;';

      Params.ParamByName('ID').AsString := USERID;
      Params.ParamByName('OBJEKTID').AsInteger := Integer(cbObjekt.Items.Objects[cbObjekt.ItemIndex]);
      Params.ParamByName('PERSONALNR').AsString := edPersonalNr.Text;
      Params.ParamByName('NACHNAME').AsString := edNachname.Text;
      Params.ParamByName('VORNAME').AsString := edVorname.Text;

      erfolg := TryStrToDate(edGeburtsdatum.Text, dt);
      if(erfolg) then Params.ParamByName('GEBURTSDATUM').AsString := ConvertGermanDateToSQLDate(edgeburtsdatum.Text, false)
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

      Params.ParamByName('GUTSCHEINART').AsString := cbGutscheinart.Items[cbGutscheinart.ItemIndex];


      dhindex := cbDiensthund.ItemIndex;
      if dhindex <> -1 then
      begin
        dhid := Integer(cbDiensthund.Items.Objects[dhindex]);
      end
      else
      begin
        dhid := 0;
      end;
      Params.ParamByName('DIENSTHUNDID').AsInteger := dhid;



      try
        ExecSQL;
      except
        on E: Exception do
          ShowMessage('Fehler beim Speichern der Mitarbeiterdaten: ' + E.Message);
      end;


{*******************************************************************************
  Alle Objekte in denen der Mitarbeiter aushelfen darf aktualisieren           *
*******************************************************************************}

      for i := 0 to lvObjekte.Items.Count - 1 do
      begin
        //Jeden Eintrag aus lvObjekte durchgehen
        objektid := StrToInt(lvObjekte.Items[i].SubItems[1]); //Objektid des angehakten Eintrages in ListView

        //Objekt mit der selektierten ObjektID aus Datenbank auslesen
        SQL.Clear;
        SQL.Text := 'SELECT id FROM mitarbeiter_objekte WHERE mitarbeiterid = :MAID AND objektid = :OBID; ';

        Params.ParamByName('MAID').AsInteger := StrToInt(USERID);
        Params.ParamByName('OBID').AsInteger := objektid;
        Open;

        //In Datenbank schauen ob vorhanden
        if(RecordCount > 0) then ObjektFound := true else ObjektFound := false;

        //Wenn in Datenbank vorhanden und in ListBox nicht selektiert dann DELETE
        if(ObjektFound = true) AND (not lvObjekte.Items[i].Checked) then
        begin
          SQL.Clear;
          SQL.Text := 'DELETE FROM mitarbeiter_objekte WHERE mitarbeiterid = :MAID AND objektid = :OBID;';

          Params.ParamByName('MAID').AsString  := USERID;
          Params.ParamByName('OBID').AsInteger := objektid;
          try
            ExecSQL;
          except
            on E: Exception do
              ShowMessage('Fehler beim Speichern der Aushilfsobjekte: ' + E.Message);
          end;
        end;


        //Wenn nicht in DB vorhanden aber in ListView selektiert dann INSERT
        if(ObjektFound = false) AND (lvObjekte.Items[i].Checked) then
        begin
          SQL.Clear;
          SQL.Text := 'INSERT INTO mitarbeiter_objekte (mitarbeiterid, objektid) ' +
                      'VALUES(:MAID, :OBID);';

          Params.ParamByName('MAID').AsString  := USERID;
          Params.ParamByName('OBID').AsInteger := objektid;
          try
            ExecSQL;
          except
            on E: Exception do
              ShowMessage('Fehler beim Hinzufügen der Aushilfsobjekte: ' + E.Message);
          end;
        end;
      end; //for



{*******************************************************************************
  Adress- und Kontaktdaten in DB-Tabelle "kontakte" updaten                    *
*******************************************************************************}
      SQL.Clear;
      SQL.Text := 'SELECT id FROM mitarbeiter_kontaktdaten WHERE mitarbeiterid = :ID;';

      Params.ParamByName('ID').AsInteger := StrToInt(USERID);
      Open;


{*******************************************************************************
  Wenn bereits Daten zu diesem Mitarbeiter in der DB-Tabelle "kontakte"        *
  stehen dann update ansonsten insert.                                         *
*******************************************************************************}
      if not IsEmpty then
      begin
        SQL.Clear;
        SQL.Text := 'UPDATE mitarbeiter_kontaktdaten SET telefon = :TELEFON, handy = :HANDY, email = :EMAIL, ' +
                    'strasse = :STRASSE, hausnr = :HAUSNR, plz = :PLZ, ort = :ORT ' +
                    'WHERE mitarbeiterid = :MITARBEITERID;';

        Params.ParamByName('MITARBEITERID').AsString := USERID;
        Params.ParamByName('TELEFON').AsString       := edTelefon.Text;
        Params.ParamByName('HANDY').AsString         := edHandy.Text;
        Params.ParamByName('EMAIL').AsString         := edEmail.Text;
        Params.ParamByName('STRASSE').AsString       := edStrasse.Text;
        Params.ParamByName('HAUSNR').AsString        := edHausNr.Text;
        Params.ParamByName('PLZ').AsString           := edPLZ.Text;
        Params.ParamByName('ORT').AsString           := edOrt.Text;
        try
          ExecSQL;
        except
          on E: Exception do
            ShowMessage('Fehler beim Speichern der Änderungen an den Kontaktdaten des Mitarbeiters: ' + E.Message);
        end;
      end // if not IsEmpty then
      else
      begin
        SQL.Clear;
        SQL.Text := 'INSERT INTO mitarbeiter_kontaktdaten (mitarbeiterid, telefon, handy, email, strasse, hausnr, plz, ort) ' +
                    'VALUES(:MITARBEITERID, :TELEFON, :HANDY, :EMAIL, :STRASSE, :HAUSNR, :PLZ, :ORT);';

        Params.ParamByName('MITARBEITERID').AsString := USERID;
        Params.ParamByName('TELEFON').AsString       := edTelefon.Text;
        Params.ParamByName('HANDY').AsString         := edHandy.Text;
        Params.ParamByName('EMAIL').AsString         := edEmail.Text;
        Params.ParamByName('STRASSE').AsString       := edStrasse.Text;
        Params.ParamByName('HAUSNR').AsString        := edHausNr.Text;
        Params.ParamByName('PLZ').AsString           := edPLZ.Text;
        Params.ParamByName('ORT').AsString           := edOrt.Text;
        try
          ExecSQL;
        except
          on E: Exception do
            ShowMessage('Fehler beim Hinzufügen der Kontaktdaten des Mitarbeiters: ' + E.Message);
        end;
      end; // else if not IsEmpty then
    end;
  finally
    FDQuery.Free;
  end;

  if(ABSENDER = '') then
  begin
    a := fMitarbeiter.lvMitarbeiter.ItemIndex;
    with fMitarbeiter.lvMitarbeiter.Items[a] do
    begin
      SubItems[0] := edPersonalNr.Text;
      SubItems[1] := edNachname.Text;
      SubItems[2] := edVorname.Text;
      SubItems[3] := edAusweisNr.Text;
      SubItems[4] := edAusweisGueltigkeit.Text;
      SubItems[5] := edSonderausweisnr.Text;
      SubItems[6] := edSonderausweisGueltigkeit.Text;
      SubItems[7] := cbWaffennummer.Text;
    end;
  end;

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

  close;
end;





procedure TfMitarbeiterEdit.cbDiensthundChange(Sender: TObject);
//var
//  SelectedIndex, AssociatedID: Integer;
begin
{  SelectedIndex := cbDiensthund.ItemIndex;

  if SelectedIndex <> -1 then
  begin
    AssociatedID := Integer(cbDiensthund.Items.Objects[SelectedIndex]);
    ShowMessage('Der assoziierte ID-Wert ist: ' + IntToStr(AssociatedID));
  end;
}end;







procedure TfMitarbeiterEdit.edAustrittsdatumDblClick(Sender: TObject);
begin
  if(MessageDlg('Wollen Sie wirklich das Datum löschen?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    TMaskEditEx(Sender).Clear;
    TMaskEditEx(Sender).SelectAll;
  end;
end;





procedure TfMitarbeiterEdit.FormCreate(Sender: TObject);
begin
  ABSENDER := '';
end;





procedure TfMitarbeiterEdit.FormShow(Sender: TObject);
var
  q: TFDQuery;
  i, objektid, index: integer;
begin
  if(UsereintraegeInDBTablesGefunden(USERID) = true) then
  begin
    btnDel.Enabled := false;
    StatusBar1.Panels[0].Text := 'Dieser Mitarbeiter kann nicht gelöscht werden weil bereits Dokumente erstellt wurden in denen dessen ID vorkommt.';
  end
  else
  begin
    btnDel.Enabled := true;
  end;


  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TEdit then
      TEdit(Components[i]).Clear;
  end;

  showObjekteInListView(lvObjekte);
  showSerienNrByNrWBKInCB(cbWaffennummer,'Alle'); //Alle Waffennummern in cbWaffennummern anzeigen
  showObjekteInComboBox(cbObjekt);
  showDiensthundeInCB(cbDiensthund);

  PageControl1.ActivePageIndex := 0;

  q := TFDquery.Create(nil);
  try
    with q do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT id, objektid, personalnr, nachname, vorname, geburtsdatum, eintrittsdatum, ' +
                  'austrittsdatum, waffennummer, ausweisnr, ausweisgueltigbis, sonderausweisnr, ' +
                  'sonderausweisgueltigbis, tankgutscheinart, diensthundID FROM mitarbeiter WHERE id = :ID ORDER BY nachname ASC;';

      Params.ParamByName('ID').AsString := USERID;
      Open;

      while not Eof do
      begin
        edPersonalNr.Text               := FieldByName('personalnr').AsString;
        edNachname.Text                 := FieldByName('nachname').AsString;
        edVorname.Text                  := FieldByName('vorname').AsString;
        edGeburtsdatum.Text             := ConvertSQLDateToGermanDate(FieldByName('geburtsdatum').AsString, false);
        edEintrittsdatum.Text           := ConvertSQLDateToGermanDate(FieldByName('eintrittsdatum').AsString, false);
        edAustrittsdatum.Text           := ConvertSQLDateToGermanDate(FieldByName('austrittsdatum').AsString, false);
        cbWaffennummer.ItemIndex        := cbWaffennummer.Items.IndexOf(FieldByName('waffennummer').AsString);
        edAusweisnr.Text                := FieldByName('ausweisnr').AsString;
        edAusweisgueltigkeit.Text       := ConvertSQLDateToGermanDate(FieldByName('ausweisgueltigbis').AsString, false);
        edSonderausweisnr.Text          := FieldByName('sonderausweisnr').AsString;
        edSonderausweisgueltigkeit.Text := ConvertSQLDateToGermanDate(FieldByName('sonderausweisgueltigbis').AsString, false);
        cbObjekt.ItemIndex              := cbObjekt.Items.IndexOfObject(TObject(FieldByName('objektid').AsInteger));
        cbDiensthund.ItemIndex          := cbDiensthund.Items.IndexOfObject(TObject(FieldByName('diensthundID').AsInteger));
        index := cbGutscheinart.Items.IndexOf(FieldByName('tankgutscheinart').AsString);
        if Index <> -1 then cbGutscheinart.ItemIndex := index;

        Next;
      end;




//Kontaktdaten aus DB Tabelle kontakte auslesen
      SQL.Text := 'SELECT telefon, handy, email, strasse, hausnr, plz, ort ' +
                  'FROM mitarbeiter_kontaktdaten WHERE mitarbeiterid = :ID;';

      Params.ParamByName('ID').AsString := USERID;
      Open;

      while not Eof do
      begin
        edTelefon.Text  := FieldByName('telefon').AsString;
        edHandy.Text    := FieldByName('handy').AsString;
        edEmail.Text    := FieldByName('email').AsString;
        edStrasse.Text  := FieldByName('strasse').AsString;
        edHausNr.Text   := FieldByName('hausnr').AsString;
        edPLZ.Text      := FieldByName('plz').AsString;
        edOrt.Text      := FieldByName('ort').AsString;
        Next;
      end;


//Mitarbeiterobjekte aus DB Tabelle mitarbeiterobjekte auslesen
      SQL.Text := 'SELECT id, objektid FROM mitarbeiter_objekte WHERE mitarbeiterid = :ID;';

      Params.ParamByName('ID').AsString := USERID;
      Open;

      while not Eof do
      begin
        for i := 0 to lvObjekte.Items.Count-1 do
        begin
          objektid := StrToInt(lvObjekte.Items[i].SubItems[1]);

          if(FieldByName('objektid').AsInteger = objektid) then
            lvObjekte.Items[i].Checked := true;
        end;

        Next;
      end;

    end;
  finally
    q.free;
  end;
end;



end.
