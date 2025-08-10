unit uFrameWachpersonal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, AdvListV,
  Vcl.StdCtrls, Vcl.ExtCtrls, DateUtils,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, System.Actions, Vcl.ActnList, Vcl.Menus, TaskDialog,
  Vcl.Imaging.pngimage, System.Math, ShellApi, System.UITypes, Vcl.Buttons;

type
  TFrameWachpersonal = class(TFrame)
    Panel2: TPanel;
    Label10: TLabel;
    Label9: TLabel;
    cbJahr: TComboBox;
    cbMonat: TComboBox;
    Panel3: TPanel;
    cbAushilfen: TComboBox;
    AdvInputTaskDialog1: TAdvInputTaskDialog;
    pmWachpersonal: TPopupMenu;
    Mitarbeiterentfernen1: TMenuItem;
    ActionList1: TActionList;
    acDelMaFromWachpersonal: TAction;
    btnSavePDF: TImage;
    lvWachpersonal: TAdvListView;
    btnDelWachpersonalListe: TButton;
    Panel1: TPanel;
    lbHinweis: TLabel;
    sbWeiter: TSpeedButton;
    lbWaffennummer: TLabel;
    cbWaffennummer: TComboBox;
    btnInsertAllStamm: TButton;
    lbHinzufügen: TLabel;
    btnSaveEntryInDB: TButton;
    N1: TMenuItem;
    N2: TMenuItem;
    procedure Initialize;
    procedure cbMonatSelect(Sender: TObject);
    procedure cbAushilfenSelect(Sender: TObject);
    procedure lvWachpersonalColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvWachpersonalCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure lvWachpersonalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lvWachpersonalKeyPress(Sender: TObject; var Key: Char);
    procedure btnSavePDFClick(Sender: TObject);
    procedure AdvInputTaskDialog1DialogButtonClick(Sender: TObject; ButtonID: Integer);
    procedure acDelMaFromWachpersonalExecute(Sender: TObject);
    procedure acDelMaFromWachpersonalUpdate(Sender: TObject);
    procedure btnDelWachpersonalListeClick(Sender: TObject);
    procedure sbWeiterClick(Sender: TObject);
    procedure lvWachpersonalClick(Sender: TObject);
    procedure btnInsertAllStammClick(Sender: TObject);
    procedure btnSaveEntryInDBClick(Sender: TObject);
    procedure cbWaffennummerSelect(Sender: TObject);
    procedure lvWachpersonalDblClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
  private
    s1, s2, s3: String;
    currentIndex: Integer;
    procedure DisplayHinweisString;
    procedure showWachpersonalInListView(LV: TListView; Monat, Jahr: integer);
    procedure showAlleSerienNummernInCB(cb: TComboBox);
    procedure InsertMitarbeiterInWachpersonal(lv: TListView; MitarbeiterID, monat, jahr, posLastEntry: integer);
    procedure GeneratePrintableWachpersonallisteAllInOne(DatumStand: TDate);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public-Deklarationen }
  end;


var
  MELDENDERID: Integer;
  MELDENDER, MELDEDATUM: string;



implementation

{$R *.dfm}
{$R WachpersonallisteAllInOne.RES}

uses uMain, uFunktionen, uDBFunktionen, uWebBrowser, uDatumMeldender,uMitarbeiterEdit;



procedure TFrameWachpersonal.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_COMPOSITED;
end;








procedure TFrameWachpersonal.Initialize;
var
  CurrentMonth, CurrentYear, start: Integer;
begin
  // Hinweistexte
  s1 := 'Schnell eine neue Wachpersonalliste erstellen:'+#13#10+'Klicken Sie auf den Button "Komplettes Stammpersonal hinzufügen und wählen Sie danach alle Mitarbeiter, die im gewählten Monat ausgeholfen haben!';
  s2 := 'Wählen Sie die Mitarbeiter, die im gewählten Monat ausgeholfen haben und geben Sie an welche Waffe ihnen zugewiesen wurde.';
  s3 := 'Löschen eines Eintrages mit rechter Maustaste'+sLineBreak+'Sortieren der Liste mit den + und - Tasten';


  //Jahre in Combobox einfügen
  CurrentYear := YearOf(Now);
  for start := STARTYEAR to CurrentYear + 1 do
    cbJahr.Items.Add(IntToStr(start));

  cbJahr.ItemIndex := cbJahr.Items.IndexOf(IntToStr(CurrentYear));

  //Aktuallen Monat in cbMonatWachpersonal anzeigen
  CurrentMonth := MonthOf(Now); // Den aktuellen Monat ermitteln (1 bis 12)
  cbMonat.ItemIndex := CurrentMonth;

  SELMONTH := CurrentMonth;
  SELYEAR  := CurrentYear;

  cbMonatSelect(Self);

  cbAushilfen.ItemIndex     := 0;
  cbWaffennummer.ItemIndex  := 0;
end;






//Alle Seriennummern in Combobox anzeigen
procedure TFrameWachpersonal.showAlleSerienNummernInCB(cb: TComboBox);
var
  FDQuery: TFDQuery;
begin
  cb.Clear;

  FDQuery := TFDQuery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT seriennr FROM waffenbestand ORDER BY seriennr ASC;';
      Open;

      cb.Items.Add('');

      while not Eof do
      begin
        cb.Items.Add(FieldByName('seriennr').AsString);
        Next;
      end;
    end;
  finally
    FDQuery.Free;
  end;
end;







procedure TFrameWachpersonal.acDelMaFromWachpersonalExecute(Sender: TObject);
var
  FDQuery: TFDQuery;
