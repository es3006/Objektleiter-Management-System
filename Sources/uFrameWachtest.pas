unit uFrameWachtest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls, Vcl.ComCtrls, AdvListV, Vcl.StdCtrls, DateUtils, ShellApi,
  System.Math, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, System.Actions, Vcl.ActnList, Vcl.Menus, System.UITypes,
  Vcl.Buttons;

type
  TFrameWachtest = class(TFrame)
    Panel2: TPanel;
    Label10: TLabel;
    cbJahr: TComboBox;
    lvWachtest: TAdvListView;
    Image1: TImage;
    Panel1: TPanel;
    Panel3: TPanel;
    cbStammpersonal: TComboBox;
    Label4: TLabel;
    btnSave: TButton;
    Label1: TLabel;
    dtpDatum: TDateTimePicker;
    cbArt: TComboBox;
    Label2: TLabel;
    sbInsertAllStamm: TSpeedButton;
    cbAushilfen: TComboBox;
    Label3: TLabel;
    lbHinweis: TLabel;
    sbWeiter: TSpeedButton;
    procedure Initialize;
    procedure Image1Click(Sender: TObject);
    procedure cbJahrSelect(Sender: TObject);
    procedure cbStammpersonalSelect(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure lvWachtestSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure lvWachtestRightClickCell(Sender: TObject; iItem, iSubItem: Integer);
    procedure sbInsertAllStammClick(Sender: TObject);
    procedure cbAushilfenSelect(Sender: TObject);
    procedure sbWeiterClick(Sender: TObject);
    procedure lvWachtestClick(Sender: TObject);
  private
    s1, s2, s3, s4: String;
    currentIndex: Integer;
    procedure DisplayHinweisString;
    procedure generatePrintableWachtestTestSachkundestand(jahr: integer);
    procedure showWachtestTestSachkundestandInListView(LV: TListView; jahr: integer);
    procedure InsertMitarbeiterInListView(lv: TListView; MitarbeiterID, jahr: integer);
    procedure InsertItemInTableAusbildungen(mitarbeiterID, objektID, ausbildungsartID: integer; datum: TDate);
    procedure DeleteItemFromTableAusbildungen(mitarbeiterID, ausbildungsartID: integer; datum: string);
    procedure UpdateDatumInAusbildung(mitarbeiterID, objektID, ausbildungsartID: integer; datumAlt: string; neuesDatum: TDate);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public-Deklarationen }
  end;



