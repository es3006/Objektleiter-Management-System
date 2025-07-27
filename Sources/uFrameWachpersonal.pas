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
    cbStammpersonal: TComboBox;
    AdvInputTaskDialog1: TAdvInputTaskDialog;
    pmWachpersonal: TPopupMenu;
    Mitarbeiterentfernen1: TMenuItem;
    ActionList1: TActionList;
    acDelMaFromWachpersonal: TAction;
    Image1: TImage;
    lvWachpersonal: TAdvListView;
    cbAushilfen: TComboBox;
    sbInsertAllStamm: TSpeedButton;
    btnDelWachpersonalListe: TButton;
    Panel1: TPanel;
    lbHinweis: TLabel;
    Label4: TLabel;
    Label3: TLabel;
    sbWeiter: TSpeedButton;
    Label1: TLabel;
    cbWaffennummer: TComboBox;
    procedure Initialize;
    procedure cbMonatSelect(Sender: TObject);
    procedure cbStammpersonalSelect(Sender: TObject);
    procedure lvWachpersonalColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvWachpersonalCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure lvWachpersonalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lvWachpersonalKeyPress(Sender: TObject; var Key: Char);
    procedure Image1Click(Sender: TObject);
    procedure AdvInputTaskDialog1DialogButtonClick(Sender: TObject; ButtonID: Integer);
    procedure acDelMaFromWachpersonalExecute(Sender: TObject);
    procedure acDelMaFromWachpersonalUpdate(Sender: TObject);
    procedure sbInsertAllStammClick(Sender: TObject);
    procedure btnDelWachpersonalListeClick(Sender: TObject);
    procedure sbWeiterClick(Sender: TObject);
    procedure lvWachpersonalClick(Sender: TObject);
    procedure cbWaffennummerSelect(Sender: TObject);
  private
    s1, s2, s3, s4, s5: String;
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

uses uMain, uFunktionen, uDBFunktionen, uWebBrowser, uDatumMeldender;



procedure TFrameWachpersonal.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_COMPOSITED;
end;








procedure TFrameWachpersonal.Initialize;
var
  Index: integer;
  CurrentMonth, CurrentYear, start: Integer;
begin
  //Jahre in Combobox einfügen
  CurrentYear := YearOf(Now);
  for start := STARTYEAR to CurrentYear + 1 do
    cbJahr.Items.Add(IntToStr(start));

  cbJahr.ItemIndex := cbJahr.Items.IndexOf(IntToStr(CurrentYear));

  //Aktuallen Monat in cbMonatWachpersonal anzeigen
  CurrentMonth := MonthOf(Now); // Den aktuellen Monat ermitteln (1 bis 12)
  cbMonat.ItemIndex := CurrentMonth;


 {
  //Aktuelles Jahr anzeigen
  CurrentYear := YearOf(Now); // Das aktuelle Jahr ermitteln
  Index := cbJahr.Items.IndexOf(IntToStr(CurrentYear));  // Den Index des Eintrags mit dem aktuellen Jahr finden
  if Index <> -1 then // Wenn der Index gefunden wurde, den Eintrag selektieren
    cbJahr.ItemIndex := Index;
}
 // cbMonatSelect(nil);


  SELMONTH := CurrentMonth;
  SELYEAR  := CurrentYear;

{  showWachpersonalInListView(lvWachpersonal, CurrentMonth, CurrentYear);

  showMitarbeiterInComboBox(cbStammpersonal, SELMONTH, SELYEAR, false, OBJEKTID, 1);  //Stammpersonal des gewählten Objektes
  showMitarbeiterInComboBox(cbAushilfen, SELMONTH, SELYEAR, false, OBJEKTID, 2); //Aushilfen die im gewählten Objekt aushelfen dürfen
  showAlleSerienNummernInCB(cbWaffennummer);
}

cbMonatSelect(Self);

  cbStammpersonal.ItemIndex := 0;
  cbAushilfen.ItemIndex     := 0;
  cbWaffennummer.ItemIndex  := 0;


  // Hinweistexte für Timer
  s1 := 'Schnell eine neue Wachpersonalliste erstellen:'+#13#10+'Klicken Sie auf den kleinen Button hinter dem Auswahlfeld für das Stammpersonal. (Die Liste muss dafür leer sein)';
  s2 := 'Aushilfen zur Liste hinzufügen:'+#13#10+'Wählen Sie im Auswahlfeld "Aushilfen" die Namen die Sie der Liste hinzufügen wollen';
  s3 := 'Löschen eines Eintrages mit rechter Maustaste';
  s4 := 'Sortieren der Liste mit den + und - Tasten';
  s5 := 'Änderungen an den Mitarbeiterdaten:'+#13#10+'Über das Hauptmenü "Bestandsdaten / Mitarbeiter"';
  currentIndex := 2;  // Setze den Index auf den ersten String
  lbHinweis.Caption := s1;
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
      btnDelWachpersonalListe.Enabled := false;
    end;
  end;
end;








procedure TFrameWachpersonal.cbStammpersonalSelect(Sender: TObject);
var
  SelectedIndex: Integer;
  m, j: integer;
  posLastEntry: integer;
