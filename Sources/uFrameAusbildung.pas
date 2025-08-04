unit uFrameAusbildung;

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
  TFrameAusbildung = class(TFrame)
    Panel2: TPanel;
    Label10: TLabel;
    Label3: TLabel;
    cbJahr: TComboBox;
    cbMonat: TComboBox;
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    lbHinweis: TLabel;
    sbWeiter: TSpeedButton;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    lvAusbildung1: TAdvListView;
    lvAusbildung2: TAdvListView;
    lvAusbildung3: TAdvListView;
    Panel6: TPanel;
    cbPersonal1: TComboBox;
    dtpDatum1: TDateTimePicker;
    Label1: TLabel;
    Label4: TLabel;
    Panel7: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    cbPersonal2: TComboBox;
    dtpDatum2: TDateTimePicker;
    Panel8: TPanel;
    Label7: TLabel;
    Label8: TLabel;
    cbPersonal3: TComboBox;
    dtpDatum3: TDateTimePicker;
    sbSaveWaffenhandhabung: TSpeedButton;
    sbSaveTheorie: TSpeedButton;
    sbSaveSzenario: TSpeedButton;
    BalloonHint1: TBalloonHint;
    procedure Initialize;
    procedure cbMonatSelect(Sender: TObject);
    procedure cbPersonal1Select(Sender: TObject);
    procedure cbPersonal2Select(Sender: TObject);
    procedure cbPersonal3Select(Sender: TObject);
    procedure sbSaveWaffenhandhabungClick(Sender: TObject);
    procedure sbSaveTheorieClick(Sender: TObject);
    procedure sbSaveSzenarioClick(Sender: TObject);
    procedure lvAusbildung1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure sbWeiterClick(Sender: TObject);
    procedure lvAusbildung2SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure lvAusbildung3SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure lvAusbildung1RightClickCell(Sender: TObject; iItem, iSubItem: Integer);
  private
    s1, s2: String;
    currentIndex: Integer;
    procedure DisplayHinweisString;
    procedure showAusbildungInListView(LV: TListView; ausbildungsart, monat, jahr: integer);
    procedure SortDateList(StringList: TStringList);
    procedure InsertMitarbeiterInListView(lv: TListView; MitarbeiterID, ausbildungsart, monat, jahr: integer);
    procedure DeleteListEntry(LV: TListView; iItem, iSubItem, AusbildungsartID: integer);
    procedure AddAusbildungInDB(ausbildungsartID: integer; lvListe: TAdvListView);
    procedure MitarbeiterZuListeHinzufuegen(cbMitarbeiter: TComboBox; lvListe: TAdvListView);
    procedure SelectAusbildungslisteItem(cbPersonal: TComboBox; lvListe: TAdvListView);
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




procedure TFrameAusbildung.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_COMPOSITED;
end;




procedure TFrameAusbildung.Initialize;
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


  selectedMonth := CurrentMonth;
  selectedYear  := CurrentYear;

  cbMonatSelect(self);

  // Hinweistexte für Timer
  s1 := 'Wählen Sie in der jeweiligen Spalte den Mitarbeiter unten aus, geben Sie das Datum der Ausbildung an und klicken Sie auf OK!' + sLineBreak + 'Wenn der Mitarbeiter schon in der Liste steht, wählen Sie diesen in der Liste, geben das Datum der Ausbildung an und drücken Sie auf den OK Button!';
  s2 := 'Zum löschen eines Datums klicken Sie mit der rechten Maustaste auf das zu löschende Datum!'+ sLineBreak + 'Zum löschen einer kompletten Zeile, klicken Sie mit der rechten Maustaste auf den Mitarbeiternamen in der Liste!';
  currentIndex := 2;  // Setze den Index auf den ersten String
  lbHinweis.Caption := s1;
end;

















procedure TFrameAusbildung.DeleteListEntry(LV: TListView; iItem, iSubItem, AusbildungsartID: integer);
var
  FDQuery: TFDQuery;
  Datum, Mitarbeitername: string;
  i, spalte, MitarbeiterID: integer;
