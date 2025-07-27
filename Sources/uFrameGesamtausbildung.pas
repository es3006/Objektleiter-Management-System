unit uFrameGesamtausbildung;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, AdvListV, Vcl.ExtCtrls, DateUtils,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Imaging.pngimage, System.Math, ShellApi, Vcl.Buttons;

type
  TFrameGesamtausbildung = class(TFrame)
    Panel2: TPanel;
    lbMonat: TLabel;
    lbJahr: TLabel;
    lbQuartal: TLabel;
    cbMonat: TComboBox;
    cbJahr: TComboBox;
    cbQuartal: TComboBox;
    rbMonat: TRadioButton;
    rbQuartal: TRadioButton;
    lvGesamtausbildung: TAdvListView;
    btnGeneratePDF: TImage;
    Panel1: TPanel;
    lbHinweis: TLabel;
    sbWeiter: TSpeedButton;
    procedure Initialize;
    procedure rbQuartalClick(Sender: TObject);
    procedure cbQuartalSelect(Sender: TObject);
    procedure cbMonatSelect(Sender: TObject);
    procedure btnGeneratePDFClick(Sender: TObject);
    procedure lvGesamtausbildungColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvGesamtausbildungCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure sbWeiterClick(Sender: TObject);
    procedure rbMonatClick(Sender: TObject);
  private
    s1, s2: String;
    currentIndex: Integer;
    procedure DisplayHinweisString;
    procedure GeneratePrintableGesamtausbildung(monat, quartal, jahr: integer);

    procedure showMonatsausbildungInListView;
    procedure showQuartalsausbildungInListView(Quartal, Jahr: integer);

    procedure LoadWachschiessen(mitarbeiterID, Monat, Jahr: integer; subItems: TStrings);
    procedure LoadAusbildung(mitarbeiterID, ausbildungsartID, Monat, Jahr: integer; subItems: TStrings);
    procedure LoadErsteHilfe(mitarbeiterID: integer; subItems: TStrings);

    procedure LoadWachschiessenQuartal(mitarbeiterID, Quartal, Jahr: integer; subItems: TStrings);
    procedure LoadAusbildungQuartal(mitarbeiterID, ausbildungsartID, Quartal, Jahr: integer; subItems: TStrings);
  public
    { Public-Deklarationen }
  end;




var
  NEWENTRY: boolean;
  SELID, SELMONTH, SELQUARTAL, SELYEAR, SEITE: integer;
  TITEL: string;
  mitarbeiterid: integer;
  Nachname, Vorname, PersonalNr, SaNr, AusbSchiessen, AusbWaffenhandh, AusbTheorie: string;
  AusbSzenario, AusbErsteh, Eintrittsdatum, Austrittsdatum: string;
  monatsnamen: array[1..12] of string = ('Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember');




implementation

{$R *.dfm}
{$R Gesamtausbildung.RES}

uses uMain, uFunktionen, uWebBrowser;





procedure TFrameGesamtausbildung.Initialize;
var
  CurrentMonth, CurrentYear, StartYear, CurrentQuarter: Integer;
  Index: Integer;
begin
  NEWENTRY := true;
  SELID    := -1;

  rbQuartal.Checked := true;

  CurrentMonth   := MonthOf(Now); // aktuellen Monat ermitteln
  CurrentQuarter := GetQuarterForMonth(CurrentMonth); // aktuelles Quartal ermitteln

  //aktuellen Monat in combobox auswählen
  cbMonat.ItemIndex := CurrentMonth - 1;


  //Die Jahre von 2023 bis aktuelles Jahr + 1 in cbJahr anzeigen
  CurrentYear := YearOf(Now);
  StartYear   := 2023;
  for CurrentYear := StartYear to CurrentYear + 1 do
    cbJahr.Items.Add(IntToStr(CurrentYear));

  //aktuelles Jahr in combobox auswählen
  CurrentYear := YearOf(Now);
  Index       := cbJahr.Items.IndexOf(IntToStr(CurrentYear));
  if Index <> -1 then cbJahr.ItemIndex := Index;

  //aktuelles Quartal in Combobox auswählen
  cbQuartal.ItemIndex := CurrentQuarter-1;

  SELMONTH   := CurrentMonth;
  SELQUARTAL := CurrentQuarter;
  SELYEAR    := CurrentYear;

  showQuartalsausbildungInListView(CurrentQuarter, CurrentYear);

  // Hinweistexte für Timer
  s1 := 'Dies ist nur eine Zusammenfassung'+#13#10+'Änderungen oder neue Einträge, nehmen Sie bitte direkt auf den Seiten "Ausbildung", "Wachtest/Sachk", "Wachschießen" oder "Erste-Hilfe" vor';
  s2 := 'Für Änderungen an den Mitarbeiterdaten, öffnen Sie bitte im Hauptmenü den Menüpunkt "Bestandsdaten / Mitarbeiter"';
  currentIndex := 2;
  lbHinweis.Caption := s1;