begin
  m := cbMonat.ItemIndex;
  j := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);
  SelectedIndex := -1;

  if(lvWachpersonal.Items.Count = 0) then
    posLastEntry := 1
  else
    posLastEntry := StrToInt(lvWachpersonal.Items[lvWachpersonal.Items.Count-1].SubItems[1])+1;

  if TComboBox(Sender).ItemIndex > 0 then
  begin
    SelectedIndex := Integer(TComboBox(Sender).Items.Objects[TComboBox(Sender).ItemIndex]);
    InsertMitarbeiterInWachpersonal(lvWachpersonal, SelectedIndex, m, j, PosLastEntry); //id des Mitarbeiters aus der ComboBox übergeben
  end;

  TComboBox(Sender).ItemIndex := 0;

  SearchAndHighlight(lvWachpersonal, IntToStr(SelectedIndex), [1]);
end;





procedure TFrameWachpersonal.cbWaffennummerSelect(Sender: TObject);
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

  end;
end;





procedure TFrameWachpersonal.cbMonatSelect(Sender: TObject);
var
  c, monat, jahr: integer;
begin
  monat := cbMonat.ItemIndex;
  jahr  := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);

  SELMONTH := monat;
  SELYEAR  := jahr;


  showMitarbeiterInComboBox(cbStammpersonal, SELMONTH, SELYEAR, false, OBJEKTID, 1);  //Stammpersonal des gewählten Objektes
  showMitarbeiterInComboBox(cbAushilfen, SELMONTH, SELYEAR, false, OBJEKTID, 2); //Aushilfen die im gewählten Objekt aushelfen dürfen
  showAlleSerienNummernInCB(cbWaffennummer);

  showWachpersonalInListView(lvWachpersonal, SELMONTH, SELYEAR);

  c := lvWachpersonal.Items.Count;

  if(c <= 0) then
    btnDelWachpersonalListe.Enabled := false
  else
    btnDelWachpersonalListe.Enabled := true;
end;








procedure TFrameWachpersonal.Image1Click(Sender: TObject);
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
procedure TFrameWachpersonal.sbInsertAllStammClick(Sender: TObject);
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
  end
  else
  begin
    PlayResourceMP3('BLING', 'TEMP\bling.wav');
    showmessage('Diese Funktion kann nur genutzt werden wenn die Liste leer ist.'+#13#10+'Fügen Sie weitere Mitarbeiter bitte einzeln hinzu!');
    exit;
  end;
end;





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
        id             := FieldByName('id').AsInteger;
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

          if(EintrDatum <> '') then
            Params.ParamByName('EINTRDATUM').AsString := EintrDatum
          else
            Params.ParamByName('EINTRDATUM').AsString := '';

          if(GebDatum <> '') then
            Params.ParamByName('GEBDATUM').AsString := GebDatum
          else
            Params.ParamByName('GEBDATUM').AsString := '';

          Params.ParamByName('PASSNR').AsString := PassNr;

          if(PassGueltigBis <> '') then
            Params.ParamByName('PASSGUELTIGBIS').AsString := PassGueltigBis
          else
            Params.ParamByName('PASSGUELTIGBIS').AsString := '';

          Params.ParamByName('SANR').AsString := SaNr;

          if(SaGueltigBis <> '') then
            Params.ParamByName('SAGUELTIGBIS').AsString := SaGueltigBis
          else
            Params.ParamByName('SAGUELTIGBIS').AsString := '';



          Params.ParamByName('WAFFENNR').AsString   := WaffenNr;
          Params.ParamByName('DIENSTHUND').AsString := Diensthund;
          Params.ParamByName('POSITION').AsString   := Position;
          ExecSQL;
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
    btnDelWachpersonalListe.Enabled := true;

    Waffennr := lvWachpersonal.Items[i].SubItems[10];

    Index := cbWaffennummer.Items.IndexOf(Waffennr);
    if Index <> -1 then
    begin
      cbWaffennummer.ItemIndex := Index;
    end;
  end
  else
  begin
    cbWaffennummer.ItemIndex := 0;
    btnDelWachpersonalListe.Enabled := false
  end;
end;







procedure TFrameWachpersonal.lvWachpersonalColumnClick(Sender: TObject; Column: TListColumn);
begin
  lvColumnClickForSort(Sender, Column);
end;







procedure TFrameWachpersonal.lvWachpersonalCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  lvCompareForSort(Sender, Item1, Item2, Data, Compare);
end;







procedure TFrameWachpersonal.lvWachpersonalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  i: integer;
  FDQuery: TFDQuery;
  id, m, j: integer;
  posVorher, posNachher: integer;
  UPDATEDB: boolean;
begin
  UPDATEDB   := false;
  PosNachher := 0;

  if lvWachpersonal.Selected <> nil then
  begin
    i  := lvWachpersonal.ItemIndex;
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
  end;
  //Wachpersonalliste beim start automatisch nach Laufender Nummer sortieren
  ColumnToSort := 2; //Spalte 0=Caption, 1=erstes SubItem
  SortDir      := 0; //Aufsteigend- oder absteigend sortieren 0 = A-Z, 1 = Z-A
  lvWachpersonal.AlphaSort; //Sortierung anwenden
end;





procedure TFrameWachpersonal.lvWachpersonalKeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
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
  case currentIndex of
    1: lbHinweis.Caption := s1;
    2: lbHinweis.Caption := s2;
    3: lbHinweis.Caption := s3;
    4: lbHinweis.Caption := s4;
    5: lbHinweis.Caption := s5;
  end;

  // Inkrementiere den Index und setze ihn zurück auf 1, wenn er 4 erreicht
  currentIndex := currentIndex mod 5 + 1;
end;



end.
