unit uGesamtausbildung;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, AdvListV,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls, StrUtils, ShellApi, DateUtils, Math,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param;

type
  TfGesamtausbildung = class(TForm)
    Panel1: TPanel;
    Label7: TLabel;
    Label8: TLabel;
    btnGeneratePDF: TImage;
    lvGesamtausbildung: TAdvListView;
    StatusBar1: TStatusBar;
    Panel2: TPanel;
    lbMonat: TLabel;
    lbJahr: TLabel;
    lbQuartal: TLabel;
    cbMonat: TComboBox;
    cbJahr: TComboBox;
    cbQuartal: TComboBox;
    mQuartalsabfrage: TMemo;
    mMonatsabfrage: TMemo;
    rbMonat: TRadioButton;
    rbQuartal: TRadioButton;
    procedure btnGeneratePDFClick(Sender: TObject);
    procedure cbMonatSelect(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rbQuartalClick(Sender: TObject);
    procedure cbQuartalSelect(Sender: TObject);
  private
    procedure GeneratePrintableQuartalsGesamtausbildungFromDB(quartal, jahr: integer);
    procedure GeneratePrintableMonatsGesamtausbildungFromDB(monat, jahr: integer);
    procedure showQuartalsausbildungInListView(Quartal, Jahr: integer);
    procedure showMonatsausbildungInListView(Monat, Jahr: integer);
  public
    { Public-Deklarationen }
  end;

var
  fGesamtausbildung: TfGesamtausbildung;
  NEWENTRY: boolean;
  SELID, SEITE: integer;
  TITEL: string;
  mitarbeiterid: integer;
  Nachname, Vorname, PersonalNr, SaNr, AusbSchiessen, AusbWaffenhandh, AusbTheorie: string;
  AusbSzenario, AusbErsteh, Eintrittsdatum, Austrittsdatum: string;


implementation

{$R *.dfm}

uses
  uMain, uDBFunktionen, uFunktionen;

procedure TfGesamtausbildung.btnGeneratePDFClick(Sender: TObject);
begin
  if(rbMonat.Checked) then
  begin
    GeneratePrintableQuartalsGesamtausbildungFromDB(cbQuartal.ItemIndex+1, StrToInt(cbJahr.Text));
    rbQuartal.Checked := true;
    GeneratePrintableMonatsGesamtausbildungFromDB(cbMonat.ItemIndex+1, StrToInt(cbJahr.Text));
  end
  else
  begin
    GeneratePrintableMonatsGesamtausbildungFromDB(cbMonat.ItemIndex+1, StrToInt(cbJahr.Text));
    rbMonat.Checked := true;
    GeneratePrintableQuartalsGesamtausbildungFromDB(cbQuartal.ItemIndex+1, StrToInt(cbJahr.Text));
  end;
  close;
end;







{
  Neue Version lädt die, im Formular anzuzeigenden Daten aus der Datenbank
  anstatt diese aus der ListView zu nehmen.
}
procedure TfGesamtausbildung.cbMonatSelect(Sender: TObject);
var
  q, m, j: integer;
begin
  q := cbQuartal.ItemIndex+1;
  m := cbMonat.ItemIndex+1;
  j := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);

  if(rbQuartal.Checked) then
    showQuartalsausbildungInListView(q, j)
  else
    showMonatsausbildungInListView(m, j);
end;





procedure TfGesamtausbildung.cbQuartalSelect(Sender: TObject);
var
  q, j: integer;
begin
  q := cbQuartal.ItemIndex+1;
  j := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);
  showQuartalsausbildungInListView(q, j);
end;




procedure TfGesamtausbildung.FormShow(Sender: TObject);
var
  CurrentMonth, CurrentYear, StartYear, CurrentQuarter: Integer;
  Index: Integer;