end;






procedure TFrameGesamtausbildung.btnGeneratePDFClick(Sender: TObject);
begin
  if(rbMonat.Checked) then
  begin
    GeneratePrintableGesamtausbildung(SELMONTH, 0, SELYEAR);
  end
  else
  begin
    GeneratePrintableGesamtausbildung(0, SELQUARTAL, SELYEAR);
  end;
end;






procedure TFrameGesamtausbildung.LoadWachschiessen(mitarbeiterID, Monat, Jahr: integer; subItems: TStrings);
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDQuery.Create(nil);

  with FDQuery do
  begin
    Connection := fMain.FDConnection1;

    FDQuery.SQL.Text := 'SELECT strftime("%d.%m.%Y", datum) AS datum FROM ausbildung ' +
                        'WHERE (mitarbeiterID = :maid ' +
                        'AND ausbildungsartID = 4 ' +
                        'AND strftime("%Y-%m", datum) <= :jahr || "-" || :monat) ' +
                        'GROUP BY mitarbeiterID ' +
                        'LIMIT 0, 1;';

    ParamByName('monat').AsString := Format('%.2d', [SelMonth]); //Monat als zweistellige Zahl ausgeben
    ParamByName('jahr').AsString  := IntToStr(SelYear);
    ParamByName('maid').AsInteger := mitarbeiterid;

    Open;
    try
      if IsEmpty = false then
      begin
        SubItems.Add(FieldByName('datum').AsString);
      end
      else
      begin
        SubItems.Add('-----');
      end;
    finally
      Close;
      Free;
    end;
  end;
end;




procedure TFrameGesamtausbildung.LoadWachschiessenQuartal(mitarbeiterID, Quartal, Jahr: integer; subItems: TStrings);
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := fMain.FDConnection1;

    // Versuche, das Datum aus dem angegebenen Quartal zu holen
    FDQuery.SQL.Text := 'SELECT strftime("%d.%m.%Y", datum) AS datum ' +
                        'FROM ausbildung ' +
                        'WHERE mitarbeiterID = :maid ' +
                        'AND ausbildungsartID = 4 ' +
                        'AND strftime("%Y", datum) = :jahr ' +
                        'AND (CAST(strftime("%m", datum) AS INTEGER) - 1) / 3 + 1 = :quartal ' +
                        'ORDER BY datum DESC ' +
                        'LIMIT 1;';

    FDQuery.ParamByName('quartal').AsInteger := Quartal;
    FDQuery.ParamByName('jahr').AsString := IntToStr(Jahr);
    FDQuery.ParamByName('maid').AsInteger := mitarbeiterID;

    FDQuery.Open;
    try
      if not FDQuery.IsEmpty then
      begin
        subItems.Add(FDQuery.FieldByName('datum').AsString);
      end
      else
      begin
        // Kein Datum im aktuellen Quartal gefunden, versuche das letzte Datum aus dem vorherigen Quartal zu holen
        Quartal := Quartal - 1;
        if Quartal = 0 then
        begin
          Quartal := 4;
          Jahr := Jahr - 1;
        end;

        FDQuery.Close;
        FDQuery.SQL.Text := 'SELECT strftime("%d.%m.%Y", datum) AS datum ' +
                            'FROM ausbildung ' +
                            'WHERE mitarbeiterID = :maid ' +
                            'AND ausbildungsartID = 4 ' +
                            'AND strftime("%Y", datum) = :jahr ' +
                            'AND (CAST(strftime("%m", datum) AS INTEGER) - 1) / 3 + 1 = :quartal ' +
                            'ORDER BY datum DESC ' +
                            'LIMIT 1;';

        FDQuery.ParamByName('quartal').AsInteger := Quartal;
        FDQuery.ParamByName('jahr').AsString := IntToStr(Jahr);
        FDQuery.ParamByName('maid').AsInteger := mitarbeiterID;

        FDQuery.Open;
        if not FDQuery.IsEmpty then
        begin
          subItems.Add(FDQuery.FieldByName('datum').AsString);
        end
        else
        begin
          subItems.Add('-----');
        end;
      end;
    finally
      FDQuery.Close;
    end;
  finally
    FDQuery.Free;
  end;
