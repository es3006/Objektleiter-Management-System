unit uDBFunktionen;

interface

uses
  Windows, Classes, Forms, SysUtils, Vcl.StdCtrls, Vcl.ComCtrls, Dialogs, Controls, ExtCtrls, DateUtils,
  Graphics, StrUtils, ShellApi, System.UITypes, System.Zip, System.IOUtils,
  FireDAC.Stan.Param, FireDAC.Phys.SQLite, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;


procedure CreateDatabaseTables;
procedure CreateIndexes;
procedure ReadSettingsFromDB;
procedure ReadObjektleiterObjektSettings;
procedure showAdmins(LV: TListView);
procedure showMitarbeiterInComboBox(cb: TComboBox; monat, jahr: integer; aushilfe: boolean = false; ObjektID: integer = 0; art: integer = 1);
procedure showSerienNrByNrWBKInCB(cb: TComboBox; NrWBK: String);
procedure showObjekteInComboBox(CB: TComboBox; ort: boolean = false);
procedure showObjekteInListView(LV: TListView);
procedure showDiensthundeInCB(cb: TComboBox);
procedure BackupSQLiteTable(const TableName: string; const BackupDir: string);
procedure BackupAllTables;
procedure ZipDir(const Dir: string);
procedure ImportSQLiteTable(const SQLFileName: string);
procedure ExtractAndImportSQLFiles(const ZipFileName, TargetDir: string);
procedure AddDogDatabaseTables;

function showGutscheinartByMitarbeterID(MitarbeiterID: integer): string;
function WochenberichtExists(KW, JAHR: integer): boolean;
function showObjektOrtByObjektID(ObjektID: integer): string;




implementation

uses
  uMain, uFunktionen, uDBSettings, uWebBrowser;





procedure ReadSettingsFromDB;
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDQuery.Create(nil);
  try
    try
      FDQuery.Connection := fMain.FDConnection1;

      FDQuery.SQL.Text := 'SELECT ObjektID, ObjektleiterID, StellvObjektleiterID, Waffenbestand, Waffentyp, BestandWachMun, WachmunKaliber, BestandWachschiessenMun, ' +
                          'WachschiessenMunKaliber, BestandManoeverMun, ManoeverMunKaliber, BestandVerschussmenge, ' +
                          'VerschussmengeMunKaliber FROM einstellungen;';

      FDQuery.Open;

      if not FDQuery.IsEmpty then
      begin
        OBJEKTID                 := FDQuery.FieldByName('ObjektID').AsInteger;
        OBJEKTLEITERID           := FDQuery.FieldByName('ObjektleiterID').AsInteger;
        STELLVOBJEKTLEITERID     := FDQuery.FieldByName('StellvObjektleiterID').AsInteger;
        WAFFENBESTAND            := FDQuery.FieldByName('Waffenbestand').AsInteger;
        WAFFENTYP                := FDQuery.FieldByName('Waffentyp').AsString;
        BESTANDWACHMUN           := FDQuery.FieldByName('BestandWachMun').AsInteger;
        WACHMUNKALIBER           := FDQuery.FieldByName('WachmunKaliber').AsString;
        BESTANDWACHSCHIESSENMUN  := FDQuery.FieldByName('BestandWachschiessenMun').AsInteger;
        WACHSCHIESSENMUNKALIBER  := FDQuery.FieldByName('WachschiessenMunKaliber').AsString;
        BESTANDMANOEVERMUN       := FDQuery.FieldByName('BestandManoeverMun').AsInteger;
        MANOEVERMUNKALIBER       := FDQuery.FieldByName('ManoeverMunKaliber').AsString;
        BESTANDVERSCHUSSMENGE    := FDQuery.FieldByName('BestandVerschussmenge').AsInteger;
        VERSCHUSSMENGEMUNKALIBER := FDQuery.FieldByName('VerschussmengeMunKaliber').AsString;
      end;
    except
      on E: Exception do
      begin
        ShowMessage('Fehler beim Lesen von Waffen- und Munition aus der Tabelle [einstellungen]: ' + E.Message);
      end;
    end;
  finally
    FDQuery.Free;
  end;
end;




procedure ReadObjektleiterObjektSettings;
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDQuery.Create(nil);
  try
    try
      FDQuery.Connection := fMain.FDConnection1;

      FDQuery.SQL.Text := 'SELECT E.objektid, O.objektname, O.ort, E.objektleiterid, E.stellvobjektleiterid, ' +
                          'L.nachname || " " || L.vorname AS objektleitername, ' +
                          'S.nachname || " " || S.vorname AS stellvobjektleitername ' +
                          'FROM einstellungen AS E ' +
                          'INNER JOIN objekte AS O ON E.objektid = O.id ' +
                          'LEFT JOIN mitarbeiter AS L ON E.objektleiterid = L.id ' +
                          'LEFT JOIN mitarbeiter AS S ON E.stellvobjektleiterid = S.id;';
      FDQuery.Open;

      if not FDQuery.IsEmpty then
      begin
        OBJEKTID             := FDQuery.FieldByName('objektid').AsInteger;
        OBJEKTNAME           := FDQuery.FieldByName('objektname').AsString;
        OBJEKTORT            := FDQuery.FieldByName('ort').AsString;
        OBJEKTLEITERID       := FDQuery.FieldByName('objektleiterid').AsInteger;
        STELLVOBJEKTLEITERID := FDQuery.FieldByName('stellvobjektleiterid').AsInteger;
       // OBJEKTLEITERNAME     := FDQuery.FieldByName('objektleitername').AsString;
       // STELLVOBJEKTLEITERNAME := FDQuery.FieldByName('objektleitername').AsString;

      end;
    except
      on E: Exception do
      begin
        ShowMessage('Fehler beim Lesen von Objekt- und Objektleiter aus der Tabelle [einstellungen]: ' + E.Message);
      end;
    end;
  finally
    FDQuery.Free;
  end;