begin
  NEWENTRY := true;
  SELID    := -1;

  rbQuartal.Checked := true;

  CurrentMonth := MonthOf(Now); // aktuellen Monat ermitteln
  CurrentQuarter := GetQuarterForMonth(CurrentMonth); // aktuelles Quartal ermitteln

  //aktuellen Monat in combobox auswählen
  cbMonat.ItemIndex := CurrentMonth - 1;


  //Die Jahre von 2023 bis aktuelles Jahr + 1 in cbJahr anzeigen
  CurrentYear := YearOf(Now);
  StartYear := 2023;
  for CurrentYear := StartYear to CurrentYear + 1 do
    cbJahr.Items.Add(IntToStr(CurrentYear));

  //aktuelles Jahr in combobox auswählen
  CurrentYear := YearOf(Now);
  Index       := cbJahr.Items.IndexOf(IntToStr(CurrentYear));
  if Index <> -1 then cbJahr.ItemIndex := Index;

  //aktuelles Quartal in Combobox auswählen
  cbQuartal.ItemIndex := CurrentQuarter-1;

  //Alle Ausbildungen des gewählten Quartals in ListView anzeigen
  showQuartalsausbildungInListView(CurrentQuarter, CurrentYear);
  //GeneratePrintableQuartalsGesamtausbildungFromDB(cbQuartal.ItemIndex+1, CurrentYear);
end;





procedure TfGesamtausbildung.showQuartalsausbildungInListView(Quartal, Jahr: integer);
var
  q: TFDQuery;
  l: TListItem;
  Trenner: String;
begin
  Trenner := '-----';

  q := TFDquery.Create(nil);
  try
    with q do
    begin
      Connection := fMain.FDConnection1;
      fMain.FDConnection1.Connected := true;

      SQL.Clear;
      SQL.Text := mQuartalsabfrage.Text;
      Params.ParamByName('QUARTAL').AsInteger := Quartal;
      Params.ParamByName('JAHR').AsInteger    := Jahr;

      try
        Open;
      except
        on E: Exception do ShowMessage('Fehler: ' + E.Message);
      end;

      lvGesamtausbildung.Items.Clear;

      while not Eof do
      begin
        Vorname         := FieldByName('vorname').AsString;
        Nachname        := FieldByName('nachname').AsString;
        PersonalNr      := FieldByName('personalnr').AsString;
        SaNr            := FieldByName('sonderausweisnr').AsString;
        AusbSchiessen   := FieldByName('Waschschiessen').AsString;
        AusbWaffenhandh := FieldByName('Waffenhandhabung').AsString;
        AusbTheorie     := FieldByName('Theorie').AsString;
        AusbSzenario    := FieldByName('Szenario').AsString;
        AusbErsteH      := FieldByName('ErsteHilfe').AsString;
        Eintrittsdatum  := FieldByName('eintrittsdatum').AsString;
        Austrittsdatum  := FieldByName('austrittsdatum').AsString;

        if(PersonalNr = '') then PersonalNr := Trenner;
        if(Eintrittsdatum = '01.01.0001') then Eintrittsdatum := Trenner;
        if(Austrittsdatum = '01.01.0001') then Austrittsdatum := Trenner;
        if(SaNr = '') then SaNr := Trenner;
        if(AusbSchiessen = '') then AusbSchiessen := Trenner;
        if(AusbWaffenhandh = '') then AusbWaffenhandh := Trenner;
        if(AusbTheorie = '') then AusbTheorie := Trenner;
        if(AusbSzenario = '') then AusbSzenario := Trenner;
        if(AusbErsteH = '') then AusbErsteH := Trenner;

        if(Pos('-', AusbWaffenhandh) > 0) AND (Pos('-', AusbTheorie) > 0) AND (Pos('-', AusbSzenario) > 0) then
        begin
          next;
        end
        else
        begin
          l := lvGesamtausbildung.Items.Add;
          l.Caption := IntToStr(MitarbeiterID);
          l.SubItems.Add(Vorname);
          l.SubItems.Add(Nachname);
          l.SubItems.Add(PersonalNr);
          l.SubItems.Add(SaNr);
          l.SubItems.Add(AusbSchiessen);
          l.SubItems.Add(AusbWaffenhandh);
          l.SubItems.Add(AusbTheorie);
          l.SubItems.Add(AusbSzenario);
          l.SubItems.Add(AusbErsteH);
          l.SubItems.Add(Eintrittsdatum);
          l.SubItems.Add(Austrittsdatum);
          next;
        end;
      end;

      fMain.FDConnection1.Connected := false;
    end;
  finally
    q.Free;
  end;
