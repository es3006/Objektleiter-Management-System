unit uFrameWachschiessen;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, AdvListV,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls, Vcl.StdCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, DateUtils, System.Math, ShellApi, Vcl.Mask, MaskEdEx,
  Vcl.Buttons, Vcl.Menus, System.Actions, Vcl.ActnList, System.UITypes;

type
  TFrameWachschiessen = class(TFrame)
    Panel2: TPanel;
    Label10: TLabel;
    cbJahr: TComboBox;
    Image1: TImage;
    lvWachschiessen: TAdvListView;
    Panel4: TPanel;
    Panel3: TPanel;
    Label1: TLabel;
    cbStammpersonal: TComboBox;
    Label2: TLabel;
    btnNewEntry: TButton;
    dtpDatum: TDateTimePicker;
    lbHinweis: TLabel;
    sbWeiter: TSpeedButton;
    cbQuartal: TComboBox;
    Label3: TLabel;
    procedure Initialize;
    procedure cbJahrSelect(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure lvWachschiessenColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvWachschiessenCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure cbStammpersonalSelect(Sender: TObject);
    procedure btnNewEntryClick(Sender: TObject);
    procedure lvWachschiessenClick(Sender: TObject);
    procedure lvWachschiessenRightClickCell(Sender: TObject; iItem, iSubItem: Integer);
    procedure sbWeiterClick(Sender: TObject);
    procedure cbQuartalSelect(Sender: TObject);
  private
    s1, s2: String;
    currentIndex: Integer;
    procedure DisplayHinweisString;
    procedure generatePrintableWachschiessenJahresansicht(jahr: integer);
    procedure SortDateList(StringList: TStringList);
    procedure showAusbildungInListView(LV: TListView; ausbildungsart, jahr: Integer);
    procedure showQuartalsAusbildungInListView(LV: TListView; ausbildungsart, quartal, jahr: Integer);
    procedure InsertMitarbeiterInListView(lv: TListView; MitarbeiterID, jahr: integer);
    procedure generateTankgutschein(quartal: string; jahr: integer);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public-Deklarationen }
  end;





var
  selectedYear: integer;
  AusbildungsartID: integer;
  SelectedMitarbeiterID, SELENTRYID: integer;
  Spaltenname: array[3..6] of string = ('Quartal 1', 'Quartal 2', 'Quartal 3', 'Quartal 4');



implementation

{$R *.dfm}
{$R Wachschiessen.res}
{$R TankgutscheinAntragEmpfang.res}

uses uMain, uWebBrowser, uFunktionen, uDBFunktionen;





procedure TFrameWachschiessen.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_COMPOSITED;
end;




procedure TFrameWachschiessen.Initialize;
var
  Index: integer;
  CurrentYear, StartYear: Integer;
begin
  //Die Jahre von 2023 bis aktuelles Jahr + 1 in ComboBox cbJahr einfügen
  CurrentYear := YearOf(Now);
  StartYear := 2023;
  for CurrentYear := StartYear to CurrentYear + 1 do
    cbJahr.Items.Add(IntToStr(CurrentYear));

  //Aktuelles Jahr in ComboBox selektieren
  CurrentYear := YearOf(Now);
  Index := cbJahr.Items.IndexOf(IntToStr(CurrentYear));
  if Index <> -1 then cbJahr.ItemIndex := Index;


  SelYear := CurrentYear;


  AusbildungsartID := 4; // 4 = Wachschiessen

  showMitarbeiterInComboBox(cbStammpersonal, 1, SelYear, true, false, OBJEKTID, 1);

  cbJahrSelect(nil);

  dtpDatum.Date := Date;

  // Hinweistexte für Timer
  s1 := 'Datum aus einem Quartal entfernen'+#13#10+'Rechte Maustaste auf das Datum im entsprechenden Quartal';
  s2 := 'Ändern des Datums in einem Quartal'+#13#10+'Wählen Sie den Eintrag in der Liste und geben Sie das gewünschte Datum ein. Je nach gewähltem Datum wird das Datum im richtigen Quartal geändert"';
  currentIndex := 2;
  lbHinweis.Caption := s1;

  cbQuartal.ItemIndex := 0;
  cbQuartalSelect(nil);
end;





