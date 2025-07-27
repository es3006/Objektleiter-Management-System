unit uFunktionen;

interface

uses
  Winapi.Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, Menus,
  StdCtrls, ComCtrls, inifiles, ExtCtrls, DateUtils, ShellApi, FileCtrl,
  IdMessage, IdSMTP, IdSSL, IdAttachment, IdText, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase, IdMessageClient,
  IdSMTPBase, IdServerIOHandler, idAttachmentFile, IdAttachmentMemory,
  System.UITypes, CryptBase, AESObj, MMSystem, IdHTTP, IdSSLOpenSSL, IdSSLOpenSSLHeaders,
  System.IOUtils;


procedure CreateDirectoriesAndExtractFilesFromRes;
//procedure SpeicherePDFDatei(const TempDateiPfad, ZielVerzeichnis, VorgeschlagenerName: string);
procedure SpeicherePDFDatei(filename, ZielVerzeichnis: string);
procedure SucheMitarbeiterUndAnzeigen(cb: TComboBox; gesuchterName: string);
procedure ClearListView(LV: TListView);
procedure SearchAndHighlight(lv: TListView; suchbegriff: string; const ColumnsToSearch: array of Integer);
procedure lvColumnClickForSort(Sender: TObject; Column: TListColumn);
procedure lvCompareForSort(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
procedure SaveResourceToFile(ResourceName, FileName: string);
procedure ResetEscPressed;
procedure SelectMitarbeiterInListView(lv: TListView; MitarbeiterID: integer);
procedure PlayResourceMP3(ResEntryName, TempFileName: string);

function EntryExistsInListView(lv: TListView; MitarbeiterID: integer): boolean;
function ConvertGermanDateToSQLDate(const GermanDate: string; ShowTime: boolean = false): string;
function ConvertSQLDateToGermanDate(const SQLDate: string; ShowTime: boolean = true; ShortYear: boolean = false): string;
function GetMonatsIndexFromDatum(const datum: string): Integer;
function EscPressed(const Msg:string):Boolean;
function getWeekNumber(_Date: TDateTime): Word;
function GetQuarterForMonth(selectedMonth: Integer): Integer;
function ReplaceUmlauteWithHtmlEntities(const InputString: string): string;
function ReplaceUmlaute(const InputString: string): string;
function DeleteFiles(const AFile: string): boolean;
function IsFileZeroSize(const FileName: string): Boolean;
function GetLastDayOfMonth(AYear, AMonth: Integer): TDateTime;
function GetStartEndOfWeek(Kalenderwoche: Integer; Jahr: Integer): string;
function GetEndOfWeek(Kalenderwoche: Integer; Jahr: Integer): string;

function ShortPath(const LongPath: string): string;

procedure CreateHtmlAndPdfFileFromResource(dateiname: string; stl: TStringList; ausrichtung: string = 'print_landscape.bat');

implementation

uses
  uMain, uMitarbeiterNeu, uEinstellungen_Programm;




//Erzeugt aus einer Stringlist eine temporäre Html-Datei und daraus eine PDF Datei.
procedure CreateHtmlAndPdfFileFromResource(dateiname: string; stl: TStringList; ausrichtung: string = 'print_landscape.bat');
var
  MaxWaitTime: Integer;
  WaitInterval: Integer;
  TotalWaitTime: Integer;
  ScriptDatei, HtmlFile, PdfFile: string;
  CommandLine: string;
begin
  dateiname := ReplaceUmlaute(dateiname);

  ScriptDatei := SCRIPTPATH + ausrichtung; //print_portrait.bat oder print_landscape.bat

  HtmlFile    := TEMPPATH + dateiname + '.html';
  PdfFile     := TEMPPATH + dateiname + '.pdf';

  stl.SaveToFile(HTMLFile);  //Formular aus Resource als html-Datei speichern

  CommandLine := Format('"%s" "%s"', [HtmlFile, PdfFile]);

  //PDF aus Html Datei erzeugen
  if ShellExecute(0, 'open', PChar(ScriptDatei), PChar(CommandLine), '', SW_HIDE) <= 32 then
  begin
    ShowMessage('Fehler beim Ausführen des Skripts zum erzeugen des PDF Formulars.');
  end;

  // Warten bis die Datei existiert (mit einem maximalen Timeout)
  MaxWaitTime   := 10000;  // Maximum Wartezeit in Millisekunden (z.B. 10 Sekunden = 10000)
  WaitInterval  := 1000;   // Warteintervall in Millisekunden (z.B. 500 ms)
  TotalWaitTime := 0;

  while not FileExists(PdfFile) do
  begin
    Sleep(WaitInterval);
    TotalWaitTime := TotalWaitTime + WaitInterval;
    if TotalWaitTime >= MaxWaitTime then
    begin
      ShowMessage('Fehler: Das erzeugen der PDF-Datei hat zu lang gedauert.');
      Exit;  // Beenden, wenn die Datei nicht innerhalb der MaxWaitTime erstellt wurde.
    end;
  end;
end;



function ShortPath(const LongPath: string): string;
var
  Buffer: array[0..MAX_PATH] of Char;
begin
  if GetShortPathName(PChar(LongPath), Buffer, MAX_PATH) > 0 then
    Result := string(Buffer)
  else
    Result := LongPath; // Fallback: gib Original zurück, falls Umwandlung fehlschlägt
end;



//Eine PDF Datei am angegebenen Ort speichern
procedure SpeicherePDFDatei(filename, ZielVerzeichnis: string);
var
  SaveDialog: TSaveDialog;
  tempfile, pdffile: string;
begin
  filename := ReplaceUmlaute(filename); //Ohne Pfad und Erweiterung

  if not FileExists(TEMPPATH + filename + '.pdf') then
  begin
    ShowMessage('Die temporäre Datei wurde nicht gefunden:' + sLineBreak + filename);
    Exit;
  end;

  if not DirectoryExists(ZielVerzeichnis) then
  begin
    if MessageDlg('Bitte geben Sie in den Einstellungen den Pfad an, unter dem Sie die Datei ' + filename + ' abspeichern wollen!'+sLineBreak+sLineBreak+'Wollen Sie den Pfad jetzt angeben?', mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
    begin
      fEinstellungen_Programm.Show;
      exit;
    end
    else
    begin
      exit;
    end;
  end;

  SaveDialog := TSaveDialog.Create(nil);
  try
    SaveDialog.DefaultExt := 'pdf';
    SaveDialog.Filter     := 'PDF-Dateien (*.pdf)|*.pdf';
    SaveDialog.InitialDir := IncludeTrailingPathDelimiter(ZielVerzeichnis);
    SaveDialog.FileName   := ReplaceUmlaute(filename) + '.pdf';

    if SaveDialog.Execute then
    begin
      try
        TFile.Copy(TEMPPATH + filename + '.pdf', SaveDialog.FileName, True); // True: Ziel überschreiben
        ShowMessage('Datei erfolgreich gespeichert unter:' + sLineBreak + SaveDialog.FileName);
      except
        on E: Exception do
          ShowMessage('Fehler beim Speichern der Datei:' + sLineBreak + E.Message);
      end;
    end;
  finally
    SaveDialog.Free;
  end;
end;







procedure CreateDirectoriesAndExtractFilesFromRes;
begin
  if not SysUtils.DirectoryExists('TEMP') then
  begin
    CreateDirectory(PChar('TEMP'), nil);
  end;

  if not SysUtils.DirectoryExists('DBDUMPS') then
  begin
    CreateDirectory(PChar('DBDUMPS'), nil);
  end;

  if not SysUtils.FileExists('WebView2Loader_x64.dll') then
  begin
    SaveResourceToFile('WEBVIEWLOADER', 'WebView2Loader_x64.dll');
  end;

  if not SysUtils.DirectoryExists('SCRIPTS') then
  begin
    CreateDirectory(PChar('SCRIPTS'), nil);
  end;

  if not FileExists('print_landscape.bat') then
  begin
    SaveResourceToFile('landscape', 'SCRIPTS\print_landscape.bat');
  end;


  if not FileExists('print_portrait.bat') then
  begin
    SaveResourceToFile('portrait', 'SCRIPTS\print_portrait.bat');
  end;


  if not FileExists('printHtmlAsPDF.bat') then
  begin
    SaveResourceToFile('html2pdf', 'SCRIPTS\printHtmlAsPDF.bat');
  end;

  if not FileExists('wkhtmltopdf.exe') then
  begin
    SaveResourceToFile('wkhtmltopdfexe', 'SCRIPTS\wkhtmltopdf.exe');
  end;

  if not FileExists('wkhtmltox.dll') then
  begin
    SaveResourceToFile('wkhtmltoxdll', 'SCRIPTS\wkhtmltox.dll');
  end;
end;






function IsFileZeroSize(const FileName: string): Boolean;
var
  FileInfo: TSearchRec;
begin
  Result := False;
  if FindFirst(FileName, faAnyFile, FileInfo) = 0 then
  try
    Result := FileInfo.Size = 0;
  finally
    FindClose(FileInfo);
  end;
end;





function GetLastDayOfMonth(AYear, AMonth: Integer): TDateTime;
var
  FirstDayNextMonth: TDateTime;
begin
  // Berechne den ersten Tag des nächsten Monats
  if AMonth = 12 then
    FirstDayNextMonth := EncodeDate(AYear + 1, 1, 1)
  else
    FirstDayNextMonth := EncodeDate(AYear, AMonth + 1, 1);

  // Einen Tag davon abziehen, um den letzten Tag des angegebenen Monats zu erhalten
  Result := FirstDayNextMonth - 1;
end;





function GetMonatsIndexFromDatum(const datum: string): Integer;
var
  dt: TDateTime;
begin
  // Konvertieren des Datums von String zu TDateTime
  dt := StrToDate(datum); // Vorausgesetzt, das Datum ist im Format 'YYYY-MM-DD' oder 'DD.MM.YYYY'

  // Rückgabe des Monatsindex
  Result := MonthOf(dt);
end;







function GetStartEndOfWeek(Kalenderwoche: Integer; Jahr: Integer): string;
var
  StartDatum, EndDatum: TDateTime;
  ErsteKW: TDateTime;
begin
  // 4. Januar ist immer in KW1 laut ISO 8601
  ErsteKW := StartOfTheWeek(EncodeDate(Jahr, 1, 4));

  // Berechne den Wochenanfang (Montag) der gewünschten Kalenderwoche
  StartDatum := IncWeek(ErsteKW, Kalenderwoche - 1);

  // Sonntag ist 6 Tage später
  EndDatum := StartDatum + 6;

  Result := Format('%s - %s', [FormatDateTime('dd.mm.yyyy', StartDatum), FormatDateTime('dd.mm.yyyy', EndDatum)]);
end;







function GetEndOfWeek(Kalenderwoche: Integer; Jahr: Integer): string;
var
  StartOfYear, StartDatum, EndDatum: TDateTime;
  DaysToAdd: Integer;
begin
  // Erster Tag des Jahres
  StartOfYear := EncodeDate(Jahr, 1, 1);

  // Bestimme den ersten Montag des Jahres
  StartDatum := StartOfYear;

  while DayOfWeek(StartDatum) <> 2 do // 2 entspricht Montag
    StartDatum := StartDatum + 1;

  // Berechne den ersten Montag der angegebenen Kalenderwoche
  DaysToAdd := (Kalenderwoche - 1) * 7;
  StartDatum := StartDatum + DaysToAdd;

  // Bestimme das Enddatum (Sonntag) der angegebenen Kalenderwoche
  EndDatum := StartDatum + 6;

  Result := Format('%s', [DateToStr(EndDatum)]);
end;





procedure SucheMitarbeiterUndAnzeigen(cb: TComboBox; gesuchterName: string);
var
  i: Integer;
begin
  if(trim(gesuchterName) <> '') then
  begin
    // Schleife durch die ComboBox-Elemente
    for i := 0 to cb.Items.Count - 1 do
    begin
      if cb.Items[i] = gesuchterName then
      begin
        // Name wurde gefunden, die zugehörige ID abrufen
        //ShowMessage('ID des gefundenen Mitarbeiters ' + gesuchterName + ': ' + IntToStr(Integer(cb.Items.Objects[i])));

        // Den gefundenen Namen in der ComboBox auswählen
        cb.ItemIndex := i;
        Exit; // Die Schleife beenden, nachdem der Name gefunden wurde
      end;
    end;

    // Name wurde nicht gefunden
    if MessageDlg(gesuchterName + ' wurde nicht in der Mitarbeiterliste gefunden.'+#13#10+'Wollen Sie diesen jetzt zur Mitarbeiterliste hinzufügen?',
      mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
    begin
      fMitarbeiterNeu.ShowModal;
    end;
  end;
end;





{************************
  Eine ListView leeren  *
************************}
procedure ClearListView(LV: TListView);
begin
 with LV do
  begin
    Items.BeginUpdate;
    try
      ViewStyle := vsReport;
      Items.Clear;
    finally
      Items.EndUpdate;
    end;
  end;
end;













// Funktion zum Ersetzen von Umlauten durch HTML-Entities
function ReplaceUmlauteWithHtmlEntities(const InputString: string): string;
begin
  // Ersetzen Sie die Umlaute durch die entsprechenden HTML-Entities
  Result := StringReplace(InputString, 'ä', '&auml;', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'Ä', '&Auml;', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'ö', '&ouml;', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'Ö', '&Ouml;', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'ü', '&uuml;', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'Ü', '&Uuml;', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'ß', '&szlig;', [rfReplaceAll, rfIgnoreCase]);
end;


// Funktion zum Ersetzen von Umlauten
function ReplaceUmlaute(const InputString: string): string;
begin
  // Ersetzen Sie die Umlaute durch die entsprechenden HTML-Entities
  Result := StringReplace(InputString, 'ä', 'ae', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'Ä', 'Ae', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'ö', 'oe', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'Ö', 'Oe', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'ü', 'ue', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'Ü', 'Ue', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'ß', 'ss', [rfReplaceAll, rfIgnoreCase]);
end;





function DeleteFiles(const AFile: string): boolean;
var
  sh: SHFileOpStruct;
begin
  ZeroMemory(@sh, SizeOf(sh));
  with sh do
  begin
    Wnd := Application.Handle;
    wFunc := FO_DELETE;
    pFrom := PChar(AFile +#0);
    fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
  end;
  result := SHFileOperation(sh) = 0;
end;







procedure SearchAndHighlight(lv: TListView; suchbegriff: string; const ColumnsToSearch: array of Integer);
var
  Index: Integer;
  FoundFirstEntry: Boolean;
  ColumnIndex: Integer;
  SearchText: string;
  ItemText: string;
begin
  SearchText := LowerCase(suchbegriff);

  if SearchText = '' then
    Exit;

  if lv.Selected <> nil then
    Index := lv.Selected.Index + 1
  else
    Index := 0;

  FoundFirstEntry := False;

  while Index < lv.Items.Count do
  begin
    for ColumnIndex in ColumnsToSearch do
    begin
      if ColumnIndex = 0 then
        ItemText := lv.Items[Index].Caption
      else if (ColumnIndex > 0) and (ColumnIndex <= lv.Items[Index].SubItems.Count) then
        ItemText := lv.Items[Index].SubItems[ColumnIndex - 1]
      else
        Continue;

      if Pos(SearchText, LowerCase(ItemText)) > 0 then
      begin
        lv.Selected := lv.Items[Index];
        lv.Selected.MakeVisible(False);
        lv.Items[Index].MakeVisible(True);
        Exit;
      end;
    end;

    Inc(Index);
  end;

  if not FoundFirstEntry then
  begin
    Index := 0;
    while Index < lv.Items.Count do
    begin
      for ColumnIndex in ColumnsToSearch do
      begin
        if ColumnIndex = 0 then
          ItemText := lv.Items[Index].Caption
        else if (ColumnIndex > 0) and (ColumnIndex <= lv.Items[Index].SubItems.Count) then
          ItemText := lv.Items[Index].SubItems[ColumnIndex - 1]
        else
          Continue;

        if Pos(SearchText, LowerCase(ItemText)) > 0 then
        begin
          lv.Selected := lv.Items[Index];
          lv.Selected.MakeVisible(False);
          lv.Items[Index].MakeVisible(True);
          Exit;
        end;
      end;

      Inc(Index);
    end;
  end;
end;







procedure lvColumnClickForSort(Sender: TObject; Column: TListColumn);
begin
  ColumnToSort := Column.Index;
  if ColumnToSort = LastSorted then
    SortDir := 1 - SortDir
  else
    SortDir := 0;
  LastSorted := ColumnToSort;
  (Sender as TCustomListView).AlphaSort;
end;







procedure lvCompareForSort(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
var
  TempStr, TextToSort1, TextToSort2: String;
begin
//Texte zuweisen
  if ColumnToSort = 0 then
  begin
    TextToSort1 := Item1.Caption;
    TextToSort2 := Item2.Caption;
  end //if ColumnToSort = 0 then
  else
  begin
    TextToSort1 := Item1.SubItems[ColumnToSort - 1];
    TextToSort2 := Item2.SubItems[ColumnToSort - 1];
  end; //if ColumnToSort <> 0 then

//Je nach Sortierrichtung evtl. Texte vertauschen
  if SortDir <> 0 then
  begin
    TempStr := TextToSort1;
    TextToSort1 := TextToSort2;
    TextToSort2 := TempStr;
  end; //if SortDir <> 0 then

//Texte je nach Tag der Spalte unterschiedlich vergleichen
  case (Sender as TListView).Columns[ColumnToSort].Tag of
//Integer-Werte
    1: Compare := StrToIntDef(TextToSort1,0)-StrToIntDef(TextToSort2,0);
//Float-Werte
    2: begin
      Compare := 0;
      if StrToFloat(TextToSort1) > StrToFloat(TextToSort2) then
        Compare := Trunc(StrToFloat(TextToSort1)-StrToFloat(TextToSort2))+1;
      if StrToFloat(TextToSort1) < StrToFloat(TextToSort2) then
        Compare := Trunc(StrToFloat(TextToSort1)-StrToFloat(TextToSort2))-1;
    end; //2
//DateTime-Werte
    3: begin
      Compare := 0;
      if StrToDateTime(TextToSort1) > StrToDateTime(TextToSort2) then
        Compare := Trunc(StrToDateTime(TextToSort1)-StrToDateTime(TextToSort2))+1;
      if StrToDateTime(TextToSort1) < StrToDateTime(TextToSort2) then
        Compare := Trunc(StrToDateTime(TextToSort1)-StrToDateTime(TextToSort2))-1;
    end; //3
//Alles andere sind Strings
    else
      Compare := CompareText(TextToSort1,TextToSort2);
  end; //case (Sender as TListView).Columns[ColumnToSort].Tag of
end;







Function getWeekNumber(_Date: TDateTime): Word;
// Zunächst wird die KW des 1.1 des Jahres ermittelt.
// Sind in der ersten KW des Jahres mehr als drei Tage,
// dann ist dies die KW 1, sonst die KW '0' bzw.
// die KW des 31.12. des vorherigen Jahres.
Var
  MondayOfKW1,
    FirstOfJanuary: TDateTime;
  Dow, KW, y, m, d: Word;

Begin
  DecodeDate(_Date, y, m, d);
  FirstOfJanuary := EncodeDate(Y, 1, 1);
  Dow := SysUtils.DayOfWeek(FirstOfJanuary);

  // Ändere die Berechnung, um die Woche am Montag beginnen zu lassen
  If Dow = 1 Then
    MondayOfKW1 := FirstOfJanuary + 1
  Else
    MondayOfKW1 := FirstOfJanuary - Dow + 2;

  KW := Trunc(_Date - MondayOfKW1) Div 7 + 1;

  If KW < 1 Then
    KW := getWeekNumber(EncodeDate(Y - 1, 12, 31))
  Else If KW = 53 Then
    If SysUtils.DayOfWeek(EncodeDate(Y + 1, 1, 1)) <= 4 Then KW := 1;

  Result := KW;
End;






function GetQuarterForMonth(selectedMonth: Integer): Integer;
begin
  case selectedMonth of
    1, 2, 3:
      Result := 1; // Januar, Februar oder März gehören zum 1. Quartal
    4, 5, 6:
      Result := 2; // April, Mai oder Juni gehören zum 2. Quartal
    7, 8, 9:
      Result := 3; // Juli, August oder September gehören zum 3. Quartal
    10, 11, 12:
      Result := 4; // Oktober, November oder Dezember gehören zum 4. Quartal
  else
    Result := 0; // Ungültiger Monat
  end;
end;














procedure SaveResourceToFile(ResourceName, FileName: string);
var
  ResStream: TResourceStream;
  FileStream: TFileStream;
begin
  ResStream := TResourceStream.Create(HInstance, ResourceName, RT_RCDATA); // RT_RCDATA ist ein gängiger Typ für benutzerdefinierte Ressourcen
  try
    FileStream := TFileStream.Create(FileName, fmCreate);
    try
      FileStream.CopyFrom(ResStream, 0); // Kopiere den Ressourceninhalt in die Datei
    finally
      FileStream.Free;
    end;
  finally
    ResStream.Free;
  end;
end;










// zum vorzeitigen Verlassen einer Schleife mit der ESC Taste
function EscPressed(const Msg:string):Boolean;
begin
  // Aus der WinAPI-Doku zu GetAsyncKeyState:
  // if the function succeeds, the return value specifies whether the key was pressed
  // since the last call to GetAsyncKeyState, and whether the key is currently up or down.
  // If the most significant bit is set, the key is down, and if the least significant bit is set,
  // the key was pressed after the previous call to GetAsyncKeyState.
  // The return value is zero if a window in another thread or process currently has the keyboard focus
  Result := ((GetAsyncKeyState(VK_ESCAPE) and $8001) <> 0) or
    ((GetAsyncKeyState(VK_PAUSE) and $8001) <> 0);

  if Result then
  begin
     Result := (MessageDlg(Msg, mtConfirmation, [mbYes,mbNo], 0) = mrYes);
  end;
end;





// muss vor dem Benutzen von EscPressed() aufgerufen werden
procedure ResetEscPressed;
begin
  GetAsyncKeyState(VK_ESCAPE);
  GetAsyncKeyState(VK_PAUSE);
end;







{
  Aktuelle Version um ein deutsches Dateum im Format DD.MM.YY oder DD.MM.YYYY HH:NN:SS in ein
  SQL-Datum im Format YYYY-MM-DD oder YYYY-MM-DD HH:NN:SS umzuwandeln

  Aufruf mit
  ConvertGermanDateToSQLDate('30.06.1975'); //Nur Datum
  ConvertGermanDateToSQLDate('30.06.1975 10:30:20'); //Datum und Zeit
}
function ConvertGermanDateToSQLDate(const GermanDate: string; ShowTime: boolean = false): string;
var
  DateValue: TDateTime;
  FormatedDate: string;
begin
  if(GermanDate = '') then
  begin
    result := '';
    exit;
  end;

  // Prüfen und Konvertieren des Datumsformats von DD.MM.YYYY HH:NN:SS zu einem TDateTime-Wert
  if TryStrToDateTime(GermanDate, DateValue, FormatSettings) then
  begin
    if(ShowTime = true) then
      FormatedDate := FormatDateTime('yyyy-mm-dd hh:nn', DateValue, FormatSettings)
    else
      FormatedDate := FormatDateTime('yyyy-mm-dd', DateValue, FormatSettings);

    Result := FormatedDate;
  end
  else
  begin
    // Bei Fehler wird ein leerer String zurückgegeben
    Result := '';
    ShowMessage('Ungültiges Datumsformat: ' + GermanDate);
    abort;
  end;
end;







function ConvertSQLDateToGermanDate(const SQLDate: string; ShowTime: boolean = true; ShortYear: boolean = false): string;
var
  DateValue: TDateTime;
  FormattedDate: string;
  FormatSettings: TFormatSettings;
begin
  // Spezifische FormatSettings für die Konvertierung von Datums- und Zeitwerten konfigurieren
  FormatSettings := TFormatSettings.Create;
  FormatSettings.DateSeparator   := '-';
  FormatSettings.TimeSeparator   := ':';
  FormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  FormatSettings.LongTimeFormat  := 'hh:nn:ss';

  if(SQLDate = '') then
  begin
    result := '';
    exit;
  end;
  // Konvertieren des Datumsformats von YYYY-MM-DD HH:NN:SS zu einem TDateTime-Wert
  if TryStrToDateTime(SQLDate, DateValue, FormatSettings) then
  begin
    // Spezifische FormatSettings für die deutsche Schreibweise konfigurieren
    FormatSettings.DateSeparator   := '.';
    FormatSettings.ShortDateFormat := 'dd.mm.yyyy';
    FormatSettings.LongTimeFormat  := 'hh:nn';

    // Das Datum im Format DD.MM.YYYY HH:NN formatiert
    if(ShowTime = true) then
      FormattedDate := FormatDateTime('dd.mm.yyyy hh:nn', DateValue, FormatSettings)
    else
      FormattedDate := FormatDateTime('dd.mm.yyyy', DateValue, FormatSettings);

    // Das Datum im Format DD.MM.YY formatiert
    if(ShortYear = true) then
      FormattedDate := FormatDateTime('dd.mm.yy', DateValue, FormatSettings)
    else
      FormattedDate := FormatDateTime('dd.mm.yyyy', DateValue, FormatSettings);



    Result := FormattedDate;
  end
  else
  begin
    // Bei Fehler wird ein leerer String zurückgegeben
    Result := '';
    ShowMessage('Ungültiges Datumsformat: ' + SQLDate);
    Abort;
  end;
end;









//In ListView Caption nach einem Wert suchen und diesen wenn gefunden markieren
procedure SelectMitarbeiterInListView(lv: TListView; MitarbeiterID: integer);
var
  i: integer;
begin
  for i := 0 to lv.Items.Count - 1 do
  begin
    // Prüfen, ob die Caption des Items dem Suchtext entspricht
    if lv.Items[i].Caption = IntToStr(MitarbeiterID) then
    begin
      // Item markieren
      lv.Selected := lv.Items[i];
      lv.ItemFocused := lv.Items[i];
      // Scrollt zum markierten Item (optional)
      lv.Items[i].MakeVisible(False);
      Exit; // Suche beenden, sobald der Eintrag gefunden wurde
    end;
  end;
end;







//Prüfen ob ein Eintrag in der Caption einer ListView vorhanden ist
function EntryExistsInListView(lv: TListView; MitarbeiterID: integer): boolean;
var
  i: integer;
begin
  result := false;

  for i := 0 to lv.Items.Count - 1 do
  begin
    // Prüfen, ob die Caption des Items dem Suchtext entspricht
    if lv.Items[i].Caption = IntToStr(MitarbeiterID) then
    begin
      result := true;
      Exit; // Suche beenden, sobald der Eintrag gefunden wurde
    end
    else
    begin
      result := false;
    end;
  end;
end;





procedure PlayResourceMP3(ResEntryName, TempFileName: string);
var
  ResStream: TResourceStream;
  MemStream: TMemoryStream;
begin
  // Prüfen, ob die Datei bereits vorhanden ist
  if not FileExists(TempFileName) then
  begin
    // Datei aus der Resource holen und speichern
    ResStream := TResourceStream.Create(HInstance, ResEntryName, RT_RCDATA);
    try
      MemStream := TMemoryStream.Create;
      try
        MemStream.LoadFromStream(ResStream);
        MemStream.SaveToFile(TempFileName);
      finally
        MemStream.Free;
      end;
    finally
      ResStream.Free;
    end;
  end;

  // Datei abspielen
  PlaySound(PChar(TempFileName), 0, SND_FILENAME or SND_ASYNC);
end;







end.
