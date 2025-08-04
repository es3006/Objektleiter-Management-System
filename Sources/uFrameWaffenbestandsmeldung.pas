unit uFrameWaffenbestandsmeldung;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, AdvListV,
  Vcl.StdCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls, TaskDialog,
  inifiles, AdvDateTimePicker, System.UITypes, DateUtils, System.Math, ShellApi,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param,
  System.Actions, Vcl.ActnList, Vcl.Menus, Vcl.Buttons, HTMLabel;

type
  TFrameWaffenbestandsmeldung = class(TFrame)
    Panel2: TPanel;
    Label9: TLabel;
    Label10: TLabel;
    cbMonat: TComboBox;
    cbJahr: TComboBox;
    imgCreateWaffenzuordnungAlsPdf: TImage;
    Panel3: TPanel;
    cbMitarbeiter: TComboBox;
    lvWaffenbestandsliste: TAdvListView;
    Panel1: TPanel;
    btnUpdate: TButton;
    lbHinweis: TLabel;
    lbMitarbeiter: TLabel;
    sbWeiter: TSpeedButton;
    btnDelWaffenbestandsmeldung: TButton;
    btnAddAllGunsInListView: TButton;
    procedure Initialize;
    procedure cbMonatSelect(Sender: TObject);
    procedure lvWaffenbestandslisteColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvWaffenbestandslisteCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure lvWaffenbestandslisteKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lvWaffenbestandslisteKeyPress(Sender: TObject; var Key: Char);
    procedure imgCreateWaffenzuordnungAlsPdfClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure btnAddAllGunsInListViewClick(Sender: TObject);
    procedure sbWeiterClick(Sender: TObject);
    procedure btnDelWaffenbestandsmeldungClick(Sender: TObject);
    procedure lvWaffenbestandslisteSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure cbMitarbeiterSelect(Sender: TObject);
    procedure lvWaffenbestandslisteClick(Sender: TObject);
  private
    s1, s2, s3, s4: String;
    currentIndex: Integer;
    procedure DisplayHinweisString;
    procedure InsertWaffenbestandslisteInDB;
    function ShowMunitionstausch: boolean;
    procedure GeneratePrintableWaffenbestandslisteAllInOne(erstellungsdatum: string);
    procedure GeneratePrintableWaffenSchliessfachZuordnung(erstellungsdatum: string);
    procedure showWaffenbestandslisteInListView(LV: TListView; monat, jahr: integer);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public-Deklarationen }
  end;



var
  NEUEWAFFE: boolean;
  EINTRAGID: integer;
  WAFFENPROSEITE: integer;
  MUNTAUSCHDATUM, UEBERGEBENDER, OBJEKTORTDATUM, UEBERNEHMENDER : string;
  STLWAFFENSCHLIESSFACHZUORDNUNG: TStringList;
  SelMonth, SelYear, MELDENDERID, OBJEKTID: integer;
  MELDENDER, MELDEDATUM, GESPMELDENDER, GESPMELDEDATUM: string;


implementation

uses uMain, uFunktionen, uDBFunktionen, uWebBrowser, uDatumMeldender,
  uEinstellungen_WaffenMunition, uWaffenbestand;

{$R *.dfm}
{$R WaffenbestandslisteAllInOne.res}    //enthält die Waffenbestandsliste
{$R ZuordnungWaffenSchliessfach.res}    //enthält die Zuordnung der Waffen und Schließfächer




procedure TFrameWaffenbestandsmeldung.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_COMPOSITED;
end;




procedure TFrameWaffenbestandsmeldung.Initialize;
var
  CurrentMonth, CurrentYear, StartYear: Integer;
  Index: Integer;
begin
  STLWAFFENSCHLIESSFACHZUORDNUNG := TStringList.Create;

  CurrentMonth := MonthOf(Now);
  cbMonat.ItemIndex := CurrentMonth;

  //Die Jahre von 2023 bis aktuelles Jahr + 1 in cbJahr anzeigen
  CurrentYear := YearOf(Now);
  StartYear := 2023;
  for CurrentYear := StartYear to CurrentYear + 1 do
    cbJahr.Items.Add(IntToStr(CurrentYear));

  //Das aktuelle Jahr auswählen
  CurrentYear := YearOf(Now);
  Index := cbJahr.Items.IndexOf(IntToStr(CurrentYear));
  if Index <> -1 then cbJahr.ItemIndex := Index;

  SelMonth := CurrentMonth;
  SelYear  := CurrentYear;

  OBJEKTID := uMain.OBJEKTID;

  showMitarbeiterInComboBox(cbMitarbeiter, SELMONTH, SELYEAR, false, true, OBJEKTID, 3);

  showWaffenbestandslisteInListView(lvWaffenbestandsliste, CurrentMonth, CurrentYear);

  WAFFENPROSEITE := 16; //Wie viele Einträge sollen auf der Waffenbestandsmeldung pro Seite erscheinen?

  //Waffenbestandsliste beim start automatisch nach Laufender Nummer sortieren
  ColumnToSort := 1; //Spalte
  SortDir      := 0; //Aufsteigend- oder absteigend sortieren
  lvWaffenbestandsliste.AlphaSort; //Sortierung anwenden


  // Hinweistexte für Timer
  s1 := 'Zum Erstellen einer neuen Waffenbestandsliste klicken Sie auf den Button "Alle Waffen in die Liste eintragen"';
  s2 := 'Es werden alle Waffen des Objektes ausgegeben. Dabei werden erst die, dem jeweiligen Mitarbeiter zugewiesenen Waffen angezeigt und darunter die nicht zugewiesenen Waffen als "Aushilfe"';
  s3 := 'Passen Sie die Zuordnung einer Waffe zu einer Aushilfe gegebenfalls an, indem Sie die entsprechende Waffe auswählen, unten den Namen der Aushilfe auswählen und dann auf "Speichern" klicken!';
  s4 := 'Sie können einem Mitarbeiter eine andere Waffe zuweisen, indem Sie im Hauptmenü auf "Bestandsdaten / Mitarbeiter" klicken, den Mitarbeiter in der Liste mit einem Doppelklick auswählen und anschließend auf dem Tab "Dienstlich" die Waffe auswählen.';
  currentIndex := 2;  // Setze den Index auf den ersten String
  lbHinweis.Caption := s1;



  if(lvWaffenbestandsliste.Items.Count = WAFFENBESTAND) then
  begin