end;







procedure TFrameGesamtausbildung.LoadAusbildung(mitarbeiterID, ausbildungsartID, Monat, Jahr: integer; subItems: TStrings);
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDQuery.Create(nil);

  with FDQuery do
  begin
    Connection := fMain.FDConnection1;

    FDQuery.SQL.Text := 'SELECT GROUP_CONCAT(strftime("%d.%m", datum), " | ") AS datum ' +
                        'FROM ausbildung ' +
                        'WHERE mitarbeiterID = :MITARBEITERID ' +
                        'AND ausbildungsartID = :AUSBILDUNGSARTID ' +
                        'AND (strftime("%Y-%m", datum) = :JAHR || "-" || :MONAT) ' +
                        'GROUP BY mitarbeiterID ' +
                        'ORDER BY datum DESC;';

    ParamByName('MONAT').AsString := Format('%.2d', [SelMonth]); //Monat als zweistellige Zahl ausgeben
    ParamByName('JAHR').AsString  := IntToStr(SelYear);
    ParamByName('MITARBEITERID').AsInteger := mitarbeiterid;
    ParamByName('AUSBILDUNGSARTID').AsInteger := ausbildungsartid;

    Open;
    try
      if IsEmpty = false then
      begin
        SubItems.Add(FieldByName('datum').AsString);
      end
      else
      begin
        SubItems.Add('-----');
      end;
    finally
      Close;
      Free;
    end;
  end;
end;






procedure TFrameGesamtausbildung.LoadAusbildungQuartal(mitarbeiterID, ausbildungsartID, Quartal, Jahr: integer; subItems: TStrings);
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDQuery.Create(nil);

  with FDQuery do
  begin
    Connection := fMain.FDConnection1;

    FDQuery.SQL.Text := 'SELECT GROUP_CONCAT(strftime("%d.%m", datum), " | ") AS datum ' +
                        'FROM ausbildung ' +
                        'WHERE mitarbeiterID = :MITARBEITERID ' +
                        'AND ausbildungsartID = :AUSBILDUNGSARTID ' +
                        'AND strftime("%Y", datum) = :JAHR ' +
                        'AND (CAST(strftime("%m", datum) AS INTEGER) - 1) / 3 + 1 = :QUARTAL ' +
                        'GROUP BY mitarbeiterID ' +
                        'ORDER BY datum DESC;';

    ParamByName('QUARTAL').AsInteger := Quartal;
    ParamByName('JAHR').AsString := IntToStr(Jahr);
    ParamByName('MITARBEITERID').AsInteger := mitarbeiterID;
    ParamByName('AUSBILDUNGSARTID').AsInteger := ausbildungsartID;

    Open;
    try
      if not IsEmpty then
      begin
        subItems.Add(FieldByName('datum').AsString);
      end
      else
      begin
        subItems.Add('-----');
      end;
    finally
      Close;
      Free;
    end;
  end;
end;






procedure TFrameGesamtausbildung.LoadErsteHilfe(mitarbeiterID: integer; subItems: TStrings);
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDQuery.Create(nil);

  with FDQuery do
  begin
    Connection := fMain.FDConnection1;

    FDQuery.SQL.Text := 'SELECT strftime("%m/%Y", date(datum, "+2 years")) AS datum ' +
                        'FROM ausbildung ' +
                        'WHERE mitarbeiterID = :MITARBEITERID AND ausbildungsartID = :AUSBILDUNGSARTID ' +
                        'ORDER BY Datum ASC LIMIT 1;';

    ParamByName('MITARBEITERID').AsInteger := mitarbeiterid;
    ParamByName('AUSBILDUNGSARTID').AsInteger := 5; // 5 = ersteHilfe

    Open;
    try
      if IsEmpty = false then
      begin
        SubItems.Add(FieldByName('datum').AsString);
      end
      else
      begin
        SubItems.Add('-----');
      end;
    finally
      Close;
      Free;
    end;
  end;
end;









procedure TFrameGesamtausbildung.cbMonatSelect(Sender: TObject);
var
  quartal, monat, jahr: integer;
begin
  quartal := cbQuartal.ItemIndex+1;
  monat   := cbMonat.ItemIndex+1;
  jahr    := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);

  SELMONTH   := monat;
  SELQUARTAL := quartal;
  SELYEAR    := jahr;

  if(rbQuartal.Checked) then
    showQuartalsausbildungInListView(quartal, jahr)
  else
    showMonatsausbildungInListView;
end;