const
  MonatsSpalten: array[2..14] of string = ('jan', 'feb', 'mar', 'apr', 'mai', 'jun', 'jul', 'aug', 'sep', 'okt', 'nov', 'dez', 'tsw');
  MONATSNAMEN: array[1..12] of string = ('jan', 'feb', 'mar', 'apr', 'mai', 'jun', 'jul', 'aug', 'sep', 'okt', 'nov', 'dez');
  Spaltenname: array[2..14] of string = ('Januar', 'Februar', 'M�rz', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember', 'TSW');



var
  SelYear: integer;
  SelectedMitarbeiterID: integer;





implementation

{$R *.dfm}
{$R WachtestTestSachkundestand.res}



uses
  uMain, uFunktionen, uDBFunktionen, uWebBrowser;




procedure TFrameWachtest.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_COMPOSITED;
end;




procedure TFrameWachtest.Initialize;
var
  Index: integer;
  CurrentYear, StartYear: Integer;
begin
   //Wahpersonalliste beim start automatisch nach Laufender Nummer sortieren
  ColumnToSort := 0; //Spalte 0=Caption, 1=erstes SubItem
  SortDir      := 0; //Aufsteigend- oder absteigend sortieren 0 = A-Z, 1 = Z-A
  lvWachtest.AlphaSort; //Sortierung anwenden

  //Die Jahre von 2023 bis aktuelles Jahr + 1 in cbJahr anzeigen
  CurrentYear := YearOf(Now);
  StartYear := 2023;
  for CurrentYear := StartYear to CurrentYear + 1 do
    cbJahr.Items.Add(IntToStr(CurrentYear));

  //Aktuelles Jahr ausw�hlen
  CurrentYear := YearOf(Now); // Das aktuelle Jahr ermitteln
  Index := cbJahr.Items.IndexOf(IntToStr(CurrentYear));  // Den Index des Eintrags mit dem aktuellen Jahr finden
  if Index <> -1 then // Wenn der Index gefunden wurde, den Eintrag selektieren
    cbJahr.ItemIndex := Index;

  cbJahrSelect(self);

  dtpDatum.Date := Date;
  SelMonth := 1;
  SelYear  := CurrentYear;

  showMitarbeiterInComboBox(cbStammpersonal, SelMonth, SelYear, false, OBJEKTID, 1);
  showMitarbeiterInComboBox(cbAushilfen, SelMonth, SelYear, false, OBJEKTID, 2); //Aushilfen die im gew�hlten Objekt aushelfen d�rfen

  lvWachtest.ItemIndex := -1;
  lvWachtest.Selected := nil;
  cbStammpersonal.ItemIndex := -1;
  cbAushilfen.ItemIndex := -1;
  cbStammpersonal.SetFocus;
  cbArt.ItemIndex := 0;
  dtpDatum.Date := Date;

  SelectedMitarbeiterID := -1;

  // Hinweistexte f�r Timer
  s1 := 'Schnell eine neue Wachtest-Jahres�bersicht erstellen'+#13#10+'klicken Sie auf den kleinen Button hinter dem Auswahlfeld f�r das Stammpersonal. (Die Liste muss daf�r leer sein)';
  s2 := 'Zum l�schen eines Datums mit der rechten Maustaste auf das zu l�schende Datum klicken';
  s3 := 'Zum l�schen eines kompletten Eintrages mit rechter Maustaste auf den Mitarbeiternamen in der Liste klicken';
  s4 := 'Zum �ndern eines Datums im gew�hlten Monat das Datum in der Liste anklicken, unten das neue Datum ausw�hlen und auf "Speichern" klicken';
  currentIndex := 2;  // Setze den Index auf den ersten String
  lbHinweis.Caption := s1;
end;







procedure TFrameWachtest.lvWachtestClick(Sender: TObject);
var
  m, i: Integer;
begin
  i := lvWachtest.ItemIndex;
  if(i <> -1) then
  begin
    for m := 0 to cbStammpersonal.Items.Count - 1 do
    begin
      if Integer(cbStammpersonal.Items.Objects[m]) = StrToInt(lvWachtest.Items[i].Caption) then
      begin
      //  SELENTRYID := StrToInt(lvWachtest.Items[i].Caption);
        cbStammpersonal.ItemIndex := m;
        Exit;
      end;
    end;
  end;
end;




procedure TFrameWachtest.lvWachtestRightClickCell(Sender: TObject; iItem, iSubItem: Integer);
var
  FDQuery: TFDQuery;
  s: string;
  i, spalte: integer;
  datumRaw, datum: string;
  parsedDate: TDateTime;
begin
  i := lvWachtest.ItemIndex;
  spalte := iSubItem;

  if spalte = 1 then
  begin
    if MessageDlg('Wollen Sie den kompletten Eintrag wirklich entfernen?', mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
    begin
      FDQuery := TFDQuery.Create(nil);
      try
        with FDQuery do
        begin
          Connection := fMain.FDConnection1;

          SQL.Text := 'DELETE FROM ausbildung_wachtest_tsw WHERE mitarbeiterid = :MAID AND jahr = :JAHR;';
          Params.ParamByName('MAID').AsInteger := SelectedMitarbeiterID;
          Params.ParamByName('JAHR').AsInteger := StrToInt(cbJahr.Text);

          ExecSql;

          lvWachtest.Items[iItem].Delete;
        end;
      except
        on E: Exception do
        begin
          ShowMessage('Fehler beim l�schen des Eintrags aus der Datenbank: ' + E.Message);
          Exit;
        end;
      end;
      FDQuery.Free;
    end;
  end;



  if(spalte > 1) then
  begin
    if(lvWachtest.Items[i].SubItems[spalte-1] <> '-----') then
    begin
      if MessageDlg('Wollen Sie das Datum im "' + Spaltenname[spalte] + '" wirklich entfernen?', mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
      begin
        datumRaw := lvWachtest.Items[i].SubItems[spalte - 1];

        if TryStrToDate(datumRaw, parsedDate) then
          datum := FormatDateTime('yyyy-mm-dd', parsedDate)
        else
          datum := '';



        FDQuery := TFDQuery.Create(nil);
        try
          with FDQuery do
          begin
            Connection := fMain.FDConnection1;

            if (spalte < 2) or (spalte > 14) then
              Exit; // ung�ltiger Index

            s := Format('UPDATE ausbildung_wachtest_tsw SET %s = :DATUM WHERE mitarbeiterid = :MAID AND jahr = :JAHR;', [MonatsSpalten[spalte]]);

            SQL.Text := s;
            Params.ParamByName('DATUM').AsString := '';
            Params.ParamByName('MAID').AsInteger := SelectedMitarbeiterID;
            Params.ParamByName('JAHR').AsInteger := StrToInt(cbJahr.Text);

            ExecSql;

            lvWachtest.Items[iItem].SubItems[spalte-1] := '-----';
          end;
        except
          on E: Exception do
          begin
            ShowMessage('Fehler beim Speichern des Eintrags in der Datenbanktabelle ' + E.Message);
            Exit;
          end;
        end;
        FDQuery.Free;


        //Ausbildung auch aus der Tabelle ausbildung entfernen (ausbildungsartID = 2)
        DeleteItemFromTableAusbildungen(SelectedMitarbeiterID, 2, datum);
      end;
    end;
  end;
end;





procedure TFrameWachtest.lvWachtestSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  i, a, maid: Integer;
begin
  a := lvWachtest.ItemIndex;

  if a > -1 then
  begin
    maid := StrToInt(lvWachtest.Items[a].Caption);
    SelectedMitarbeiterID := maid;

    for i := 0 to cbStammpersonal.Items.Count - 1 do
    begin
      if (cbStammpersonal.Items.Objects[i] is TObject) then
      begin
        if Integer(cbStammpersonal.Items.Objects[i]) = maid then
        begin
          cbStammpersonal.ItemIndex := i;
          Exit;
        end;
      end;
    end;


    for i := 0 to cbAushilfen.Items.Count - 1 do
    begin
      if (cbAushilfen.Items.Objects[i] is TObject) then
      begin
        if Integer(cbAushilfen.Items.Objects[i]) = maid then
        begin
          cbAushilfen.ItemIndex := i;
          Exit;
        end;
      end;
    end;
  end
  else
  begin
    cbStammpersonal.ItemIndex := 0;
    cbAushilfen.ItemIndex := 0;
    dtpDatum.Date := date;
    cbAushilfen.SetFocus;
  end;
end;







procedure TFrameWachtest.btnSaveClick(Sender: TObject);
var
  FDQuery: TFDQuery;
  Jahr, ausbildungsart, monatsindex: Integer;
  sqlText, datumSQL, monatSpalte, DatumAlt: string;
  i: Integer;
  EintragExistiert, MonatHatEintrag: Boolean;
begin
  i := lvWachtest.ItemIndex;
  if (i = -1) or ((cbStammpersonal.ItemIndex = -1) and (cbAushilfen.ItemIndex = -1)) then
  begin
    ShowMessage('Bitte w�hlen Sie einen Mitarbeiter aus dem Stammpersonal oder eine Aushilfe aus');
    Exit;
  end;

  if (SelectedMitarbeiterID <= 0) or (cbJahr.ItemIndex = -1) or (cbArt.ItemIndex = -1) then
  begin
    ShowMessage('Bitte w�hlen Sie Mitarbeiter, Jahr, Art und ein Datum!');
    Exit;
  end;

  Jahr := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);
  ausbildungsart := cbArt.ItemIndex;
  monatsindex := GetMonatsIndexFromDatum(DateToStr(dtpDatum.Date));
  monatSpalte := MONATSNAMEN[monatsindex];
  datumSQL := ConvertGermanDateToSQLDate(DateToStr(dtpDatum.Date), false);
  DatumAlt := '';
  MonatHatEintrag := False;

  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := fMain.FDConnection1;

    // Pr�fen, ob Datensatz mit MitarbeiterID + Jahr existiert und ob Monatsspalte gef�llt ist
    FDQuery.SQL.Text := Format(
      'SELECT %s FROM ausbildung_wachtest_tsw WHERE mitarbeiterid = :MAID AND jahr = :JAHR;',
      [monatSpalte]
    );
    FDQuery.ParamByName('MAID').AsInteger := SelectedMitarbeiterID;
    FDQuery.ParamByName('JAHR').AsInteger := Jahr;
    FDQuery.Open;

    EintragExistiert := not FDQuery.IsEmpty;
    if EintragExistiert then
    begin
      DatumAlt := Trim(FDQuery.FieldByName(monatSpalte).AsString);
      MonatHatEintrag := DatumAlt <> '';
    end;
    FDQuery.Close;

    // SQL vorbereiten
    if ausbildungsart = 1 then
    begin
      // Ausbildungsart = TSW
      if EintragExistiert then
        sqlText := 'UPDATE ausbildung_wachtest_tsw SET tsw = :DATUM WHERE mitarbeiterid = :MAID AND jahr = :JAHR;'
      else
        sqlText := 'INSERT INTO ausbildung_wachtest_tsw (mitarbeiterid, objektid, jahr, tsw) VALUES (:MAID, :OBID, :JAHR, :DATUM);';
    end
    else
    begin
      // Monatsbasierte Ausbildung
      if EintragExistiert then
        sqlText := Format(
          'UPDATE ausbildung_wachtest_tsw SET %s = :DATUM WHERE mitarbeiterid = :MAID AND jahr = :JAHR;',
          [monatSpalte]
        )
      else
        sqlText := Format(
          'INSERT INTO ausbildung_wachtest_tsw (mitarbeiterid, objektid, jahr, %s) VALUES (:MAID, :OBID, :JAHR, :DATUM);',
          [monatSpalte]
        );
    end;

    // Ausf�hren
    FDQuery.SQL.Text := sqlText;
    FDQuery.ParamByName('MAID').AsInteger := SelectedMitarbeiterID;
    FDQuery.ParamByName('JAHR').AsInteger := Jahr;
    FDQuery.ParamByName('DATUM').AsString := datumSQL;

    if not EintragExistiert then
    begin
      FDQuery.ParamByName('OBID').AsInteger := OBJEKTID;
    end;

    FDQuery.ExecSQL;

    // Daten in Tabelle "ausbildung" pflegen (UzwGBw-Theorie = 2)
    if MonatHatEintrag and (DatumAlt <> datumSQL) then
    begin
      UpdateDatumInAusbildung(SelectedMitarbeiterID, OBJEKTID, 2, DatumAlt, dtpDatum.Date);
    end
    else if not MonatHatEintrag then
    begin
      InsertItemInTableAusbildungen(SelectedMitarbeiterID, OBJEKTID, 2, dtpDatum.Date);
    end;
  except
    on E: Exception do
    begin
      ShowMessage('Fehler beim Speichern des Eintrags: ' + E.Message);
      FDQuery.Free;
      Exit;
    end;
  end;

  FDQuery.Free;

  cbJahrSelect(Self);
  SelectMitarbeiterInListView(lvWachtest, SelectedMitarbeiterID);
end;









procedure TFrameWachtest.InsertItemInTableAusbildungen(mitarbeiterID, objektID, ausbildungsartID: integer; datum: TDate);
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDQuery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'INSERT INTO ausbildung (mitarbeiterID, objektID, ausbildungsartID, datum) ' +
                  'VALUES (:MID, :OID, :AID, :DAT);';

      Params.ParamByName('MID').AsInteger := mitarbeiterID;
      Params.ParamByName('OID').AsInteger := objektID;
      Params.ParamByName('AID').AsInteger := ausbildungsartID;
      Params.ParamByName('DAT').AsString  := ConvertGermanDateToSQLDate(DateToStr(datum), false);
      try
        ExecSQL;
      except
        on E: Exception do
        begin
          ShowMessage('Fehler beim Speichern des Eintrags in der Datenbanktabelle ausbildung: ' + E.Message);
          Exit;
        end;
      end;
    end;
  finally
    FDQuery.Free;
  end;
end;




procedure TFrameWachtest.UpdateDatumInAusbildung(mitarbeiterID, objektID, ausbildungsartID: integer; datumAlt: string; neuesDatum: TDate);
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := fMain.FDConnection1;
    FDQuery.SQL.Text := 'UPDATE ausbildung SET datum = :NEU ' +
                        'WHERE mitarbeiterID = :MID AND objektID = :OID AND ausbildungsartID = :AID AND datum = :ALT;';
    FDQuery.ParamByName('MID').AsInteger := mitarbeiterID;
    FDQuery.ParamByName('OID').AsInteger := objektID;
    FDQuery.ParamByName('AID').AsInteger := ausbildungsartID;
    FDQuery.ParamByName('ALT').AsString := datumAlt;
    FDQuery.ParamByName('NEU').AsString := ConvertGermanDateToSQLDate(DateToStr(neuesDatum), False);
    FDQuery.ExecSQL;
  finally
    FDQuery.Free;
  end;
end;






procedure TFrameWachtest.DeleteItemFromTableAusbildungen(mitarbeiterID, ausbildungsartID: integer; datum: string);
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDQuery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'DELETE FROM ausbildung WHERE mitarbeiterID = :MID AND ausbildungsartID = :AID AND datum = :DAT;';

      Params.ParamByName('MID').AsInteger := mitarbeiterID;
      Params.ParamByName('AID').AsInteger := ausbildungsartID;
      Params.ParamByName('DAT').AsString  := datum;
      try
        ExecSQL;
      except
        on E: Exception do
        begin
          ShowMessage('Fehler beim l�schen des Eintrags aus der Datenbanktabelle ausbildung: ' + E.Message);
          Exit;
        end;
      end;
    end;
  finally
    FDQuery.Free;
  end;
end;






procedure TFrameWachtest.cbAushilfenSelect(Sender: TObject);
var
  SelectedIndex: Integer;
  j: integer;
begin
  j := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);
  SelectedIndex := -1;


  if cbAushilfen.ItemIndex <> -1 then
  begin
    SelectedIndex := Integer(cbAushilfen.Items.Objects[cbAushilfen.ItemIndex]);
    InsertMitarbeiterInListView(lvWachtest, SelectedIndex, j);
  end;

  cbAushilfen.ItemIndex := -1;

  SearchAndHighlight(lvWachtest, IntToStr(SelectedIndex), [1]);
end;




procedure TFrameWachtest.cbJahrSelect(Sender: TObject);
var
  CurrentDate: TDateTime;
  NewDate: TDateTime;
  Year, Month, Day: Word;
begin
  SelYear  := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);

  //Das Jahr im dtpDatum auf dsa gew�hlte Jahr �ndern
  CurrentDate := dtpDatum.Date;
  DecodeDate(CurrentDate, Year, Month, Day);
  NewDate := EncodeDate(SelYear, Month, Day);
  dtpDatum.Date := NewDate;

  cbStammpersonal.ItemIndex := 0;
  cbAushilfen.ItemIndex := 0;

  showMitarbeiterInComboBox(cbStammpersonal, 1, SelYear, false, OBJEKTID, 1);
  showMitarbeiterInComboBox(cbAushilfen, 1, SelYear, false, OBJEKTID, 2);

  showWachtestTestSachkundestandInListView(lvWachtest, SelYear);