end;






//NEU START
procedure CreateDatabaseTables;
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := fMain.FDConnection1;


    FDQuery.SQL.Text := 'SELECT name FROM sqlite_master WHERE type="table" AND name="admins"';
    FDQuery.Open();
    if not FDQuery.IsEmpty then
      Exit
    else
    begin
      FDQuery.SQL.Text := 'CREATE TABLE admins (' +
                          'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                          'mitarbeiterid TEXT, ' +
                          'username TEXT, ' +
                          'password TEXT);';
      FDQuery.ExecSQL;
    end;


    FDQuery.SQL.Text := 'SELECT name FROM sqlite_master WHERE type="table" AND name="einstellungen"';
    FDQuery.Open();
    if not FDQuery.IsEmpty then
      Exit
    else
    begin
      FDQuery.SQL.Text := 'CREATE TABLE einstellungen (' +
                          'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                          'ObjektID INTEGER, ' +
                          'ObjektleiterID INTEGER, ' +
                          'StellvObjektleiterID INTEGER, ' +
                          'Waffenbestand INTEGER DEFAULT 0, ' +
                          'Waffentyp TEXT DEFAULT "H+K P8", ' +
                          'BestandWachMun INTEGER DEFAULT 0, ' +
                          'WachmunKaliber TEXT DEFAULT "9x19 mm", ' +
                          'BestandWachschiessenMun INTEGER DEFAULT 0, ' +
                          'WachschiessenMunKaliber TEXT DEFAULT "9x19 mm", ' +
                          'BestandManoeverMun INTEGER DEFAULT 0, ' +
                          'ManoeverMunKaliber TEXT DEFAULT "9x19 mm", ' +
                          'BestandVerschussmenge INTEGER DEFAULT 0, ' +
                          'VerschussmengeMunKaliber TEXT DEFAULT "9x19 mm");';
      FDQuery.ExecSQL;
    end;



    FDQuery.SQL.Text := 'SELECT name FROM sqlite_master WHERE type="table" AND name="objekte"';
    FDQuery.Open();
    if not FDQuery.IsEmpty then
      Exit
    else
    begin
      FDQuery.SQL.Text := 'CREATE TABLE objekte (' +
                          'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                          'objektname TEXT NOT NULL, ' +
                          'strasse TEXT, ' +
                          'hausnr TEXT, ' +
                          'plz TEXT, ' +
                          'ort TEXT, ' +
                          'tel1beschreibung TEXT, '+
                          'tel1 TEXT, ' +
                          'tel2beschreibung TEXT, ' +
                          'tel2 TEXT, ' +
                          'tel3beschreibung TEXT, ' +
                          'tel3 TEXT, ' +
                          'registriert TEXT);';
      FDQuery.ExecSQL;
    end;


    FDQuery.SQL.Text := 'SELECT name FROM sqlite_master WHERE type="table" AND name="mitarbeiter"';
    FDQuery.Open();
    if not FDQuery.IsEmpty then
      Exit
    else
    begin
      FDQuery.SQL.Text := 'CREATE TABLE mitarbeiter (' +
                          'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                          'objektid INTEGER, ' +
                          'personalnr TEXT, ' +
                          'nachname TEXT NOT NULL, ' +
                          'vorname TEXT NOT NULL, ' +
                          'geburtsdatum TEXT, ' +
                          'eintrittsdatum TEXT, ' +
                          'austrittsdatum TEXT, ' +
                          'waffennummer TEXT, ' +
                          'ausweisnr TEXT, ' +
                          'ausweisgueltigbis TEXT, ' +
                          'sonderausweisnr TEXT, ' +
                          'sonderausweisgueltigbis TEXT, ' +
                          'tankgutscheinart TEXT);';
      FDQuery.ExecSQL;
    end;



    FDQuery.SQL.Text := 'SELECT name FROM sqlite_master WHERE type="table" AND name="mitarbeiter_kontaktdaten"';
    FDQuery.Open();
    if not FDQuery.IsEmpty then
      Exit
    else
    begin
      FDQuery.SQL.Text := 'CREATE TABLE mitarbeiter_kontaktdaten (' +
                          'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                          'mitarbeiterid INTEGER NOT NULL, ' +
                          'telefon TEXT, ' +
                          'handy TEXT, ' +
                          'email TEXT, ' +
                          'strasse TEXT, ' +
                          'hausnr TEXT, ' +
                          'plz TEXT, ' +
                          'ort TEXT);';
      FDQuery.ExecSQL;
    end;



    FDQuery.SQL.Text := 'SELECT name FROM sqlite_master WHERE type="table" AND name="mitarbeiter_objekte"';
    FDQuery.Open();
    if not FDQuery.IsEmpty then
      Exit
    else
    begin
      FDQuery.SQL.Text := 'CREATE TABLE mitarbeiter_objekte (' +
                          'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                          'mitarbeiterid INTEGER, ' +
                          'objektid INTETER);';
      FDQuery.ExecSQL;
    end;


    FDQuery.SQL.Text := 'SELECT name FROM sqlite_master WHERE type="table" AND name="wachpersonal"';
    FDQuery.Open();
    if not FDQuery.IsEmpty then
      Exit
    else
    begin
      FDQuery.SQL.Text := 'CREATE TABLE wachpersonal (' +
                          'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                          'mitarbeiterid INTEGER NOT NULL, ' +
                          'monat INTEGER, ' +
                          'jahr INTEGER, ' +
                          'nachname TEXT, ' +
                          'vorname TEXT, ' +
                          'eintrittsdatum TEXT, ' +
                          'geburtsdatum TEXT, ' +
                          'ausweisnr TEXT, ' +
                          'ausweisgueltigbis TEXT, ' +
                          'sonderausweisnr TEXT, ' +
                          'sonderausweisgueltigbis TEXT, ' +
                          'waffennummer TEXT, ' +
                          'diensthund TEXT, ' +
                          'position INTEGER);';
      FDQuery.ExecSQL;
    end;


    FDQuery.SQL.Text := 'SELECT name FROM sqlite_master WHERE type="table" AND name="waffenbestand"';
    FDQuery.Open();
    if not FDQuery.IsEmpty then
      Exit
    else
    begin
      FDQuery.SQL.Text := 'CREATE TABLE waffenbestand (' +
                          'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                          'pos INTEGER, ' +
                          'nrwbk TEXT, ' +
                          'waffentyp TEXT, ' +
                          'seriennr TEXT, ' +
                          'fach INTEGER);';
      FDQuery.ExecSQL;
    end;



    FDQuery.SQL.Text := 'SELECT name FROM sqlite_master WHERE type="table" AND name="waffenbestandsliste"';
    FDQuery.Open();
    if not FDQuery.IsEmpty then
      Exit
    else
    begin
      FDQuery.SQL.Text := 'CREATE TABLE waffenbestandsliste (' +
                          'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                          'pos INTEGER, ' +
                          'monat INTEGER, ' +
                          'jahr INTEGER, ' +
                          'nrwbk TEXT, ' +
                          'waffentyp TEXT, ' +
                          'waffennutzer TEXT, ' +
                          'seriennr TEXT, ' +
                          'fach INTEGER);';
      FDQuery.ExecSQL;
    end;



    FDQuery.SQL.Text := 'SELECT name FROM sqlite_master WHERE type="table" AND name="munitionstausch"';
    FDQuery.Open();
    if not FDQuery.IsEmpty then
      Exit
    else
    begin
      FDQuery.SQL.Text := 'CREATE TABLE munitionstausch (' +
                          'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                          'datum TEXT, ' +
                          'bestandvorher INTEGER, ' +
                          'eingang INTEGER, ' +
                          'abgang INTEGER, ' +
                          'bestandnachher INTEGER, ' +
                          'zweck TEXT, ' +
                          'uebergebender TEXT, ' +
                          'uebernehmender TEXT);';
      FDQuery.ExecSQL;
    end;


    FDQuery.SQL.Text := 'SELECT name FROM sqlite_master WHERE type="table" AND name="wochenbericht_data"';
    FDQuery.Open();
    if not FDQuery.IsEmpty then
      Exit
    else
    begin
      FDQuery.SQL.Text := 'CREATE TABLE wochenbericht_data (' +
                          '`id` INTEGER PRIMARY KEY AUTOINCREMENT, '+
                          '`kundengespr1` TEXT,'+
                          '`kundengespr2` TEXT,'+
                          '`kundengespr3` TEXT,'+
                          '`kundenbeschw1` TEXT,'+
                          '`kundenbeschw2` TEXT,'+
                          '`kundenbeschw3` TEXT,'+
                          '`personalbedarf1` TEXT,'+
                          '`personalbedarf2` TEXT,'+
                          '`ausbildungen1` TEXT,'+
                          '`ausbildungen2` TEXT,'+
                          '`mehrdienste1` TEXT,'+
                          '`mehrdienste2` TEXT,'+
                          '`ausruestung1` TEXT,'+
                          '`ausruestung2` TEXT,'+
                          '`vorkommnisse1` TEXT,'+
                          '`vorkommnisse2` TEXT,'+
                          '`sonstiges1` TEXT,'+
                          '`sonstiges2` TEXT,'+
                          '`mo_wann` TEXT,'+
                          '`mo_wer` TEXT,'+
                          '`di_wann` TEXT,'+
                          '`di_wer` TEXT,'+
                          '`mi_wann` TEXT,'+
                          '`mi_wer` TEXT,'+
                          '`do_wann` TEXT,'+
                          '`do_wer` TEXT,'+
                          '`fr_wann` TEXT,'+
                          '`fr_wer` TEXT,'+
                          '`sa_wann` TEXT,'+
                          '`sa_wer` TEXT,'+
                          '`so_wann` TEXT,'+
                          '`so_wer` TEXT,'+
                          '`ssvm` TEXT,'+
                          '`svm` TEXT,'+
                          '`ssmw` TEXT,'+
                          '`smw` TEXT,'+
                          '`ssmm` TEXT,'+
                          '`smm` TEXT);';
      FDQuery.ExecSQL;
    end;

    FDQuery.SQL.Text := 'SELECT name FROM sqlite_master WHERE type="table" AND name="wochenberichte"';
    FDQuery.Open();
    if not FDQuery.IsEmpty then
      Exit
    else
    begin
      FDQuery.SQL.Text := 'CREATE TABLE wochenberichte (' +
                          '`id` INTEGER PRIMARY KEY AUTOINCREMENT, '+
                          '`wochenberichtID` INTEGER NOT NULL,'+
                          '`meldenderID` INTEGER NOT NULL,'+
                          '`kw` INTEGER NOT NULL,'+
                          '`jahr` INTEGER NOT NULL,'+
                          '`meldeDatum` TEXT);';
      FDQuery.ExecSQL;
    end;


    FDQuery.SQL.Text := 'SELECT name FROM sqlite_master WHERE type="table" AND name="ausbildung_wachtest_tsw"';
    FDQuery.Open();
    if not FDQuery.IsEmpty then
      Exit
    else
    begin
      FDQuery.SQL.Text := 'CREATE TABLE ausbildung_wachtest_tsw (' +
                          'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                          'mitarbeiterid INTEGER NOT NULL, ' +
                          'objektid INTEGER, ' +
                          'jahr INTEGER, ' +
                          'jan TEXT, ' +
                          'feb TEXT, ' +
                          'mar TEXT, ' +
                          'apr TEXT, ' +
                          'mai TEXT, ' +
                          'jun TEXT, ' +
                          'jul TEXT, ' +
                          'aug TEXT, ' +
                          'sep TEXT, ' +
                          'okt TEXT, ' +
                          'nov TEXT, ' +
                          'dez TEXT, ' +
                          'tsw TEXT);';
      FDQuery.ExecSQL;
    end;




    FDQuery.SQL.Text := 'SELECT name FROM sqlite_master WHERE type="table" AND name="ausbildung"';
    FDQuery.Open();
    if not FDQuery.IsEmpty then
      Exit
    else
    begin
      FDQuery.SQL.Text := 'CREATE TABLE ausbildung (' +
                          'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                          'mitarbeiterID INTEGER NOT NULL, ' +
                          'objektID INTEGER, ' +
                          'ausbildungsartID INTEGER, ' +
                          'datum TEXT);';
      FDQuery.ExecSQL;
    end;
  finally
    FDQuery.Free;
  end;

  CreateIndexes;
