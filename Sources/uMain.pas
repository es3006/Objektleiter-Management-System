unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, Menus, System.DateUtils,
  StdCtrls, ComCtrls, inifiles, ExtCtrls, ActnList, AdvListV,
  Math, ShellApi, System.UITypes, System.Actions,
  Vcl.Imaging.pngimage, AdvCustomControl, AdvTableView, AdvTypes,
  System.ImageList, Vcl.ImgList,
  Vcl.OleCtrls, SHDocVw, AdvMenus, Vcl.ToolWin, AdvUtils, StrUtils,
  CommCtrl, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.SQLite,
  AdvPageControl, uFrameWochenberichtEdit, uFrameWachpersonal,
  uFrameGesamtausbildung, uFrameWachtest, uFrameWachschiessen, uFrameMunTausch,
  uFrameWaffenbestandsmeldung, uFrameTheorieausbildung, uFrameAusbildung, uFrameErsteHilfe,
  FireDAC.Phys.SQLiteWrapper.Stat, AdvMetroHint;


type
  TFrameClass = class of TFrame;



const
  PROGRAMMNAME = 'Objektleiter_Management';
  PROGRAMMVERSION = '2.1.0.0';
  LASTCHANGEDATE  = '09.08.2025';
  ENCRYPTIONKEY = 'mdklwuje90321iks,2moijlwödmeu3290dnu2i1p,sdim1239';
  WriteErrorsInFile = true;

  PANEL_IDX_ONLINE = 0; //Panel Online in Statusbar Panels[0]
  PANEL_IDX_INFO   = 1; //Panel Info in Statusbar Panels[1]


type
  TfMain = class(TForm)
    MainMenu1: TMainMenu;
    Datei1: TMenuItem;
    Beenden1: TMenuItem;
    StatusBar1: TStatusBar;
    Einstellungen2: TMenuItem;
    Einstellungen3: TMenuItem;
    ToolBar1: TToolBar;
    tbWaffenbestandsliste: TToolButton;
    tbWachpersonal: TToolButton;
    tbGesamtausbildung: TToolButton;
    tbWochenbericht: TToolButton;
    tbWachtestTestSachkunde: TToolButton;
    ImageListToolBar: TImageList;
    tbWachschiessen: TToolButton;
    tbMuntausch: TToolButton;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDConnection1: TFDConnection;
    Bestandsdaten1: TMenuItem;
    Objekte2: TMenuItem;
    Mitarbeiter2: TMenuItem;
    Waffen1: TMenuItem;
    tbAusbildung: TToolButton;
    tbErsteHilfe: TToolButton;
    N2: TMenuItem;
    Datenbank1: TMenuItem;
    Importieren1: TMenuItem;
    Exportieren1: TMenuItem;
    OpenDialog1: TOpenDialog;
    ObjektObjektleiter1: TMenuItem;
    N3: TMenuItem;
    Administratoren1: TMenuItem;
    Diensthunde1: TMenuItem;
    mProgrammeinstellungen: TMenuItem;
    Timer1: TTimer;
    FDSQLiteBackup1: TFDSQLiteBackup;
    N1: TMenuItem;
    N4: TMenuItem;
    AdvMetroHint1: TAdvMetroHint;
    N7: TMenuItem;
    PrfeauffehlendeStammdaten1: TMenuItem;
    PrfeauffehlendeStammdaten2: TMenuItem;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    pnLogedUser: TPanel;
    NachUpdatesuchen1: TMenuItem;
    N5: TMenuItem;
    Hilfe1: TMenuItem;
    Programmhilfe1: TMenuItem;
    Programmbeschreibung1: TMenuItem;
    TimerOnlineOffline: TTimer;
    pnlOnlineStatus: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Einstellungen1Click(Sender: TObject);
    procedure lvMitarbeiterColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvMitarbeiterCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure FormShow(Sender: TObject);
    procedure Beenden1Click(Sender: TObject);
    procedure Einstellungen3Click(Sender: TObject);
    procedure tbWochenberichtClick(Sender: TObject);
    procedure Objekte2Click(Sender: TObject);
    procedure Mitarbeiter2Click(Sender: TObject);
    procedure tbWachpersonalClick(Sender: TObject);
    procedure tbWaffenbestandslisteClick(Sender: TObject);
    procedure tbGesamtausbildungClick(Sender: TObject);
    procedure tbWachtestTestSachkundeClick(Sender: TObject);
    procedure tbWachschiessenClick(Sender: TObject);
    procedure tbMuntauschClick(Sender: TObject);
    procedure tbAusbildungClick(Sender: TObject);
    procedure tbErsteHilfeClick(Sender: TObject);
    procedure Waffen1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Exportieren1Click(Sender: TObject);
    procedure Importieren1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ObjektObjektleiter1Click(Sender: TObject);
    procedure Administratoren1Click(Sender: TObject);
    procedure Diensthunde1Click(Sender: TObject);
    procedure mProgrammeinstellungenClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure PrfeauffehlendeStammdaten2Click(Sender: TObject);
    procedure PrfeauffehlendeStammdaten1Click(Sender: TObject);
    procedure NachUpdatesuchen1Click(Sender: TObject);
    procedure Programmhilfe1Click(Sender: TObject);
    procedure Programmbeschreibung1Click(Sender: TObject);
    procedure TimerOnlineOfflineTimer(Sender: TObject);
    procedure StatusBar1Resize(Sender: TObject);
  private
    procedure PlaceCtrlInStatusBar(AControl: TWinControl; APanelIndex: Integer; AInset: Integer = 2);
    procedure WMPlaceSBChildren(var Msg: TMessage); message WM_APP + $42;
  public
    CurrentFrame: TFrame;
    ColumnToSort, LastSorted, SortDir: Integer;
    procedure LoadFrame(FrameClass: TFrameClass);
    procedure ReadSettingsFromIni;
    procedure BringAppToFront;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;