procedure TFrameWachschiessen.btnNewEntryClick(Sender: TObject);
var
  FDQuery: TFDQuery;
  MaID: integer;
  Nachname: string;
  Datum: TDate;
  DatumSQL: string;
  i: integer;

  function EintragExistiert(aArtID: Integer): Boolean;
  begin
    FDQuery.SQL.Text :=
      'SELECT COUNT(*) FROM ausbildung ' +
      'WHERE mitarbeiterID = :MAID AND objektID = :OBID AND ausbildungsartID = :ARTID AND datum = :DATUM;';
    FDQuery.ParamByName('MAID').AsInteger := MaID;
    FDQuery.ParamByName('OBID').AsInteger := OBJEKTID;
    FDQuery.ParamByName('ARTID').AsInteger := aArtID;
    FDQuery.ParamByName('DATUM').AsString := DatumSQL;

    FDQuery.Open;
    Result := FDQuery.Fields[0].AsInteger > 0;
    FDQuery.Close;
  end;

begin
  i := lvWachschiessen.ItemIndex;
  if i <> -1 then
  begin
    MaID     := StrToInt(lvWachschiessen.Items[i].Caption);
    Nachname := lvWachschiessen.Items[i].SubItems[0];
    Datum    := dtpDatum.Date;
  end
  else
  begin
    ShowMessage('Bitte wählen Sie einen Mitarbeiter aus der Liste aus.');
    Exit;
  end;

  if MaID = -1 then
  begin
    ShowMessage('Bitte wählen Sie einen Mitarbeiter aus!');
    Exit;
  end;

  DatumSQL := ConvertGermanDateToSQLDate(DateToStr(Datum), false);

  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := fMain.FDConnection1;

    if EintragExistiert(4) then
    begin
      ShowMessage('Das Wachschiessen am ' + DateToStr(Datum) + ' wurde bereits gespeichert!');
      Exit;
    end;

    if EintragExistiert(1) then
    begin
      ShowMessage('Das Datum "' + DateToStr(Datum) + '" wurde bereits in den Ausbildungsunterlagen unter "Waffenhandhabung / Sachkunde" gespeichert!');
      Exit;
    end;

    fMain.FDConnection1.StartTransaction;
    try
      // Eintrag für Ausbildungsart 4
      FDQuery.SQL.Text := 'INSERT INTO ausbildung (mitarbeiterID, objektID, ausbildungsartID, datum) ' +
                          'VALUES (:MAID, :OBID, :AUSBILDUNGSARTID, :DATUM);';
      FDQuery.ParamByName('MAID').AsInteger := MaID;
      FDQuery.ParamByName('OBID').AsInteger := OBJEKTID;
      FDQuery.ParamByName('AUSBILDUNGSARTID').AsInteger := 4;
      FDQuery.ParamByName('DATUM').AsString := DatumSQL;
      FDQuery.ExecSQL;

      // Eintrag für Ausbildungsart 1
      FDQuery.ParamByName('AUSBILDUNGSARTID').AsInteger := 1;
      FDQuery.ExecSQL;

      fMain.FDConnection1.Commit;
    except
      on E: Exception do
      begin
        fMain.FDConnection1.Rollback;
        ShowMessage('Fehler beim Speichern der Einträge: ' + E.Message);
        Exit;
      end;
    end;
  finally
    FDQuery.Free;
  end;

  cbJahrSelect(Self);
  SelectMitarbeiterInListView(lvWachschiessen, MaID);
  lvWachschiessenClick(Self);
end;









procedure TFrameWachschiessen.cbJahrSelect(Sender: TObject);
var
  i, jahr: integer;
  CurrentDate: TDateTime;
  NewDate: TDateTime;
  Year, Month, Day: Word;
begin
  i := cbJahr.ItemIndex;
  if i <> -1 then
  begin
    jahr        := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);
    SelYear     := jahr;

    //Das Jahr im dtpDatum auf dsa gewählte Jahr ändern
    CurrentDate := dtpDatum.Date;
    DecodeDate(CurrentDate, Year, Month, Day);
    NewDate := EncodeDate(SelYear, Month, Day);
    dtpDatum.Date := NewDate;

    cbStammpersonal.ItemIndex := 0;

    showMitarbeiterInComboBox(cbStammpersonal, 1, SelYear, true, false, OBJEKTID, 1);

    showAusbildungInListView(lvWachschiessen, AusbildungsartID, SelYear);
  end;
end;







procedure TFrameWachschiessen.cbQuartalSelect(Sender: TObject);
var
  i, q, quartal, jahr: integer;
  CurrentDate: TDateTime;
  NewDate: TDateTime;
  Year, Month, Day: Word;