begin
  FDQuery := nil; // Initialisierung

  if(lvWachpersonal.ItemIndex<>-1) then
  begin
    if MessageDlg('Wollen Sie diesen Mitarbeiter wirklich aus der Wachpersonal-Liste entfernen?', mtConfirmation, [mbyes, mbno], 0) = mrYes then
    begin
      FDQuery := TFDquery.Create(nil);
      try
        with FDQuery do
        begin
          Connection := fMain.FDConnection1;

          SQL.Text := 'DELETE FROM wachpersonal WHERE id = :ID AND monat = :MONAT AND jahr = :JAHR;';

          Params.ParamByName('ID').AsInteger := StrToInt(lvWachpersonal.Items[lvWachpersonal.ItemIndex].Caption);
          Params.ParamByName('MONAT').AsInteger := cbMonat.ItemIndex;
          Params.ParamByName('JAHR').AsInteger := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);

          ExecSQL;
        end;
      except
        showmessage('Fehler beim löschen des Mitarbeiters aus der Liste');
      end;
      lvWachpersonal.DeleteSelected;
    end;
  end;

  // Freigabe nur wenn FDQuery erstellt wurde
  if FDQuery <> nil then
  begin
    FDQuery.Free;
  end;
end;





procedure TFrameWachpersonal.acDelMaFromWachpersonalUpdate(Sender: TObject);
begin
  if(lvWachpersonal.ItemIndex<>-1) then
    acDelMaFromWachpersonal.Enabled := true
  else
    acDelMaFromWachpersonal.Enabled := false;
end;





procedure TFrameWachpersonal.AdvInputTaskDialog1DialogButtonClick(Sender: TObject; ButtonID: Integer);
begin
  if(ButtonID = 1) then
  begin
    GeneratePrintableWachpersonallisteAllInOne(StrToDate(AdvInputTaskDialog1.InputText));
  end;
end;






procedure TFrameWachpersonal.btnDelWachpersonalListeClick(Sender: TObject);
var
  FDQuery: TFDQuery;