procedure TFrameGesamtausbildung.cbQuartalSelect(Sender: TObject);
var
  quartal, jahr: integer;
begin
  quartal := cbQuartal.ItemIndex+1;
  jahr    := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);
  SELMONTH := 0;
  SELQUARTAL := quartal;

  showQuartalsausbildungInListView(quartal, jahr);
end;





procedure TFrameGesamtausbildung.lvGesamtausbildungColumnClick(Sender: TObject; Column: TListColumn);
begin
  lvColumnClickForSort(Sender, Column);
end;





procedure TFrameGesamtausbildung.lvGesamtausbildungCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  lvCompareForSort(Sender, Item1, Item2, Data, Compare);
end;





procedure TFrameGesamtausbildung.rbMonatClick(Sender: TObject);
var
  Index, CurrentYear, CurrentMonth, CurrentQuarter: integer;
begin
  CurrentMonth        := MonthOf(Now); // aktuellen Monat ermitteln
  CurrentYear         := YearOf(Now);   // aktuelles Jahr ermitteln
  CurrentQuarter      := GetQuarterForMonth(CurrentMonth); // aktuelles Quartal ermitteln
  cbQuartal.ItemIndex := CurrentQuarter-1; //aktuelles Quartal in Combobox auswählen
  cbMonat.ItemIndex   := CurrentMonth - 1; //aktuellen Monat in combobox auswählen
  Index               := cbJahr.Items.IndexOf(IntToStr(CurrentYear));
  if Index <> -1 then cbJahr.ItemIndex := Index; //aktuelles Jahr in combobox auswählen


  if(rbQuartal.Checked) then
  begin
    lbQuartal.Visible := true;
    cbQuartal.Visible := true;
    lbMonat.Visible   := false;
    cbMonat.Visible   := false;
    cbQuartalSelect(self);
  end
  else
  begin
    lbQuartal.Visible := false;
    cbQuartal.Visible := false;
    lbMonat.Visible   := true;
    cbMonat.Visible   := true;
    cbMonatSelect(self);
  end;
end;




procedure TFrameGesamtausbildung.rbQuartalClick(Sender: TObject);
var
  Index, CurrentYear, CurrentMonth, CurrentQuarter: integer;
begin
  CurrentMonth        := MonthOf(Now); // aktuellen Monat ermitteln
  CurrentYear         := YearOf(Now);   // aktuelles Jahr ermitteln
  CurrentQuarter      := GetQuarterForMonth(CurrentMonth); // aktuelles Quartal ermitteln
  cbQuartal.ItemIndex := CurrentQuarter-1; //aktuelles Quartal in Combobox auswählen
  cbMonat.ItemIndex   := CurrentMonth - 1; //aktuellen Monat in combobox auswählen
  Index               := cbJahr.Items.IndexOf(IntToStr(CurrentYear));

  if Index <> -1 then cbJahr.ItemIndex := Index; //aktuelles Jahr in combobox auswählen


  if(rbQuartal.Checked) then
  begin
    lbQuartal.Visible := true;
    cbQuartal.Visible := true;
    lbMonat.Visible   := false;
    cbMonat.Visible   := false;
    cbQuartalSelect(self);
  end
  else
  begin
    lbQuartal.Visible := false;
    cbQuartal.Visible := false;
    lbMonat.Visible   := true;
    cbMonat.Visible   := true;
    cbMonatSelect(self);
  end;
end;















procedure TFrameGesamtausbildung.sbWeiterClick(Sender: TObject);
begin
  DisplayHinweisString;
end;






procedure TFrameGesamtausbildung.showMonatsausbildungInListView;
var
  FDQuery: TFDQuery;
  item: TListItem;
  mitarbeiterID: integer;
  StartDate, EndDate: TDateTime;