begin
  i := cbJahr.ItemIndex;
  q := cbQuartal.ItemIndex;

  if (i <> -1) AND (q > 0) then
  begin
    jahr        := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);
    quartal     := cbQuartal.ItemIndex;
    SelYear     := jahr;

    //Das Jahr im dtpDatum auf das gewählte Jahr ändern
    CurrentDate := dtpDatum.Date;
    DecodeDate(CurrentDate, Year, Month, Day);
    NewDate := EncodeDate(SelYear, Month, Day);
    dtpDatum.Date := NewDate;

    cbStammpersonal.ItemIndex := 0;

    showQuartalsAusbildungInListView(lvWachschiessen, AusbildungsartID, quartal, SelYear);
  end;

  if(i <> -1) AND (q = 0) then
  begin
    jahr        := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);
    SelYear     := jahr;

    //Das Jahr im dtpDatum auf das gewählte Jahr ändern
    CurrentDate := dtpDatum.Date;
    DecodeDate(CurrentDate, Year, Month, Day);
    NewDate := EncodeDate(SelYear, Month, Day);
    dtpDatum.Date := NewDate;

    cbStammpersonal.ItemIndex := 0;

    showAusbildungInListView(lvWachschiessen, AusbildungsartID, SelYear);
  end;
end;





procedure TFrameWachschiessen.Image1Click(Sender: TObject);
var
  i: integer;
  quartal: string;