//    btnUpdate.Visible := true;
    btnAddAllGunsInListView.Visible := false;
//    lbMitarbeiter.Visible := true;
  end;

  lbMitarbeiter.Visible := false;
  cbMitarbeiter.Visible := false;
  btnUpdate.Visible := false;
end;










procedure TFrameWaffenbestandsmeldung.btnDelWaffenbestandsmeldungClick(Sender: TObject);
var
  FDQuery: TFDQuery;
begin
  if MessageDlg('Wollen Sie die Waffenbestandsmeldung von ' + cbMonat.Text + ' - ' + cbJahr.Text + ' wirklich löschen?', mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
  begin
    FDQuery := TFDquery.Create(nil);
    try
      with FDQuery do
      begin
        Connection := fMain.FDConnection1;

        SQL.Text := 'DELETE FROM waffenbestandsliste WHERE monat = :MONAT AND jahr = :JAHR;';
        Params.ParamByName('MONAT').AsInteger := SELMONTH;
        Params.ParamByName('JAHR').AsInteger := SELYEAR;
        try
          ExecSQL;
        except
          on E: Exception do
          begin
            ShowMessage('Fehler beim löschen der Daten aus der Tabelle "waffenbestandsliste": ' + E.Message);
          end;
        end;
      end;
    finally
      FDQuery.Free;
      cbMonatSelect(self);
      btnDelWaffenbestandsmeldung.visible := false;
    end;
  end;
end;






procedure TFrameWaffenbestandsmeldung.btnUpdateClick(Sender: TObject);
var
  FDQuery: TFDQuery;
  a, i, EntryID: integer;
  Mitarbeiter: string;
begin
  i := lvWaffenbestandsliste.ItemIndex;
  a := cbMitarbeiter.ItemIndex;

  EntryID := 0;


  if(i <> -1) then
  begin
    EntryID     := StrToInt(lvWaffenbestandsliste.Items[i].Caption);
    Mitarbeiter := cbMitarbeiter.Items[a];
  end
  else
  begin
    ShowMessage('Wählen Sie in der Liste den zu ändernden Eintrag aus!');
    exit;
  end;

  if(a <> -1) then
  begin
    FDQuery := TFDQuery.Create(nil);
    try
      with FDQuery do
      begin
        Connection := fMain.FDConnection1;

        SQL.Text := 'UPDATE waffenbestandsliste SET waffennutzer = :WAFFENNUTZER WHERE id = :ID';

        Params.ParamByName('ID').AsInteger          := EntryID;
        Params.ParamByName('WAFFENNUTZER').AsString := Mitarbeiter;

        ExecSQL;
      end;
    except
      on E: Exception do
      begin
        ShowMessage('Fehler beim Speichern des Eintrags in der Datenbanktabelle Waffenbestandsliste: ' + E.Message);
        Exit;
      end;
    end;
    FDQuery.Free;

    lbMitarbeiter.Visible := false;
    cbMitarbeiter.Visible := false;
    btnUpdate.Visible := false;

    lvWaffenbestandsliste.Items[i].SubItems[3] := Mitarbeiter;
    lvWaffenbestandslisteClick(Self);

  end
  else
  begin
    showmessage('Bitte wählen Sie einen Mitarbeiter aus dem Auswahlfeld unten aus und klicken Sie danach auf "Speichern"!');
  end;
end;









procedure TFrameWaffenbestandsmeldung.btnAddAllGunsInListViewClick(Sender: TObject);
var
  FDQuery: TFDQuery;
  l: TListItem;
  i, a, Monat, Jahr: integer;
  startDate: TDateTime;
  waffenNutzer: string;
begin
  Monat := selMonth;
  Jahr  := selYear;

  i := 0;                   // Laufende Nummer für echte Nutzer
  a := WAFFENBESTAND;       // Rückwärtslaufende Nummer für Aushilfen

  ClearListView(lvWaffenbestandsliste);

  startDate := EncodeDate(Jahr, Monat, 1);

  FDQuery := TFDQuery.Create(Self);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text :=
        'SELECT W.id, W.pos, W.nrwbk, W.waffentyp, ' +
        'COALESCE((SELECT M.nachname || " " || M.vorname ' +
        '          FROM mitarbeiter M ' +
        '          WHERE M.waffennummer = W.seriennr ' +
        '            AND M.objektid = :OBJEKTID ' +
        '            AND (M.austrittsdatum IS NULL OR M.austrittsdatum = "" OR DATE(M.austrittsdatum) >= DATE(:STARTDATE)) ' +
        '          ORDER BY M.nachname ASC LIMIT 1), "Aushilfe") AS Waffennutzer, ' +
        'W.seriennr, W.fach, ' +
        '(SELECT CASE ' +
        '          WHEN EXISTS (SELECT 1 FROM mitarbeiter M ' +
        '                      WHERE M.waffennummer = W.seriennr ' +
        '                        AND M.objektid = :OBJEKTID ' +
        '                        AND (M.austrittsdatum IS NULL OR M.austrittsdatum = "" OR DATE(M.austrittsdatum) >= DATE(:STARTDATE))) ' +
        '          THEN 0 ELSE 1 END) AS Sortierung ' +
        'FROM Waffenbestand W ' +
        'ORDER BY Sortierung ASC, Waffennutzer COLLATE NOCASE;';

      Params.ParamByName('STARTDATE').AsDate := startDate;
      Params.ParamByName('OBJEKTID').AsInteger := OBJEKTID;

      Open;

      while not Eof do
      begin
        waffenNutzer := FieldByName('Waffennutzer').AsString;
        l := lvWaffenbestandsliste.Items.Add;
        l.Caption := FieldByName('id').AsString;

        if waffenNutzer <> 'Aushilfe' then
        begin
          Inc(i);
          l.SubItems.Add(IntToStr(i));  // Laufende Nummer
        end
        else
        begin
          l.SubItems.Add(IntToStr(a));  // Rückwärtslauf für Aushilfen
          Dec(a);
        end;

        l.SubItems.Add(FieldByName('nrwbk').AsString);
        l.SubItems.Add(FieldByName('waffentyp').AsString);
        l.SubItems.Add(waffenNutzer);
        l.SubItems.Add(FieldByName('seriennr').AsString);
        l.SubItems.Add(FieldByName('fach').AsString);

        Next;
      end;
    end;
  finally
    FDQuery.Free;
  end;

  ColumnToSort := 1;
  SortDir      := 0;
  LastSorted   := 0;
  lvWaffenbestandsliste.AlphaSort;

  InsertWaffenbestandslisteInDB;
end;







procedure TFrameWaffenbestandsmeldung.InsertWaffenbestandslisteInDB;
var
  FDQuery: TFDQuery;
  i, c: integer;
  erg: integer;
  s: string;
begin
  c := lvWaffenbestandsliste.Items.Count;

  if c = WAFFENBESTAND then
  begin
    lvWaffenbestandsliste.ItemIndex := 0;

    FDQuery := TFDQuery.Create(nil);
    try
      with FDQuery do
      begin
        Connection := fMain.FDConnection1;

        for i := 0 to c-1 do
        begin
          //Jeden Eintrag aus der ListView durchgehen und Werte in Datenbank schreiben
          SQL.Text := 'INSERT INTO waffenbestandsliste (pos, monat, jahr, nrwbk, ' +
                      'waffentyp, waffennutzer, seriennr, fach) ' +
                      'VALUES (:POS, :MONAT, :JAHR, :NRWBK, ' +
                      ':WAFFENTYP, :WAFFENNUTZER, :SERIENNR, :FACH);';

          Params.ParamByName('POS').AsInteger         := StrToInt(lvWaffenbestandsliste.Items[i].SubItems[0]);
          Params.ParamByName('MONAT').AsInteger       := SelMonth;
          Params.ParamByName('JAHR').AsInteger        := SelYear;
          Params.ParamByName('NRWBK').AsString        := lvWaffenbestandsliste.Items[i].SubItems[1];
          Params.ParamByName('WAFFENTYP').AsString    := lvWaffenbestandsliste.Items[i].SubItems[2];;
          Params.ParamByName('WAFFENNUTZER').AsString := lvWaffenbestandsliste.Items[i].SubItems[3];;
          Params.ParamByName('SERIENNR').AsString     := lvWaffenbestandsliste.Items[i].SubItems[4];;
          Params.ParamByName('FACH').AsString         := lvWaffenbestandsliste.Items[i].SubItems[5];;

          ExecSQL;

          lvWaffenbestandsliste.Selected := lvWaffenbestandsliste.Items[i];
          lvWaffenbestandsliste.Selected.MakeVisible(False);
          lvWaffenbestandsliste.Items[i].MakeVisible(True);
        end;
      end;
    finally
      FDQuery.Free;
    end;
  end
  else
  begin
    erg := WAFFENBESTAND - lvWaffenbestandsliste.Items.Count;
    if(erg = 1) then
      s := 'Es fehlt ' + IntToStr(erg) + ' Waffe'
    else
      s := 'Es fehlen ' + IntToStr(erg)+' Waffen';

    if MessageDlg('Die Anzahl der Waffen stimmt nicht mit der Gesamtanzahl an Waffen in diesem Objekt überein.'+#13#10+#13#10+s+#13#10+#13#10+'Wollen Sie die fehlende Waffe jetzt nachtragen?',
    mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
    begin
      fWaffenbestand.ShowModal;
    end
    else
    begin
      lvWaffenbestandsliste.Items.Clear;
      exit;
    end;
  end;
  cbMonatSelect(self);
end;








procedure TFrameWaffenbestandsmeldung.cbMitarbeiterSelect(Sender: TObject);
var
  i: integer;
begin
  i := cbMitarbeiter.ItemIndex;
  if(i<>-1) AND (cbMitarbeiter.Items[i] <> lvWaffenbestandsliste.Items[lvWaffenbestandsliste.ItemIndex].SubItems[3]) then
  begin
    btnUpdate.Visible := true;
  end
  else
  begin
    btnUpdate.Visible := false;
  end;
end;

procedure TFrameWaffenbestandsmeldung.cbMonatSelect(Sender: TObject);
var
  monat, jahr: integer;
begin
  monat    := cbMonat.ItemIndex;
  jahr     := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);
  SelMonth := monat;
  SelYear  := jahr;

  showMitarbeiterInComboBox(cbMitarbeiter, SELMONTH, SELYEAR, false, true, OBJEKTID, 3);

  showWaffenbestandslisteInListView(lvWaffenbestandsliste, SelMonth, SelYear);

  if(lvWaffenbestandsliste.Items.Count = 0) then
    btnAddAllGunsInListView.Visible := true
  else
    btnAddAllGunsInListView.Visible := false;


  lbMitarbeiter.Visible := false;
  cbMitarbeiter.Visible := false;
  btnUpdate.Visible := false;
end;






procedure TFrameWaffenbestandsmeldung.imgCreateWaffenzuordnungAlsPdfClick(Sender: TObject);
var
  mDatum: TDate;
begin
  if(cbMonat.ItemIndex < 1) OR (cbJahr.Text = '') then
  begin
    showmessage('Bitte wählen Sie den Monat und das Jahr für den Sie die Waffenbestandsmeldung generieren wollen!');
    exit;
  end;

  mDatum := GetLastDayOfMonth(SelYear, SelMonth);

  //Werte an Form DatumMeldender übergeben und Form anzeigen
  uDatumMeldender.MELDEDATUM := DateToStr(mDatum);
  uDatumMeldender.MELDENDER  := OBJEKTLEITERNAME;
  uDatumMeldender.ABSENDER := 'uFrameWaffenbestandsmeldung';


  //Werte von Form fDatumMeldender übergeben
  if(ShowMunitionstausch = false) then
  begin
    if MessageDlg('Im gewählten Zeitraum wurde noch kein Munitionstausch durchgeführt!'+#13#10+'Wollen Sie die Waffenbestandsmeldung trotzdem anlegen?', mtConfirmation, [mbyes, mbno], 0) = mrNo then
      exit;
  end;

  //Formular mit Auswahlfeld für Datum und Objektleiter anzeigen
  if fDatumMeldender.ShowModal = mrOk then
  begin
    if (MELDEDATUM = '') then
      MELDEDATUM := DateToStr(mDatum);

    GeneratePrintableWaffenbestandslisteAllInOne(MELDEDATUM);

    if MessageDlg('Wollen Sie auch die Zuordnung der Waffen und Schließfächer als PDF speichern?', mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
    begin
      GeneratePrintableWaffenSchliessfachZuordnung(MELDEDATUM);
    end;
  end;
end;






procedure TFrameWaffenbestandsmeldung.lvWaffenbestandslisteClick(Sender: TObject);
var
  i: integer;
begin
  i := lvWaffenbestandsliste.ItemIndex;
  if i <> -1 then
  begin
    lbMitarbeiter.Visible := true;
    cbMitarbeiter.Visible := true;
  end
  else
  begin
    lbMitarbeiter.Visible := false;
    cbMitarbeiter.Visible := false;
  end;
end;




procedure TFrameWaffenbestandsmeldung.lvWaffenbestandslisteColumnClick(Sender: TObject; Column: TListColumn);
begin
  lvColumnClickForSort(Sender, Column);
end;






procedure TFrameWaffenbestandsmeldung.lvWaffenbestandslisteCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  lvCompareForSort(Sender, Item1, Item2, Data, Compare);
end;







procedure TFrameWaffenbestandsmeldung.lvWaffenbestandslisteKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  i: integer;
  q: TFDQuery;
  id, m, j: integer;
  posVorher, posNachher: integer;
  UPDATEDB: boolean;
begin
  UPDATEDB := false;
  PosNachher := 0;

  if lvWaffenbestandsliste.Selected <> nil then
  begin
    i  := lvWaffenbestandsliste.ItemIndex;
    id := StrToInt(lvWaffenbestandsliste.Items[i].Caption);
    m  := cbMonat.ItemIndex;
    j  := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);

    if Key = VK_OEM_PLUS then
    begin
      posVorher := StrToInt(lvWaffenbestandsliste.Items[i].SubItems[0]);
      posNachher := posVorher + 1;
      UPDATEDB := true;
    end
    else if Key = VK_OEM_MINUS then
    begin
      posVorher := StrToInt(lvWaffenbestandsliste.Items[i].SubItems[0]);
      if(posVorher > 0) then posNachher := posVorher - 1 else posNachher := 0;
      UPDATEDB := true;
    end;


    if(UPDATEDB = true) then
    begin
      q := TFDquery.Create(nil);
      try
        with q do
        begin
          Connection := fMain.FDConnection1;

          SQL.Clear;
          SQL.Add('UPDATE waffenbestandsliste SET pos = :POS ' );
          SQL.Add('WHERE id = :ID AND monat = :MONAT AND jahr = :JAHR');
          Params.ParamByName('ID').AsInteger := id;
          Params.ParamByName('MONAT').AsInteger := m;
          Params.ParamByName('JAHR').AsInteger := j;
          Params.ParamByName('POS').AsInteger := posNachher;

          ExecSQL;

          lvWaffenbestandsliste.Items[i].SubItems[0] := IntToStr(posNachher);
        end;
      finally
        q.free;
      end;
    end;
  end;
  ColumnToSort := 1; //Spalte 0=Caption, 1=erstes SubItem
  SortDir      := 0; //Aufsteigend- oder absteigend sortieren 0 = A-Z, 1 = Z-A
  lvWaffenbestandsliste.AlphaSort; //Sortierung anwenden
end;






procedure TFrameWaffenbestandsmeldung.lvWaffenbestandslisteKeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
end;











procedure TFrameWaffenbestandsmeldung.lvWaffenbestandslisteSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  mitarbeiterName: string;
  idx: Integer;
begin
  lvWaffenbestandslisteClick(Self);

  if not Selected or (Item = nil) then
    Exit;

  if Item.SubItems.Count >= 4 then
  begin
    mitarbeiterName := Item.SubItems[3]; // SubItems[3] = Spalte 4 (0-basiert)
    idx := cbMitarbeiter.Items.IndexOf(mitarbeiterName);
    if idx >= 0 then
      cbMitarbeiter.ItemIndex := idx;
  end;

  if(Selected = true) then
  begin
    lbMitarbeiter.Visible := true;
    cbMitarbeiter.Visible := true;
  end
  else
  begin
    lbMitarbeiter.Visible := false;
    cbMitarbeiter.Visible := false;
  end;
end;




procedure TFrameWaffenbestandsmeldung.sbWeiterClick(Sender: TObject);
begin
  DisplayHinweisString;
end;






function TFrameWaffenbestandsmeldung.ShowMunitionstausch: boolean;
var
  FDQuery: TFDQuery;
  Monat, Jahr: Integer;
  Trenner: String;
begin
  Monat   := cbMonat.ItemIndex;
  Jahr    := StrToInt(cbJahr.Text);
  Trenner := '---';
  Result  := False;

  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := fMain.FDConnection1;

    FDQuery.SQL.Text := 'SELECT datum, uebergebender, uebernehmender ' +
                  'FROM munitionstausch ' +
                  'WHERE strftime(''%m'', datum) = :MONAT AND strftime(''%Y'', datum) = :JAHR';
    FDQuery.Params.ParamByName('MONAT').AsString := Format('%.2d', [Monat]); // Monat als zweistellige Zahl
    FDQuery.Params.ParamByName('JAHR').AsString := IntToStr(Jahr);
    FDQuery.Open;

    if FDQuery.RecordCount = 1 then
    begin
      MUNTAUSCHDATUM := ConvertSQLDateToGermanDate(FDQuery.FieldByName('datum').AsString, false);
      UEBERGEBENDER  := FDQuery.FieldByName('uebergebender').AsString;
      OBJEKTORTDATUM := OBJEKTORT + ', ' + FormatDateTime('dd.mm.yyyy', Now);
      UEBERNEHMENDER := FDQuery.FieldByName('uebernehmender').AsString;
      Result := True;
    end
    else
    begin
      MUNTAUSCHDATUM := Trenner;
      UEBERGEBENDER  := Trenner;
      OBJEKTORTDATUM := OBJEKTORT + ', ' + FormatDateTime('dd.mm.yyyy', Now);
      UEBERNEHMENDER := Trenner;
    end;
  except
    on E: Exception do
      ShowMessage('Fehler beim Auslesen des Munitionstauschs für den gewählten Monat/Jahr: ' + E.Message);
  end;
  FDQuery.Free;
end;







procedure TFrameWaffenbestandsmeldung.GeneratePrintableWaffenbestandslisteAllInOne(erstellungsdatum: string);
var
  stlTemp: TStringList;
  SEITE, a, lvCount, ANZAHLSEITEN, StartIndex, EndIndex: integer;
  monat, jahr: integer;
  filename, MonatJahr: string;
  stlHtmlHeader, stlHtmlFooter, stlSiteHeader, stlSiteFooter, stlContent: TStringList;
  resHtmlHeader, resHtmlFooter, resSiteHeader, resSiteFooter, resContent: TResourceStream;
  lfdnr, nrwbk, waffentyp, waffennutzer, seriennr: string;
begin
  stlHtmlHeader := nil;
  stlHtmlFooter := nil;
  resHtmlHeader := nil;
  resHtmlFooter := nil;
  stlTemp       := nil;

  monat     := cbMonat.ItemIndex;
  jahr      := StrToInt(cbJahr.Text);
  MonatJahr := cbMonat.Text + '/' + cbJahr.Text;

  if OBJEKTNAME = '' then
  begin
    ShowMessage('Bitte geben Sie in den Einstellungen erst an, in welchem Objekt Sie arbeiten!');
    fEinstellungen_WaffenMunition.Show;
    Exit;
  end;

  lvCount      := lvWaffenbestandsliste.Items.Count;
  ANZAHLSEITEN := Ceil(lvCount / WAFFENPROSEITE);

  // Header und Footer für das gesamte Dokument laden
  try
    resHtmlHeader := TResourceStream.Create(HInstance, 'WaffenbestandHtmlHeader', 'TXT');
    resHtmlFooter := TResourceStream.Create(HInstance, 'WaffenbestandHtmlFooter', 'TXT');
    stlHtmlHeader := TStringList.Create;
    stlHtmlHeader.LoadFromStream(resHtmlHeader);
    stlHtmlFooter := TStringList.Create;
    stlHtmlFooter.LoadFromStream(resHtmlFooter);

    stlTemp := TStringList.Create;

    // Seitenweise Inhalte erstellen
    for SEITE := 0 to ANZAHLSEITEN - 1 do
    begin
      // Seitenheader laden
      resSiteHeader := TResourceStream.Create(HInstance, 'WaffenbestandSiteHeader', 'TXT');
      stlSiteHeader := TStringList.Create;
      try
        stlSiteHeader.LoadFromStream(resSiteHeader);
        stlSiteHeader.Text := StringReplace(stlSiteHeader.Text, '[OBJEKT]', OBJEKTNAME, [rfReplaceAll]);
        stlSiteHeader.Text := StringReplace(stlSiteHeader.Text, '[MONATJAHR]', MonatJahr, [rfReplaceAll]);
        stlTemp.Add(stlSiteHeader.Text);
      finally
        stlSiteHeader.Free;
        resSiteHeader.Free;
      end;

      // Inhalte für die aktuelle Seite hinzufügen
      StartIndex := SEITE * WAFFENPROSEITE;
      EndIndex   := Min((SEITE + 1) * WAFFENPROSEITE - 1, lvCount - 1);

      for a := StartIndex to EndIndex do
      begin
        lfdnr        := lvWaffenbestandsliste.Items[a].SubItems[0];
        nrwbk        := lvWaffenbestandsliste.Items[a].SubItems[1];
        waffentyp    := lvWaffenbestandsliste.Items[a].SubItems[2];
        waffennutzer := lvWaffenbestandsliste.Items[a].SubItems[3];
        seriennr     := lvWaffenbestandsliste.Items[a].SubItems[4];

        resContent := TResourceStream.Create(HInstance, 'WaffenbestandContent', 'TXT');
        stlContent := TStringList.Create;
        try
          stlContent.LoadFromStream(resContent);
          stlContent.Text := StringReplace(stlContent.Text, '[LFDNR]', lfdnr, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[NRWBK]', nrwbk, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[WAFFENTYP]', waffentyp, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[WAFFENNUTZER]', waffennutzer, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[SERIENNUMMER]', seriennr, [rfReplaceAll]);
          stlTemp.Add(stlContent.Text);
        finally
          resContent.Free;
          stlContent.Free;
        end;
      end;

      // Leere Zeilen hinzufügen, falls nötig
      if (SEITE = ANZAHLSEITEN - 1) and (EndIndex - StartIndex < WAFFENPROSEITE - 1) then
      begin
        for a := EndIndex + 1 to (SEITE + 1) * WAFFENPROSEITE - 1 do
        begin
          resContent := TResourceStream.Create(HInstance, 'WaffenbestandContent', 'TXT');
          stlContent := TStringList.Create;
          try
            stlContent.LoadFromStream(resContent);
            stlContent.Text := StringReplace(stlContent.Text, '[LFDNR]', '&nbsp;', [rfReplaceAll]);
            stlContent.Text := StringReplace(stlContent.Text, '[NRWBK]', '&nbsp;', [rfReplaceAll]);
            stlContent.Text := StringReplace(stlContent.Text, '[WAFFENTYP]', '&nbsp;', [rfReplaceAll]);
            stlContent.Text := StringReplace(stlContent.Text, '[WAFFENNUTZER]', '&nbsp;', [rfReplaceAll]);
            stlContent.Text := StringReplace(stlContent.Text, '[SERIENNUMMER]', '&nbsp;', [rfReplaceAll]);
            stlTemp.Add(stlContent.Text);
          finally
            resContent.Free;
            stlContent.Free;
          end;
        end;
      end;

      // Seitenfooter laden
      resSiteFooter := TResourceStream.Create(HInstance, 'WaffenbestandSiteFooter', 'TXT');
      stlSiteFooter := TStringList.Create;
      try
        stlSiteFooter.LoadFromStream(resSiteFooter);
        stlSiteFooter.Text := StringReplace(stlSiteFooter.Text, '[BESTANDWACHMUN]', '-'+IntToStr(BESTANDWACHMUN)+'-', [rfReplaceAll]);
        stlSiteFooter.Text := StringReplace(stlSiteFooter.Text, '[WACHMUNKALIBER]', WACHMUNKALIBER, [rfReplaceAll]);
        stlSiteFooter.Text := StringReplace(stlSiteFooter.Text, '[BESTANDWACHSCHIESSENMUN]', '-'+IntToStr(BESTANDWACHSCHIESSENMUN)+'-', [rfReplaceAll]);
        stlSiteFooter.Text := StringReplace(stlSiteFooter.Text, '[WACHSCHIESSENMUNKALIBER]', WACHSCHIESSENMUNKALIBER, [rfReplaceAll]);
        stlSiteFooter.Text := StringReplace(stlSiteFooter.Text, '[BESTANDMANOEVERMUN]', '-'+IntToStr(BESTANDMANOEVERMUN)+'-', [rfReplaceAll]);
        stlSiteFooter.Text := StringReplace(stlSiteFooter.Text, '[MANOEVERMUNKALIBER]', MANOEVERMUNKALIBER, [rfReplaceAll]);
        stlSiteFooter.Text := StringReplace(stlSiteFooter.Text, '[BESTANDVERSCHUSSMENGE]', '-'+IntToStr(BESTANDVERSCHUSSMENGE)+'-', [rfReplaceAll]);
        stlSiteFooter.Text := StringReplace(stlSiteFooter.Text, '[VERSCHUSSMENGEKALIBER]', VERSCHUSSMENGEMUNKALIBER, [rfReplaceAll]);
        stlSiteFooter.Text := StringReplace(stlSiteFooter.Text, '[MUNTAUSCHDATUM]', MUNTAUSCHDATUM, [rfReplaceAll]);
        stlSiteFooter.Text := StringReplace(stlSiteFooter.Text, '[MUNTAUSCHDURCH]', UEBERGEBENDER, [rfReplaceAll]);
        stlSiteFooter.Text := StringReplace(stlSiteFooter.Text, '[ORTDATUM]', OBJEKTORT + ', ' + ConvertSQLDateToGermanDate(erstellungsdatum, false), [rfReplaceAll]);
        stlSiteFooter.Text := StringReplace(stlSiteFooter.Text, '[NAMEMELDENDER]', MELDENDER, [rfReplaceAll]); //cbMeldender.Items[m], [rfReplaceAll]);
        stlTemp.Add(stlSiteFooter.Text);
      finally
        resSiteFooter.Free;
        stlSiteFooter.Free;
      end;
    end;

    stlTemp.Text := stlHtmlHeader.Text + stlTemp.Text + stlHtmlFooter.Text;

    // Alle Umlaute in der StringList ersetzen durch HTML Code
    for a := 0 to stlTemp.Count - 1 do
    begin
      stlTemp[a] := ReplaceUmlauteWithHtmlEntities(stlTemp[a]);
    end;

    //Dateiname für zu speichernde Datei erzeugen
    filename := Format('Waffenbestandsmeldung %0:s.%1:s %2:s %3:s', [Format('%.2d', [monat]), jahr.ToString, OBJEKTNAME, OBJEKTORT]);

    //Aus Resource-Datei temporäre Html-Datei und daraus eine PDF-Datei im TEMP Verzeichnis erzeugen
    CreateHtmlAndPdfFileFromResource(filename, stlTemp, 'print_portrait.bat');

    //PDF Datei aus Temp Verzeichnis im Zielverzeichnis speichern
    SpeicherePDFDatei(filename, SAVEPATH_Waffenbestandsmeldungen);
  finally
    if Assigned(stlHtmlHeader) then stlHtmlHeader.Free;
    if Assigned(stlHtmlFooter) then stlHtmlFooter.Free;
    if Assigned(resHtmlHeader) then resHtmlHeader.Free;
    if Assigned(resHtmlFooter) then resHtmlFooter.Free;
    if Assigned(stlTemp) then stlTemp.Free;
  end;
end;








procedure TFrameWaffenbestandsmeldung.GeneratePrintableWaffenSchliessfachZuordnung(erstellungsdatum: string);
var
  stltemp: TStringList;
  i, a, monat, jahr: integer;
  filename: string;
  stlHeader, stlFooter, stlContent: TStringList;
  resHeader, resFooter, resContent: TResourceStream;
  mitarbeiter, waffennr, schliessfach: String;
  MonatJahr, mon: String;
begin
  resHeader := nil;
  resFooter := nil;
  stlHeader := nil;
  stlFooter := nil;
  stlTemp   := nil;

  monat     := cbMonat.ItemIndex;
  jahr      := StrToInt(cbJahr.Text);
  MonatJahr := cbMonat.Text + '/' + cbJahr.Text;


  try
    resHeader := TResourceStream.Create(HInstance, 'ZuordnungWaffenSchliessfachHeader', 'TXT');
    stlHeader := TStringList.Create;
    stlHeader.LoadFromStream(resHeader);

    resFooter := TResourceStream.Create(HInstance, 'ZuordnungWaffenSchliessfachFooter', 'TXT');
    stlFooter := TStringList.Create;
    stlFooter.LoadFromStream(resFooter);
    stlFooter.Text := StringReplace(stlFooter.Text, '[STAND]', ConvertSQLDateToGermanDate(erstellungsdatum, false), [rfReplaceAll]);
    stlFooter.Text := StringReplace(stlFooter.Text, '[MELDENDER]', MELDENDER, [rfReplaceAll]);


    stlTemp := TStringList.Create;

    for a := 0 to lvWaffenbestandsliste.Items.Count-1 do
    begin
      mitarbeiter   := lvWaffenbestandsliste.Items[a].SubItems[3];
      waffennr      := lvWaffenbestandsliste.Items[a].SubItems[4];
      schliessfach  := lvWaffenbestandsliste.Items[a].SubItems[5];

      resContent := TResourceStream.Create(HInstance, 'ZuordnungWaffenSchliessfachContent', 'TXT');
      stlContent := TStringList.Create;
      try
        stlContent.LoadFromStream(resContent);
        stlContent.Text := StringReplace(stlContent.Text, '[MITARBEITER]', mitarbeiter, [rfReplaceAll]);
        stlContent.Text := StringReplace(stlContent.Text, '[WAFFENNUMMER]', waffennr, [rfReplaceAll]);
        stlContent.Text := StringReplace(stlContent.Text, '[SCHLIESSFACH]', schliessfach, [rfReplaceAll]);
        stltemp.Add(stlContent.Text);
      finally
        resContent.Free;
        stlContent.Free;
      end;
    end;

    stlTemp.Text := stlHeader.Text + stlTemp.Text + stlFooter.Text;

  //Alle Umlaute in der StringList ersetzen durch html code
    for i := 0 to stlTemp.Count - 1 do
    begin
      stlTemp[i] := ReplaceUmlauteWithHtmlEntities(stlTemp[i]);
    end;

    STLWAFFENSCHLIESSFACHZUORDNUNG.Text := stlTemp.Text;

    //Seiten als Html-Datei speichern
    if(Monat < 10) then mon := '0'+IntToStr(Monat) else mon := inttostr(Monat);
    filename := 'ZuordnungWaffenSchließfach '+ mon +'.'+IntToStr(jahr);

    //Aus Resource-Datei temporäre Html-Datei und daraus eine PDF-Datei im TEMP Verzeichnis erzeugen
    CreateHtmlAndPdfFileFromResource(filename, stlTemp, 'print_portrait.bat');

    //PDF Datei aus Temp Verzeichnis im Zielverzeichnis speichern
    SpeicherePDFDatei(filename, SAVEPATH_ZuordnungWaffeSchliessfach);
  finally
    if Assigned(stlHeader) then stlHeader.Free;
    if Assigned(stlFooter) then stlFooter.Free;
    if Assigned(resHeader) then resHeader.Free;
    if Assigned(resFooter) then resFooter.Free;
    if Assigned(stlTemp) then stlTemp.Free;
  end;
end;








{******************************************************************************************
  Alle Waffen aus der Waffenbestandsmeldung aus Datenbank-Tabelle Waffenbestandsliste     *
  auslesen und in ListView anzeigen                                                       *
******************************************************************************************}
procedure TFrameWaffenbestandsmeldung.showWaffenbestandslisteInListView(LV: TListView; monat, jahr: integer);
var
  id, pos, nrwbk, waffentyp, waffennutzer, seriennr, fach: TField;
  L: TListItem;
  FDQuery: TFDQuery;
begin
  ClearListView(LV);


  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT id, pos, nrwbk, waffentyp, waffennutzer, seriennr, fach ' +
                  'FROM waffenbestandsliste WHERE monat = :MONAT AND jahr = :JAHR ' +
                  'ORDER BY pos ASC;';
      Params.ParamByName('MONAT').AsInteger := Monat;
      Params.ParamByName('JAHR').AsInteger  := Jahr;
      Open;

      id           := FieldByName('id');
      pos          := FieldByName('pos');
      nrwbk        := FieldByName('nrwbk');
      waffentyp    := FieldByName('waffentyp');
      waffennutzer := FieldByName('waffennutzer');
      seriennr     := FieldByName('seriennr');
      fach         := FieldByName('fach');

      while not Eof do
      begin
        l := LV.Items.Add;
        l.Caption := id.AsString;
        l.SubItems.Add(pos.AsString);
        l.SubItems.Add(nrwbk.AsString);
        l.SubItems.Add(waffentyp.AsString);
        l.SubItems.Add(waffennutzer.AsString);
        l.SubItems.Add(seriennr.AsString);
        l.SubItems.Add(fach.AsString);

        Next;
      end;
    end;
  finally
    FDQuery.free;
  end;

  if LV.Items.Count <= 0 then
  begin
    btnAddAllGunsInListView.visible := true;
    btnDelWaffenbestandsmeldung.Visible := false;
  end
  else
  begin
    btnAddAllGunsInListView.visible := false;
    btnDelWaffenbestandsmeldung.Visible := true;
  end;
end;





procedure TFrameWaffenbestandsmeldung.DisplayHinweisString;
begin
  case currentIndex of
    1: lbHinweis.Caption := s1;
    2: lbHinweis.Caption := s2;
    3: lbHinweis.Caption := s3;
    4: lbHinweis.Caption := s4;
  end;

  // Inkrementiere den Index und setze ihn zurück auf 1, wenn er 4 erreicht
  currentIndex := currentIndex mod 4 + 1;
end;

end.