begin
  lvGesamtausbildung.Items.Clear;

  // Start- und Enddatum für den Monat berechnen
  StartDate := EncodeDate(SelYear, SelMonth, 1);
  EndDate := EndOfTheMonth(StartDate);

  FDQuery := TFDQuery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT M.id, M.vorname, M.nachname, M.personalnr, ' +
                  'M.sonderausweisnr, M.eintrittsdatum, ' +
                  'CASE WHEN M.austrittsdatum BETWEEN :STARTDATE AND :ENDDATE ' +
                  'THEN M.austrittsdatum ELSE NULL END AS austrittsdatum ' +
                  'FROM mitarbeiter AS M ' +
                  'INNER JOIN ausbildung AS A ON A.mitarbeiterID = M.id ' +
                  'WHERE (M.austrittsdatum IS NULL OR M.austrittsdatum = "" OR ' +
                  'M.austrittsdatum >= :STARTDATE) ' +
                  'AND A.datum BETWEEN :STARTDATE AND :ENDDATE ' +
                  'AND A.ausbildungsartID IN (1, 2, 3) ' +
                  'GROUP BY M.id ' +
                  'ORDER BY M.objektid, M.nachname;';

      // Parameter für Start- und Enddatum setzen
      Params.ParamByName('STARTDATE').AsDate := StartDate;
      Params.ParamByName('ENDDATE').AsDate := EndDate;

      Open;
      while not Eof do
      begin
        mitarbeiterID := Fields[0].AsInteger;

        item := lvGesamtausbildung.Items.Add;
        with item do
        begin
          Caption := IntToStr(mitarbeiterID);
          SubItems.Add(Fields[1].AsString); // vorname
          SubItems.Add(Fields[2].AsString); // nachname
          SubItems.Add(Fields[3].AsString); // personalnr
          SubItems.Add(Fields[4].AsString); // sonderausweisnr

          LoadWachschiessen(mitarbeiterID, SelMonth, SelYear, SubItems);
          LoadAusbildung(mitarbeiterID, 1, SelMonth, SelYear, SubItems);
          LoadAusbildung(mitarbeiterID, 2, SelMonth, SelYear, SubItems);
          LoadAusbildung(mitarbeiterID, 3, SelMonth, SelYear, SubItems);
          LoadErsteHilfe(mitarbeiterID, SubItems);

          SubItems.Add(ConvertSQLDateToGermanDate(Fields[5].AsString, false)); // eintrittsdatum
          SubItems.Add(ConvertSQLDateToGermanDate(Fields[6].AsString, false)); // austrittsdatum
        end;

        Next;
      end;
    end;
  finally
    FDQuery.Free;
  end;
end;








procedure TFrameGesamtausbildung.showQuartalsausbildungInListView(Quartal, Jahr: integer);
var
  FDQuery: TFDQuery;
  item: TListItem;
  mitarbeiterID: integer;
begin
  lvGesamtausbildung.Items.Clear;

  // Alle Mitarbeiter auslesen die einen Eintrag in der Tabelle ausbildung für den übergebenen Zeitraum haben
  FDQuery := TFDQuery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT M.id, M.vorname, M.nachname, M.personalnr, ' +
                  'M.sonderausweisnr, M.eintrittsdatum, ' +
                  'CASE WHEN strftime("%Y", M.austrittsdatum) = :JAHR AND ' +
                  '(CAST(strftime("%m", M.austrittsdatum) AS INTEGER) - 1) / 3 + 1 = :QUARTAL ' +
                  'THEN M.austrittsdatum ELSE NULL END AS austrittsdatum ' +
                  'FROM mitarbeiter AS M ' +
                  'INNER JOIN ausbildung AS A ON A.mitarbeiterID = M.id ' +
                  'WHERE (M.austrittsdatum IS NULL OR M.austrittsdatum = "" OR ' +
                  '(strftime("%Y", M.austrittsdatum) = :JAHR AND ' +
                  '(CAST(strftime("%m", M.austrittsdatum) AS INTEGER) - 1) / 3 + 1 >= :QUARTAL)) ' +
                  'AND strftime("%Y", A.datum) = :JAHR AND ' +
                  '(CAST(strftime("%m", A.datum) AS INTEGER) - 1) / 3 + 1 = :QUARTAL ' +
                  'AND A.ausbildungsartID BETWEEN 1 AND 3 ' +
                  'GROUP BY M.id ' +
                  'ORDER BY M.objektid, M.nachname;';

      Params.ParamByName('QUARTAL').AsInteger := Quartal;
      Params.ParamByName('JAHR').AsString := IntToStr(Jahr);

      Open;

      while not Eof do
      begin
        mitarbeiterID := FieldByName('id').AsInteger;

        item := lvGesamtausbildung.Items.Add;
        item.Caption := IntToStr(mitarbeiterID);
        item.SubItems.Add(FieldByName('vorname').AsString);
        item.SubItems.Add(FieldByName('nachname').AsString);
        item.SubItems.Add(FieldByName('personalnr').AsString);
        item.SubItems.Add(FieldByName('sonderausweisnr').AsString);

        LoadWachschiessenQuartal(mitarbeiterID, Quartal, Jahr, item.SubItems);
        LoadAusbildungQuartal(mitarbeiterID, 1, Quartal, Jahr, item.SubItems);
        LoadAusbildungQuartal(mitarbeiterID, 2, Quartal, Jahr, item.SubItems);
        LoadAusbildungQuartal(mitarbeiterID, 3, Quartal, Jahr, item.SubItems);
        LoadErsteHilfe(mitarbeiterID, item.SubItems);

        item.SubItems.Add(ConvertSQLDateToGermanDate(FieldByName('eintrittsdatum').AsString, false));
        item.SubItems.Add(ConvertSQLDateToGermanDate(FieldByName('austrittsdatum').AsString, false));

        Next;
      end;
    end;
  finally
    FDQuery.Close;
    FDQuery.Free;
  end;