begin
  if MessageDlg('Wollen Sie die Wachpersonalliste von ' + cbMonat.Text + ' - ' + cbJahr.Text + ' wirklich löschen?', mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
  begin
    FDQuery := TFDquery.Create(nil);
    try
      with FDQuery do
      begin
        Connection := fMain.FDConnection1;

        SQL.Clear;
        SQL.Add('DELETE FROM wachpersonal WHERE monat = :MONAT AND jahr = :JAHR');
        Params.ParamByName('MONAT').AsInteger := SELMONTH;
        Params.ParamByName('JAHR').AsInteger := SELYEAR;
        try
          ExecSQL;
        except
          on E: Exception do
          begin
            ShowMessage('Fehler beim löschen der Wachpersonalliste ' + E.Message);
          end;
        end;
      end;
    finally
      FDQuery.Free;
      cbMonatSelect(self);
      btnDelWachpersonalListe.Visible := false;
    end;
  end;
end;








procedure TFrameWachpersonal.btnInsertAllStammClick(Sender: TObject);
var
  FDQuery: TFDQuery;
  StartDate: TDateTime;
  i, maid, pos: integer;
begin
  i := lvWachpersonal.Items.Count;

  if i = 0 then
  begin
    pos := 0;

    FDQuery := TFDquery.Create(nil);
    try
      with FDQuery do
      begin
        Connection := fMain.FDConnection1;

        //Alle Mitarbeiter des Stammobjektes auslesen, die im übergebenen Monat und Jahr nicht ausgetreten sind
        SQL.Text := 'SELECT id FROM mitarbeiter ' +
                    'WHERE objektid = :OBJEKTID ' +
                    'AND (austrittsdatum IS NULL OR austrittsdatum = '''' OR DATE(austrittsdatum) >= DATE(:STARTDATE)) ' +
                    'ORDER BY nachname ASC;';
        Params.ParamByName('OBJEKTID').AsInteger := ObjektID;
        StartDate := EncodeDate(SELYEAR, SELMONTH, 1);
        Params.ParamByName('STARTDATE').AsDate := StartDate;

        Open;

        while not Eof do
        begin
          inc(pos);

          maid := FieldByName('id').AsInteger;

          InsertMitarbeiterInWachpersonal(lvWachpersonal, maid, SELMONTH, SELYEAR, pos); //id des Mitarbeiters aus der ComboBox übergeben

          Next;
        end;
      end;
    finally
      FDQuery.free;
    end;
    btnInsertAllStamm.Visible := false;
    cbAushilfen.Visible := true;
    lbHinzufügen.Visible := true;
    lbWaffennummer.Visible := true;
    cbWaffennummer.Visible := true;
    btnDelWachpersonalListe.Visible := true;
    btnSavePDF.Visible := true;
    lbHinweis.Visible := true;

    //Hinweistext anzeigen
    currentIndex := 1;  // Setze den Index auf den ersten String
    lbHinweis.Caption := s1;
  end
  else
  begin
    cbAushilfen.Visible := false;
    lbWaffennummer.Visible := false;
    cbWaffennummer.Visible := false;
    lbHinzufügen.Visible := false;
    btnDelWachpersonalListe.Visible := false;
    btnSavePDF.Visible := false;

    //Hinweistext anzeigen
    currentIndex := 2;  // Setze den Index auf den ersten String
    lbHinweis.Caption := s2;

    PlayResourceMP3('BLING', 'TEMP\bling.wav');
    showmessage('Diese Funktion kann nur genutzt werden wenn die Liste leer ist.'+#13#10+'Fügen Sie weitere Mitarbeiter bitte einzeln hinzu!');
    exit;
  end;
end;





procedure TFrameWachpersonal.cbAushilfenSelect(Sender: TObject);
var
  mitarbeiterID: Integer;
  m, j: integer;
  posLastEntry: integer;
begin
  m := cbMonat.ItemIndex;
  j := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);

  //Setzen der Nummer für die Sortierung
  if(lvWachpersonal.Items.Count = 0) then
    posLastEntry := 1
  else
    posLastEntry := StrToInt(lvWachpersonal.Items[lvWachpersonal.Items.Count-1].SubItems[1])+1;

  //Es wurde ein Mitarbeiter aus dem Feld Aushilfen ausgewählt
  if cbAushilfen.ItemIndex > 0 then
  begin
    //Die Mitarbeiterliste aus der ComboBox in mitarbeiterID schreiben
    mitarbeiterID := Integer(TComboBox(Sender).Items.Objects[TComboBox(Sender).ItemIndex]);

    //prüfen ob Mitarbeiter mit der übergebenen ID schon in der Liste steht
    if(ListViewContainsIntInColumn(lvWachpersonal, mitarbeiterID, 1) = true) then
    begin
      //In Spalte 1 nach der MitarbeiterID suchen die von der ComboBox übergeben wurde
      SelectListViewItemByIntInColumn(lvWachpersonal, mitarbeiterID, 1);
    end
    else
    begin
      //Wenn der Mitarbeiter nicht in der ListView steht, diesen einfügen
      InsertMitarbeiterInWachpersonal(lvWachpersonal, mitarbeiterID, m, j, PosLastEntry); //id des Mitarbeiters aus der ComboBox übergeben
      SelectListViewItemByIntInColumn(lvWachpersonal, mitarbeiterID, 1);
    end;
    lvWachpersonalClick(Self);
  end;
end;





procedure TFrameWachpersonal.cbMonatSelect(Sender: TObject);
var
  c, monat, jahr: integer;
begin
  if(cbMonat.ItemIndex > 0) AND (cbJahr.ItemIndex > 0) then
  begin
    monat := cbMonat.ItemIndex;
    jahr  := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);

    SELMONTH := monat;
    SELYEAR  := jahr;

    showMitarbeiterInComboBox(cbAushilfen, SELMONTH, SELYEAR, true, false, OBJEKTID, 3); //Aushilfen die im gewählten Objekt aushelfen dürfen

    showAlleSerienNummernInCB(cbWaffennummer);

    showWachpersonalInListView(lvWachpersonal, SELMONTH, SELYEAR);

    c := lvWachpersonal.Items.Count;

    if(c <= 0) then
    begin
      btnInsertAllStamm.Visible := true;
      cbAushilfen.Visible := false;
      lbWaffennummer.Visible := false;
      cbWaffennummer.Visible := false;
      btnDelWachpersonalListe.Visible := false;
      btnSavePDF.Visible := false;
      lbHinzufügen.Visible := false;

      //Hinweistext anzeigen
      currentIndex := 1;  // Setze den Index auf den ersten String
      lbHinweis.Caption := s1;
    end
    else
    begin
      btnInsertAllStamm.Visible := false;
      cbAushilfen.Visible := true;
      lbWaffennummer.Visible := true;
      cbWaffennummer.Visible := true;
      btnDelWachpersonalListe.Visible := true;
      btnSavePDF.Visible := true;
      lbHinzufügen.Visible := true;

      cbAushilfen.ItemIndex := 0;

      //Hinweistext anzeigen
      currentIndex := 2;  // Setze den Index auf den ersten String
      lbHinweis.Caption := s2;
    end;
  end
  else
  begin
    showmessage('Bitte wählen Sie einen Monat');
  end;

  lbWaffennummer.Visible := false;
  cbWaffennummer.Visible := false;
  btnSaveEntryInDB.Visible := false;
end;







procedure TFrameWachpersonal.cbWaffennummerSelect(Sender: TObject);
var
  i: integer;
begin
  i := cbWaffennummer.ItemIndex;
  if(i<>-1) then
  begin
    if(cbWaffennummer.Items[i] <> lvWachpersonal.Items[lvWachpersonal.ItemIndex].SubItems[10]) then
    begin
      btnSaveEntryInDB.Visible := true;
    end
    else
    begin
      btnSaveEntryInDB.Visible := false;
    end;
  end;
end;





procedure TFrameWachpersonal.btnSaveEntryInDBClick(Sender: TObject);
var
  i, entryID: integer;
  waffennr: string;
  FDQuery: TFDQuery;
begin
  i := lvWachpersonal.ItemIndex;
  if i <> 0 then
  begin
    entryID  := StrToInt(lvWachpersonal.Items[i].Caption);
    waffennr := cbWaffennummer.Text;
    lvWachpersonal.Items[i].SubItems[10] := waffennr;

    //Änderung der Waffennummer in Datenbank speichern
    FDQuery := TFDquery.Create(nil);
    try
      with FDQuery do
      begin
        Connection := fMain.FDConnection1;

        SQL.Text := 'UPDATE wachpersonal SET waffennummer = :WAFFENNR ' +
                    'WHERE id = :ID;';
        Params.ParamByName('ID').AsInteger := entryID;
        Params.ParamByName('WAFFENNR').AsString := waffennr;

        try
          ExecSQL;
        except
          on E: Exception do
          begin
            ShowMessage('Fehler beim speichern der Änderung der Waffennummer in der Datenbank: ' + E.Message);
          end;
        end;
      end;
    finally
      FDQuery.free;
    end;
    lbWaffennummer.Visible := false;
    cbWaffennummer.Visible := false;
    btnSaveEntryInDB.Visible := false;
    lvWachpersonal.ItemIndex := -1;
    cbAushilfen.ItemIndex := -1;
  end;
end;





procedure TFrameWachpersonal.btnSavePDFClick(Sender: TObject);
var
  mDatum: TDate;
begin
  if (cbMonat.ItemIndex < 1) or (cbJahr.Text = '') then
  begin
    ShowMessage('Bitte wählen Sie den Monat und das Jahr für den Sie die Wachpersonalliste generieren wollen!');
    Exit;
  end;

  mDatum := GetLastDayOfMonth(SelYear, SelMonth);
  uDatumMeldender.MELDEDATUM := DateToStr(mDatum);
  uDatumMeldender.MELDENDER  := OBJEKTLEITERNAME;
  uDatumMeldender.ABSENDER   := 'uFrameWachpersonal';

  if fDatumMeldender.ShowModal = mrOk then
  begin
    if (MELDEDATUM = '') then
      MELDEDATUM := DateToStr(mDatum);

    GeneratePrintableWachpersonallisteAllInOne(StrToDate(ConvertSQLDateToGermanDate(MELDEDATUM, false)));
  end;
end;














{******************************************************************************************
  Alle Mitarbeiter aus Datenbank-Tabelle wachpersonal auslesen und in ListView anzeigen   *
******************************************************************************************}
procedure TFrameWachpersonal.sbWeiterClick(Sender: TObject);
begin
  DisplayHinweisString;
end;

procedure TFrameWachpersonal.showWachpersonalInListView(LV: TListView; Monat, Jahr: integer);
var
  id, MitarbeiterID, Nachname, Vorname : TField;
  GebDatum, EintrDatum, WaffenNr, PassNr: TField;
  PassGueltigBis, SaNr, SaGueltigBis, Diensthund, Position: TField;
  L: TListItem;
  FDQuery: TFDQuery;
begin
  ClearListView(LV);

  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Clear;
      SQL.Add('SELECT id, mitarbeiterid, nachname, vorname, eintrittsdatum, geburtsdatum, ');
      SQL.Add('ausweisnr, ausweisgueltigbis, sonderausweisnr, sonderausweisgueltigbis, ');
      SQL.Add('waffennummer, diensthund, position ');
      SQL.Add('FROM wachpersonal ');
      SQL.Add('WHERE monat = :MONAT AND jahr = :JAHR');
      SQL.Add('ORDER BY position ASC;');
      Params.ParamByName('MONAT').AsInteger := Monat;
      Params.ParamByName('JAHR').AsInteger  := Jahr;
      Open;

      id             := FieldByName('id');
      Nachname       := FieldByName('nachname');
      Vorname        := FieldByName('vorname');
      EintrDatum     := FieldByName('eintrittsdatum');
      GebDatum       := FieldByName('geburtsdatum');
      PassNr         := FieldByName('ausweisnr');
      PassGueltigBis := FieldByName('ausweisgueltigbis');
      SaNr           := FieldByName('sonderausweisnr');
      SaGueltigBis   := FieldByName('sonderausweisgueltigbis');
      WaffenNr       := FieldByName('waffennummer');
      Diensthund     := FieldByName('diensthund');
      Position       := FieldByName('position');
      MitarbeiterID  := FieldByName('mitarbeiterid');

      while not Eof do
      begin
        l := LV.Items.Add;
        l.Caption := id.AsString;
        l.SubItems.Add(MitarbeiterID.AsString);
        l.SubItems.Add(Position.AsString);
        l.SubItems.Add(Nachname.AsString);
        l.SubItems.Add(Vorname.AsString);

        if(EintrDatum.AsString = '') then
          l.SubItems.Add('-----')
        else
          l.SubItems.Add(ConvertSQLDateToGermanDate(EintrDatum.AsString, false));

        if(GebDatum.AsString = '') then
          l.SubItems.Add('-----')
        else
          l.SubItems.Add(ConvertSQLDateToGermanDate(GebDatum.AsString, false));

        l.SubItems.Add(PassNr.AsString);

        if(PassGueltigBis.AsString = '') then
          l.SubItems.Add('-----')
        else
        l.SubItems.Add(ConvertSQLDateToGermanDate(PassGueltigBis.AsString, false));


        if(SaNr.AsString = '') then
          l.SubItems.Add('-----')
        else
          l.SubItems.Add(SaNr.AsString);

        if(SaGueltigBis.AsString = '') then
          l.SubItems.Add('-----')
        else
          l.SubItems.Add(ConvertSQLDateToGermanDate(SaGueltigBis.AsString, false));

        l.SubItems.Add(WaffenNr.AsString);
        l.subitems.Add(Diensthund.AsString);

        Next;
      end;
    end;
  finally
    FDQuery.free;
  end;
end;



procedure SetParamStr(FD: TFDQuery; const ParamName, Value: string);
begin
  FD.Params.ParamByName(ParamName).AsString := Value;
end;





procedure TFrameWachpersonal.InsertMitarbeiterInWachpersonal(lv: TListView; MitarbeiterID, monat, jahr, posLastEntry: integer);
var
  FDQuery: TFDQuery;
  Nachname, Vorname, EintrDatum, GebDatum, PassNr, PassGueltigBis: string;
  SaNr, SaGueltigBis, WaffenNr, Diensthund, Position: string;
  id: integer;
  l: TListItem;
begin
  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

//Schauen ob der Mitarbeiter für den gewünschten Zeitraum
//bereits in der Datenbanktabelle "wachpersonal" steht
      SQL.Clear;
      SQL.Add('SELECT id FROM wachpersonal ');
      SQL.Add('WHERE mitarbeiterid = :MITARBEITERID AND ');
      SQL.Add('monat = :MONAT AND jahr = :JAHR;');
      Params.ParamByName('MITARBEITERID').AsInteger := MitarbeiterID; //ID aus ComboBox
      Params.ParamByName('MONAT').AsInteger         := monat;
      Params.ParamByName('JAHR').AsInteger          := jahr;
      Open;



//Mitarbeiter steht noch nicht in der Tabelle "wachpersonal"
      if(RecordCount = 0) then
      begin

//Mitarbeiterdaten aus Datenbanktabelle "mitarbeiter" auslesen
        SQL.Text := 'SELECT M.id, M.nachname, M.vorname, M.eintrittsdatum, M.geburtsdatum, M.ausweisnr, ' +
                    'M.ausweisgueltigbis, M.sonderausweisnr, M.sonderausweisgueltigbis, M.waffennummer, ' +
                    'D.diensthundname ' +
                    'FROM mitarbeiter AS M LEFT JOIN diensthunde AS D ON D.id = M.diensthundID ' +
                    'WHERE M.id = :MITARBEITERID;';

        Params.ParamByName('MITARBEITERID').AsInteger := MitarbeiterID;
        Open;

//Ausgelesene Werte Variablen zuweisen
       // id             := FieldByName('id').AsInteger;
        Nachname       := FieldByName('nachname').AsString;
        Vorname        := FieldByName('vorname').AsString;
        EintrDatum     := FieldByName('eintrittsdatum').AsString;
        GebDatum       := FieldByName('geburtsdatum').AsString;
        PassNr         := FieldByName('ausweisnr').AsString;
        PassGueltigBis := FieldByName('ausweisgueltigbis').AsString;
        SaNr           := FieldByName('sonderausweisnr').AsString;
        SaGueltigBis   := FieldByName('sonderausweisgueltigbis').AsString;
        WaffenNr       := FieldByName('waffennummer').AsString;
        if(FieldByName('diensthundname').AsString <> '') then
          Diensthund     := FieldByName('diensthundname').AsString
        else
          Diensthund  := '-----';

        Position       := IntToStr(posLastEntry);


//Mitarbeiter in Datenbanktabelle "wachpersonal" schreiben
        with FDQuery do
        begin
          SQL.Text := 'INSERT INTO wachpersonal (mitarbeiterid, monat, jahr, nachname, ' +
                      'vorname, eintrittsdatum, geburtsdatum, ausweisnr, ausweisgueltigbis, ' +
                      'sonderausweisnr, sonderausweisgueltigbis, waffennummer, diensthund, position) ' +
                      'VALUES (:MITARBEITERID, :MONAT, :JAHR, :NACHNAME, :VORNAME, ' +
                      ':EINTRDATUM, :GEBDATUM, :PASSNR, :PASSGUELTIGBIS, ' +
                      ':SANR, :SAGUELTIGBIS, :WAFFENNR, :DIENSTHUND, :POSITION);';

          Params.ParamByName('MITARBEITERID').AsInteger := MitarbeiterID;
          Params.ParamByName('MONAT').AsInteger         := monat;
          Params.ParamByName('JAHR').AsInteger          := jahr;
          Params.ParamByName('NACHNAME').AsString       := Nachname;
          Params.ParamByName('VORNAME').AsString        := Vorname;
          Params.ParamByName('PASSNR').AsString := PassNr;
          Params.ParamByName('SANR').AsString := SaNr;
          Params.ParamByName('WAFFENNR').AsString   := WaffenNr;
          Params.ParamByName('DIENSTHUND').AsString := Diensthund;
          Params.ParamByName('POSITION').AsString   := Position;

          SetParamStr(FDQuery, 'EINTRDATUM', EintrDatum);
          SetParamStr(FDQuery, 'GEBDATUM', GebDatum);
          SetParamStr(FDQuery, 'PASSGUELTIGBIS', PassGueltigBis);
          SetParamStr(FDQuery, 'SAGUELTIGBIS', SaGueltigBis);

          ExecSQL;

          // Hier: ID des zuletzt eingefügten wachpersonal-Eintrags holen
          id := FDQuery.Connection.ExecSQLScalar('SELECT last_insert_rowid();');

          //Mitarbeiter in ListView eintragen
          l := LV.Items.Add;
          l.Caption := IntToStr(id);  //id
          l.SubItems.Add(IntToStr(MitarbeiterID)); //mitarbeiterid
          l.SubItems.Add(Position);  //sortierung
          l.SubItems.Add(Nachname);
          l.SubItems.Add(Vorname);
          if(EintrDatum <> '') then l.SubItems.Add(ConvertSQLDateToGermanDate(EintrDatum, false)) else l.subItems.Add('-----');
          if(GebDatum <> '') then l.SubItems.Add(ConvertSQLDateToGermanDate(GebDatum, false)) else l.SubItems.Add('-----');
          l.SubItems.Add(PassNr);
          if(PassGueltigBis <> '') then l.SubItems.Add(ConvertSQLDateToGermanDate(PassGueltigBis, false)) else l.SubItems.Add('-----');
          if(SaNr <> '') then l.SubItems.Add(SaNr) else l.SubItems.Add('-----');
          if(SaGueltigBis <> '') then l.SubItems.Add(ConvertSQLDateToGermanDate(SaGueltigBis, false)) else l.SubItems.Add('-----');
          l.SubItems.Add(WaffenNr);
          l.SubItems.Add(Diensthund);
        end;
      end
      else
      begin
        //showmessage('Dieser Mitarbeiter steht bereits in der Liste');
        SelectMitarbeiterInListView(lvWachpersonal, MitarbeiterID);
      end;
    end;
  finally
    FDQuery.free;
  end;
end;






procedure TFrameWachpersonal.lvWachpersonalClick(Sender: TObject);
var
  i: integer;
  Waffennr: string;
  Index: integer;
begin
  i := lvWachpersonal.ItemIndex;

  if i <> -1 then
  begin
    btnDelWachpersonalListe.Visible := true;

    Waffennr := lvWachpersonal.Items[i].SubItems[10];

    Index := cbWaffennummer.Items.IndexOf(Waffennr);
    if Index <> -1 then
    begin
      cbWaffennummer.ItemIndex := Index;
    end;
    lbWaffennummer.Visible := true;
    cbWaffennummer.Visible := true;
    btnDelWachpersonalListe.Visible := true;
  end
  else
  begin
    lbWaffennummer.Visible := false;
    cbWaffennummer.Visible := false;
    btnDelWachpersonalListe.Visible := false;
  end;

  btnSaveEntryInDB.Visible := false;

  lvWachpersonal.SetFocus;
end;







procedure TFrameWachpersonal.lvWachpersonalColumnClick(Sender: TObject; Column: TListColumn);
begin
  lvColumnClickForSort(Sender, Column);
end;







procedure TFrameWachpersonal.lvWachpersonalCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  lvCompareForSort(Sender, Item1, Item2, Data, Compare);
end;







procedure TFrameWachpersonal.lvWachpersonalDblClick(Sender: TObject);
var
  i: integer;
  mitarbeiterID: string;
begin
  i := lvWachpersonal.ItemIndex;

  if i <> -1 then
  begin
    mitarbeiterID := lvWachpersonal.Items[i].SubItems[0];
    fMitarbeiterEdit.USERID := mitarbeiterID;
    fMitarbeiterEdit.ABSENDER := 'FrameWachpersonal';
    fMitarbeiterEdit.Show;
  end;
end;





procedure TFrameWachpersonal.lvWachpersonalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  i: integer;
  FDQuery: TFDQuery;
  id, m, j: integer;
  posVorher, posNachher: integer;
  UPDATEDB: boolean;
begin
  i := lvWachpersonal.ItemIndex;
  if(i<>-1) then
  begin
    UPDATEDB   := false;
    PosNachher := 0;

    id := StrToInt(lvWachpersonal.Items[i].Caption);
    m  := cbMonat.ItemIndex;
    j  := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);

    if Key = VK_OEM_PLUS then
    begin
      posVorher := StrToInt(lvWachpersonal.Items[i].SubItems[1]);
      posNachher := posVorher + 1;
      UPDATEDB := true;
    end
    else if Key = VK_OEM_MINUS then
    begin
      posVorher := StrToInt(lvWachpersonal.Items[i].SubItems[1]);
      if(posVorher > 0) then posNachher := posVorher - 1 else posNachher := 0;
      UPDATEDB := true;
    end;


    if(UPDATEDB = true) then
    begin
      FDQuery := TFDquery.Create(nil);
      try
        with FDQuery do
        begin
          Connection := fMain.FDConnection1;

          SQL.Text := 'UPDATE wachpersonal SET position = :POS ' +
                      'WHERE id = :ID AND monat = :MONAT AND jahr = :JAHR;';

          Params.ParamByName('ID').AsInteger    := id;
          Params.ParamByName('MONAT').AsInteger := m;
          Params.ParamByName('JAHR').AsInteger  := j;
          Params.ParamByName('POS').AsInteger   := posNachher;

          ExecSQL;

          lvWachpersonal.Items[i].SubItems[1] := IntToStr(posNachher);
        end;
      finally
        FDQuery.free;
      end;
    end;

    //Wachpersonalliste beim start automatisch nach Laufender Nummer sortieren
    ColumnToSort := 2; //Spalte 0=Caption, 1=erstes SubItem
    SortDir      := 0; //Aufsteigend- oder absteigend sortieren 0 = A-Z, 1 = Z-A
    lvWachpersonal.AlphaSort; //Sortierung anwenden
  end;
end;





procedure TFrameWachpersonal.lvWachpersonalKeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
end;




procedure TFrameWachpersonal.N2Click(Sender: TObject);
var
  Q: TFDQuery;
  i, selEntryID: Integer;
  vorname, nachname, geburtsdatum, eintrittsdatum,
  ausweisnr, ausweisgueltigbis, sonderausweisnr, sonderausweisgueltigbis: string;
  altVorname, altNachname, altGeburtsdatum, altEintrittsdatum,
  altAusweisnr, altAusweisgueltigbis, altSonderausweisnr, altSonderausweisgueltigbis: string;
begin
  i := lvWachpersonal.ItemIndex;
  if i = -1 then Exit;

  if MessageDlg(
       'Haben Sie Daten dieses Mitarbeiters in den Stammdaten geändert und wollen Sie diesen Eintrag jetzt aktualisieren?',
       mtConfirmation, [mbYes, mbNo], 0
     ) <> mrYes then
    Exit;

  selEntryID := StrToIntDef(lvWachpersonal.Items[i].Caption, -1);
  if selEntryID = -1 then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := fMain.FDConnection1;

    try
      // 1. Aktuelle Daten aus mitarbeiter laden
      Q.SQL.Text :=
        'SELECT vorname, nachname, geburtsdatum, eintrittsdatum, ' +
        'ausweisnr, ausweisgueltigbis, sonderausweisnr, sonderausweisgueltigbis ' +
        'FROM mitarbeiter WHERE id = :MAID';
      Q.ParamByName('MAID').AsInteger := StrToIntDef(lvWachpersonal.Items[i].SubItems[0], -1);
      Q.Open;

      if Q.IsEmpty then Exit;

      vorname := Q.FieldByName('vorname').AsString;
      nachname := Q.FieldByName('nachname').AsString;
      geburtsdatum := Q.FieldByName('geburtsdatum').AsString;
      eintrittsdatum := Q.FieldByName('eintrittsdatum').AsString;
      ausweisnr := Q.FieldByName('ausweisnr').AsString;
      ausweisgueltigbis := Q.FieldByName('ausweisgueltigbis').AsString;
      sonderausweisnr := Q.FieldByName('sonderausweisnr').AsString;
      sonderausweisgueltigbis := Q.FieldByName('sonderausweisgueltigbis').AsString;

      Q.Close;

      // 2. Vorhandene Daten aus wachpersonal laden
      Q.SQL.Text :=
        'SELECT vorname, nachname, geburtsdatum, eintrittsdatum, ' +
        'ausweisnr, ausweisgueltigbis, sonderausweisnr, sonderausweisgueltigbis ' +
        'FROM wachpersonal WHERE id = :ID';
      Q.ParamByName('ID').AsInteger := selEntryID;
      Q.Open;

      if Q.IsEmpty then Exit;

      altVorname := Q.FieldByName('vorname').AsString;
      altNachname := Q.FieldByName('nachname').AsString;
      altGeburtsdatum := Q.FieldByName('geburtsdatum').AsString;
      altEintrittsdatum := Q.FieldByName('eintrittsdatum').AsString;
      altAusweisnr := Q.FieldByName('ausweisnr').AsString;
      altAusweisgueltigbis := Q.FieldByName('ausweisgueltigbis').AsString;
      altSonderausweisnr := Q.FieldByName('sonderausweisnr').AsString;
      altSonderausweisgueltigbis := Q.FieldByName('sonderausweisgueltigbis').AsString;

      Q.Close;

      // 3. Vergleich
      if (vorname = altVorname) and
         (nachname = altNachname) and
         (geburtsdatum = altGeburtsdatum) and
         (eintrittsdatum = altEintrittsdatum) and
         (ausweisnr = altAusweisnr) and
         (ausweisgueltigbis = altAusweisgueltigbis) and
         (sonderausweisnr = altSonderausweisnr) and
         (sonderausweisgueltigbis = altSonderausweisgueltigbis) then
      begin
        ShowMessage('Sie haben bereits die aktuellen Mitarbeiterdaten gespeichert. Es wurde nichts geändert.');
        Exit;
      end;

      // 4. Update ausführen
      Q.SQL.Text :=
        'UPDATE wachpersonal SET vorname = :VORNAME, nachname = :NACHNAME, geburtsdatum = :GEBURTSDATUM, ' +
        'eintrittsdatum = :EINTRITTSDATUM, ausweisnr = :AUSWEISNR, ausweisgueltigbis = :AUSWEISGUELTIGBIS, ' +
        'sonderausweisnr = :SONDERAUSWEISNR, sonderausweisgueltigbis = :SONDERAUSWEISGUELTIGBIS ' +
        'WHERE id = :ID';
      Q.ParamByName('ID').AsInteger := selEntryID;
      Q.ParamByName('VORNAME').AsString := vorname;
      Q.ParamByName('NACHNAME').AsString := nachname;
      Q.ParamByName('GEBURTSDATUM').AsString := geburtsdatum;
      Q.ParamByName('EINTRITTSDATUM').AsString := eintrittsdatum;
      Q.ParamByName('AUSWEISNR').AsString := ausweisnr;
      Q.ParamByName('AUSWEISGUELTIGBIS').AsString := ausweisgueltigbis;
      Q.ParamByName('SONDERAUSWEISNR').AsString := sonderausweisnr;
      Q.ParamByName('SONDERAUSWEISGUELTIGBIS').AsString := sonderausweisgueltigbis;
      Q.ExecSQL;

      // 5. ListView aktualisieren
      lvWachpersonal.Items[i].SubItems[2] := nachname;
      lvWachpersonal.Items[i].SubItems[3] := vorname;
      lvWachpersonal.Items[i].SubItems[4] := ConvertSQLDateToGermanDate(eintrittsdatum, false, false);
      lvWachpersonal.Items[i].SubItems[5] := ConvertSQLDateToGermanDate(geburtsdatum, false, false);
      lvWachpersonal.Items[i].SubItems[6] := ausweisnr;
      lvWachpersonal.Items[i].SubItems[7] := ConvertSQLDateToGermanDate(ausweisgueltigbis, false, false);
      lvWachpersonal.Items[i].SubItems[8] := sonderausweisnr;
      lvWachpersonal.Items[i].SubItems[9] := ConvertSQLDateToGermanDate(sonderausweisgueltigbis, false, false);

    except
      on E: Exception do
        ShowMessage('Fehler: ' + E.Message);
    end;

  finally
    Q.Free;
  end;
end;















//Aus den Einträgen in der Wachpersonalliste mehrere Seiten als html erstellen und diese
//anschließend als eine einzelne PDF Datei für den Webbrowser speichern
procedure TFrameWachpersonal.GeneratePrintableWachpersonallisteAllInOne(DatumStand: TDate);
var
  stltemp: TStringList;
  nachname, vorname, eintrittsdatum, geburtsdatum, passnr: string;
  passgueltig, swnr, swgueltig, waffennr, dhname: String;
  SEITE, i, a, lvCount, ANZAHLSEITEN, ZEILEN: integer;
  StartIndex: integer;
  EndIndex: integer;
  monat, jahr: integer;
  filename: string;
  stlHtmlHeader, stlHtmlFooter, stlSiteHeader, stlSiteFooter, stlContent: TStringList;
  resHtmlHeader, resHtmlFooter, resSiteHeader, resSiteFooter, resContent: TResourceStream;
  mon, Trenner: string;
begin
  stlHtmlHeader := nil;
  stlHtmlFooter := nil;
  resHtmlHeader := nil;
  resHtmlFooter := nil;
  stlTemp := nil;

  monat   := cbMonat.ItemIndex;
  jahr    := StrToInt(cbJahr.Text);
  ZEILEN  := 14;
  SEITE   := 0;
  lvCount := lvWachpersonal.Items.Count;
  Trenner := '-----';

  //Anzahl Seiten für die PDF-Datei aus der Anzahl der Einträge in der ListView berechnen
  if(lvCount > ZEILEN) then ANZAHLSEITEN := CEIL(lvCount / ZEILEN) else ANZAHLSEITEN := 1;

//Hier nur das was einmal für alle Seiten geladen werden muss (HtmlHeader, HtmlFooter)
  try
    resHtmlHeader := TResourceStream.Create(HInstance, 'WachpersonalHtmlHeader', 'TXT');
    resHtmlFooter := TResourceStream.Create(HInstance, 'WachpersonalHtmlFooter', 'TXT');

    stlHtmlHeader := TStringList.Create;
    stlHtmlHeader.LoadFromStream(resHtmlHeader);
    stlHtmlHeader.Text := StringReplace(stlHtmlHeader.Text, '[OBJEKTNAME]', OBJEKTNAME + '  (Seite ' + IntToStr(SEITE+1) + ')', [rfReplaceAll]);

    stlHtmlFooter := TStringList.Create;
    stlHtmlFooter.LoadFromStream(resHtmlFooter);
    stlHtmlFooter.Text := StringReplace(stlHtmlFooter.Text, '[DATUM]', DateToStr(now), [rfReplaceAll]);

    stlTemp := TStringList.Create;

//Hier alles was mehrmals geladen werden muss (für jede Seite - SiteHeader, SiteFooter, Content)

    for SEITE := 0 to ANZAHLSEITEN - 1 do
    begin
//SITEHEADER START
      resSiteHeader := TResourceStream.Create(HInstance, 'WachpersonalSiteHeader', 'TXT');
      stlSiteHeader := TStringList.Create;
      try
        stlSiteHeader.LoadFromStream(resSiteHeader);
        stlSiteHeader.Text := StringReplace(stlSiteHeader.Text, '[OBJEKTNAME]', OBJEKTNAME + '  (Seite ' + IntToStr(SEITE+1) + ')', [rfReplaceAll]);
        stltemp.Add(stlSiteHeader.Text);
      finally
        stlSiteHeader.Free;
        resSiteHeader.Free;
      end;
//SITEHEADER ENDE


//CONTENT START
      StartIndex := SEITE * ZEILEN;
      EndIndex := Min((SEITE + 1) * ZEILEN - 1, lvCount - 1);

      for a := StartIndex to EndIndex do
      begin
        nachname       := lvWachpersonal.Items[a].SubItems[2];
        vorname        := lvWachpersonal.Items[a].SubItems[3];
        eintrittsdatum := lvWachpersonal.Items[a].SubItems[4];
        geburtsdatum   := lvWachpersonal.Items[a].SubItems[5];
        passnr         := lvWachpersonal.Items[a].SubItems[6];
        passgueltig    := lvWachpersonal.Items[a].SubItems[7];
        swnr           := lvWachpersonal.Items[a].SubItems[8];
        swgueltig      := lvWachpersonal.Items[a].SubItems[9];
        waffennr       := lvWachpersonal.Items[a].SubItems[10];
        dhname         := lvWachpersonal.Items[a].SubItems[11];

        if(eintrittsdatum='') then eintrittsdatum := Trenner;
        if(swnr='') then swnr := Trenner;
        if(swgueltig='') then swgueltig := Trenner;
        if(passnr='') then passnr := Trenner;
        if(passgueltig='') then passgueltig := Trenner;

//Resource WaffenbestandContent auslesen und in Stringlist laden
        resContent := TResourceStream.Create(HInstance, 'WachpersonalContent', 'TXT');
        stlContent := TStringList.Create;
        try
          stlContent.LoadFromStream(resContent);
          stlContent.Text := StringReplace(stlContent.Text, '[NACHNAME]', nachname, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[VORNAME]', vorname, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[EINTRITTSDATUM]', eintrittsdatum, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[GEBURTSDATUM]', geburtsdatum, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[PASSNR]', passnr, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[PASSGUELTIGBIS]', passgueltig, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[WSNR]', swnr, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[WSGUELTIGBIS]', swgueltig, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[WAFFENNR]', waffennr, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[DHNAME]', dhname, [rfReplaceAll]);
          stltemp.Add(stlContent.Text);
        finally
          resContent.Free;
          stlContent.Free;
        end;
      end;


//Wenn auf der letzten Seite weniger als X Einträge vorhanden sind, dann leere Zeilen einfügen
//damit das Formular immer gleich groß ist
      if (SEITE = ANZAHLSEITEN - 1) and (EndIndex - StartIndex < ZEILEN - 1) then
      begin
        for a := EndIndex + 1 to (SEITE + 1) * ZEILEN - 1 do
        begin
          resContent := TResourceStream.Create(HInstance, 'WachpersonalContent', 'TXT');
          stlContent := TStringList.Create;
          try
            stlContent.LoadFromStream(resContent);
            stlContent.Text := StringReplace(stlContent.Text, '[NACHNAME]', '&nbsp;', [rfReplaceAll]);
            stlContent.Text := StringReplace(stlContent.Text, '[VORNAME]', '&nbsp;', [rfReplaceAll]);
            stlContent.Text := StringReplace(stlContent.Text, '[EINTRITTSDATUM]', '&nbsp;', [rfReplaceAll]);
            stlContent.Text := StringReplace(stlContent.Text, '[GEBURTSDATUM]', '&nbsp;', [rfReplaceAll]);
            stlContent.Text := StringReplace(stlContent.Text, '[PASSNR]', '&nbsp;', [rfReplaceAll]);
            stlContent.Text := StringReplace(stlContent.Text, '[PASSGUELTIGBIS]', '&nbsp;', [rfReplaceAll]);
            stlContent.Text := StringReplace(stlContent.Text, '[WSNR]', '&nbsp;', [rfReplaceAll]);
            stlContent.Text := StringReplace(stlContent.Text, '[WSGUELTIGBIS]', '&nbsp;', [rfReplaceAll]);
            stlContent.Text := StringReplace(stlContent.Text, '[WAFFENNR]', '&nbsp;', [rfReplaceAll]);
            stlContent.Text := StringReplace(stlContent.Text, '[DHNAME]', '&nbsp;', [rfReplaceAll]);
            stltemp.Add(stlContent.Text);
          finally
            resContent.Free;
            stlContent.Free;
          end;
        end;
      end;
//CONTENT ENDE


//SITEFOOTER START
      resSiteFooter := TResourceStream.Create(HInstance, 'WachpersonalSiteFooter', 'TXT');
      stlSiteFooter := TStringList.Create;
      try
        stlSiteFooter.LoadFromStream(resSiteFooter);
        stlSiteFooter.Text := StringReplace(stlSiteFooter.Text, '[DATUM]', DateToStr(DatumStand), [rfReplaceAll]);
        stltemp.Add(stlSiteFooter.Text);
      finally
        resSiteFooter.Free;
        stlSiteFooter.Free;
      end;
//SITEFOOTER ENDE
    end;

    stlTemp.Text := stlHtmlHeader.Text + stlTemp.Text + stlHtmlFooter.Text;


  //Alle Umlaute in der StringList ersetzen durch html code
    for i := 0 to stlTemp.Count - 1 do
    begin
      stlTemp[i] := ReplaceUmlauteWithHtmlEntities(stlTemp[i]);
    end;


    //Seiten als Html-Datei speichern
    if(Monat < 10) then mon := '0'+IntToStr(Monat) else mon := inttostr(Monat);

    //Dateiname für zu speichernde Datei erzeugen
    filename := 'Wachpersonal '+ mon +'.'+IntToStr(jahr) + ' ' + OBJEKTNAME + ' ' + OBJEKTORT;

    //Aus Resource-Datei temporäre Html-Datei und daraus eine PDF-Datei im TEMP Verzeichnis erzeugen
    CreateHtmlAndPdfFileFromResource(filename, stlTemp);

    //PDF Datei aus Temp Verzeichnis im Zielverzeichnis speichern
    SpeicherePDFDatei(filename, SAVEPATH_Wachpersonalliste);
  finally
    if Assigned(stlHtmlHeader) then stlHtmlHeader.Free;
    if Assigned(stlHtmlFooter) then stlHtmlFooter.Free;
    if Assigned(resHtmlHeader) then resHtmlHeader.Free;
    if Assigned(resHtmlFooter) then resHtmlFooter.Free;
    if Assigned(stlTemp) then stlTemp.Free;
  end;
end;





procedure TFrameWachpersonal.DisplayHinweisString;
begin
  currentIndex := currentIndex mod 3 + 1;

  case currentIndex of
    1: lbHinweis.Caption := s1;
    2: lbHinweis.Caption := s2;
    3: lbHinweis.Caption := s3;
  end;
end;



end.