end;



procedure TfGesamtausbildung.showMonatsausbildungInListView(Monat, Jahr: integer);
var
  q: TFDQuery;
  l: TListItem;
  Trenner: String;
begin
  Trenner := '-----';

  q := TFDquery.Create(nil);
  try
    with q do
    begin
      Connection := fMain.FDConnection1;
      fMain.FDConnection1.Connected := true;

      SQL.Clear;
      SQL.Text := mMonatsabfrage.Text;
      Params.ParamByName('MONAT').AsInteger := Monat;
      Params.ParamByName('JAHR').AsInteger  := Jahr;

      try
        Open;
      except
        on E: Exception do ShowMessage('Fehler: ' + E.Message);
      end;

      lvGesamtausbildung.Items.Clear;

      while not Eof do
      begin
        Vorname         := FieldByName('vorname').AsString;
        Nachname        := FieldByName('nachname').AsString;
        PersonalNr      := FieldByName('personalnr').AsString;
        SaNr            := FieldByName('sonderausweisnr').AsString;
        AusbSchiessen   := FieldByName('Waschschiessen').AsString;
        AusbWaffenhandh := FieldByName('Waffenhandhabung').AsString;
        AusbTheorie     := FieldByName('Theorie').AsString;
        AusbSzenario    := FieldByName('Szenario').AsString;
        AusbErsteH      := FieldByName('ErsteHilfe').AsString;
        Eintrittsdatum  := FieldByName('eintrittsdatum').AsString;
        Austrittsdatum  := FieldByName('austrittsdatum').AsString;

        if(PersonalNr = '') then PersonalNr := Trenner;
        if(SaNr = '') then SaNr := Trenner;
        if(AusbSchiessen = '') then AusbSchiessen := Trenner;
        if(AusbWaffenhandh = '') then AusbWaffenhandh := Trenner;
        if(AusbTheorie = '') then AusbTheorie := Trenner;
        if(AusbSzenario = '') then AusbSzenario := Trenner;
        if(AusbErsteH = '') then AusbErsteH := Trenner;
        if(Eintrittsdatum = '01.01.0001') then Eintrittsdatum := Trenner;
        if(Austrittsdatum = '01.01.0001') then Austrittsdatum := Trenner;

        if(Pos('-', AusbWaffenhandh) > 0) AND (Pos('-', AusbTheorie) > 0) AND (Pos('-', AusbSzenario) > 0) then
        begin
          next;
        end
        else
        begin
          l := lvGesamtausbildung.Items.Add;
          l.Caption := IntToStr(MitarbeiterID);
          l.SubItems.Add(Vorname);
          l.SubItems.Add(Nachname);
          l.SubItems.Add(PersonalNr);
          l.SubItems.Add(SaNr);
          l.SubItems.Add(AusbSchiessen);
          l.SubItems.Add(AusbWaffenhandh);
          l.SubItems.Add(AusbTheorie);
          l.SubItems.Add(AusbSzenario);
          l.SubItems.Add(AusbErsteH);
          l.SubItems.Add(Eintrittsdatum);
          l.SubItems.Add(Austrittsdatum);
          next;
        end;
      end;

      fMain.FDConnection1.Connected := false;
    end;
  finally
    q.Free;
  end;
end;








procedure TfGesamtausbildung.GeneratePrintableMonatsGesamtausbildungFromDB(monat, jahr: integer);
var
  stltemp: TStringList;
  SEITE, i, a, lvCount, ANZAHLSEITEN: integer;
  StartIndex: integer;
  EndIndex: integer;
  filename: string;
  BatchScriptPath: string;
  HTMLFilePath: string;
  PDFFilePath: string;
  CommandLine: string;
  dateipfad: string;
  stlHtmlHeader, stlHtmlFooter, stlSiteHeader, stlSiteFooter, stlSiteContent: TStringList;
  resHtmlHeader, resHtmlFooter, resSiteHeader, resSiteFooter, resSiteContent: TResourceStream;
  MonatJahr, Monatsname, mon: String;
  ZEILENPROSEITE, ZEILE: integer;