var
  fMain: TfMain;
  PATH, TEMPPATH, SCRIPTPATH: string;
  ColumnToSort: Integer;
  LastSorted: Integer;
  SortDir: Integer;
  CurrentDate: TDateTime;
  MonthName, Year: string;
  DBPORT: integer;
  DBHOST, DBUSR, DBPW, DBNAME, DBPROT, DBLIBLOC: string;
  IDANGEMELDETEROBJEKTLEITER: integer;
  WACHPERSONALLISTE, WAFFENBESTANDSLISTE, WOCHENBERICHT, GESAMTAUSBILDUNG: string;
  DOKUMENTNAME: string;
  SAVEPATHWOCHENBERICHTE, SAVEPATHWAFFENBESTANDSLISTEN, SAVEPATHWACHPERSONAL,
  SAVEPATHGESAMTAUSBILDUNGMONAT, SAVEPATHGESAMTAUSBILDUNGQUARTAL, SAVEPATHTANKGUTSCHEINE: string;
  SAVEPATHWACHTEST, SAVEPATHWACHSCHIESSEN, SAVEPATHMUNITIONSTAUSCH: string;
  PDFDocumentDirectory, PDFDocumentName: string;
  FIRSTSTART, ENCRYPTDB: boolean;
  GlobalFormatSettings: TFormatSettings;
  NEWWOCHENBERICHT: boolean;
  WOCHENBERICHTID: integer;
  SELECTEDKW: integer;
  SELMONTH, SELYEAR, STARTYEAR: integer;
  BESTANDWACHMUN, BESTANDWACHSCHIESSENMUN, BESTANDMANOEVERMUN, BESTANDVERSCHUSSMENGE: integer;
  WACHMUNKALIBER, WACHSCHIESSENMUNKALIBER, MANOEVERMUNKALIBER, VERSCHUSSMENGEMUNKALIBER: string;
  OBJEKTNAME, OBJEKTORT: string;
  OBJEKTID, OBJEKTLEITERID, STELLVOBJEKTLEITERID, WAFFENBESTAND: integer;
  OLUSERNAME, OBJEKTLEITERNAME, STELLVOBJEKTLEITERNAME, OBJEKTLEITERUSERNAME, WAFFENTYP: string;
  CurrentVersion: string;
  SAVEPATH_Wochenberichte, SAVEPATH_Wachpersonalliste, SAVEPATH_Waffenbestandsmeldungen: string;
  SAVEPATH_AusbildungMonat, SAVEPATH_Ausbildungquartal: string;
  SAVEPATH_WACHTEST, SAVEPATH_WACHSCHIESSENQUARTAL, SAVEPATH_WACHSCHIESSENJAHR: string;
  SAVEPATH_WachschiessenGutscheinAntrag, SAVEPATH_ZuordnungWaffeSchliessfach: string;
  SAVEPATH_Munitionstausch: string;


  WebsiteURL: string;
  ScriptURL: string;
  HilfeURL: string;
  UpdateURL: string;
  ProgrammURL: string;