end;












procedure TFrameGesamtausbildung.DisplayHinweisString;
begin
  case currentIndex of
    1: lbHinweis.Caption := s1;
    2: lbHinweis.Caption := s2;
  end;

  // Inkrementiere den Index und setze ihn zurück auf 1, wenn er 4 erreicht
  currentIndex := currentIndex mod 2 + 1;
end;







procedure TFrameGesamtausbildung.GeneratePrintableGesamtausbildung(monat, quartal, jahr: integer);
var
  stltemp: TStringList;
  SEITE, i, a, lvCount, ANZAHLSEITEN: integer;
  StartIndex: integer;
  EndIndex: integer;
  filename: string;
  stlHtmlHeader, stlHtmlFooter, stlSiteHeader, stlSiteFooter, stlSiteContent: TStringList;
  resHtmlHeader, resHtmlFooter, resSiteHeader, resSiteFooter, resSiteContent: TResourceStream;
  MonatJahr: String;
  ZEILENPROSEITE, ZEILE: integer;
  zeitraumtitel, zeitraum: string;
begin
  stlHtmlHeader := nil;
  stlHtmlFooter := nil;
  resHtmlHeader := nil;
  resHtmlFooter := nil;
  stlTemp := nil;


  Zeile          := 0;
  ZEILENPROSEITE := 17;
  MonatJahr := IntToStr(Monat) + '/' + IntToStr(Jahr);

  if(rbQuartal.Checked) then
  begin
    zeitraumtitel := 'Quartal';
    zeitraum      := inttostr(quartal);
  end
  else
  begin
    zeitraumtitel := 'Monat';
    zeitraum      := monatsnamen[monat];
  end;

  lvCount := lvGesamtausbildung.Items.Count;

  if(lvCount > ZEILENPROSEITE) then ANZAHLSEITEN := CEIL(lvCount / ZEILENPROSEITE) else ANZAHLSEITEN := 1;


//Hier nur das was einmal für alle Seiten geladen werden muss (HtmlHeader, HtmlFooter)
  try
    resHtmlHeader := TResourceStream.Create(HInstance, 'Gesamtausbildung_HTML_Header', 'TXT');
    resHtmlFooter := TResourceStream.Create(HInstance, 'Gesamtausbildung_HTML_Footer', 'TXT');
    stlHtmlHeader := TStringList.Create;
    stlHtmlHeader.LoadFromStream(resHtmlHeader);
    stlHtmlFooter := TStringList.Create;
    stlHtmlFooter.LoadFromStream(resHtmlFooter);
    stlTemp := TStringList.Create;

//Hier alles was mehrmals geladen werden muss (für jede Seite - SiteHeader, SiteFooter, SiteContent)
    for SEITE := 0 to ANZAHLSEITEN - 1 do
    begin
      resSiteHeader := TResourceStream.Create(HInstance, 'Gesamtausbildung_SITE_Header', 'TXT');
      stlSiteHeader := TStringList.Create;
      try
        stlSiteHeader.LoadFromStream(resSiteHeader);
        stlSiteHeader.Text := StringReplace(stlSiteHeader.Text, '[JAHR]',    IntToStr(Jahr), [rfReplaceAll]);
        stlSiteHeader.Text := StringReplace(stlSiteHeader.Text, '[OBJEKTORT]', OBJEKTNAME + ' ' + OBJEKTORT, [rfReplaceAll]);
        stlSiteHeader.Text := StringReplace(stlSiteHeader.Text, '[MONATQUARTAL]',  zeitraum,  [rfReplaceAll]);
        stlSiteHeader.Text := StringReplace(stlSiteHeader.Text, '[ZEITRAUMTITEL]',  zeitraumtitel,  [rfReplaceAll]);
        stltemp.Add(stlSiteHeader.Text);
      finally
        stlSiteHeader.Free;
        resSiteHeader.Free;
      end;




