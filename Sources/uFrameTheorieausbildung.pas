unit uFrameTheorieausbildung;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  Vcl.StdCtrls, AdvListV, Vcl.Imaging.pngimage, Vcl.ExtCtrls, DateUtils,

  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Mask, MaskEdEx, System.UITypes, Vcl.Buttons;

type
  TFrameTheorieausbildung = class(TFrame)
    Panel2: TPanel;
    Label10: TLabel;
    cbJahr: TComboBox;
    lvTheorieausbildung: TAdvListView;
    Panel3: TPanel;
    Label4: TLabel;
    Label1: TLabel;
    cbStammpersonal: TComboBox;
    btnInsert: TButton;
    Label3: TLabel;
    cbMonat: TComboBox;
    dtpDatum: TDateTimePicker;
    cbAusbildungsart: TComboBox;
    Label2: TLabel;
    Panel1: TPanel;
    lbHinweis: TLabel;
    sbWeiter: TSpeedButton;
    cbAushilfen: TComboBox;
    Label5: TLabel;
    SpeedButton1: TSpeedButton;
    procedure Initialize;
    procedure cbMonatSelect(Sender: TObject);
    procedure btnInsertClick(Sender: TObject);
    procedure lvTheorieausbildungRightClickCell(Sender: TObject; iItem, iSubItem: Integer);
    procedure sbWeiterClick(Sender: TObject);
    procedure cbStammpersonalSelect(Sender: TObject);
    procedure cbAushilfenSelect(Sender: TObject);
    procedure lvTheorieausbildungSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
  private
    s1, s2: String;
    currentIndex: Integer;
    procedure DisplayHinweisString;
    procedure showAusbildungInListView(LV: TListView; ausbildungsart, monat, jahr: integer);
    procedure SortDateList(StringList: TStringList);
    procedure InsertMitarbeiterInListView(lv: TListView; MitarbeiterID, ausbildungsart, monat, jahr: integer);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public-Deklarationen }
  end;


var
  selectedMonth, selectedYear, selectedAusbildungsartID, SelectedMitarbeiterID: integer;


implementation

{$R *.dfm}




uses
  uMain, uFunktionen, uDBFunktionen, uWebBrowser;



procedure TFrameTheorieAusbildung.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_COMPOSITED;
end;




procedure TFrameTheorieAusbildung.Initialize;
var
  CurrentMonth, CurrentYear, StartYear: Integer;
  Index: Integer;
begin
  CurrentMonth := MonthOf(Now);
  cbMonat.ItemIndex := CurrentMonth;

  //Die Jahre von 2023 bis aktuelles Jahr + 1 in cbJahr anzeigen
  CurrentYear := YearOf(Now);
  StartYear := 2022;
  for CurrentYear := StartYear to CurrentYear + 1 do
    cbJahr.Items.Add(IntToStr(CurrentYear));

  //Das aktuelle Jahr auswählen
  CurrentYear := YearOf(Now);
  Index := cbJahr.Items.IndexOf(IntToStr(CurrentYear));
  if Index <> -1 then cbJahr.ItemIndex := Index;

  cbAusbildungsart.ItemIndex := 0;

  selectedAusbildungsartID   := 0;
  selectedMonth := CurrentMonth;
  selectedYear  := CurrentYear;

  cbMonatSelect(self);

  showAusbildungInListView(lvTheorieausbildung, selectedAusbildungsartID, selectedMonth, selectedYear);
  showMitarbeiterInComboBox(cbStammpersonal, selectedMonth, selectedYear, false, OBJEKTID, 1);  //Stammpersonal des gewählten Objektes
  showMitarbeiterInComboBox(cbAushilfen, selectedMonth, selectedYear, false, OBJEKTID, 2);      //Aushilfen die im gewählten Objekt aushelfen dürfen

  cbStammpersonal.ItemIndex := 0;
  cbAushilfen.ItemIndex     := 0;

  // Hinweistexte für Timer
  s1 := 'Wählen Sie oben die Art der Ausbildung, klicken Sie auf den Namen eines Mitarbeiters und geben Sie anschließend das Datum der Ausbildung ein!';
  s2 := 'Löschen eines Datums'+#13#10+'mit rechter Maustaste auf das zu löschende Datum klicken';
  currentIndex := 2;  // Setze den Index auf den ersten String
  lbHinweis.Caption := s1;