implementation

uses uFirstStart, uDBSettings, uDBFunktionen, uFunktionen, uWebBrowser, uMitarbeiter,
     uMitarbeiterNeu, uMitarbeiterEdit, uObjekte, uObjekteNeu, uWaffenbestand,
     uEinstellungen_WaffenMunition, uAnmeldung, uEinstellungen_Objekt, uZugangsdaten, uDiensthunde,
     uEinstellungen_Programm, uUpdate, uErrorLog;

{$R *.dfm}
{$R MyResources.RES}



procedure TfMain.PlaceCtrlInStatusBar(AControl: TWinControl; APanelIndex: Integer; AInset: Integer);
var
  R: TRect;
begin
  if (AControl = nil) or (StatusBar1 = nil) then Exit;
  if not StatusBar1.HandleAllocated then Exit;

  // Bei SimplePanel existiert nur Index 0
  if StatusBar1.SimplePanel and (APanelIndex <> 0) then Exit;
  if (not StatusBar1.SimplePanel) and ((APanelIndex < 0) or (APanelIndex >= StatusBar1.Panels.Count)) then Exit;

  // Panel-Rechteck holen (wichtig: LPARAM(@R), nicht Integer(@R)!)
  SendMessage(StatusBar1.Handle, SB_GETRECT, APanelIndex, LPARAM(@R));

  // Control in die Statusbar hängen und exakt in das Panel-Rechteck legen
  AControl.Parent := StatusBar1;
  AControl.Align := alNone;
  AControl.SetBounds(R.Left + AInset, R.Top + AInset,
                     (R.Right - R.Left) - 2*AInset,
                     (R.Bottom - R.Top) - 2*AInset);
  AControl.BringToFront;
  AControl.Visible := True;
end;



procedure TfMain.WMPlaceSBChildren(var Msg: TMessage);
begin
  // Handle sicherstellen (falls noch nicht erzeugt)
  StatusBar1.HandleNeeded;

  // Beide Panels in die gewünschten Statusbar-Panels setzen
  PlaceCtrlInStatusBar(pnlOnlineStatus, PANEL_IDX_ONLINE, 2);
  PlaceCtrlInStatusBar(pnLogedUser,   PANEL_IDX_INFO,   2);
end;





procedure TfMain.ReadSettingsFromIni;
var
  ini: TIniFile;
  LetzterCheck: TDateTime;
  CheckAusweiseStr: string;