begin
  i := LV.ItemIndex;

  spalte := iSubItem - 1;

  if spalte = 0 then
  begin
    if(trim(LV.Items[i].SubItems[0]) <> '') then
    begin
      Mitarbeitername := LV.Items[i].SubItems[0];

      if MessageDlg('Wollen Sie den kompletten Eintrag von ' + sLineBreak + Mitarbeitername + ' wirklich entfernen?', mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
      begin
        MitarbeiterID := StrToInt(LV.Items[i].Caption);
        Datum := LV.Items[i].SubItems[spalte];

        FDQuery := TFDQuery.Create(nil);
        try
          with FDQuery do
          begin
            Connection := fMain.FDConnection1;

            SQL.Text := 'DELETE FROM ausbildung WHERE mitarbeiterID = :ID ' +
                        'AND ausbildungsartID = :AID ' +
                        'AND strftime("%Y-%m", datum) = :JAHR || "-" || :MONAT;';
            Params.ParamByName('ID').AsInteger   := MitarbeiterID;
            Params.ParamByName('AID').AsInteger  := AusbildungsartID;
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
            LV.DeleteSelected;
          end;
        finally
          FDQuery.Free;
        end;
      end;
    end;
  end;




  if spalte > 0 then
  begin
    if(trim(LV.Items[i].SubItems[spalte]) <> '') then
    begin
      if MessageDlg('Wollen Sie das Datum in Spalte "' + IntToStr(spalte) + '" wirklich entfernen?', mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
      begin
        MitarbeiterID := StrToInt(LV.Items[i].Caption);
        Datum := ConvertGermanDateToSQLDate(LV.Items[i].SubItems[spalte], false);

        FDQuery := TFDQuery.Create(nil);
        try
          with FDQuery do
          begin
            Connection := fMain.FDConnection1;


            SQL.Text := 'DELETE FROM ausbildung WHERE mitarbeiterid = :ID ' +
                        'AND ausbildungsartID = :AID ' +
                        'AND datum = :DATUM;';
            Params.ParamByName('ID').AsInteger   := MitarbeiterID;
            Params.ParamByName('AID').AsInteger  := AusbildungsartID;
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
end;















procedure TFrameAusbildung.SelectAusbildungslisteItem(cbPersonal: TComboBox; lvListe: TAdvListView);
var
  i, a, maid: Integer;
begin
  a := lvListe.ItemIndex;

  if a <> -1 then
  begin
    maid := StrToInt(lvListe.Items[a].Caption);
    SelectedMitarbeiterID := maid;

    for i := 0 to cbPersonal.Items.Count - 1 do
    begin
      if (cbPersonal.Items.Objects[i] is TObject) then
      begin
        if Integer(cbPersonal.Items.Objects[i]) = maid then
        begin
          cbPersonal.ItemIndex := i;
          Exit;
        end;
      end;
    end;
  end
  else
  begin
    cbPersonal.ItemIndex := 0;
    cbPersonal.SetFocus;
  end;
end;













procedure TFrameAusbildung.cbMonatSelect(Sender: TObject);
var
  i, monat, jahr: integer;
begin
  i := cbMonat.ItemIndex;
  if i > 0 then
  begin
    monat       := cbMonat.ItemIndex;
    jahr        := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);

    selectedMonth    := monat;
    selectedYear     := jahr;

    showMitarbeiterInComboBox(cbPersonal1, selectedMonth, selectedYear, true, false, OBJEKTID, 3);
    showMitarbeiterInComboBox(cbPersonal2, selectedMonth, selectedYear, true, false, OBJEKTID, 3);
    showMitarbeiterInComboBox(cbPersonal3, selectedMonth, selectedYear, true, false, OBJEKTID, 3);

    showAusbildungInListView(lvAusbildung1, 1, selectedMonth, selectedYear);
    showAusbildungInListView(lvAusbildung2, 2, selectedMonth, selectedYear);
    showAusbildungInListView(lvAusbildung3, 3, selectedMonth, selectedYear);

    cbPersonal1.ItemIndex := 0;
    cbPersonal2.ItemIndex := 0;
    cbPersonal3.ItemIndex := 0;

    if(selectedMonth <> MonthOf(Date)) OR (selectedYear <> YearOf(Date)) then
    begin
      dtpDatum1.Date := StrToDate('01.'+IntToStr(selectedMonth)+'.'+IntToStr(selectedYear));
      dtpDatum2.Date := StrToDate('01.'+IntToStr(selectedMonth)+'.'+IntToStr(selectedYear));
      dtpDatum3.Date := StrToDate('01.'+IntToStr(selectedMonth)+'.'+IntToStr(selectedYear));
    end
    else
    begin
      dtpDatum1.Date := Date;
      dtpDatum2.Date := Date;
      dtpDatum3.Date := Date;
    end;
  end;
end;










procedure TFrameAusbildung.MitarbeiterZuListeHinzufuegen(cbMitarbeiter: TComboBox; lvListe: TAdvListView);
var
  MitarbeiterID: Integer;
  i: integer;
begin
  MitarbeiterID := 0;

  i := cbMitarbeiter.ItemIndex;

  //Prüfen ob ein Mitarbeiter aus der ComboBox ausgewählt wurde
  if i > 0 then
  begin
    MitarbeiterID := Integer(cbMitarbeiter.Items.Objects[i]);

    //Prüfen ob der Mitarbeiter schon in der ListView steht
    if(EntryExistsInListView(lvListe, MitarbeiterID) = true) then
    begin
      //Mitarbeiter schon in ListView - Eintrag markieren
      SelectMitarbeiterInListView(lvListe, MitarbeiterID);
    end
    else
    begin
      //Mitarbeiter noch nicht in ListView - Name aus ComboBox hinzufügen
      InsertMitarbeiterInListView(lvListe, MitarbeiterID, selectedAusbildungsartID, selectedMonth, selectedYear); //id des Mitarbeiters aus der ComboBox übergeben
    end;
  end
  else
  begin
    lvListe.ItemIndex := -1;
  end;
  SelectMitarbeiterInListView(lvListe, MitarbeiterID);
end;





procedure TFrameAusbildung.lvAusbildung1RightClickCell(Sender: TObject; iItem, iSubItem: Integer);
begin
  DeleteListEntry(TListView(Sender), iItem, iSubItem, TListView(Sender).Tag);
end;




procedure TFrameAusbildung.lvAusbildung1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  SelectAusbildungslisteItem(cbPersonal1, lvAusbildung1);
end;




procedure TFrameAusbildung.lvAusbildung2SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  SelectAusbildungslisteItem(cbPersonal2, lvAusbildung2);
end;




procedure TFrameAusbildung.lvAusbildung3SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  SelectAusbildungslisteItem(cbPersonal3, lvAusbildung3);
end;




procedure TFrameAusbildung.cbPersonal1Select(Sender: TObject);
begin
  MitarbeiterZuListeHinzufuegen(cbPersonal1, lvAusbildung1);
end;




procedure TFrameAusbildung.cbPersonal2Select(Sender: TObject);
begin
  MitarbeiterZuListeHinzufuegen(cbPersonal2, lvAusbildung2);
end;




procedure TFrameAusbildung.cbPersonal3Select(Sender: TObject);
begin
  MitarbeiterZuListeHinzufuegen(cbPersonal3, lvAusbildung3);
end;




procedure TFrameAusbildung.sbSaveWaffenhandhabungClick(Sender: TObject);
begin
  AddAusbildungInDB(1, lvAusbildung1);
end;




procedure TFrameAusbildung.sbSaveTheorieClick(Sender: TObject);
begin
  AddAusbildungInDB(2, lvAusbildung2);
end;




procedure TFrameAusbildung.sbSaveSzenarioClick(Sender: TObject);
begin
  AddAusbildungInDB(3, lvAusbildung3);
end;













procedure TFrameAusbildung.AddAusbildungInDB(ausbildungsartID: integer; lvListe: TAdvListView);
var
  FDQuery: TFDQuery;
  MID, AID: integer;
  Nachname: string;
  i: integer;
begin
  i := lvListe.ItemIndex;
  if i <> -1 then
  begin
    MID      := StrToInt(lvListe.Items[i].Caption);
    Nachname := lvListe.Items[i].SubItems[0];
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
  end;


  FDQuery := TFDQuery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'INSERT INTO ausbildung (mitarbeiterID, objektID, ausbildungsartID, datum) ' +
                  'VALUES (:MID, :OID, :AID, :DAT);';

      Params.ParamByName('MID').AsInteger := MID;
      Params.ParamByName('OID').AsInteger := OBJEKTID;
      Params.ParamByName('AID').AsInteger := ausbildungsartID;
      Params.ParamByName('DAT').AsString  := ConvertGermanDateToSQLDate(DateToStr(dtpDatum2.Date), false);
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
    SelectMitarbeiterInListView(lvListe, MID);
  end;

  showAusbildungInListView(lvListe, ausbildungsartID, selectedMonth, selectedYear);

  SearchAndHighlight(lvListe, Nachname, [1]);
end;













procedure TFrameAusbildung.DisplayHinweisString;
begin
  case currentIndex of
    1: lbHinweis.Caption := s1;
    2: lbHinweis.Caption := s2;
  end;

  // Inkrementiere den Index und setze ihn zurück auf 1, wenn er 4 erreicht
  currentIndex := currentIndex mod 2 + 1;
end;




procedure TFrameAusbildung.sbWeiterClick(Sender: TObject);
begin
  DisplayHinweisString;
end;




procedure TFrameAusbildung.showAusbildungInListView(LV: TListView; ausbildungsart, monat, jahr: Integer);
var
  id, mitarbeiter: String;
  datumList: TStringList;
  L: TListItem;
  q: TFDQuery;
  i: Integer;
begin
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
      Params.ParamByName('AID').AsInteger  := ausbildungsart;

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
procedure TFrameAusbildung.SortDateList(StringList: TStringList);
begin
  StringList.CustomSort(@DateCompare);
end;







procedure TFrameAusbildung.InsertMitarbeiterInListView(lv: TListView; MitarbeiterID, ausbildungsart, monat, jahr: integer);
var
  FDQuery: TFDQuery;
  Mitarbeiter: string;
  id: integer;
  l: TListItem;
begin
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
      Params.ParamByName('AUSBILDUNGSARTID').AsInteger := selectedAusbildungsartID;

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
        SelectMitarbeiterInListView(lv, MitarbeiterID);
      end;
    end;
  finally
    FDQuery.free;
  end;
end;




end.