end;






procedure TFrameWachtest.Image1Click(Sender: TObject);
begin
  generatePrintableWachtestTestSachkundestand(SelYear);
end;












procedure TFrameWachtest.cbStammpersonalSelect(Sender: TObject);
var
  MitarbeiterID: Integer;
  i: integer;
begin
  i := cbStammpersonal.ItemIndex;
  if i <> -1 then
  begin
    if cbStammpersonal.ItemIndex > 0 then
    begin
      MitarbeiterID := Integer(cbStammpersonal.Items.Objects[i]);
      InsertMitarbeiterInListView(lvWachtest, MitarbeiterID, SelYear); //id des Mitarbeiters aus der ComboBox �bergeben
      SelectMitarbeiterInListView(lvWachtest, MitarbeiterID);
    end;

    cbStammpersonal.ItemIndex := -1;
    dtpDatum.SetFocus;
  end
  else
  begin
    showmessage('Bitte w�hlen Sie einen Mitarbeiter aus der Auswahlbox aus.');
  end;
end;





procedure TFrameWachtest.InsertMitarbeiterInListView(lv: TListView; MitarbeiterID, jahr: integer);
var
  FDQuery: TFDQuery;
  id, objektid: integer;
begin
  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

//Schauen ob der Mitarbeiter f�r den gew�nschten Zeitraum
//bereits in der Datenbanktabelle "wachpersonal" steht
      SQL.Clear;
      SQL.Add('SELECT id FROM ausbildung_wachtest_tsw ');
      SQL.Add('WHERE mitarbeiterid = :MITARBEITERID AND jahr = :JAHR;');
      Params.ParamByName('MITARBEITERID').AsInteger := MitarbeiterID; //ID aus ComboBox
      Params.ParamByName('JAHR').AsInteger          := jahr;
      Open;