end;






//Indexe auf oft abgefragte Spalten erstellen um die Datenbankabfragen zu optimieren
procedure CreateIndexes;
begin
  with fMain.FDConnection1 do
  begin
    ExecSQL('CREATE INDEX IF NOT EXISTS maIndex ON mitarbeiter(id, objektid, personalnr);');
    ExecSQL('CREATE INDEX IF NOT EXISTS maKontaktdatenIndex ON mitarbeiter_kontaktdaten(mitarbeiterid);');
    ExecSQL('CREATE INDEX IF NOT EXISTS maObjekteIndex ON mitarbeiter_objekte(mitarbeiterid, objektid);');
    ExecSQL('CREATE INDEX IF NOT EXISTS WBIndex ON wochenberichte(kw, jahr);');
    ExecSQL('CREATE INDEX IF NOT EXISTS WPIndex ON wachpersonal(id, mitarbeiterid);');
    ExecSQL('CREATE INDEX IF NOT EXISTS MTIndex ON munitionstausch(id, datum);');
  end;
end;








{******************************************************************************************
  Alle User aus Datenbank-Tabelle Admins auslesen und in ListView anzeigen                 *
******************************************************************************************}
procedure showAdmins(LV: TListView);
var
  adminid, username, nachname, vorname, mitarbeiterid: TField;
  L: TListItem;
  FDQuery: TFDQuery;