end;






procedure TFrameTheorieausbildung.lvTheorieausbildungRightClickCell(Sender: TObject; iItem, iSubItem: Integer);
var
  FDQuery: TFDQuery;
  Datum: string;
  i, spalte, MitarbeiterID, ausbildungsartID: integer;
begin
  i := lvTheorieausbildung.ItemIndex;

  case selectedAusbildungsartID of
    0: ausbildungsartID := 1; //Waffenhandhabung
    1: ausbildungsartID := 2; //Theorie
    2: ausbildungsartID := 3; //Szenario
    else
      ausbildungsartID := 0;
  end;

  spalte := iSubItem - 1;

  if spalte = 0 then
  begin
    if MessageDlg('Wollen Sie den kompletten Eintrag wirklich entfernen?', mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
    begin
      MitarbeiterID := StrToInt(lvTheorieausbildung.Items[i].Caption);
      Datum := lvTheorieausbildung.Items[i].SubItems[spalte];

      FDQuery := TFDQuery.Create(nil);
      try
        with FDQuery do
        begin
          Connection := fMain.FDConnection1;

          SQL.Text := 'DELETE FROM ausbildung WHERE mitarbeiterID = :ID ' +
                      'AND ausbildungsartID = :AID ' +
                      'AND strftime("%Y-%m", datum) = :JAHR || "-" || :MONAT;';
          Params.ParamByName('ID').AsInteger   := MitarbeiterID;
          Params.ParamByName('AID').AsInteger  := ausbildungsartID;
          Params.ParamByName('MONAT').AsString := Format('%.2d', [selectedMonth]);
          Params.ParamByName('JAHR').AsInteger := selectedYear;

          try
            ExecSql;
          except
            on E: Exception do
            begin
              ShowMessage('Fehler beim löschen des Eintrags aus der Datenbank: ' + E.Message);
              Exit;
            end;
          end;
          lvTheorieausbildung.DeleteSelected;
        end;
      finally
        FDQuery.Free;
      end;
    end;
  end;




  if spalte > 0 then
  begin
    if MessageDlg('Wollen Sie das Datum in Spalte "' + IntToStr(spalte) + '" wirklich entfernen?', mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
    begin
      MitarbeiterID := StrToInt(lvTheorieausbildung.Items[i].Caption);
      Datum := ConvertGermanDateToSQLDate(lvTheorieausbildung.Items[i].SubItems[spalte], false);

      FDQuery := TFDQuery.Create(nil);
      try
        with FDQuery do
        begin
          Connection := fMain.FDConnection1;


          SQL.Text := 'DELETE FROM ausbildung WHERE mitarbeiterid = :ID ' +
                      'AND ausbildungsartID = :AID ' +
                      'AND datum = :DATUM;';
          Params.ParamByName('ID').AsInteger   := MitarbeiterID;
          Params.ParamByName('AID').AsInteger  := ausbildungsartID;
          Params.ParamByName('DATUM').AsString := Datum;

          try
            ExecSql;
          except
            on E: Exception do
            begin
              ShowMessage('Fehler beim löschen des Datums aus Spalte ' + IntToStr(spalte) + E.Message);
              Exit;
            end;
          end;
        //  lvTheorieausbildung.Items[i].SubItems[spalte] := '';
          cbMonatSelect(nil);
        end;
      finally
        FDQuery.Free;
      end;
    end;
  end;
end;






procedure TFrameTheorieausbildung.lvTheorieausbildungSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  i, a, maid: Integer;
begin
  a := lvTheorieausbildung.ItemIndex;

  if a <> -1 then
  begin
    maid := StrToInt(lvTheorieausbildung.Items[a].Caption);
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

    cbAushilfen.SetFocus;
  end;
end;








procedure TFrameTheorieausbildung.btnInsertClick(Sender: TObject);
var
  FDQuery: TFDQuery;
  MID, AID: integer;
  Nachname: string;
  i: integer;
begin
  i := lvTheorieausbildung.ItemIndex;
  if i <> -1 then
  begin
    MID     := StrToInt(lvTheorieausbildung.Items[i].Caption);
    Nachname := lvTheorieausbildung.Items[i].SubItems[0];
  end
  else
  begin
    showmessage('Bitte wählen Sie einen Mitarbeiter aus der Liste aus.');
    exit;
  end;

  if (MID = -1) then
  begin
    ShowMessage('Bitte wählen Sie einen Mitarbeiter aus!');
    Exit;
  end
  else if (selectedAusbildungsartID < 0) then
  begin
    ShowMessage('Bitte wählen Sie die Art der Ausbildung aus!');
    Exit;
  end;


  FDQuery := TFDQuery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      case selectedAusbildungsartID of
        0: AID := 1; //Waffenhandhabung
        1: AID := 2; //Theorie
        2: AID := 3; //Szenario
        else
          AID := 0;
      end;


      SQL.Text := 'INSERT INTO ausbildung (mitarbeiterID, objektID, ausbildungsartID, datum) ' +
                  'VALUES (:MID, :OID, :AID, :DAT);';

      Params.ParamByName('MID').AsInteger := MID;
      Params.ParamByName('OID').AsInteger := OBJEKTID;
      Params.ParamByName('AID').AsInteger := AID;
      Params.ParamByName('DAT').AsString  := ConvertGermanDateToSQLDate(DateToStr(dtpDatum.Date), false);
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
    SelectMitarbeiterInListView(lvTheorieausbildung, MID);
  end;

  showAusbildungInListView(lvTheorieausbildung, selectedAusbildungsartID, selectedMonth, selectedYear);

  SearchAndHighlight(lvTheorieAusbildung, Nachname, [1]);
end;








procedure TFrameTheorieausbildung.cbAushilfenSelect(Sender: TObject);
var
  MitarbeiterID: Integer;
  i: integer;
begin
  MitarbeiterID := 0;

  i := TComboBox(Sender).ItemIndex;
  if i <> -1 then
  begin
    if TComboBox(Sender).ItemIndex > 0 then
    begin
      MitarbeiterID := Integer(TComboBox(Sender).Items.Objects[i]);
      InsertMitarbeiterInListView(lvTheorieausbildung, MitarbeiterID, selectedAusbildungsartID, selectedMonth, selectedYear); //id des Mitarbeiters aus der ComboBox übergeben
      SelectMitarbeiterInListView(lvTheorieausbildung, MitarbeiterID);
    end;

    //cbStammpersonal.ItemIndex := 0;
    //cbAushilfen.ItemIndex := 0;
  end
  else
  begin
    SelectMitarbeiterInListView(lvTheorieausbildung, MitarbeiterID);
  end;
end;





procedure TFrameTheorieausbildung.cbMonatSelect(Sender: TObject);
var
  i, monat, jahr: integer;
begin
  i := cbMonat.ItemIndex;
  if i > 0 then
  begin
    monat       := cbMonat.ItemIndex;
    jahr        := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);
    selectedAusbildungsartID := cbAusbildungsart.ItemIndex;
    selectedMonth    := monat;
    selectedYear     := jahr;

    showMitarbeiterInComboBox(cbStammpersonal, selectedMonth, selectedYear, false, OBJEKTID, 1);
    showMitarbeiterInComboBox(cbAushilfen, selectedMonth, selectedYear, false, OBJEKTID, 2);

    showAusbildungInListView(lvTheorieausbildung, selectedAusbildungsartID, selectedMonth, selectedYear);

    if(selectedMonth <> MonthOf(Date)) OR (selectedYear <> YearOf(Date)) then
      dtpDatum.Date := StrToDate('01.'+IntToStr(selectedMonth)+'.'+IntToStr(selectedYear))
    else
      dtpDatum.Date := Date;
  end;
end;







procedure TFrameTheorieausbildung.cbStammpersonalSelect(Sender: TObject);
var
  MitarbeiterID: Integer;
  i: integer;
begin
  MitarbeiterID := 0;

  i := TComboBox(Sender).ItemIndex;

  //Prüfen ob ein Mitarbeiter aus der ComboBox ausgewählt wurde
  if i > 0 then
  begin
    MitarbeiterID := Integer(TComboBox(Sender).Items.Objects[i]);

    //Prüfen ob der Mitarbeiter schon in der ListView steht
    if(EntryExistsInListView(lvTheorieausbildung, MitarbeiterID) = true) then
    begin
      //Mitarbeiter schon in ListView - Eintrag markieren
      SelectMitarbeiterInListView(lvTheorieausbildung, MitarbeiterID);
    end
    else
    begin
      //Mitarbeiter noch nicht in ListView - Name aus ComboBox hinzufügen
      InsertMitarbeiterInListView(lvTheorieausbildung, MitarbeiterID, selectedAusbildungsartID, selectedMonth, selectedYear); //id des Mitarbeiters aus der ComboBox übergeben
    end;
  end
  else
  begin
    lvTheorieausbildung.ItemIndex := -1;
  end;
  SelectMitarbeiterInListView(lvTheorieausbildung, MitarbeiterID);
end;






//Zu sortieren der Datumswerte wenn mehr als ein Datum
//im Monat in Tabelle Ausbildung bei einem Mitarbeiter vorhanden sind
function DateCompare(List: TStringList; Index1, Index2: Integer): Integer;
var
  Date1, Date2: TDateTime;
begin
  Date1 := StrToDateDef(List[Index1], 0);
  Date2 := StrToDateDef(List[Index2], 0);
  if Date1 < Date2 then
    Result := -1
  else if Date1 > Date2 then
    Result := 1
  else
    Result := 0;
end;





//Zum aufruf der function DateCompare
procedure TFrameTheorieausbildung.SortDateList(StringList: TStringList);
begin
  StringList.CustomSort(@DateCompare);
end;





procedure TFrameTheorieausbildung.sbWeiterClick(Sender: TObject);
begin
  DisplayHinweisString;
end;






procedure TFrameTheorieausbildung.showAusbildungInListView(LV: TListView; ausbildungsart, monat, jahr: Integer);
var
  id, mitarbeiter: String;
  datumList: TStringList;
  L: TListItem;
  q: TFDQuery;
  i: Integer;
  ausbildungsartID: integer;
begin
  case selectedAusbildungsartID of
    0: ausbildungsartID := 1; //Waffenhandhabung
    1: ausbildungsartID := 2; //Theorie
    2: ausbildungsartID := 3; //Szenario
    else
      ausbildungsartID := 0;
  end;

  ClearListView(LV);

  q := TFDquery.Create(nil);
  datumList := TStringList.Create;
  try
    with q do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT M.id, M.nachname || " " || SUBSTR(M.vorname, 1, 1) || "." AS Mitarbeiter, ' +
                  'GROUP_CONCAT(strftime("%d.%m.%Y", A.datum), ", ") AS Ausbildung ' +
                  'FROM mitarbeiter AS M ' +
                  'INNER JOIN ausbildung AS A ON M.id = A.mitarbeiterid ' +
                  'AND A.objektid = :OID ' +
                  'WHERE A.ausbildungsartID = :AID ' +
                  'AND (M.objektid = :OID OR M.objektid != :OID) ' +
                  'AND (M.austrittsdatum IS NULL OR M.austrittsdatum = "" OR strftime("%Y-%m", M.austrittsdatum) >= :JAHR || "-" || :MONAT) ' +
                  'AND strftime("%Y-%m", A.datum) = :JAHR || "-" || :MONAT ' +
                  'GROUP BY M.id, M.nachname ' +
                  'ORDER BY CASE WHEN M.objektid = 1 THEN 0 ELSE 1 END, M.nachname;';


      Params.ParamByName('MONAT').AsString := Format('%.2d', [monat]); //Monat als zweistellige Zahl ausgeben
      Params.ParamByName('JAHR').AsInteger := jahr;
      Params.ParamByName('OID').AsInteger  := objektID;
      Params.ParamByName('AID').AsInteger  := ausbildungsartID;

      Open;

      while not Eof do
      begin
        id := FieldByName('id').AsString;
        mitarbeiter := FieldByName('Mitarbeiter').AsString;
        datumList.CommaText := FieldByName('Ausbildung').AsString;

        // Sortiere die DatumList mit benutzerdefinierter Funktion
        SortDateList(datumList);

        l := LV.Items.Add;
        l.Caption := id;
        l.SubItems.Add(mitarbeiter);

        // Füge jedes Datum in eine eigene Spalte ein, bis zu maximal 10 Spalten
        for i := 0 to 9 do
        begin
          if i < datumList.Count then
            l.SubItems.Add(datumList[i])
          else
            l.SubItems.Add('');  // Füge leere Zeichenkette hinzu, wenn weniger als 10 Datumswerte vorhanden sind
        end;

        Next;
      end;
    end;
  finally
    datumList.Free;
    q.Free;
  end;
end;




procedure TFrameTheorieausbildung.DisplayHinweisString;
begin
  case currentIndex of
    1: lbHinweis.Caption := s1;
    2: lbHinweis.Caption := s2;
  end;

  // Inkrementiere den Index und setze ihn zurück auf 1, wenn er 4 erreicht
  currentIndex := currentIndex mod 2 + 1;
end;





procedure TFrameTheorieausbildung.InsertMitarbeiterInListView(lv: TListView; MitarbeiterID, ausbildungsart, monat, jahr: integer);
var
  FDQuery: TFDQuery;
  Mitarbeiter: string;
  id: integer;
  l: TListItem;
  ausbildungsartID: integer;
begin
  case selectedAusbildungsartID of
    0: ausbildungsartID := 1; //Waffenhandhabung
    1: ausbildungsartID := 2; //Theorie
    2: ausbildungsartID := 3; //Szenario
    else
    ausbildungsartID := 0;
  end;

  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

//Schauen ob der Mitarbeiter für den gewünschten Zeitraum
//bereits in der Datenbanktabelle "ausbildung_theorie", "ausbildung_szenario" oder "ausbildung_waffenhandhabung" steht
      SQL.Text := 'SELECT id FROM ausbildung '  +
                  'WHERE mitarbeiterid = :MITARBEITERID ' +
                  'AND ausbildungsartID = :AUSBILDUNGSARTID ' +
                  'AND strftime("%Y-%m", datum) = :JAHR || "-" || :MONAT;';

      Params.ParamByName('MITARBEITERID').AsInteger := MitarbeiterID; // ID aus ComboBox
      ParamByName('MONAT').AsString := Format('%.2d', [monat]); //Monat als zweistellige Zahl ausgeben
      Params.ParamByName('JAHR').AsInteger := jahr;
      Params.ParamByName('AUSBILDUNGSARTID').AsInteger := ausbildungsartID;

      Open;


//Mitarbeiter steht noch nicht in einer der Tabellen "ausbildung_theorie", "ausbildung_szenario" oder "ausbildung_waffenhandhabung"
      if(RecordCount = 0) then
      begin
//Mitarbeiterdaten aus den Tabellen "ausbildung_theorie", "ausbildung_szenario" oder "ausbildung_waffenhandhabung" auslesen
        SQL.Text := 'SELECT id, nachname || " " || SUBSTR(vorname, 1, 1) || "." AS Mitarbeiter ' +
                    'FROM mitarbeiter WHERE id = :MITARBEITERID;';

        Params.ParamByName('MITARBEITERID').AsInteger := MitarbeiterID;
        Open;

//Ausgelesene Werte Variablen zuweisen
        id  := FieldByName('id').AsInteger;
        Mitarbeiter    := FieldByName('Mitarbeiter').AsString;


//Mitarbeiter in ListView eintragen
        if(MitarbeiterID > 0) then
        begin
          l := LV.Items.Add;
          l.Caption := IntToStr(MitarbeiterID);  //MitarbeiterID
          l.SubItems.Add(Mitarbeiter); //mitarbeiterid
        end;
      end
      else
      begin
        SelectMitarbeiterInListView(lvTheorieausbildung, MitarbeiterID);
      end;
    end;
  finally
    FDQuery.free;
  end;
end;








end.