//Mitarbeiter steht noch nicht in der Tabelle "wachpersonal"
      if(RecordCount = 0) then
      begin
//Mitarbeiterdaten aus Datenbanktabelle "mitarbeiter" auslesen
        SQL.Text := 'SELECT id, objektid FROM mitarbeiter WHERE id = :MITARBEITERID;';
        Params.ParamByName('MITARBEITERID').AsInteger := MitarbeiterID;
        Open;

//Ausgelesene Werte Variablen zuweisen
        id             := FieldByName('id').AsInteger;
        objektid       := FieldByName('objektid').AsInteger;

//Mitarbeiter in Datenbanktabelle "ausbildung_wachtest_tsw" schreiben
        with FDQuery do
        begin
          SQL.Text := 'INSERT INTO ausbildung_wachtest_tsw (mitarbeiterid, objektid, jahr) ' +
                      'VALUES (:MITARBEITERID, :OBJEKTID, :JAHR);';

          Params.ParamByName('MITARBEITERID').AsInteger := MitarbeiterID;
          Params.ParamByName('OBJEKTID').AsInteger      := objektid;
          Params.ParamByName('JAHR').AsInteger          := jahr;

          ExecSQL;
        end;
      end
      else
      begin
        SelectMitarbeiterInListView(lvWachtest, MitarbeiterID);
      end;
    end;
  finally
    FDQuery.free;
    cbJahrSelect(nil);
  end;