begin
  ClearListView(LV);

  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT A.id, A.username, M.Nachname, M.Vorname, ' +
                  'M.id AS MitarbeiterID FROM admins AS A LEFT JOIN Mitarbeiter AS M On M.id = A.mitarbeiterID';
      Open;

      adminid       := FieldByName('id');
      mitarbeiterid := FieldByName('mitarbeiterid');
      username      := FieldByName('username');
      nachname      := FieldByName('nachname');
      vorname       := FieldByName('vorname');

      while not Eof do
      begin
        l := LV.Items.Add;
        l.Caption := adminid.AsString;
        l.SubItems.Add(MitarbeiterID.AsString);
        l.SubItems.Add(username.AsString);
        l.SubItems.Add(nachname.AsString);
        l.SubItems.Add(vorname.AsString);
        Next;
      end;
    end;
  finally
    FDQuery.free;
  end;
end;







{**************************************
  Alle Objekte in ListView anzeigen   *
**************************************}
procedure showObjekteInListView(LV: TListView);
var
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
      SQL.Add('SELECT id, objektname, ort FROM objekte ORDER BY objektname ASC;');
      Open;

      while not Eof do
      begin
        l := LV.Items.Add;
        l.Caption := FieldByName('objektname').AsString;
        l.SubItems.Add(FieldByName('ort').AsString);
        l.SubItems.Add(FieldByName('id').AsString);

        Next;
      end;
    end;
  finally
    FDQuery.Free;
  end;
