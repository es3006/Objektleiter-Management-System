unit uMunitionstausch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Mask, MaskEdEx, StdCtrls, ExtCtrls, ComCtrls, AdvListV, Vcl.Imaging.pngimage,
  DateUtils, Math, ShellApi, ZDataset, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  ZSqlProcessor, FireDAC.Stan.Param;

type
  TfMunitionstausch = class(TForm)
    Panel1: TPanel;
    lvMuntausch: TAdvListView;
    ZSQLProcessor1: TZSQLProcessor;
    Label7: TLabel;
    StatusBar1: TStatusBar;
    Label11: TLabel;
    Image1: TImage;
    Panel2: TPanel;
    Label10: TLabel;
    cbJahr: TComboBox;
    Panel3: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    edZweck: TEdit;
    edDatum: TMaskEditEx;
    edBestandVorher: TMaskEditEx;
    edEingang: TMaskEditEx;
    edAbgang: TMaskEditEx;
    edBestandNachher: TMaskEditEx;
    edUebergebender: TEdit;
    edUebernehmender: TEdit;
    Panel4: TPanel;
    btnSpeichern: TButton;
    btnNewEntry: TButton;
    procedure btnNewEntryClick(Sender: TObject);
    procedure btnSpeichernClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvMuntauschColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvMuntauschCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure lvMuntauschSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure Image1Click(Sender: TObject);
    procedure cbJahrSelect(Sender: TObject);
  private
    procedure generatePrintableMunTauschJahresansicht(jahr: integer);
  public
    { Public-Deklarationen }
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

var
  fMunitionstausch: TfMunitionstausch;
  NEWENTRY: Boolean;
  EINTRAGID: integer;
  selectedYear: integer;

implementation



{$R *.dfm}
{$R Munitionstausch.res}


uses
  uMain, uFunktionen, uDBFunktionen;




procedure TfMunitionstausch.btnNewEntryClick(Sender: TObject);
begin
  NEWENTRY := true;
  EINTRAGID := -1;

  edDatum.Clear;
  edBestandVorher.Clear;
  edEingang.Clear;
  edAbgang.Clear;
  edBestandNachher.Clear;
  edZweck.Clear;
  edUebergebender.Clear;
  edUeberNehmender.Clear;
  lvMuntausch.ItemIndex := -1;
  edDatum.SetFocus;
  btnSpeichern.Caption := 'Hinzufügen';
end;



procedure TfMunitionstausch.btnSpeichernClick(Sender: TObject);
var
  q: TFDQuery;
  l: TListItem;
  datum, bestandvorher, eingang, abgang, bestandnachher, zweck, uebergebender, uebernehmender: string;
  zuletztEingefügteID: integer;