end;





procedure TFrameWachtest.generatePrintableWachtestTestSachkundestand(jahr: integer);
var
  stltemp: TStringList;
  SEITE, i, a, lvCount, ANZAHLSEITEN: integer;
  StartIndex: integer;
  EndIndex: integer;
  filename: string;
  stlHtmlHeader, stlHtmlFooter, stlSiteHeader, stlSiteFooter, stlContent: TStringList;
  resHtmlHeader, resHtmlFooter, resSiteHeader, resSiteFooter, resContent: TResourceStream;
  mit, jan, feb, mar, apr, mai, jun, jul, aug, sep, okt, nov, dez, tsw: String;
  ZEILEN: integer;
begin
  stlHtmlHeader := nil;
  stlHtmlFooter := nil;
  resHtmlHeader := nil;
  resHtmlFooter := nil;
  stlTemp := nil;


  jahr      := StrToInt(cbJahr.Text);
  ZEILEN    := 14; //Anzahl der Tabellen-Zeilen pro Seite

  lvCount := lvWachtest.Items.Count;

  if(lvCount > ZEILEN) then ANZAHLSEITEN := CEIL(lvCount / ZEILEN) else ANZAHLSEITEN := 1;


//Hier nur das was einmal f�r alle Seiten geladen werden muss (HtmlHeader, HtmlFooter)
  try
    resHtmlHeader := TResourceStream.Create(HInstance, 'WachtestTestSachkundestand_HTML_Header', 'TXT');
    resHtmlFooter := TResourceStream.Create(HInstance, 'WachtestTestSachkundestand_HTML_Footer', 'TXT');

    stlHtmlHeader := TStringList.Create;
    stlHtmlHeader.LoadFromStream(resHtmlHeader);

    stlHtmlFooter := TStringList.Create;
    stlHtmlFooter.LoadFromStream(resHtmlFooter);

    stlTemp := TStringList.Create;