begin
  ini := TIniFile.Create(PATH + 'settings.ini');
  try
    SAVEPATH_Wochenberichte := ini.ReadString('PATH','Wochenberichte','');
    SAVEPATH_Wachpersonalliste := ini.ReadString('PATH','Wachpersonalliste','');
    SAVEPATH_Waffenbestandsmeldungen := ini.ReadString('PATH','Waffenbestandsmeldungen','');
    SAVEPATH_AusbildungMonat := ini.ReadString('PATH','AusbildungsunterlagenMonat','');
    SAVEPATH_Ausbildungquartal := ini.ReadString('PATH','AusbildungsunterlagenQuartal','');
    SAVEPATH_WACHTEST := ini.ReadString('PATH','Wachtest','');
    SAVEPATH_WACHSCHIESSENQUARTAL := ini.ReadString('PATH','WachschiessenQuartal','');
    SAVEPATH_WACHSCHIESSENJAHR := ini.ReadString('PATH','WachschiessenJahr','');
    SAVEPATH_WachschiessenGutscheinAntrag := ini.ReadString('PATH','WachschiessenGutscheinAntrag','');
    SAVEPATH_ZuordnungWaffeSchliessfach := ini.ReadString('PATH','ZuordnungWaffenSchliessfach','');
    SAVEPATH_Munitionstausch := ini.ReadString('PATH','Munitionstausch','');

    CheckAusweiseStr := Ini.ReadString('Check', 'CheckAusweisGueltigkeit', '');
    if not TryStrToDate(CheckAusweiseStr, LetzterCheck) then LetzterCheck := 0;

    if (Trunc(LetzterCheck) = 0) or (DaysBetween(Date, Trunc(LetzterCheck)) >= 7) then
    begin
      CheckFehlendeAusweisdaten(OBJEKTID);
      CheckAblaufendeAusweise(OBJEKTID);
      Ini.WriteString('Check', 'CheckAusweisGueltigkeit', DateToStr(Date));
    end;
  finally
    ini.Free;
  end;
end;






procedure TfMain.StatusBar1Resize(Sender: TObject);
begin
  PostMessage(Handle, WM_APP + $42, 0, 0);
end;

procedure TfMain.LoadFrame(FrameClass: TFrameClass);
var
  NewFrame: TFrame;
begin
  // Prüfe, ob es ein aktuelles Frame gibt und gebe es frei
  if Assigned(CurrentFrame) then
  begin
    CurrentFrame.Free;
    CurrentFrame := nil;
  end;

  // Erstelle ein neues Frame der angegebenen Klasse
  NewFrame := FrameClass.Create(Self);
  try
    NewFrame.Parent := fMain;
    NewFrame.Align  := alClient; // Wichtig, damit das Frame nicht automatisch skaliert wird

    //NewFrame.Align := alClient;
    CurrentFrame := NewFrame;
  except
    NewFrame.Free;
    raise;
  end;
end;










procedure TfMain.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle   := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;






procedure TfMain.Diensthunde1Click(Sender: TObject);
begin
  fDiensthunde.ShowModal;
end;

procedure TfMain.Administratoren1Click(Sender: TObject);
begin
  fZugangsdaten.Show;
end;

procedure TfMain.Beenden1Click(Sender: TObject);
begin
  close;
end;




procedure TfMain.Einstellungen1Click(Sender: TObject);
begin
  fDBSettings.show;
end;




procedure TfMain.Einstellungen3Click(Sender: TObject);
begin
  fEinstellungen_WaffenMunition.show;
end;






procedure TfMain.Exportieren1Click(Sender: TObject);
begin
  BackupAllTables;
  ShowMessage('Datenbanktabellen wurden im Verzeichnis "DBDUMPS" gesichert');
end;




procedure TfMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  PlayResourceMP3('WHOOSH', 'TEMP\Whoosh.wav');
end;




procedure TfMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if(FDConnection1.Connected) then FDConnection1.Connected := false; //Verbindung zur Datenbank trennen
  DeleteFiles(PATH+'TEMP\*.*'); //Temp Verzeichnis leeren
end;