end;




//Ort anhand der ObjektID auslesen
function showObjektOrtByObjektID(ObjektID: integer): string;
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT ort FROM objekte WHERE id = :OBJEKTID LIMIT 0, 1;';
      Params.ParamByName('OBJEKTID').AsInteger := ObjektID;
      Open;
      result := FieldByName('ort').AsString;
    end;
  finally
    FDQuery.free;
  end;
end;






//Tankgutscheinart anhand der MitarbeiterID auslesen
function showGutscheinartByMitarbeterID(MitarbeiterID: integer): string;
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT tankgutscheinart FROM mitarbeiter WHERE id = :ID LIMIT 0, 1;';
      Params.ParamByName('ID').AsInteger := MitarbeiterID;
      Open;
      if(FieldByName('tankgutscheinart').AsString <> '') then
        result := FieldByName('tankgutscheinart').AsString
      else
        result := 'unbekannt';
    end;
  finally
    FDQuery.free;
  end;
end;





function WochenberichtExists(KW, JAHR: integer): boolean;
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT wochenberichtID FROM wochenberichte WHERE kw = :KW AND jahr = :JAHR;';
      Params.ParamByName('KW').AsInteger   := KW;
      Params.ParamByName('JAHR').AsInteger := JAHR;
      Open;

      if(not FDQuery.IsEmpty) then
      begin
        result := true;
      end
      else
      begin
        result := false;
      end;
    end;
  finally
    FDQuery.free;
  end;
end;





{**************************************
  Alle Objekte in ComboBox anzeigen   *
**************************************}
procedure showObjekteInComboBox(CB: TComboBox; ort: boolean=false);
var
  FDQuery: TFDQuery;
  s: string;
begin
  CB.Items.Clear;

  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT id, objektname, ort FROM objekte ORDER BY objektname ASC;';
      Open;

      cb.Items.Add('Objekt');

      while not Eof do
      begin
        if(ort=false) then
          s := FieldByName('objektname').AsString
        else
          if(FieldByName('ort').AsString <> '') then
            s := FieldByName('objektname').AsString + ' (' + FieldByName('ort').AsString + ')'
          else
            s := FieldByName('objektname').AsString;

        cb.Items.AddObject(s, TObject(FieldByName('id').AsInteger));
        Next;
      end;
    end;
  finally
    FDQuery.free;
  end;
end;





//Hier noch eine Abfrage für Jahreslisten rein ob auch Mitarbeiter angezeigt werden sollen, die im
//übergebenen Jahr ausgeschieden sind. (notwendig für Wachtest)



{****************************************************************************************************************
  Alle Mitarbeiter aus Datenbank-Tabelle mitarbeiter auslesen und in ComboBox anzeigen                          *
  monat = Integer ( Damit nur Mitarbeiter ausgegeben werden deren austrittsdatum nicht im gewählten Zeitraum )  *
  jahr =  Integer ( Damit nur Mitarbeiter ausgegeben werden deren austrittsdatum nicht im gewählten Zeitraum)   *
  aushilfe = true zeigt einen Eintrag Aushilfe an                                                               *
  objekt = true zeigt nur Mitarbeiter des in den Einstellungen angegebenen Objektes an                          *
  art = 1 (Nur Stammpersonal)                                                                                   *
  art = 2 (Nur Aushilfen)                                                                                       *
  art = 3 (Stammpersonal und Aushilfen)                                                                         *
****************************************************************************************************************}
procedure showMitarbeiterInComboBox(cb: TComboBox; monat, jahr: integer; aushilfe: boolean = false; ObjektID: integer = 0; art: integer = 1);
var
  id, ma: TField;
  FDQuery: TFDQuery;
  s: string;
  StartDate, EndDate: TDateTime;