//Hier alles was mehrmals geladen werden muss (f�r jede Seite - SiteHeader, SiteFooter, Content)

    for SEITE := 0 to ANZAHLSEITEN - 1 do
    begin

//SITEHEADER START
      resSiteHeader := TResourceStream.Create(HInstance, 'WachtestTestSachkundestand_SITE_Header', 'TXT');
      stlSiteHeader := TStringList.Create;
      try
        stlSiteHeader.LoadFromStream(resSiteHeader);

        stlSiteHeader.Text := StringReplace(stlSiteHeader.Text, '[OBJEKT]', OBJEKTNAME, [rfReplaceAll]);
        stlSiteHeader.Text := StringReplace(stlSiteHeader.Text, '[JAHR]', IntToStr(Jahr), [rfReplaceAll]);
        stltemp.Add(stlSiteHeader.Text);
      finally
        stlSiteHeader.Free;
        resSiteHeader.Free;
      end;
//SITEHEADER ENDE

//CONTENT START
      StartIndex := SEITE * ZEILEN;
      EndIndex   := Min((SEITE + 1) * ZEILEN - 1, lvCount - 1);

      for a := StartIndex to EndIndex do
      begin
        mit := lvWachtest.Items[a].SubItems[0];
        jan := lvWachtest.Items[a].SubItems[1];
        feb := lvWachtest.Items[a].SubItems[2];
        mar := lvWachtest.Items[a].SubItems[3];
        apr := lvWachtest.Items[a].SubItems[4];
        mai := lvWachtest.Items[a].SubItems[5];
        jun := lvWachtest.Items[a].SubItems[6];
        jul := lvWachtest.Items[a].SubItems[7];
        aug := lvWachtest.Items[a].SubItems[8];
        sep := lvWachtest.Items[a].SubItems[9];
        okt := lvWachtest.Items[a].SubItems[10];
        nov := lvWachtest.Items[a].SubItems[11];
        dez := lvWachtest.Items[a].SubItems[12];
        tsw := lvWachtest.Items[a].SubItems[13];