begin
  Zeile          := 0;
  ZEILENPROSEITE := 16; //Wie viele Einträge sollen auf der Waffenbestandsmeldung pro Seite erscheinen?
  MonatJahr      := cbMonat.Text + '/' + cbJahr.Text;
  Monatsname     := FormatDateTime('mmmm', StrToDate(IntToStr(1)+'.'+IntToStr(Monat)+'.'+IntToStr(Jahr)));
  dateipfad      := 'Listen\Gesamtausbildung\';
  readSettings;


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
        stlSiteHeader.Text := StringReplace(stlSiteHeader.Text, '[MONAT]',  Monatsname,  [rfReplaceAll]);
        stlSiteHeader.Text := StringReplace(stlSiteHeader.Text, '[ZEITRAUMTITEL]',  'Monat',  [rfReplaceAll]);
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
          if(length(AusbWaffenhandh) = 21) then
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[ZELLWIDTHWAFFENH]',  ' style="font-size:12px;"',  [rfReplaceAll])
          else if(length(AusbWaffenhandh) = 13) then
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[ZELLWIDTHWAFFENH]',  ' style="font-size:16px;"',  [rfReplaceAll])
          else stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[ZELLWIDTHWAFFENH]',  ' style="font-size:18px;"',  [rfReplaceAll]);

          if(length(AusbTheorie) = 21) then
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[ZELLWIDTHTHEORIE]',  ' style="font-size:10px;"',  [rfReplaceAll])
          else if(length(AusbTheorie) = 13) then
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[ZELLWIDTHTHEORIE]',  ' style="font-size:16px;"',  [rfReplaceAll])
          else stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[ZELLWIDTHTHEORIE]',  ' style="font-size:18px;"',  [rfReplaceAll]);

          if(length(AusbSzenario) = 21) then
            stlSiteContent.Text := StringReplace(stlSiteContent.Text, '[ZELLWIDTHWACHAUSB]',  ' style="font-size:12px;"',  [rfReplaceAll])
          else if(length(AusbSzenario) = 13) then
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
      if (SEITE = ANZAHLSEITEN - 1) and (EndIndex < SEITE * ZEILENPROSEITE + ZEILENPROSEITE - 1) then
      begin
        for a := EndIndex + SEITE to (SEITE + 1) * ZEILENPROSEITE - 1 do
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
    if(Monat < 10) then mon := '0'+IntToStr(Monat) else mon := inttostr(Monat);
    filename := 'Gesamtausbildung ' + mon + '.'+ IntToStr(Jahr) + ' ' + OBJEKTNAME;

    //html-Datei speichern
    stlTemp.SaveToFile(PATH + 'TEMP\' + filename + '.html');


    //Als PDF-Datei mit dem Programm wkhtmltopdf.exe drucken
    BatchScriptPath := PATH + 'SCRIPTS\print_landscape.bat';
    HTMLFilePath    := PATH + 'TEMP\' + filename+'.html';
    PDFFilePath     := PATH + DateiPfad + filename+'.pdf';
    CommandLine := Format('"%s" "%s"', [HTMLFilePath, PDFFilePath]);

    if ShellExecute(0, 'open', PChar(BatchScriptPath), PChar(CommandLine), '', SW_HIDE) <= 32 then
    begin
      ShowMessage('Fehler beim Ausführen des Batch-Skripts.');
    end;

    StatusBar1.Panels[0].Text := 'Gesamtausbildungsübersicht im Verzeichnis "'+dateipfad+'" gespeichert.';

    sleep(1000);

    fMain.tbWochenberichtClick(fMain.tbGesamtausbildung);
  finally
    stlHtmlHeader.Free;
    stlHtmlFooter.Free;
    resHtmlHeader.Free;
    resHtmlFooter.Free;
    stlTemp.Free;
  //  close;
  end;
end;







procedure TfGesamtausbildung.GeneratePrintableQuartalsGesamtausbildungFromDB(quartal, jahr: integer);
var
  stltemp: TStringList;
  SEITE, i, a, lvCount, ANZAHLSEITEN: integer;
  StartIndex: integer;
  EndIndex: integer;
  monat: integer;
  filename: string;
  BatchScriptPath: string;
  HTMLFilePath: string;
  PDFFilePath: string;
  CommandLine: string;
  dateipfad: string;
  stlHtmlHeader, stlHtmlFooter, stlSiteHeader, stlSiteFooter, stlSiteContent: TStringList;
  resHtmlHeader, resHtmlFooter, resSiteHeader, resSiteFooter, resSiteContent: TResourceStream;
  MonatJahr, Monatsname: String;
  ZEILENPROSEITE, ZEILE: integer;
begin
  Zeile          := 0;
  ZEILENPROSEITE := 18; //Wie viele Einträge sollen auf der Waffenbestandsmeldung pro Seite erscheinen?

  monat      := cbMonat.ItemIndex;
  jahr       := StrToInt(cbJahr.Text);
  MonatJahr  := cbMonat.Text + '/' + cbJahr.Text;
  Monatsname := IntToStr(quartal);
  dateipfad  := 'Listen\Gesamtausbildung\';
  readSettings;


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
        stlSiteHeader.Text := StringReplace(stlSiteHeader.Text, '[MONAT]',  Monatsname,  [rfReplaceAll]);
        stlSiteHeader.Text := StringReplace(stlSiteHeader.Text, '[ZEITRAUMTITEL]',  'Quartal',  [rfReplaceAll]);
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
    filename := 'Gesamtausbildung Quartal 0'+ IntToStr(Quartal) +'.'+IntToStr(jahr) + ' ' + OBJEKTNAME + ' ' + OBJEKTORT;

    //html-Datei speichern
    stlTemp.SaveToFile(PATH + 'TEMP\' + filename + '.html');






    //Als PDF-Datei mit dem Programm wkhtmltopdf.exe drucken
    BatchScriptPath := PATH + 'SCRIPTS\print_landscape.bat';
    HTMLFilePath    := PATH + 'TEMP\' + filename+'.html';
    PDFFilePath     := PATH + DateiPfad + filename+'.pdf';
    CommandLine := Format('"%s" "%s"', [HTMLFilePath, PDFFilePath]);

    if ShellExecute(0, 'open', PChar(BatchScriptPath), PChar(CommandLine), '', SW_HIDE) <= 32 then
    begin
      ShowMessage('Fehler beim Ausführen des Batch-Skripts.');
    end;

    StatusBar1.Panels[0].Text := 'Gesamtausbildungsübersicht im Verzeichnis "'+dateipfad+'" gespeichert.';

    sleep(1000);

    fMain.tbWochenberichtClick(fMain.tbGesamtausbildung);
  finally
    stlHtmlHeader.Free;
    stlHtmlFooter.Free;
    resHtmlHeader.Free;
    resHtmlFooter.Free;
    stlTemp.Free;
   // close;
  end;
end;






procedure TfGesamtausbildung.rbQuartalClick(Sender: TObject);
var
  Index, CurrentYear, CurrentMonth, CurrentQuarter: integer;
begin
  if(rbQuartal.Checked) then
  begin
    CurrentMonth        := MonthOf(Now); // aktuellen Monat ermitteln
    CurrentYear         := YearOf(Now);   // aktuelles Jahr ermitteln
    CurrentQuarter      := GetQuarterForMonth(CurrentMonth); // aktuelles Quartal ermitteln
    cbQuartal.ItemIndex := CurrentQuarter-1; //aktuelles Quartal in Combobox auswählen
    cbMonat.ItemIndex   := CurrentMonth - 1; //aktuellen Monat in combobox auswählen
    Index               := cbJahr.Items.IndexOf(IntToStr(CurrentYear));
    if Index <> -1 then cbJahr.ItemIndex := Index; //aktuelles Jahr in combobox auswählen

    lbQuartal.Visible := true;
    cbQuartal.Visible := true;
    lbMonat.Visible := false;
    cbMonat.Visible := false;
    cbQuartalSelect(self);
  end
  else
  begin
    lbQuartal.Visible := false;
    cbQuartal.Visible := false;
    lbMonat.Visible := true;
    cbMonat.Visible := true;
    cbMonatSelect(self);
  end;
end;

end.