begin
  cb.Clear;

  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;


      if (objektid <> 0) AND (art = 1) then
      begin
        s := 'Stammpersonal';
        SQL.Text := 'SELECT id, objektid, nachname || " " || vorname AS Mitarbeiter ' +
                    'FROM mitarbeiter ' +
                    'WHERE objektid = :OBJEKTID ' +
                    'AND (austrittsdatum IS NULL OR austrittsdatum = '''' OR DATE(austrittsdatum) >= DATE(:STARTDATE)) ' +
                    'ORDER BY Mitarbeiter ASC;';
        Params.ParamByName('OBJEKTID').AsInteger := ObjektID;
        StartDate := EncodeDate(jahr, monat, 1);
        Params.ParamByName('STARTDATE').AsDate := StartDate;
      end
      else if (objektid <> 0) AND (art = 2) then
      begin
        s := 'Aushilfen';
        SQL.Text := 'SELECT M.id, M.objektid, nachname || " " || vorname AS Mitarbeiter ' +
                    'FROM mitarbeiter AS M ' +
                    'INNER JOIN mitarbeiter_objekte AS O ON O.mitarbeiterid = M.id ' +
                    'WHERE O.objektid = :OBJEKTID ' +
                    'AND (m.austrittsdatum IS NULL OR m.austrittsdatum = '''' OR DATE(m.austrittsdatum) >= DATE(:STARTDATE)) ' +
                    'ORDER BY Mitarbeiter ASC;';

        Params.ParamByName('OBJEKTID').AsInteger := ObjektID;
        StartDate := EncodeDate(jahr, monat, 1);
        Params.ParamByName('STARTDATE').AsDate := StartDate;
      end
      else if(objektid <> 0) AND (art = 3) then
      begin
        //Stammpersonal des gewählten Objektes und Aushilfen die im gewählten Objekt aushelfen dürfen
        s := 'Mitarbeiter';
        SQL.Text := 'SELECT M.id, M.objektid, nachname || " " || vorname AS Mitarbeiter ' +
                    'FROM mitarbeiter AS M ' +
                    'LEFT JOIN mitarbeiter_objekte AS O ON O.mitarbeiterid = M.id ' +
                    'WHERE (M.objektid = :OBJEKTID OR O.objektid = :OBJEKTID) ' +
                    'AND (m.austrittsdatum IS NULL OR m.austrittsdatum = '''' OR DATE(m.austrittsdatum) >= DATE(:STARTDATE)) ' +
                    'GROUP BY M.id ' +
                    'ORDER BY ' +
                    '  CASE WHEN M.objektid = :OBJEKTID THEN 0 ELSE 1 END, ' +  // Stammpersonal zuerst
                    '  Mitarbeiter COLLATE NOCASE ASC;';                         // dann alphabetisch

        Params.ParamByName('OBJEKTID').AsInteger := ObjektID;
        StartDate := EncodeDate(jahr, monat, 1);
        Params.ParamByName('STARTDATE').AsDate := StartDate;
      end
      else if(objektid = 0) AND (art = 3) then //Wenn als user "esd" angemeldet, dem kein Objekt zugewiesen ist
      begin
        //Mitarbeiter aller Objekte ausgeben
        s := 'Mitarbeiter';
        SQL.Text := 'SELECT M.id, M.objektid, nachname || " " || vorname AS Mitarbeiter ' +
                    'FROM mitarbeiter AS M ' +
                    'WHERE (m.austrittsdatum IS NULL OR m.austrittsdatum = '''' OR DATE(m.austrittsdatum) >= DATE(:ENDDATE)) ' +
                    'GROUP BY M.id, M.objektid, nachname, vorname ' +
                    'ORDER BY M.objektid ASC, Mitarbeiter ASC;';
        endDate := EncodeDate(jahr, monat, DaysInAMonth(jahr, monat));
        Params.ParamByName('ENDDATE').AsDateTime := endDate;
      end;

      Open;

      id := FieldByName('id');
      ma := FieldByName('Mitarbeiter');

      cb.Items.Add(s);

      if(aushilfe = true) then
      begin
        cb.Items.Add('Aushilfe');
      end;

      while not Eof do
      begin
        cb.Items.AddObject(ma.AsString, TObject(id.AsInteger));
        Next;
      end;
    end;
  finally
    FDQuery.free;
  end;
end;






//Alle Seriennummern in Combobox anzeigen die eine bestimmte NrWBK haben
procedure showSerienNrByNrWBKInCB(cb: TComboBox; NrWBK: String);
var
  seriennr: TField;
  FDQuery: TFDQuery;
begin
  cb.Clear;

  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      if(NrWBK='Alle') then
      begin
        SQL.Text := 'SELECT id, seriennr FROM waffenbestand ORDER BY seriennr ASC;';
        Open;
      end
      else
      begin
        SQL.Text := 'SELECT id, seriennr FROM waffenbestand WHERE nrwbk = :NRWBK ORDER BY seriennr ASC;';
        Params.ParamByName('NRWBK').AsString := NrWBK;
        Open;
      end;


      seriennr := FieldByName('seriennr');

      cb.Items.Add('');

      while not Eof do
      begin
        cb.Items.Add(seriennr.AsString);
        Next;
      end;
    end;
  finally
    FDQuery.free;
  end;
end;







//Alle Seriennummern in Combobox anzeigen die eine bestimmte NrWBK haben
procedure showDiensthundeInCB(cb: TComboBox);
var
  FDQuery: TFDQuery;
begin
  cb.Clear;

  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT ID, diensthundname FROM diensthunde ORDER BY diensthundname ASC;';
      Open;

      cb.Items.Add('');

      while not Eof do
      begin
        cb.Items.AddObject(FieldByName('diensthundname').AsString, TObject(FieldByName('ID').AsInteger));
        Next;
      end;
    end;
  finally
    FDQuery.free;
  end;
end;






procedure BackupAllTables;
var
  FDQuery: TFDQuery;
  TableNames: TStringList;
  i: Integer;
  BackupDir: string;