//CONTENT START
      StartIndex := SEITE * ZEILENPROSEITE;
      EndIndex   := Min((SEITE + 1) * ZEILENPROSEITE - 1, lvCount - 1);

      for a := StartIndex to EndIndex do
      begin
        Vorname         := lvGesamtausbildung.Items[a].SubItems[0];
        Nachname        := lvGesamtausbildung.Items[a].SubItems[1];
        PersonalNr      := lvGesamtausbildung.Items[a].SubItems[2];
        SaNr            := lvGesamtausbildung.Items[a].SubItems[3];
        AusbSchiessen   := lvGesamtausbildung.Items[a].SubItems[4];
        AusbWaffenhandh := lvGesamtausbildung.Items[a].SubItems[5];
        AusbTheorie     := lvGesamtausbildung.Items[a].SubItems[6];
        AusbSzenario    := lvGesamtausbildung.Items[a].SubItems[7];
        AusbErsteh      := lvGesamtausbildung.Items[a].SubItems[8];
        Eintrittsdatum  := lvGesamtausbildung.Items[a].SubItems[9];
        Austrittsdatum  := lvGesamtausbildung.Items[a].SubItems[10];

        resSiteContent := TResourceStream.Create(HInstance, 'Gesamtausbildung_SITE_Content', 'TXT');
        stlSiteContent := TStringList.Create;
        try
          inc(Zeile);

          stlSiteContent.LoadFromStream(resSiteContent);

          //Jede zweite Zeile farblich markieren
          if Zeile mod 2 = 0 then
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[LINECOLOR]',  ' class="linecolor"',  [rfReplaceAll]);

          //Schriftgrößen in Ausbildung anpassen
          if(length(AusbWaffenhandh) >= 21) then
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[ZELLWIDTHWAFFENH]',  ' style="font-size:12px;"',  [rfReplaceAll])
          else if(length(AusbWaffenhandh) >= 13) then
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[ZELLWIDTHWAFFENH]',  ' style="font-size:16px;"',  [rfReplaceAll])
          else stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[ZELLWIDTHWAFFENH]',  ' style="font-size:18px;"',  [rfReplaceAll]);

          if(length(AusbTheorie) >= 21) then
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[ZELLWIDTHTHEORIE]',  ' style="font-size:10px;"',  [rfReplaceAll])
          else if(length(AusbTheorie) >= 13) then
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[ZELLWIDTHTHEORIE]',  ' style="font-size:16px;"',  [rfReplaceAll])
          else stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[ZELLWIDTHTHEORIE]',  ' style="font-size:18px;"',  [rfReplaceAll]);

          if(length(AusbSzenario) >= 21) then
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[ZELLWIDTHWACHAUSB]',  ' style="font-size:12px;"',  [rfReplaceAll])
          else if(length(AusbSzenario) >= 13) then
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[ZELLWIDTHWACHAUSB]',  ' style="font-size:16px;"',  [rfReplaceAll])
          else stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[ZELLWIDTHWACHAUSB]',  ' style="font-size:18px;"',  [rfReplaceAll]);

          stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[VORNAME]', vorname, [rfReplaceAll]);
          stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[NACHNAME]', nachname, [rfReplaceAll]);
          stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[PERSONALNR]', personalnr, [rfReplaceAll]);
          stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[SWANR]', SaNr, [rfReplaceAll]);
          stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[LETZTESSCHIESSEN]', AusbSchiessen, [rfReplaceAll]);
          stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[WAFFENHANDHABUNG]', AusbWaffenhandh, [rfReplaceAll]);
          stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[THEORIE]', AusbTheorie, [rfReplaceAll]);
          stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[WACHAUSBILDUNG]', AusbSzenario, [rfReplaceAll]);
          stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[ERSTEHILFE]', AusbErsteh, [rfReplaceAll]);
          stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[EINTRITTSDATUM]', eintrittsdatum, [rfReplaceAll]);
          stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[AUSTRITTSDATUM]', austrittsdatum, [rfReplaceAll]);

          stltemp.Add(stlSiteContent.Text);
        finally
          resSiteContent.Free;
          stlSiteContent.Free;
        end;
      end; //for a := StartIndex to EndIndex do