begin
  datum          := trim(edDatum.Text);
  bestandvorher  := trim(edBestandVorher.Text);
  eingang        := trim(edEingang.Text);
  abgang         := trim(edAbgang.Text);
  bestandnachher := trim(edBestandNachher.Text);
  zweck          := trim(edZweck.Text);
  uebergebender  := trim(edUebergebender.Text);
  uebernehmender := trim(edUebernehmender.Text);

  if(datum='') OR (bestandvorher='') OR (eingang='') OR (abgang='') OR (bestandnachher='') OR (zweck='') OR (uebergebender='') OR (uebernehmender='') then
  begin
    showmessage('Bitte füllen Sie alle Pflichtfelder aus!'+#13#10+'Pflichtfelder sind fett markiert');
    exit;
  end;


  q := TFDquery.Create(nil);
  try
    with q do
    begin
      Connection := fMain.FDConnection1;
      fMain.FDConnection1.Connected := true;

      SQL.Clear;
//INSERT START
      if(NEWENTRY = true) then
      begin
        SQL.Add('INSERT INTO munitionstausch (datum, bestandvorher, eingang, abgang, bestandnachher, zweck, uebergebender, uebernehmender)');
        SQL.Add('VALUES (:DATUM, :BESTANDVORHER, :EINGANG, :ABGANG, :BESTANDNACHHER, :ZWECK, :UEBERGEBENDER, :UEBERNEHMENDER);');
        Params.ParamByName('DATUM').AsString := DateToMySQLDate(StrToDate(datum));
        Params.ParamByName('BESTANDVORHER').AsString := bestandvorher;
        Params.ParamByName('EINGANG').AsString := eingang;
        Params.ParamByName('ABGANG').AsString := abgang;
        Params.ParamByName('BESTANDNACHHER').AsString := bestandnachher;
        Params.ParamByName('ZWECK').AsString := zweck;
        Params.ParamByName('UEBERGEBENDER').AsString := uebergebender;
        Params.ParamByName('UEBERNEHMENDER').AsString := uebernehmender;
      end;
//INSERT ENDE

//UPDATE START
      if(NEWENTRY = false) then
      begin
        SQL.Add('UPDATE munitionstausch SET datum = :DATUM, bestandvorher = :BESTANDVORHER, '+
                'eingang = :EINGANG, abgang = :ABGANG, '+
                'bestandnachher = :BESTANDNACHHER, zweck = :ZWECK, '+
                'uebergebender = :UEBERGEBENDER, uebernehmender = :UEBERNEHMENDER WHERE id = :ID');
        Params.ParamByName('ID').AsInteger := EINTRAGID;
        Params.ParamByName('DATUM').AsString := DateToMySQLDate(StrToDate(datum));
        Params.ParamByName('BESTANDVORHER').AsString := bestandvorher;
        Params.ParamByName('EINGANG').AsString := eingang;
        Params.ParamByName('ABGANG').AsString := abgang;
        Params.ParamByName('BESTANDNACHHER').AsString := bestandnachher;
        Params.ParamByName('ZWECK').AsString := zweck;
        Params.ParamByName('UEBERGEBENDER').AsString := uebergebender;
        Params.ParamByName('UEBERNEHMENDER').AsString := uebernehmender;
      end;
//UPDATE ENDE
      ExecSQL;
    end;
  except
    showmessage('Fehler beim speichern des Eintrages in der Datenbanktabelle "Munitionstausch"');
  end;


  if(NEWENTRY = true) then
  begin
//Zuletzt vergeben ID herausfinden und mit in die ListView einfügen
    with q do
    begin
      Connection := fMain.FDConnection1;
      fMain.FDConnection1.Connected := true;

      SQL.Clear;
      SQL.Text := 'SELECT LAST_INSERT_ID()';
      Open;
      zuletztEingefügteID := Fields[0].AsInteger;
      Close;
    end;

//Alle Einträge in die Listview einfügen
    with lvMuntausch do
    begin
      l := Items.Add;
      l.Caption := IntToStr(zuletztEingefügteID);
      l.SubItems.Add(datum);
      l.SubItems.Add(bestandvorher);
      l.SubItems.Add(eingang);
      l.SubItems.Add(abgang);
      l.SubItems.Add(bestandnachher);
      l.SubItems.Add(zweck);
      l.SubItems.Add(uebergebender);
      l.SubItems.Add(uebernehmender);
    end;
  end;

  if(NEWENTRY = false) then
  begin
    with lvMuntausch.Items[lvMuntausch.ItemIndex] do
    begin
      SubItems[0] := datum;
      SubItems[1] := bestandvorher;
      SubItems[2] := eingang;
      SubItems[3] := abgang;
      SubItems[4] := bestandnachher;
      SubItems[5] := zweck;
      SubItems[6] := uebergebender;
      SubItems[7] := uebernehmender;
    end;
  end;

  edDatum.Clear;
  edBestandvorher.Clear;
  edEingang.Clear;
  edAbgang.Clear;
  edBestandNachher.Clear;
  edZweck.Clear;
  edUebergebender.Clear;
  edUebernehmender.Clear;

  fMain.FDConnection1.Connected := false;
end;







procedure TfMunitionstausch.cbJahrSelect(Sender: TObject);
begin
  selectedYear  := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);
  //showMuntauschInListView(lvMuntausch, selectedYear);
end;







procedure TfMunitionstausch.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle   := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;



procedure TfMunitionstausch.FormShow(Sender: TObject);
var
  Index: integer;
  CurrentYear, StartYear: Integer;
begin
  NEWENTRY := true;
  EINTRAGID := -1;

  //showMuntauschInListView(lvMuntausch, selectedYear);

  //lvMuntausch beim start automatisch nach Datum sortieren
  ColumnToSort := 1; //Spalte
  SortDir      := 0; //Aufsteigend- oder absteigend sortieren
  lvMuntausch.AlphaSort; //Sortierung anwenden

  btnNewEntryClick(Self);

  //Die Jahre von 2023 bis aktuelles Jahr + 1 in cbJahr anzeigen
  CurrentYear := YearOf(Now);
  StartYear := 2023;
  for CurrentYear := StartYear to CurrentYear + 1 do
    cbJahr.Items.Add(IntToStr(CurrentYear));

  //Aktuelles Jahr auswählen
  CurrentYear := YearOf(Now); // Das aktuelle Jahr ermitteln
  Index := cbJahr.Items.IndexOf(IntToStr(CurrentYear));  // Den Index des Eintrags mit dem aktuellen Jahr finden
  if Index <> -1 then // Wenn der Index gefunden wurde, den Eintrag selektieren
    cbJahr.ItemIndex := Index;

  cbJahrSelect(self);
end;








procedure TfMunitionstausch.Image1Click(Sender: TObject);
begin
   generatePrintableMunTauschJahresansicht(selectedYear);
end;









procedure TfMunitionstausch.generatePrintableMunTauschJahresansicht(jahr: integer);
var
  i, a: integer;
  filename: string;
  BatchScriptPath: string;
  HTMLFilePath: string;
  PDFFilePath: string;
  CommandLine: string;
  dateipfad: string;
  stlTemp, stlHeader, stlFooter, stlContent: TStringList;
  resHeader, resFooter, resContent: TResourceStream;
  datum, bestandv, eingang, abgang, bestandn, zweck, uebergebender, uebernehmender: String;