begin
  TableNames := TStringList.Create;
  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := fMain.FDConnection1;
    FDQuery.SQL.Text := 'SELECT name FROM sqlite_master WHERE type=''table'' AND name NOT LIKE ''sqlite_%'';';
    FDQuery.Open;

    while not FDQuery.Eof do
    begin
      TableNames.Add(FDQuery.Fields[0].AsString);
      FDQuery.Next;
    end;

    // Erzeuge das Verzeichnis für das aktuelle Datum
    BackupDir := IncludeTrailingPathDelimiter(PATH + 'DBDUMPS') + FormatDateTime('DDMMYYYY', Now);
    if not DirectoryExists(BackupDir) then
    begin
      if not ForceDirectories(BackupDir) then
      begin
        ShowMessage('Fehler beim Erstellen des Verzeichnisses ' + BackupDir);
        Exit;
      end;
    end;

    // Sichere jede Tabelle in das entsprechende Verzeichnis
    for i := 0 to TableNames.Count - 1 do
    begin
      BackupSQLiteTable(TableNames[i], BackupDir);
    end;

    // Packe das Verzeichnis am Ende des Vorgangs
    ZipDir(BackupDir);
  finally
    FDQuery.Free;
    TableNames.Free;
  end;
end;







procedure BackupSQLiteTable(const TableName: string; const BackupDir: string);
var
  FDQuery: TFDQuery;
  SQLFile: TStringList;
  FileName: string;
  i: integer;
  Field: TField;
  FieldType: string;
  InsertSQL, CreateTableSQL: string;
begin
  FDQuery := TFDquery.Create(nil);
  SQLFile := TStringList.Create;
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;
      SQL.Text := Format('SELECT * FROM %s', [TableName]);
      Open;

      // Erzeuge die CREATE TABLE-Anweisung
      CreateTableSQL := Format('DROP TABLE IF EXISTS %s; CREATE TABLE %s (', [TableName, TableName]);
      for i := 0 to FDQuery.FieldCount - 1 do
      begin
        Field := FDQuery.Fields[i];

        // Überprüfen, ob es sich um die id-Spalte handelt
        if (Field.FieldName = 'id') and (Field.DataType in [ftInteger, ftAutoInc]) then
          FieldType := 'INTEGER PRIMARY KEY AUTOINCREMENT'
        else
        begin
        case Field.DataType of
            ftString, ftMemo, ftWideString, ftWideMemo:
              FieldType := 'TEXT';
            ftInteger, ftSmallint, ftWord, ftAutoInc:
              FieldType := 'INTEGER';
            ftFloat, ftCurrency, ftBCD:
              FieldType := 'REAL';
            ftDate, ftTime, ftDateTime, ftTimeStamp:
              FieldType := 'TEXT'; // SQLite speichert Datumswerte als TEXT
            else
              FieldType := 'BLOB';
          end;
        end;

        if i > 0 then
          CreateTableSQL := CreateTableSQL + ', ';

        CreateTableSQL := CreateTableSQL + Format('%s %s', [Field.FieldName, FieldType]);
      end;
      CreateTableSQL := CreateTableSQL + ');';
      SQLFile.Add(CreateTableSQL);

      // Füge die INSERT-Anweisungen hinzu
      FDQuery.First;
      while not FDQuery.Eof do
      begin
        InsertSQL := Format('INSERT INTO %s VALUES (', [TableName]);
        for i := 0 to FDQuery.FieldCount - 1 do
        begin
          if i > 0 then
            InsertSQL := InsertSQL + ', ';

          if FDQuery.Fields[i].IsNull then
            InsertSQL := InsertSQL + 'NULL'
          else
            InsertSQL := InsertSQL + QuotedStr(FDQuery.Fields[i].AsString);
        end;
        InsertSQL := InsertSQL + ');';
        SQLFile.Add(InsertSQL);
        FDQuery.Next;
      end;

      // Speichere die SQL-Anweisungen in einer Datei
      FileName := Format('%s.sql', [TableName]);
      SQLFile.SaveToFile(IncludeTrailingPathDelimiter(BackupDir) + FileName);
    end;
  finally
    FDQuery.Free;
    SQLFile.Free;
  end;
end;







procedure ZipDir(const Dir: string);
var
  ZipFile: TZipFile;
  SearchRec: TSearchRec;
  FilePath: string;
  FullDirPath: string;
begin
  // Sicherstellen, dass der Pfad ohne zusätzliche Leerzeichen oder ungültige Zeichen ist
  FullDirPath := Trim(Dir);

  ZipFile := TZipFile.Create;
  try
    ZipFile.Open(FullDirPath + '.zip', zmWrite);

    // Verzeichnisinhalt durchsuchen und Dateien zur Zip-Datei hinzufügen
    if FindFirst(IncludeTrailingPathDelimiter(FullDirPath) + '*.sql', faAnyFile, SearchRec) = 0 then
    begin
      repeat
        FilePath := IncludeTrailingPathDelimiter(FullDirPath) + SearchRec.Name;
        ZipFile.Add(FilePath, ExtractFileName(FilePath));
      until FindNext(SearchRec) <> 0;
      FindClose(SearchRec);
    end;

    ZipFile.Close;
  finally
    ZipFile.Free;
  end;

  // Nach erfolgreicher Zip-Erstellung Verzeichnis löschen
  if DirectoryExists(FullDirPath) then
    TDirectory.Delete(FullDirPath, True);
end;










procedure ImportSQLiteTable(const SQLFileName: string);
var
  FDQuery: TFDQuery;
  SQLFile: TStringList;
  TableName, InsertSQL: string;
  HighestID: Integer;