//Resource WaffenbestandContent auslesen und in Stringlist laden
        resContent := TResourceStream.Create(HInstance, 'WachtestTestSachkundestand_SITE_Content', 'TXT');
        stlContent := TStringList.Create;
        try
          stlContent.LoadFromStream(resContent);
          stlContent.Text := StringReplace(stlContent.Text, '[MIT]', mit, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[JAN]', jan, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[FEB]', feb, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[MAR]', mar, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[APR]', apr, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[MAI]', mai, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[JUN]', jun, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[JUL]', jul, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[AUG]', aug, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[SEP]', sep, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[OKT]', okt, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[NOV]', nov, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[DEZ]', dez, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[TSW]', tsw, [rfReplaceAll]);
          stltemp.Add(stlContent.Text);
        finally
          resContent.Free;
          stlContent.Free;
        end;
      end;


//Wenn auf der letzten Seite weniger als WAFFENPROSEITE vorhanden sind. leere Zeilen einf�gen
//damit das Formular immer gleich gro� ist
//�berpr�fen, ob weniger als WAFFENPROSEITE Eintr�ge vorhanden sind
    if (SEITE = ANZAHLSEITEN - 1) and (EndIndex - StartIndex < ZEILEN - 1) then
    begin
      for a := EndIndex + 1 to (SEITE + 1) * ZEILEN - 1 do
      begin
        resContent := TResourceStream.Create(HInstance, 'WachtestTestSachkundestand_SITE_Content', 'TXT');
        stlContent := TStringList.Create;
        try
          stlContent.LoadFromStream(resContent);
          stlContent.Text := StringReplace(stlContent.Text, '[MIT]', '&nbsp;', [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[JAN]', '&nbsp;', [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[FEB]', '&nbsp;', [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[MAR]', '&nbsp;', [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[APR]', '&nbsp;', [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[MAI]', '&nbsp;', [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[JUN]', '&nbsp;', [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[JUL]', '&nbsp;', [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[AUG]', '&nbsp;', [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[SEP]', '&nbsp;', [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[OKT]', '&nbsp;', [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[NOV]', '&nbsp;', [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[DEZ]', '&nbsp;', [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[TSW]', '&nbsp;', [rfReplaceAll]);
          stltemp.Add(stlContent.Text);
        finally
          resContent.Free;
          stlContent.Free;
        end;
      end;
    end;
//CONTENT ENDE


//SITEFOOTER START
      resSiteFooter := TResourceStream.Create(HInstance, 'WachtestTestSachkundestand_SITE_Footer', 'TXT');
      stlSiteFooter := TStringList.Create;
      try
        stlSiteFooter.LoadFromStream(resSiteFooter);
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


    //Dateiname f�r zu speichernde Datei erzeugen
    filename := 'Wachtest - Sachkunde '+ IntToStr(jahr)+' '+OBJEKTNAME + ' ' + OBJEKTORT;

    //Aus Resource-Datei tempor�re Html-Datei und daraus eine PDF-Datei im TEMP Verzeichnis erzeugen
    CreateHtmlAndPdfFileFromResource(filename, stlTemp);

    //PDF Datei aus Temp Verzeichnis im Zielverzeichnis speichern
    SpeicherePDFDatei(filename, SAVEPATH_Wachtest);
  finally
    if Assigned(stlHtmlHeader) then stlHtmlHeader.Free;
    if Assigned(stlHtmlFooter) then stlHtmlFooter.Free;
    if Assigned(resHtmlHeader) then resHtmlHeader.Free;
    if Assigned(resHtmlFooter) then resHtmlFooter.Free;
    if Assigned(stlTemp) then stlTemp.Free;
  end;
end;








{******************************************************************************************
  Alle Waffen aus der Waffenbestandsmeldung aus Datenbank-Tabelle Waffenbestandsliste     *
  auslesen und in ListView anzeigen                                                       *
******************************************************************************************}
procedure TFrameWachtest.sbInsertAllStammClick(Sender: TObject);
var
  a, x: integer;
begin
  x := lvWachtest.Items.Count;

  if x = 0 then
  begin
    for a := 1 to cbStammpersonal.Items.Count do
    begin
      cbStammpersonal.ItemIndex := a;
      cbStammpersonalSelect(self);
    end;
  end
  else
  begin
    PlayResourceMP3('BLING', 'TEMP\bling.wav');
    showmessage('Diese Funktion steht nur zur Verf�gung wenn die Liste leer ist.');
  end;
end;





procedure TFrameWachtest.sbWeiterClick(Sender: TObject);
begin
  DisplayHinweisString;
end;

procedure TFrameWachtest.showWachtestTestSachkundestandInListView(LV: TListView; jahr: integer);
var
  L: TListItem;
  FDQuery: TFDQuery;
  Jan, Feb, Mar, Apr, Mai, Jun, Jul, Aug, Sep, Okt, Nov, Dez, TSW: string;
begin
  ClearListView(LV);

  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT M.id, M.nachname, M.vorname, A.jahr, A.jan, A.feb, A.mar, A.apr, ' +
                  'A.mai, A.jun, A.jul, A.aug, A.sep, A.okt, A.nov, A.dez, A.tsw ' +
                  'FROM mitarbeiter AS M LEFT JOIN ausbildung_wachtest_tsw AS A ON M.id = A.mitarbeiterid ' +
                  'WHERE jahr = :JAHR ' +
                  'ORDER BY M.objektid, M.nachname, M.vorname;';

      Params.ParamByName('JAHR').AsInteger := jahr;

      Open;


      while not Eof do
      begin
        Jan := ConvertSQLDateToGermanDate(FieldByName('jan').AsString, false, true);
        Feb := ConvertSQLDateToGermanDate(FieldByName('feb').AsString, false, true);
        Mar := ConvertSQLDateToGermanDate(FieldByName('mar').AsString, false, true);
        Apr := ConvertSQLDateToGermanDate(FieldByName('apr').AsString, false, true);
        Mai := ConvertSQLDateToGermanDate(FieldByName('mai').AsString, false, true);
        Jun := ConvertSQLDateToGermanDate(FieldByName('jun').AsString, false, true);
        Jul := ConvertSQLDateToGermanDate(FieldByName('jul').AsString, false, true);
        Aug := ConvertSQLDateToGermanDate(FieldByName('aug').AsString, false, true);
        Sep := ConvertSQLDateToGermanDate(FieldByName('sep').AsString, false, true);
        Okt := ConvertSQLDateToGermanDate(FieldByName('okt').AsString, false, true);
        Nov := ConvertSQLDateToGermanDate(FieldByName('nov').AsString, false, true);
        Dez := ConvertSQLDateToGermanDate(FieldByName('dez').AsString, false, true);
        TSW := ConvertSQLDateToGermanDate(FieldByName('tsw').AsString, false, true);

        l := LV.Items.Add;
        l.Caption := FieldByName('id').AsString;
        l.SubItems.Add(FieldByName('Nachname').AsString);
        if(Jan<>'') then l.SubItems.Add(Jan) else l.SubItems.Add('-----');
        if(Feb<>'') then l.SubItems.Add(Feb) else l.SubItems.Add('-----');
        if(Mar<>'') then l.SubItems.Add(Mar) else l.SubItems.Add('-----');
        if(Apr<>'') then l.SubItems.Add(Apr) else l.SubItems.Add('-----');
        if(Mai<>'') then l.SubItems.Add(Mai) else l.SubItems.Add('-----');
        if(Jun<>'') then l.SubItems.Add(Jun) else l.SubItems.Add('-----');
        if(Jul<>'') then l.SubItems.Add(Jul) else l.SubItems.Add('-----');
        if(Aug<>'') then l.SubItems.Add(Aug) else l.SubItems.Add('-----');
        if(Sep<>'') then l.SubItems.Add(Sep) else l.SubItems.Add('-----');
        if(Okt<>'') then l.SubItems.Add(Okt) else l.SubItems.Add('-----');
        if(Nov<>'') then l.SubItems.Add(Nov) else l.SubItems.Add('-----');
        if(Dez<>'') then l.SubItems.Add(Dez) else l.SubItems.Add('-----');
        if(TSW<>'') then l.SubItems.Add(TSW) else l.SubItems.Add('-----');

        Next;
      end;
    end;
  finally
    FDQuery.free;
  end;
end;





procedure TFrameWachtest.DisplayHinweisString;
begin
  case currentIndex of
    1: lbHinweis.Caption := s1;
    2: lbHinweis.Caption := s2;
    3: lbHinweis.Caption := s3;
    4: lbHinweis.Caption := s4;
  end;

  // Inkrementiere den Index und setze ihn zur�ck auf 1, wenn er 4 erreicht
  currentIndex := currentIndex mod 4 + 1;
end;







end.