begin
  jahr      := StrToInt(cbJahr.Text);
  dateipfad := 'Listen\Munitionstausch\';

  readSettings;

  try
    resHeader := TResourceStream.Create(HInstance, 'Munitionstausch_Header', 'TXT');
    stlHeader := TStringList.Create;
    stlHeader.LoadFromStream(resHeader);

    resFooter := TResourceStream.Create(HInstance, 'Munitionstausch_Footer', 'TXT');
    stlFooter := TStringList.Create;
    stlFooter.LoadFromStream(resFooter);

    stlTemp := TStringList.Create;


    //Platzhalter in "Munitionstausch_Header" ersetzen
    stlHeader.Text := StringReplace(stlHeader.Text, '[OBJEKTNAMEORT]', OBJEKTNAME + ' ' + OBJEKTORT, [rfReplaceAll]);
    stlHeader.Text := StringReplace(stlHeader.Text, '[VORZWACHMUN]', BESTANDWACHMUN, [rfReplaceAll]);



    //CONTENT START
    for a := 0 to 11 do
    begin
      if(a <= lvMunTausch.Items.Count-1) then
      begin
        datum          := lvMuntausch.Items[a].SubItems[0];
        bestandv       := lvMuntausch.Items[a].SubItems[1];
        eingang        := lvMuntausch.Items[a].SubItems[2];
        abgang         := lvMuntausch.Items[a].SubItems[3];
        bestandn       := lvMuntausch.Items[a].SubItems[4];
        zweck          := lvMuntausch.Items[a].SubItems[5];
        uebergebender  := lvMuntausch.Items[a].SubItems[6];
        uebernehmender := lvMuntausch.Items[a].SubItems[7];
      end
      else
      begin
        datum          := '&nbsp;';
        bestandv       := '&nbsp;';
        eingang        := '&nbsp;';
        abgang         := '&nbsp;';
        bestandn       := '&nbsp;';
        zweck          := '&nbsp;';
        uebergebender  := '&nbsp;';
        uebernehmender := '&nbsp;';
      end;

      //Platzhalter in Munitionstausch_Content ersetzen
      resContent := TResourceStream.Create(HInstance, 'Munitionstausch_Content', 'TXT');
      stlContent := TStringList.Create;
      try
        stlContent.LoadFromStream(resContent);
        stlContent.Text := StringReplace(stlContent.Text, '[DATUM]',          datum, [rfReplaceAll]);
        stlContent.Text := StringReplace(stlContent.Text, '[BESTANDVOR]',     bestandv, [rfReplaceAll]);
        stlContent.Text := StringReplace(stlContent.Text, '[EINGANG]',        eingang, [rfReplaceAll]);
        stlContent.Text := StringReplace(stlContent.Text, '[ABGANG]',         abgang, [rfReplaceAll]);
        stlContent.Text := StringReplace(stlContent.Text, '[BESTANDNACH]',    bestandn, [rfReplaceAll]);
        stlContent.Text := StringReplace(stlContent.Text, '[ZWECK]',          zweck, [rfReplaceAll]);
        stlContent.Text := StringReplace(stlContent.Text, '[UEBERGEBENDER]',  uebergebender, [rfReplaceAll]);
        stlContent.Text := StringReplace(stlContent.Text, '[UEBERNEHMENDER]', uebernehmender, [rfReplaceAll]);
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


    //Seiten als Html-Datei speichern
    filename := 'Munitionstausch '+ IntToStr(jahr)+' '+OBJEKTNAME+' '+OBJEKTORT;

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

    StatusBar1.Panels[0].Text := 'Munitionstausach Jahresansicht im Verzeichnis "'+dateipfad+'" gespeichert.';

    sleep(1000);

    fMain.tbWochenberichtClick(fMain.tbMuntausch);
  finally
    resHeader.Free;
    resFooter.Free;
    stlHeader.Free;
    stlFooter.Free;
    stlTemp.Free;
  end;
  close;
end;











procedure TfMunitionstausch.lvMuntauschColumnClick(Sender: TObject; Column: TListColumn);
begin
  lvColumnClickForSort(Sender, Column);
end;





procedure TfMunitionstausch.lvMuntauschCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  lvCompareForSort(Sender, Item1, Item2, Data, Compare);
end;



procedure TfMunitionstausch.lvMuntauschSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if(Selected) then
  begin
    NEWENTRY := false;
    btnSpeichern.Caption := 'Speichern';

    EINTRAGID := StrToInt(Item.Caption);
    edDatum.Text := Item.SubItems[0];
    edBestandvorher.Text := Item.SubItems[1];
    edEingang.Text := Item.SubItems[2];
    edAbgang.Text := Item.SubItems[3];
    edBestandnachher.Text := Item.SubItems[4];
    edZweck.Text := Item.SubItems[5];
    edUebergebender.Text := Item.SubItems[6];
    edUebernehmender.Text := Item.SubItems[7];
  end;
end;


end.