//Wenn auf der letzten Seite weniger als X Einträge vorhanden sind, leere Zeilen einfügen
//damit das Formular immer gleich groß ist
      if (SEITE = ANZAHLSEITEN - 1) and (EndIndex - StartIndex < ZEILENPROSEITE - 1) then
      begin
      for a := EndIndex + 1 to (SEITE + 1) * ZEILENPROSEITE - 1 do
        begin
          resSiteContent := TResourceStream.Create(HInstance, 'Gesamtausbildung_SITE_Content', 'TXT');
          stlSiteContent := TStringList.Create;
          try
            stlSiteContent.LoadFromStream(resSiteContent);

            if a mod 2 = 1 then
              stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[LINECOLOR]',  ' class="linecolor"',  [rfReplaceAll]);

            //Schriftgrößen in Ausbildung anpassen
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[ZELLWIDTHWAFFENH]',  ' ',  [rfReplaceAll]);
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[ZELLWIDTHTHEORIE]',  ' ',  [rfReplaceAll]);
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[ZELLWIDTHWACHAUSB]',  ' ',  [rfReplaceAll]);
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[VORNAME]', '&nbsp;', [rfReplaceAll]);
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[NACHNAME]', '&nbsp;', [rfReplaceAll]);
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[PERSONALNR]', '&nbsp;', [rfReplaceAll]);
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[SWANR]', '&nbsp;', [rfReplaceAll]);
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[LETZTESSCHIESSEN]', '&nbsp;', [rfReplaceAll]);
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[WAFFENHANDHABUNG]', '&nbsp;', [rfReplaceAll]);
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[THEORIE]', '&nbsp;', [rfReplaceAll]);
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[WACHAUSBILDUNG]', '&nbsp;', [rfReplaceAll]);
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[ERSTEHILFE]', '&nbsp;', [rfReplaceAll]);
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[EINTRITTSDATUM]', '&nbsp;', [rfReplaceAll]);
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[AUSTRITTSDATUM]', '&nbsp;', [rfReplaceAll]);
            stltemp.Add(stlSiteContent.Text);
          finally
            resSiteContent.Free;
            stlSiteContent.Free;
          end;
        end; //for a := EndIndex + SEITE to (SEITE + 1) * ZEILENPROSEITE - 1 do
      end; //if (SEITE = ANZAHLSEITEN - 1) and (EndIndex < SEITE * ZEILENPROSEITE + ZEILENPROSEITE - 1) then
//CONTENT ENDE


      resSiteFooter := TResourceStream.Create(HInstance, 'Gesamtausbildung_SITE_Footer', 'TXT');
      stlSiteFooter := TStringList.Create;
      try
        stlSiteFooter.LoadFromStream(resSiteFooter);
        stltemp.Add(stlSiteFooter.Text);
      finally
        resSiteFooter.Free;
        stlSiteFooter.Free;
      end;
    end;


    stlTemp.Text := stlHtmlHeader.Text + stlTemp.Text + stlHtmlFooter.Text;

  //Alle Umlaute in der StringList ersetzen durch html code
    for i := 0 to stlTemp.Count - 1 do
    begin
      stlTemp[i] := ReplaceUmlauteWithHtmlEntities(stlTemp[i]);
    end;

    //Seiten als Html-Datei speichern
    if(rbQuartal.Checked) then
    begin
      //Dateiname für zu speichernde Datei erzeugen
      filename := 'Gesamtausbildung Quartal 0'+ IntToStr(Quartal) +' '+IntToStr(jahr) + ' ' + OBJEKTNAME + ' ' + OBJEKTORT;

      //Aus Resource-Datei temporäre Html-Datei und daraus eine PDF-Datei im TEMP Verzeichnis erzeugen
      CreateHtmlAndPdfFileFromResource(filename, stlTemp);

      //PDF Datei aus Temp Verzeichnis im Zielverzeichnis speichern
      SpeicherePDFDatei(filename, SAVEPATH_Ausbildungquartal);
    end
    else
    begin
      //Dateiname für zu speichernde Datei erzeugen
      filename := 'Gesamtausbildung '+ monatsnamen[monat] +' '+IntToStr(jahr) + ' ' + OBJEKTNAME + ' ' + OBJEKTORT;

      //Aus Resource-Datei temporäre Html-Datei und daraus eine PDF-Datei im TEMP Verzeichnis erzeugen
      CreateHtmlAndPdfFileFromResource(filename, stlTemp);

      //PDF Datei aus Temp Verzeichnis im Zielverzeichnis speichern
      SpeicherePDFDatei(filename, SAVEPATH_Ausbildungmonat);
    end;
  finally
    if Assigned(stlHtmlHeader) then stlHtmlHeader.Free;
    if Assigned(stlHtmlFooter) then stlHtmlFooter.Free;
    if Assigned(resHtmlHeader) then resHtmlHeader.Free;
    if Assigned(resHtmlFooter) then resHtmlFooter.Free;
    if Assigned(stlTemp) then stlTemp.Free;
  end;
end;



end.