procedure TfMain.FormCreate(Sender: TObject);
begin
  pnlOnlineStatus.Visible := False;
  pnLogedUser.Visible   := False;

  Self.Scaled := False;

  CreateDirectoriesAndExtractFilesFromRes;

  PATH             := ExtractFilePath(ParamStr(0));
  TEMPPATH         := ShortPath(PATH + 'TEMP\');
  SCRIPTPATH       := ShortPath(PATH + 'SCRIPTS\');

  DBNAME           := 'esddb.s3db';
  ENCRYPTDB        := false; //im Produktivmodus auf true setzen damit Datenbank verschlüsselt wird
  FIRSTSTART       := false;
  OBJEKTLEITERID   := 0;
  OBJEKTID         := 0;
  OBJEKTLEITERNAME := '';
  STARTYEAR        := 2023;

  fMain.Caption := 'ESD Objektleiter Management Software V' + PROGRAMMVERSION + ' by Enrico Sadlowski 2024';

  CurrentDate      := Now;
  MonthName        := FormatDateTime('mmmm', CurrentDate); //Monatsname in deutscher Schreibweise
  Year             := FormatDateTime('yyyy', CurrentDate); //Jahr

  //Wenn FirstStart abgebrochen wurde und so kein Admin angelegt werden konnte,
  //die Datenbankdatei löschen
  if(FileExists(DBNAME)) then
  begin
    if IsFileZeroSize(DBNAME) then
    begin
      if(FDConnection1.Connected) then FDConnection1.Connected := false;
      DeleteFile(DBNAME);
    end;
  end;



  //Wenn Datenbank noch nicht vorhanden Formular zum anlegen eines neuen Nutzers anzeigen
  if not FileExists(DBNAME) then
  begin
    FIRSTSTART := true;
  end;

  FDConnection1.Connected := False; // Sicherstellen, dass die Verbindung geschlossen ist
  FDConnection1.DriverName := 'SQLite';
  FDConnection1.Params.Values['Database'] := DBNAME; // Datenbankname/Pfad
  FDConnection1.Params.Values['CharacterSet'] := 'utf8';
  if(ENCRYPTDB) then
  begin
    FDConnection1.Params.Values['EncryptionMode'] := 'Aes128'; // Verschlüsselung (optional)
    FDConnection1.Params.Values['Password'] := ENCRYPTIONKEY; // Passwort (optional)
  end;

  FDConnection1.Connected := true;
  FDConnection1.Open(); // Verbindung öffnen

  FDSQLiteBackup1.Database := DBNAME;


  StatusBar1.SimplePanel := False;
  while StatusBar1.Panels.Count < 4 do
    StatusBar1.Panels.Add; // du nutzt Panels[0], [1], [2], [3]
end;




procedure TfMain.FormDestroy(Sender: TObject);
begin
  FDConnection1.Connected := false;
end;






procedure TfMain.FormShow(Sender: TObject);
var
  Frame: TFrameWochenberichtEdit;
  i: integer;
begin
  PostMessage(Handle, WM_APP + $42, 0, 0);
  pnlOnlineStatus.Visible := True;
  pnLogedUser.Visible   := True;

  // Globale FormatSettings konfigurieren
  GlobalFormatSettings := TFormatSettings.Create;
  GlobalFormatSettings.DateSeparator   := '-';
  GlobalFormatSettings.TimeSeparator   := ':';
  GlobalFormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  GlobalFormatSettings.LongTimeFormat  := 'hh:nn:ss';

  if(FIRSTSTART = true) then
  begin
    CreateDatabaseTables;
    AddDogDatabaseTables;
    fFirstStart.ShowModal;
  end
  else
  begin
    ReadSettingsFromDB; //Objekt, Objektleiter, Waffen und Munition

    ReadObjektleiterObjektSettings;

    fAnmeldung.ShowModal;

    ReadSettingsFromIni;

    AddDogDatabaseTables;

    LoadFrame(TFrameWochenberichtEdit);

    if CurrentFrame is TFrameWochenberichtEdit then
    begin
      Frame := TFrameWochenberichtEdit(CurrentFrame);
      Frame.DoubleBuffered := True;
      Frame.Initialize;
    end;

    // Setze die Eigenschaften für alle ToolButtons
    for i := 0 to ComponentCount - 1 do
    begin
      if Components[i] is TToolButton then
      begin
        TToolButton(Components[i]).Down := false;
      end;
    end;
    tbWochenbericht.Down := true;
    NEWWOCHENBERICHT := false;
  end;

  pnLogedUser.Caption := 'Angemeldet als: ' + OBJEKTLEITERNAME;



  //Prüfen ob eine Internetverbindung besteht
  CheckInternetAsync(WebsiteURL, procedure(IsOnline: Boolean)
  begin
    //Internetverbindung besteht
    if IsOnline then
    begin
      pnlOnlinestatus.Caption := 'Online';
      pnlOnlinestatus.Color := clGreen;

      // Jetzt Remote-Version abrufen
      GetRemoteVersionAsync(UpdateURL + 'version.txt', procedure(RemoteVersion: string)
      begin
        if RemoteVersion = '' then
          Exit;

        if VersionCompare(PROGRAMMVERSION, RemoteVersion) < 0 then
        begin
          StatusBar1.Panels[2].Text := 'Update (' + RemoteVersion + ') verfügbar';
        end
        else
          StatusBar1.Panels[2].Text := 'Aktuelle Version';

        StatusBar1.Invalidate;
      end);
    end
    else
    begin
      pnlOnlinestatus.Caption := 'Offline';
      pnlOnlinestatus.Color := clRed;
      StatusBar1.Panels[2].Text := 'Installierte Version: ' + PROGRAMMVERSION;
    end;
  end);

  PostMessage(Handle, WM_APP + $42, 0, 0);
end;





procedure TfMain.Importieren1Click(Sender: TObject);
begin
  if opendialog1.execute  then
  begin
    ExtractAndImportSQLFiles(opendialog1.Filename, 'TEMP'); //Gezipte Tabellen importieren
    tbWochenberichtClick(nil);
  end;
end;

procedure TfMain.Waffen1Click(Sender: TObject);
begin
  fWaffenbestand.Show;
end;

procedure TfMain.lvMitarbeiterColumnClick(Sender: TObject; Column: TListColumn);
begin
  ColumnToSort := Column.Index;
  if ColumnToSort = LastSorted then
    SortDir := 1 - SortDir
  else
    SortDir := 0;
  LastSorted := ColumnToSort;
  (Sender as TCustomListView).AlphaSort;
end;






procedure TfMain.lvMitarbeiterCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
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






procedure TfMain.Mitarbeiter2Click(Sender: TObject);
begin
  BringAppToFront;

  fMitarbeiter.Show;
end;





procedure TfMain.Objekte2Click(Sender: TObject);
begin
  fObjekte.Show;
end;







procedure TfMain.ObjektObjektleiter1Click(Sender: TObject);
begin
  fEinstellungen_Objekt.Show;
end;

procedure TfMain.PrfeauffehlendeStammdaten1Click(Sender: TObject);
begin
  CheckFehlendeAusweisdaten(OBJEKTID);
end;

procedure TfMain.PrfeauffehlendeStammdaten2Click(Sender: TObject);
begin
  CheckAblaufendeAusweise(OBJEKTID);
end;

procedure TfMain.Programmbeschreibung1Click(Sender: TObject);
var
  URL: string;
begin
  URL := WebsiteURL;
  ShellExecute(0, 'open', PChar(URL), nil, nil, SW_SHOWNORMAL);
end;




procedure TfMain.Programmhilfe1Click(Sender: TObject);
var
  URL: string;
begin
  URL := HilfeURL + 'index.html';
  ShellExecute(0, 'open', PChar(URL), nil, nil, SW_SHOWNORMAL);
end;






procedure TfMain.mProgrammeinstellungenClick(Sender: TObject);
begin
  fEinstellungen_Programm.show;
end;




procedure TfMain.N4Click(Sender: TObject);
begin
  BackupDatabase;
end;

procedure TfMain.NachUpdatesuchen1Click(Sender: TObject);
begin
  TLogging.LogMessage(OLUSERNAME, 'Main', 'MainMenu Nach Update suchen', 'geöffnet');


  //Prüfen ob eine Internetverbindung besteht
  CheckInternetAsync(WebsiteURL, procedure(IsOnline: Boolean)
  begin
    //Internetverbindung besteht
    if IsOnline then
    begin
      CheckAndUpdateIfAvailableAsync(PROGRAMMVERSION); // z.B. '1.0.0.7'
    end
    else
    begin
      ShowMessage('Keine Internetverbindung. Die Updateprüfung wird abgebrochen.');
    end;
  end);
end;



procedure TfMain.tbGesamtausbildungClick(Sender: TObject);
var
  Frame: TFrameGesamtausbildung;
  i: integer;
begin
  BringAppToFront;

  PlayResourceMP3('CLICK', 'TEMP\click.wav');

  LoadFrame(TFrameGesamtausbildung);

  if CurrentFrame is TFrameGesamtausbildung then
  begin
    Frame := TFrameGesamtausbildung(CurrentFrame);
    Frame.DoubleBuffered := True;
    Frame.Initialize;
  end;


  // Setze die Eigenschaften für alle ToolButtons
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TToolButton then
    begin
      TToolButton(Components[i]).Down := false;
    end;
  end;
  tbGesamtausbildung.Down := true;
end;









procedure TfMain.tbMuntauschClick(Sender: TObject);
var
  Frame: TFrameMunTausch;
  i: integer;
begin
  BringAppToFront;

  PlayResourceMP3('CLICK', 'TEMP\click.wav');

  LoadFrame(TFrameMunTausch);

  if CurrentFrame is TFrameMunTausch then
  begin
    Frame := TFrameMunTausch(CurrentFrame);
    Frame.DoubleBuffered := True;
    Frame.Initialize;
  end;


  // Setze die Eigenschaften für alle ToolButtons
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TToolButton then
    begin
      TToolButton(Components[i]).Down := false;
    end;
  end;
  tbMunTausch.Down := true;
end;







procedure TfMain.tbAusbildungClick(Sender: TObject);
var
  Frame: TFrameAusbildung;
  i: integer;
begin
  BringAppToFront;

  PlayResourceMP3('CLICK', 'TEMP\click.wav');

  LoadFrame(TFrameAusbildung);

  if CurrentFrame is TFrameAusbildung then
  begin
    Frame := TFrameAusbildung(CurrentFrame);
    Frame.DoubleBuffered := True;
    Frame.Initialize;
  end;


  // Setze die Eigenschaften für alle ToolButtons
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TToolButton then
    begin
      TToolButton(Components[i]).Down := false;
    end;
  end;
  tbAusbildung.Down := true;
end;





procedure TfMain.tbWachpersonalClick(Sender: TObject);
var
  Frame: TFrameWachpersonal;
  i: integer;
begin
  BringAppToFront;

  PlayResourceMP3('CLICK', 'TEMP\click.wav');

  LoadFrame(TFrameWachpersonal);

  if CurrentFrame is TFrameWachpersonal then
  begin
    Frame := TFrameWachpersonal(CurrentFrame);
    Frame.DoubleBuffered := True;
    Frame.Initialize;
  end;


  // Setze die Eigenschaften für alle ToolButtons
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TToolButton then
    begin
      TToolButton(Components[i]).Down := false;
    end;
  end;
  tbWachpersonal.Down := true;
end;






procedure TfMain.tbWachschiessenClick(Sender: TObject);
var
  Frame: TFrameWachschiessen;
  i: integer;
begin
  BringAppToFront;

  PlayResourceMP3('CLICK', 'TEMP\click.wav');

  LoadFrame(TFrameWachschiessen);

  if CurrentFrame is TFrameWachschiessen then
  begin
    Frame := TFrameWachschiessen(CurrentFrame);
    Frame.DoubleBuffered := True;
    Frame.Initialize;
  end;


  // Setze die Eigenschaften für alle ToolButtons
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TToolButton then
    begin
      TToolButton(Components[i]).Down := false;
    end;
  end;
  tbWachschiessen.Down := true;
end;






procedure TfMain.tbWachtestTestSachkundeClick(Sender: TObject);
var
  Frame: TFrameWachtest;
  i: integer;
begin
  BringAppToFront;

  PlayResourceMP3('CLICK', 'TEMP\click.wav');

  LoadFrame(TFrameWachtest);

  if CurrentFrame is TFrameWachtest then
  begin
    Frame := TFrameWachtest(CurrentFrame);
    Frame.DoubleBuffered := True;
    Frame.Initialize;
  end;


  // Setze die Eigenschaften für alle ToolButtons
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TToolButton then
    begin
      TToolButton(Components[i]).Down := false;
    end;
  end;
  tbWachtestTestSachkunde.Down := true;
end;







procedure TfMain.tbWaffenbestandslisteClick(Sender: TObject);
var
  Frame: TFrameWaffenbestandsmeldung;
  i: integer;
begin
  BringAppToFront;

  PlayResourceMP3('CLICK', 'TEMP\click.wav');

  LoadFrame(TFrameWaffenbestandsmeldung);

  if CurrentFrame is TFrameWaffenbestandsmeldung then
  begin
    Frame := TFrameWaffenbestandsmeldung(CurrentFrame);
    Frame.DoubleBuffered := true;
    Frame.Initialize;
  end;


  // Setze die Eigenschaften für alle ToolButtons
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TToolButton then
    begin
      TToolButton(Components[i]).Down := false;
    end;
  end;
  tbWaffenbestandsliste.Down := true;
end;







procedure TfMain.tbWochenberichtClick(Sender: TObject);
var
  Frame: TFrameWochenberichtEdit;
  i: integer;
begin
  BringAppToFront;

  PlayResourceMP3('CLICK', 'TEMP\click.wav');

  LoadFrame(TFrameWochenberichtEdit);

  if CurrentFrame is TFrameWochenberichtEdit then
  begin
    Frame := TFrameWochenberichtEdit(CurrentFrame);
    Frame.DoubleBuffered := True;
    Frame.Initialize;
  end;

  // Setze die Eigenschaften für alle ToolButtons
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TToolButton then
    begin
      TToolButton(Components[i]).Down := false;
    end;
  end;
  tbWochenbericht.Down := true;
end;


procedure TfMain.Timer1Timer(Sender: TObject);
begin
  StatusBar1.Panels[3].Text := DateTimeToStr(Now);
end;

procedure TfMain.TimerOnlineOfflineTimer(Sender: TObject);
begin
  CheckInternetAsync(WebsiteURL, procedure(IsOnline: Boolean)
  begin
    if IsOnline then
    begin
      pnlOnlinestatus.Caption := 'Online';
      pnlOnlinestatus.Color := clGreen;

      // Jetzt Remote-Version abrufen
      GetRemoteVersionAsync(UpdateURL + 'version.txt', procedure(RemoteVersion: string)
      begin
        if RemoteVersion = '' then
          Exit;

        if VersionCompare(PROGRAMMVERSION, RemoteVersion) < 0 then
        begin
          StatusBar1.Panels[2].Text := 'Update (' + RemoteVersion + ') verfügbar';
        end
        else
          StatusBar1.Panels[2].Text := 'Aktuelle Version';

        StatusBar1.Invalidate;
      end);
    end
    else
    begin
      pnlOnlinestatus.Caption := 'Offline';
      pnlOnlinestatus.Color := clRed;
      StatusBar1.Panels[2].Text := 'Installierte Version: ' + PROGRAMMVERSION;
    end;
  end);
end;





procedure TfMain.tbErsteHilfeClick(Sender: TObject);
var
  Frame: TFrameErsteHilfe;
  i: integer;
begin
  BringAppToFront;

  PlayResourceMP3('CLICK', 'TEMP\click.wav');

  LoadFrame(TFrameErsteHilfe);

  if CurrentFrame is TFrameErsteHilfe then
  begin
    Frame := TFrameErsteHilfe(CurrentFrame);
    Frame.DoubleBuffered := True;
    Frame.Initialize;
  end;


  // Setze die Eigenschaften für alle ToolButtons
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TToolButton then
    begin
      TToolButton(Components[i]).Down := false;
    end;
  end;
  tbErsteHilfe.Down := true;
end;







procedure TfMain.BringAppToFront;
begin
  if IsIconic(Application.MainForm.Handle) then
    ShowWindow(Application.MainForm.Handle, SW_RESTORE); // wiederherstellen

  SetForegroundWindow(Application.MainForm.Handle); // in den Vordergrund
end;








initialization
  WebsiteURL  := 'https://esd.developercorner.de/API/Programme/Objektleiter_Management/Version2/';
  ScriptURL   := WebsiteURL + 'scripts/';
  HilfeURL    := WebsiteURL + 'hilfe/';
  UpdateURL   := WebsiteURL + 'update/';
  ProgrammURL := WebsiteURL + 'website/';






end.