begin
  FDQuery := TFDQuery.Create(nil);
  SQLFile := TStringList.Create;
  try
    // 1. Lade die SQL-Datei
    SQLFile.LoadFromFile(SQLFileName);

    // 2. Extrahiere den Tabellennamen aus der CREATE TABLE-Anweisung
    TableName := '';
    if SQLFile.Count > 0 then
    begin
      InsertSQL := SQLFile[0];
      if Pos('CREATE TABLE ', InsertSQL) = 1 then
      begin
        InsertSQL := Copy(InsertSQL, 14, MaxInt);
        TableName := Copy(InsertSQL, 1, Pos(' ', InsertSQL) - 1);
      end;
    end;

    // 3. Führe die SQL-Befehle aus
    FDQuery.Connection := fMain.FDConnection1;
    FDQuery.SQL.Text := SQLFile.Text;
    FDQuery.ExecSQL;

    // 4. Optional: Aktualisiere sqlite_sequence
    if TableName <> '' then
    begin
      FDQuery.SQL.Text := Format('SELECT MAX(id) FROM %s', [TableName]);
      FDQuery.Open;
      HighestID := FDQuery.Fields[0].AsInteger;

      FDQuery.SQL.Text := 'INSERT OR REPLACE INTO sqlite_sequence (name, seq) VALUES (:TableName, :Seq)';
      FDQuery.Params.ParamByName('TableName').AsString := TableName;
      FDQuery.Params.ParamByName('Seq').AsInteger := HighestID;
      FDQuery.ExecSQL;
    end;
  finally
    FDQuery.Free;
    SQLFile.Free;
  end;
end;





procedure ExtractAndImportSQLFiles(const ZipFileName, TargetDir: string);
var
  ZipFile: TZipFile;
  ArchiveDir: string;
  SQLFiles: TStringList;
  SQLQuery: TFDQuery;
  SQLFileContent: TStringList;
  i: Integer;
begin
  ZipFile := TZipFile.Create;
  SQLFiles := TStringList.Create;
  SQLQuery := TFDQuery.Create(nil);
  SQLFileContent := TStringList.Create;

  try
    ZipFile.Open(ZipFileName, zmRead);

    // Extrahiere alle SQL-Dateien aus dem Zip-Archiv
    for i := 0 to ZipFile.FileCount - 1 do
    begin
      if SameText(ExtractFileExt(ZipFile.FileNames[i]), '.sql') then
      begin
        ArchiveDir := IncludeTrailingPathDelimiter(TargetDir);
        ZipFile.Extract(ZipFile.FileNames[i], ArchiveDir);
        SQLFiles.Add(ArchiveDir + ExtractFileName(ZipFile.FileNames[i]));
      end;
    end;

    // Verbinde mit der SQLite-Datenbank
    SQLQuery.Connection := fMain.FDConnection1;
    SQLQuery.Connection.Open;

    // Lese jede SQL-Datei ein und führe den Inhalt aus
    for i := 0 to SQLFiles.Count - 1 do
    begin
      SQLFileContent.LoadFromFile(SQLFiles[i]);

      SQLQuery.SQL.Text := SQLFileContent.Text;
      SQLQuery.ExecSQL;
    end;

    ShowMessage('Import abgeschlossen.');

  finally
    ZipFile.Free;
    SQLFiles.Free;
    SQLQuery.Free;
    SQLFileContent.Free;
  end;
end;









//Spalte DhID in Tabelle mitarbeiter einfügen wenn noch nicht vorhanden
procedure AddDogDatabaseTables;
var
  Query: TFDQuery;
  ColumnExists, TableExists: Boolean;
begin
  // Initialisiere FDQuery
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := fMain.FDConnection1;  // FireDAC-Verbindung zur SQLite-Datenbank

    // Überprüfen, ob die Tabelle 'diensthunde' existiert
    Query.SQL.Text := 'SELECT name FROM sqlite_master WHERE type="table" AND name="diensthunde"';
    Query.Open;

    TableExists := not Query.IsEmpty;
    Query.Close;

    // Wenn die Tabelle 'diensthunde' nicht existiert, erstelle sie
    if not TableExists then
    begin
      Query.SQL.Text := 'CREATE TABLE IF NOT EXISTS diensthunde (' +
                        'ID INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                        'diensthundname VARCHAR(100))';
      Query.ExecSQL;
    end;

    // Überprüfen, ob die Spalte 'neue_spalte' in einer bestehenden Tabelle existiert
    Query.SQL.Text := 'PRAGMA table_info(mitarbeiter)';
    Query.Open;

    ColumnExists := False;
    while not Query.Eof do
    begin
      if Query.FieldByName('name').AsString = 'diensthundID' then
      begin
        ColumnExists := True;
        Break;
      end;
      Query.Next;
    end;

    Query.Close;

    // Wenn die Spalte 'neue_spalte' nicht existiert, füge sie hinzu
    if not ColumnExists then
    begin
      Query.SQL.Text := 'ALTER TABLE mitarbeiter ADD COLUMN diensthundID INTEGER DEFAULT 0';
      Query.ExecSQL;
    end;

  finally
    Query.Free;
  end;
end;






end.