begin
  generatePrintableWachschiessenJahresansicht(selectedYear);

  if(cbQuartal.ItemIndex > 0) then
  begin
    if MessageDlg('Wollen Sie auch den Antrag für die Tankgutscheine für dieses Quartal als PDF speichern?', mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
    begin
      i := cbQuartal.ItemIndex;
      if i > 0 then
      begin
        quartal := '0'+IntToStr(cbQuartal.ItemIndex);
        generateTankgutschein(quartal, SelYear);
      end;
    end;
  end;
end;










procedure TFrameWachschiessen.generateTankgutschein(quartal: string; jahr: Integer);
var
  stltemp: TStringList;
  i, a: integer;
  filename: string;
  stlHtmlHeader, stlHtmlFooter, stlContent: TStringList;
  resHtmlHeader, resHtmlFooter, resContent: TResourceStream;
  mitarbeiter, datum, gutscheinart: string;
  mitarbeiterID: integer;
  Color: string;
  countTankgutscheine, countLidlgutscheine: integer;
begin
  countTankgutscheine := 0;
  countLidlgutscheine := 0;


//Hier nur das was einmal für alle Seiten geladen werden muss (HtmlHeader, HtmlFooter)
  stlTemp := nil;
  try
    stlTemp := TStringList.Create;

    //HEADER
    resHtmlHeader := TResourceStream.Create(HInstance, 'GutscheinHeader', 'TXT');
    stlHtmlHeader := TStringList.Create;
    try
      stlHtmlHeader.LoadFromStream(resHtmlHeader);

      stlHtmlHeader.Text := StringReplace(stlHtmlHeader.Text, '[OBJEKTNAMEORT]', OBJEKTNAME + ' ' + OBJEKTORT, [rfReplaceAll]);
      stlHtmlHeader.Text := StringReplace(stlHtmlHeader.Text, '[QUARTAL]', quartal, [rfReplaceAll]);
      stlHtmlHeader.Text := StringReplace(stlHtmlHeader.Text, '[JAHR]', IntToStr(jahr), [rfReplaceAll]);
      stltemp.Add(stlHtmlHeader.Text);
    finally
      stlHtmlHeader.Free;
      resHtmlHeader.Free;
    end;



    for a := 0 to lvWachschiessen.Items.Count-1 do
    begin
      mitarbeiterID := StrToInt(lvWachschiessen.Items[a].Caption);
      mitarbeiter   := lvWachschiessen.Items[a].SubItems[0] + ' ' + lvWachschiessen.Items[a].SubItems[1];
      datum         := lvWachschiessen.Items[a].SubItems[cbQuartal.ItemIndex+1];

     // if(showGutscheinartByMitarbeterID(MitarbeiterID) <> '') then
        gutscheinart  := showGutscheinartByMitarbeterID(MitarbeiterID);

      resContent := TResourceStream.Create(HInstance, 'GutscheinContent', 'TXT');
      stlContent := TStringList.Create;
      try
        stlContent.LoadFromStream(resContent);
        stlContent.Text := StringReplace(stlContent.Text, '[MITARBEITER]', mitarbeiter, [rfReplaceAll]);
        stlContent.Text := StringReplace(stlContent.Text, '[DATUM]', datum, [rfReplaceAll]);
        stlContent.Text := StringReplace(stlContent.Text, '[GUTSCHEINART]', gutscheinart, [rfReplaceAll]);

        if(gutscheinart = 'Tankgutschein') then
        begin
          inc(countTankgutscheine);
          Color := ' style="background-color:#ebebeb;"';
        end
        else
        begin
          inc(countLidlgutscheine);
          Color := '';
        end;
        stlContent.Text := StringReplace(stlContent.Text, '[COLOR]', Color, [rfReplaceAll]);

        stltemp.Add(stlContent.Text);
      finally
        resContent.Free;
        stlContent.Free;
      end;
    end;
//CONTENT ENDE


//FOOTER
    resHtmlFooter := TResourceStream.Create(HInstance, 'GutscheinFooter', 'TXT');
    stlHtmlFooter := TStringList.Create;
    try
      stlHtmlFooter.LoadFromStream(resHtmlFooter);

      stlHtmlFooter.Text := StringReplace(stlHtmlFooter.Text, '[ANTRAGSDATUM]', DateToStr(Now), [rfReplaceAll]);
      stlHtmlFooter.Text := StringReplace(stlHtmlFooter.Text, '[COUNTTANKGUTSCHEIN]', IntToStr(countTankgutscheine), [rfReplaceAll]);
      stlHtmlFooter.Text := StringReplace(stlHtmlFooter.Text, '[COUNTLIDLGUTSCHEIN]', IntToStr(countLidlgutscheine), [rfReplaceAll]);

      stltemp.Add(stlHtmlFooter.Text);
    finally
      stlHtmlFooter.Free;
      resHtmlFooter.Free;
    end;


  //Alle Umlaute in der StringList ersetzen durch html code
    for i := 0 to stlTemp.Count - 1 do
    begin
      stlTemp[i] := ReplaceUmlauteWithHtmlEntities(stlTemp[i]);
    end;


    //Dateiname für zu speichernde Datei erzeugen
    filename := 'Tankgutscheinantrag '+ quartal+' '+IntToStr(jahr)+' '+OBJEKTNAME+' '+OBJEKTORT;

    //Aus Resource-Datei temporäre Html-Datei und daraus eine PDF-Datei im TEMP Verzeichnis erzeugen
    CreateHtmlAndPdfFileFromResource(filename, stlTemp, 'print_portrait.bat');

    //PDF Datei aus Temp Verzeichnis im Zielverzeichnis speichern
    SpeicherePDFDatei(filename, SAVEPATH_WachschiessenGutscheinAntrag);
  finally
    stlTemp.Free;
  end;
end;










procedure TFrameWachschiessen.lvWachschiessenClick(Sender: TObject);
var
  m, i: Integer;
begin
  i := lvWachschiessen.ItemIndex;
  if(i <> -1) then
  begin
    btnNewEntry.Enabled := true;

    for m := 0 to cbStammpersonal.Items.Count - 1 do
    begin
      if Integer(cbStammpersonal.Items.Objects[m]) = StrToInt(lvWachschiessen.Items[i].Caption) then
      begin
        SELENTRYID := StrToInt(lvWachschiessen.Items[i].Caption);
        cbStammpersonal.ItemIndex := m;
        Exit;
      end;
    end;
  end;
end;






procedure TFrameWachschiessen.lvWachschiessenColumnClick(Sender: TObject; Column: TListColumn);
begin
  lvColumnClickForSort(Sender, Column);
end;







procedure TFrameWachschiessen.lvWachschiessenCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  lvCompareForSort(Sender, Item1, Item2, Data, Compare);
end;







procedure TFrameWachschiessen.lvWachschiessenRightClickCell(Sender: TObject; iItem, iSubItem: Integer);
var
  FDQuery: TFDQuery;
  Datum: string;
  i, spalte, MitarbeiterID: integer;
begin
  i := lvWachschiessen.ItemIndex;
  spalte := iSubItem - 1;

  if spalte > 1 then
  begin
    if(lvWachschiessen.Items[i].SubItems[spalte] <> '-----') then
    begin
      if MessageDlg('Wollen Sie das Datum "' + lvWachschiessen.Items[i].SubItems[spalte] + '" wirklich entfernen?',
                    mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
      begin
        MitarbeiterID := StrToInt(lvWachschiessen.Items[i].Caption);
        Datum := ConvertGermanDateToSQLDate(lvWachschiessen.Items[i].SubItems[spalte], false);

        FDQuery := TFDQuery.Create(nil);
        try
          fMain.FDConnection1.StartTransaction;

          with FDQuery do
          begin
            Connection := fMain.FDConnection1;

            SQL.Text :=
              'DELETE FROM ausbildung ' +
              'WHERE mitarbeiterID = :MITARBEITERID ' +
              'AND datum = :DATUM ' +
              'AND ausbildungsartID IN (1, 4);';

            ParamByName('MITARBEITERID').AsInteger := MitarbeiterID;
            ParamByName('DATUM').AsString := Datum;

            ExecSQL;
          end;

          fMain.FDConnection1.Commit;
          cbQuartalSelect(nil);
        except
          on E: Exception do
          begin
            fMain.FDConnection1.Rollback;
            ShowMessage('Fehler beim Löschen aus der Tabelle "ausbildung": ' + E.Message);
            Exit;
          end;
        end;

        FDQuery.Free;

        cbJahrSelect(Self);
        SelectMitarbeiterInListView(lvWachschiessen, MitarbeiterID);
        lvWachschiessenClick(Self);
      end;
    end;
  end;
end;











procedure TFrameWachschiessen.sbWeiterClick(Sender: TObject);
begin
  DisplayHinweisString;
end;







procedure TFrameWachschiessen.cbStammpersonalSelect(Sender: TObject);
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
      InsertMitarbeiterInListView(lvWachschiessen, MitarbeiterID, SelYear); //id des Mitarbeiters aus der ComboBox übergeben
      SelectMitarbeiterInListView(lvWachschiessen, MitarbeiterID);
    end;

    cbStammpersonal.ItemIndex := -1;
    dtpDatum.SetFocus;
  end
  else
  begin
    showmessage('Bitte wählen Sie einen Mitarbeiter aus der Auswahlbox aus.');
  end;
end;










procedure TFrameWachschiessen.generatePrintableWachschiessenJahresansicht(jahr: integer);
var
  stltemp: TStringList;
  SEITE, i, a, lvCount, ANZAHLSEITEN: integer;
  StartIndex: integer;
  EndIndex: integer;
  filename: string;
  stlHtmlHeader, stlHtmlFooter, stlSiteHeader, stlSiteFooter, stlContent: TStringList;
  resHtmlHeader, resHtmlFooter, resSiteHeader, resSiteFooter, resContent: TResourceStream;
  nachname, vorname, datumq1, datumq2, datumq3, datumq4: String;
  ZEILEN: integer;
begin
  jahr      := StrToInt(cbJahr.Text);
  ZEILEN    := 15; //Anzahl der Tabellen-Zeilen pro Seite

  lvCount := lvWachschiessen.Items.Count;

  if lvCount > ZEILEN then ANZAHLSEITEN := (lvCount + ZEILEN - 1) div ZEILEN else ANZAHLSEITEN := 1;

//Hier nur das was einmal für alle Seiten geladen werden muss (HtmlHeader, HtmlFooter)
  stlTemp := TStringList.Create;
  try

    resHtmlHeader := TResourceStream.Create(HInstance, 'Wachschiessen_HTML_Header', 'TXT');
    resHtmlFooter := TResourceStream.Create(HInstance, 'Wachschiessen_HTML_Footer', 'TXT');

    stlHtmlHeader := TStringList.Create;
    stlHtmlHeader.LoadFromStream(resHtmlHeader);

    stlHtmlFooter := TStringList.Create;
    stlHtmlFooter.LoadFromStream(resHtmlFooter);




//Hier alles was mehrmals geladen werden muss (für jede Seite - SiteHeader, SiteFooter, Content)

    for SEITE := 0 to ANZAHLSEITEN - 1 do
    begin

//SITEHEADER START
      resSiteHeader := TResourceStream.Create(HInstance, 'Wachschiessen_SITE_Header', 'TXT');
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
        nachname:= lvWachschiessen.Items[a].SubItems[0];
        vorname := lvWachschiessen.Items[a].SubItems[1];
        datumq1 := lvWachschiessen.Items[a].SubItems[2];
        datumq2 := lvWachschiessen.Items[a].SubItems[3];
        datumq3 := lvWachschiessen.Items[a].SubItems[4];
        datumq4 := lvWachschiessen.Items[a].SubItems[5];


//Resource WaffenbestandContent auslesen und in Stringlist laden
        resContent := TResourceStream.Create(HInstance, 'Wachschiessen_SITE_Content', 'TXT');
        stlContent := TStringList.Create;
        try
          stlContent.LoadFromStream(resContent);
          stlContent.Text := StringReplace(stlContent.Text, '[NACHNAME]', nachname, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[VORNAME]', vorname, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[DATUMQ1]', datumq1, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[DATUMQ2]', datumq2, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[DATUMQ3]', datumq3, [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[DATUMQ4]', datumq4, [rfReplaceAll]);
          stltemp.Add(stlContent.Text);
        finally
          resContent.Free;
          stlContent.Free;
        end;
      end;


//Wenn auf der letzten Seite weniger als WAFFENPROSEITE vorhanden sind. leere Zeilen einfügen
//damit das Formular immer gleich groß ist
//Überprüfen, ob weniger als WAFFENPROSEITE Einträge vorhanden sind
    if (SEITE = ANZAHLSEITEN - 1) and (EndIndex - StartIndex < ZEILEN - 1) then
    begin
      for a := EndIndex + 1 to (SEITE + 1) * ZEILEN - 1 do
      begin
        resContent := TResourceStream.Create(HInstance, 'Wachschiessen_SITE_Content', 'TXT');
        stlContent := TStringList.Create;
        try
          stlContent.LoadFromStream(resContent);
          stlContent.Text := StringReplace(stlContent.Text, '[NACHNAME]', '&nbsp;', [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[VORNAME]', '&nbsp;', [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[DATUMQ1]', '&nbsp;', [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[DATUMQ2]', '&nbsp;', [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[DATUMQ3]', '&nbsp;', [rfReplaceAll]);
          stlContent.Text := StringReplace(stlContent.Text, '[DATUMQ4]', '&nbsp;', [rfReplaceAll]);
          stltemp.Add(stlContent.Text);
        finally
          resContent.Free;
          stlContent.Free;
        end;
      end;
    end;
//CONTENT ENDE


//SITEFOOTER START
      resSiteFooter := TResourceStream.Create(HInstance, 'Wachschiessen_SITE_Footer', 'TXT');
      stlSiteFooter := TStringList.Create;
      try
        stlSiteFooter.LoadFromStream(resSiteFooter);
        stltemp.Add(stlSiteFooter.Text);
      finally
        resSiteFooter.Free;
        stlSiteFooter.Free;
      end;
//SITEFOOTER ENDE
    end; //for SEITE := 0 to ANZAHLSEITEN - 1 do


    stlTemp.Text := stlHtmlHeader.Text + stlTemp.Text + stlHtmlFooter.Text;

  //Alle Umlaute in der StringList ersetzen durch html code
    for i := 0 to stlTemp.Count - 1 do
    begin
      stlTemp[i] := ReplaceUmlauteWithHtmlEntities(stlTemp[i]);
    end;


    //Seiten als Html-Datei speichern
    if(cbQuartal.ItemIndex = 0) then
    begin
      //Dateiname für zu speichernde Datei erzeugen
      filename := 'Wachschiessen Jahresansicht '+ IntToStr(jahr)+' '+OBJEKTNAME+' '+OBJEKTORT;

      //Aus Resource-Datei temporäre Html-Datei und daraus eine PDF-Datei im TEMP Verzeichnis erzeugen
      CreateHtmlAndPdfFileFromResource(filename, stlTemp);

      //PDF Datei aus Temp Verzeichnis im Zielverzeichnis speichern
      SpeicherePDFDatei(filename, SAVEPATH_WachschiessenJahr);
    end
    else
    begin
      //Dateiname für zu speichernde Datei erzeugen
      filename := 'Wachschiessen Quartal '+ IntToStr(cbQuartal.ItemIndex)+' '+IntToStr(jahr)+' '+OBJEKTNAME+' '+OBJEKTORT;

      //Aus Resource-Datei temporäre Html-Datei und daraus eine PDF-Datei im TEMP Verzeichnis erzeugen
      CreateHtmlAndPdfFileFromResource(filename, stlTemp);

      //PDF Datei aus Temp Verzeichnis im Zielverzeichnis speichern
      SpeicherePDFDatei(filename, SAVEPATH_WachschiessenQuartal);
    end;
  finally
    stlTemp.Free;
  end;
end;













procedure TFrameWachschiessen.DisplayHinweisString;
begin
  case currentIndex of
    1: lbHinweis.Caption := s1;
    2: lbHinweis.Caption := s2;
  end;

  // Inkrementiere den Index und setze ihn zurück auf 1, wenn er 4 erreicht
  currentIndex := currentIndex mod 2 + 1;
end;





procedure TFrameWachschiessen.showAusbildungInListView(LV: TListView; ausbildungsart, jahr: Integer);
var
  datumList: TStringList;
  L: TListItem;
  q: TFDQuery;
  i, Quartal: Integer;
  Datum: TDate;
  QuartalSpalten: array[1..4] of String; // Speichert die Datumswerte für jedes Quartal
begin
  ClearListView(LV);

  q := TFDQuery.Create(nil);
  datumList := TStringList.Create;
  try
    with q do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT M.id, M.nachname, M.vorname, ' +
                  'GROUP_CONCAT(strftime("%d.%m.%Y", A.datum), ", ") AS Ausbildung ' +
                  'FROM mitarbeiter AS M ' +
                  'INNER JOIN ausbildung AS A ON M.id = A.mitarbeiterid ' +
                  'AND A.objektid = :OBJEKTID ' +
                  'WHERE A.ausbildungsartID = :AUSBILDUNGSARTID ' +
                  'AND (M.objektid = :OBJEKTID OR M.objektid != :OBJEKTID) ' +
                  'AND (M.austrittsdatum IS NULL OR M.austrittsdatum = "" OR strftime("%Y", M.austrittsdatum) >= :JAHR) ' +
                  'AND strftime("%Y", A.datum) = :JAHR ' +
                  'GROUP BY M.id, M.nachname ' +
                  'ORDER BY CASE WHEN M.objektid = 1 THEN 0 ELSE 1 END, M.nachname;';

      Params.ParamByName('JAHR').AsString := IntToStr(selYear);
      Params.ParamByName('OBJEKTID').AsInteger := objektID;
      Params.ParamByName('AUSBILDUNGSARTID').AsInteger := Ausbildungsart;

      Open;

      while not Eof do
      begin
        datumList.CommaText := FieldByName('Ausbildung').AsString;

        // Sortiere die DatumList mit benutzerdefinierter Funktion
        SortDateList(datumList);

        // Initialisiere die Quartalsspalten mit dem String '-----'
        for i := 1 to 4 do
          QuartalSpalten[i] := '-----';

        // Jedes Datum prüfen und in die richtige Quartalsspalte einfügen
        for i := 0 to datumList.Count - 1 do
        begin
          Datum := StrToDate(datumList[i]);

          // Bestimme das Quartal für das aktuelle Datum
          Quartal := (MonthOf(Datum) - 1) div 3 + 1;

          // Speichere das Datum im entsprechenden Quartal
          QuartalSpalten[Quartal] := datumList[i];
        end;

        // Erstelle einen neuen ListView-Eintrag
        L := LV.Items.Add;
        L.Caption := FieldByName('id').AsString;
        L.SubItems.Add(FieldByName('nachname').AsString);
        L.SubItems.Add(FieldByName('vorname').AsString);

        // Füge die Datumswerte oder '-----' für die Quartale in die ListView ein
        for Quartal := 1 to 4 do
          L.SubItems.Add(QuartalSpalten[Quartal]);

        Next;
      end;
    end;
  finally
    datumList.Free;
    q.Free;
  end;
end;






procedure TFrameWachschiessen.showQuartalsAusbildungInListView(LV: TListView; ausbildungsart, quartal, jahr: Integer);
var
  datumList: TStringList;
  L: TListItem;
  q: TFDQuery;
  i: Integer;
  Datum: TDate;
  QuartalSpalten: array[1..4] of String; // Speichert die Datumswerte für jedes Quartal
begin
  ClearListView(LV);

  q := TFDQuery.Create(nil);
  datumList := TStringList.Create;
  try
    with q do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT M.id, M.nachname, M.vorname, ' +
            'GROUP_CONCAT(strftime("%d.%m.%Y", A.datum), ", ") AS Ausbildung ' +
            'FROM mitarbeiter AS M ' +
            'INNER JOIN ausbildung AS A ON M.id = A.mitarbeiterid ' +
            'AND A.objektid = :OBJEKTID ' +
            'WHERE A.ausbildungsartID = :AUSBILDUNGSARTID ' +
            'AND (M.objektid = :OBJEKTID OR M.objektid != :OBJEKTID) ' +
            'AND (M.austrittsdatum IS NULL OR M.austrittsdatum = "" OR strftime("%Y", M.austrittsdatum) >= :JAHR) ' +
            'AND strftime("%Y", A.datum) = :JAHR ' +
            'AND ((:QUARTAL = 1 AND strftime("%m", A.datum) BETWEEN "01" AND "03") ' +
            'OR (:QUARTAL = 2 AND strftime("%m", A.datum) BETWEEN "04" AND "06") ' +
            'OR (:QUARTAL = 3 AND strftime("%m", A.datum) BETWEEN "07" AND "09") ' +
            'OR (:QUARTAL = 4 AND strftime("%m", A.datum) BETWEEN "10" AND "12")) ' +
            'GROUP BY M.id, M.nachname ' +
            'ORDER BY CASE WHEN M.objektid = 1 THEN 0 ELSE 1 END, M.nachname;';

            Params.ParamByName('JAHR').AsString := IntToStr(selYear);
            Params.ParamByName('OBJEKTID').AsInteger := objektID;
            Params.ParamByName('AUSBILDUNGSARTID').AsInteger := Ausbildungsart;
            Params.ParamByName('QUARTAL').AsInteger := Quartal;  // Variable Quartal (1, 2, 3 oder 4)


      Open;

      while not Eof do
      begin
        datumList.CommaText := FieldByName('Ausbildung').AsString;

        // Sortiere die DatumList mit benutzerdefinierter Funktion
        SortDateList(datumList);

        // Initialisiere die Quartalsspalten mit dem String '-----'
        for i := 1 to 4 do
          QuartalSpalten[i] := '-----';

        // Jedes Datum prüfen und in die richtige Quartalsspalte einfügen
        for i := 0 to datumList.Count - 1 do
        begin
          Datum := StrToDate(datumList[i]);

          // Bestimme das Quartal für das aktuelle Datum
          Quartal := (MonthOf(Datum) - 1) div 3 + 1;

          // Speichere das Datum im entsprechenden Quartal
          QuartalSpalten[Quartal] := datumList[i];
        end;

        // Erstelle einen neuen ListView-Eintrag
        L := LV.Items.Add;
        L.Caption := FieldByName('id').AsString;
        L.SubItems.Add(FieldByName('nachname').AsString);
        L.SubItems.Add(FieldByName('vorname').AsString);

        // Füge die Datumswerte oder '-----' für die Quartale in die ListView ein
        for Quartal := 1 to 4 do
          L.SubItems.Add(QuartalSpalten[Quartal]);

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
procedure TFrameWachschiessen.SortDateList(StringList: TStringList);
begin
  StringList.CustomSort(@DateCompare);
end;






procedure TFrameWachschiessen.InsertMitarbeiterInListView(lv: TListView; MitarbeiterID, jahr: integer);
var
  FDQuery: TFDQuery;
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
                  'AND strftime("%Y", datum) = :JAHR;';

      Params.ParamByName('MITARBEITERID').AsInteger := MitarbeiterID; // ID aus ComboBox
      Params.ParamByName('JAHR').AsString := IntToStr(jahr);
      Params.ParamByName('AUSBILDUNGSARTID').AsInteger := 4;

      Open;




//Mitarbeiter steht noch nicht in einer der Tabellen "ausbildung_theorie", "ausbildung_szenario" oder "ausbildung_waffenhandhabung"
      if(RecordCount = 0) then
      begin

//Mitarbeiterdaten aus den Tabellen "ausbildung_theorie", "ausbildung_szenario" oder "ausbildung_waffenhandhabung" auslesen
        SQL.Text := 'SELECT id, nachname, vorname FROM mitarbeiter WHERE id = :MITARBEITERID;';
        Params.ParamByName('MITARBEITERID').AsInteger := MitarbeiterID;
        Open;


//Mitarbeiter in ListView eintragen
        if(MitarbeiterID > 0) then
        begin
          l := LV.Items.Add;
          l.Caption := IntToStr(MitarbeiterID);  //MitarbeiterID
          l.SubItems.Add(FieldByName('nachname').AsString);
          l.SubItems.Add(FieldByName('vorname').AsString);
        end;
      end
      else
      begin
        SelectMitarbeiterInListView(lvWachschiessen, MitarbeiterID);
      end;
    end;
  finally
    FDQuery.free;
  end;
end;


end.
