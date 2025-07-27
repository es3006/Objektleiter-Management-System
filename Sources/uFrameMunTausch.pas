unit uFrameMunTausch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DateUtils,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, System.Actions, Vcl.ActnList, Vcl.Menus, TaskDialog,
  System.Math, ShellApi, System.UITypes, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Mask, MaskEdEx, Vcl.ComCtrls, AdvListV, Vcl.Imaging.pngimage;

type
  TFrameMunTausch = class(TFrame)
    Panel2: TPanel;
    Label10: TLabel;
    Image1: TImage;
    imgNewEntry: TImage;
    cbJahr: TComboBox;
    lvMuntausch: TAdvListView;
    Panel3: TPanel;
    Label1: TLabel;
    btnSpeichern: TButton;
    Panel4: TPanel;
    lbHinweis: TLabel;
    sbWeiter: TSpeedButton;
    dtpDatum: TDateTimePicker;
    edBestandVorher: TLabeledEdit;
    edEingang: TLabeledEdit;
    edAbgang: TLabeledEdit;
    edBestandNachher: TLabeledEdit;
    edZweck: TLabeledEdit;
    edUebergebender: TLabeledEdit;
    edUebernehmender: TLabeledEdit;
    procedure Initialize;
    procedure Image1Click(Sender: TObject);
    procedure imgNewEntryClick(Sender: TObject);
    procedure lvMuntauschClick(Sender: TObject);
    procedure lvMuntauschColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvMuntauschCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure lvMuntauschRightClickCell(Sender: TObject; iItem, iSubItem: Integer);
    procedure btnSpeichernClick(Sender: TObject);
    procedure cbJahrSelect(Sender: TObject);
    procedure sbWeiterClick(Sender: TObject);
  private
    s1, s2: String;
    currentIndex: Integer;
    procedure DisplayHinweisString;
    procedure generatePrintableMunTauschJahresansicht(jahr: integer);
    procedure showMuntauschInListView(LV: TListView; Jahr: integer);
  public
    { Public-Deklarationen }
  end;



var
  NEWENTRY: Boolean;
  EINTRAGID: integer;
  selectedYear: integer;



implementation


{$R *.dfm}
{$R Munitionstausch.res}

uses uMain, uWebBrowser, uFunktionen;






procedure TFrameMunTausch.Image1Click(Sender: TObject);
begin
  generatePrintableMunTauschJahresansicht(selectedYear);
end;






procedure TFrameMunTausch.imgNewEntryClick(Sender: TObject);
var
  CurrentDate: TDateTime;
  NewDate: TDateTime;
  Year, Month, Day: Word;
begin
  NEWENTRY := true;
  EINTRAGID := -1;

  Month := MonthOf(now);
  Day   := DayOf(now);

  //Das Jahr im dtpDatum auf dsa gewählte Jahr ändern
  dtpDatum.Date := now;
  CurrentDate := dtpDatum.Date;
  DecodeDate(CurrentDate, Year, Month, Day);
  NewDate := EncodeDate(SelYear, Month, Day);
  dtpDatum.Date := NewDate;

  // dtpDatum.Date := date;
  edBestandVorher.Text := IntToStr(BESTANDWACHMUN);
  edEingang.Text := IntToStr(BESTANDWACHMUN);
  edAbgang.Text := IntToStr(BESTANDWACHMUN);
  edBestandNachher.Text := IntToStr(BESTANDWACHMUN);
  edZweck.Text := 'Munitionstausch';
  edUebergebender.Clear;
  edUeberNehmender.Clear;
  lvMuntausch.ItemIndex := -1;
  dtpDatum.SetFocus;
  btnSpeichern.Caption := 'Hinzufügen';
end;








procedure TFrameMunTausch.Initialize;
var
  Index: integer;
  CurrentYear, StartYear: Integer;
begin
  NEWENTRY  := true;
  EINTRAGID := -1;

  //Die Jahre von 2023 bis aktuelles Jahr + 1 in cbJahr anzeigen
  CurrentYear := YearOf(Now);
  StartYear := 2023;
  for CurrentYear := StartYear to CurrentYear + 1 do
  begin
    cbJahr.Items.Add(IntToStr(CurrentYear));
  end;

  //Aktuelles Jahr auswählen
  CurrentYear := YearOf(Now); // Das aktuelle Jahr ermitteln
  Index := cbJahr.Items.IndexOf(IntToStr(CurrentYear));  // Den Index des Eintrags mit dem aktuellen Jahr finden
  if Index <> -1 then // Wenn der Index gefunden wurde, den Eintrag selektieren
  begin
    cbJahr.ItemIndex := Index;
    cbJahrSelect(self);
  end;


  // Hinweistexte für Timer
  s1 := 'Ändern eines Eintrages:'+#13#10+'Wählen Sie den gewünschten Eintrag in der Liste, ändern Sie unten die Werte und klicken Sie auf "Speichern"';
  s2 := 'Neuen Eintrag hinzufügen'+#13#10+'Klicken Sie oben auf das Symbol "Neuer Eintrag", füllen Sie unten die Eingabefelder aus und klicken Sie auf "Hinzufügen"';
  currentIndex := 2;
  lbHinweis.Caption := s1;
end;




procedure TFrameMunTausch.lvMuntauschClick(Sender: TObject);
var
  i: integer;
begin
  i := lvMuntausch.ItemIndex;
  if(i <> -1) then
  begin
    NEWENTRY := false;
    btnSpeichern.Caption := 'Speichern';

    EINTRAGID             := StrToInt(lvMuntausch.Items[i].Caption);
    dtpDatum.Date         := StrToDate(lvMuntausch.Items[i].SubItems[0]);
    edBestandvorher.Text  := lvMuntausch.Items[i].SubItems[1];
    edEingang.Text        := lvMuntausch.Items[i].SubItems[2];
    edAbgang.Text         := lvMuntausch.Items[i].SubItems[3];
    edBestandnachher.Text := lvMuntausch.Items[i].SubItems[4];
    edZweck.Text          := lvMuntausch.Items[i].SubItems[5];
    edUebergebender.Text  := lvMuntausch.Items[i].SubItems[6];
    edUebernehmender.Text := lvMuntausch.Items[i].SubItems[7];
  end
  else
  begin
    NEWENTRY := true;
    EINTRAGID := -1;

    //dtpDatum.Date := Date;
    edBestandVorher.Text  := IntToStr(BESTANDWACHMUN);
    edEingang.Text        := IntToStr(BESTANDWACHMUN);
    edAbgang.Text         := IntToStr(BESTANDWACHMUN);
    edBestandNachher.Text := IntToStr(BESTANDWACHMUN);
    edZweck.Text          := 'Munitionstausch';
    edUebergebender.Clear;
    edUeberNehmender.Clear;
    lvMuntausch.ItemIndex := -1;
    dtpDatum.SetFocus;
    btnSpeichern.Caption  := 'Hinzufügen';
  end;
end;





procedure TFrameMunTausch.lvMuntauschColumnClick(Sender: TObject; Column: TListColumn);
begin
  lvColumnClickForSort(Sender, Column);
end;






procedure TFrameMunTausch.lvMuntauschCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  lvCompareForSort(Sender, Item1, Item2, Data, Compare);
end;






procedure TFrameMunTausch.lvMuntauschRightClickCell(Sender: TObject; iItem, iSubItem: Integer);
var
  i, spalte, SelEntry: integer;
  FDQuery: TFDQuery;
begin
  i := lvMuntausch.ItemIndex;
  if i <> -1 then
  begin
    spalte := iSubItem - 1;

    if MessageDlg('Wollen Sie diese Zeile wirklich entfernen', mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
    begin
      SelEntry := StrToInt(lvMuntausch.Items[i].Caption);

      FDQuery := TFDQuery.Create(nil);
      try
        with FDQuery do
        begin
          Connection := fMain.FDConnection1;

          SQL.Text := 'DELETE FROM munitionstausch WHERE id = :ID;';

          Params.ParamByName('ID').AsInteger    := SelEntry;

          ExecSQL;
        end;
      except
        on E: Exception do
        begin
          ShowMessage('Fehler beim löschen des Eintrags!: ' + E.Message);
          Exit;
        end;
      end;
      FDQuery.Free;

      lvMuntausch.DeleteSelected;
     end;
  end;
end;






procedure TFrameMunTausch.sbWeiterClick(Sender: TObject);
begin
  DisplayHinweisString;
end;





procedure TFrameMunTausch.btnSpeichernClick(Sender: TObject);
var
  FDQuery: TFDQuery;
  l: TListItem;
  datum, bestandvorher, eingang, abgang, bestandnachher, zweck, uebergebender, uebernehmender: string;
  LastInsertID: integer;
begin
  datum          := DateToStr(dtpDatum.Date);
  bestandvorher  := Trim(edBestandVorher.Text);
  eingang        := Trim(edEingang.Text);
  abgang         := Trim(edAbgang.Text);
  bestandnachher := Trim(edBestandNachher.Text);
  zweck          := Trim(edZweck.Text);
  uebergebender  := Trim(edUebergebender.Text);
  uebernehmender := Trim(edUebernehmender.Text);

  if (datum = '') or (bestandvorher = '') or (eingang = '') or (abgang = '') or
     (bestandnachher = '') or (zweck = '') or (uebergebender = '') or (uebernehmender = '') then
  begin
    ShowMessage('Bitte füllen Sie alle Eingabefelder aus!');
    Exit;
  end;


  FDQuery := TFDQuery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      if NEWENTRY then
      begin
        SQL.Text := 'INSERT INTO munitionstausch (datum, bestandvorher, eingang, abgang, ' +
                    'bestandnachher, zweck, uebergebender, uebernehmender) ' +
                    'VALUES (:DATUM, :BESTANDVORHER, :EINGANG, :ABGANG, :BESTANDNACHHER, ' +
                    ':ZWECK, :UEBERGEBENDER, :UEBERNEHMENDER);';

        // Parameter setzen
        Params.ParamByName('DATUM').AsString := ConvertGermanDateToSQLDate(datum, false);
        Params.ParamByName('BESTANDVORHER').AsString := bestandvorher;
        Params.ParamByName('EINGANG').AsString := eingang;
        Params.ParamByName('ABGANG').AsString := abgang;
        Params.ParamByName('BESTANDNACHHER').AsString := bestandnachher;
        Params.ParamByName('ZWECK').AsString := zweck;
        Params.ParamByName('UEBERGEBENDER').AsString := uebergebender;
        Params.ParamByName('UEBERNEHMENDER').AsString := uebernehmender;
      end
      else
      begin
        SQL.Text := 'UPDATE munitionstausch SET datum = :DATUM, bestandvorher = :BESTANDVORHER, ' +
                    'eingang = :EINGANG, abgang = :ABGANG, ' +
                    'bestandnachher = :BESTANDNACHHER, zweck = :ZWECK, ' +
                    'uebergebender = :UEBERGEBENDER, uebernehmender = :UEBERNEHMENDER ' +
                    'WHERE id = :ID;';

        Params.ParamByName('ID').AsInteger := EINTRAGID;
        Params.ParamByName('DATUM').AsString := ConvertGermanDateToSQLDate(datum, false);
        Params.ParamByName('BESTANDVORHER').AsString := bestandvorher;
        Params.ParamByName('EINGANG').AsString := eingang;
        Params.ParamByName('ABGANG').AsString := abgang;
        Params.ParamByName('BESTANDNACHHER').AsString := bestandnachher;
        Params.ParamByName('ZWECK').AsString := zweck;
        Params.ParamByName('UEBERGEBENDER').AsString := uebergebender;
        Params.ParamByName('UEBERNEHMENDER').AsString := uebernehmender;
      end;

      ExecSQL;

      if NEWENTRY then
      begin
        SQL.Text := 'SELECT last_insert_rowid() AS LastID;';
        Open;
        LastInsertID := FieldByName('LastID').AsInteger;

        // Neuen Eintrag zur ListView hinzufügen
        l := lvMuntausch.Items.Add;
        l.Caption := IntToStr(LastInsertID);
        l.SubItems.Add(datum);
        l.SubItems.Add(bestandvorher);
        l.SubItems.Add(eingang);
        l.SubItems.Add(abgang);
        l.SubItems.Add(bestandnachher);
        l.SubItems.Add(zweck);
        l.SubItems.Add(uebergebender);
        l.SubItems.Add(uebernehmender);
      end
      else
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
    end;
  except
    on E: Exception do
      ShowMessage('Fehler beim Speichern des Eintrags in der Datenbanktabelle "Munitionstausch": ' + E.Message);
  end;

  dtpDatum.Date := Date;
  edUebergebender.Clear;
  edUebernehmender.Clear;


  FDQuery.Free;

  lvMunTausch.ItemIndex := -1;
  NEWENTRY := true;
  btnSpeichern.Caption := 'Hinzufügen';
end;







procedure TFrameMunTausch.cbJahrSelect(Sender: TObject);
var
  CurrentDate: TDateTime;
  NewDate: TDateTime;
  Year, Month, Day: Word;
begin
  SelYear  := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);

  //Das Jahr im dtpDatum auf dsa gewählte Jahr ändern
  dtpDatum.Date := now;
  CurrentDate := dtpDatum.Date;
  DecodeDate(CurrentDate, Year, Month, Day);
  NewDate := EncodeDate(SelYear, Month, Day);

  dtpDatum.Date := NewDate;

  showMuntauschInListView(lvMuntausch, SelYear);
end;





procedure TFrameMunTausch.DisplayHinweisString;
begin
  case currentIndex of
    1: lbHinweis.Caption := s1;
    2: lbHinweis.Caption := s2;
  end;

  // Inkrementiere den Index und setze ihn zurück auf 1, wenn er 4 erreicht
  currentIndex := currentIndex mod 2 + 1;
end;






procedure TFrameMunTausch.generatePrintableMunTauschJahresansicht(jahr: integer);
var
  i, a: integer;
  filename: string;
  stlTemp, stlHeader, stlFooter, stlContent: TStringList;
  resHeader, resFooter, resContent: TResourceStream;
  datum, bestandv, eingang, abgang, bestandn, zweck, uebergebender, uebernehmender: String;
begin
  resHeader := nil;
  resFooter := nil;
  stlHeader := nil;
  stlFooter := nil;
  stlTemp   := nil;

  jahr      := StrToInt(cbJahr.Text);

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
    stlHeader.Text := StringReplace(stlHeader.Text, '[VORZWACHMUN]', IntToStr(BESTANDWACHMUN), [rfReplaceAll]);



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


    //Dateiname für zu speichernde Datei erzeugen
    filename := 'Munitionstausch '+ IntToStr(jahr)+' '+OBJEKTNAME+' '+OBJEKTORT;

    //Aus Resource-Datei temporäre Html-Datei und daraus eine PDF-Datei im TEMP Verzeichnis erzeugen
    CreateHtmlAndPdfFileFromResource(filename, stlTemp);

    //PDF Datei aus Temp Verzeichnis im Zielverzeichnis speichern
    SpeicherePDFDatei(filename, SAVEPATH_Munitionstausch);
  finally
    if(Assigned(resHeader)) then resHeader.Free;
    if(Assigned(resFooter)) then resFooter.Free;
    if(Assigned(stlHeader)) then stlHeader.Free;
    if(Assigned(stlFooter)) then stlFooter.Free;
    if(Assigned(stlTemp)) then stlTemp.Free;
  end;
end;





procedure TFrameMunTausch.showMuntauschInListView(LV: TListView; Jahr: Integer);
var
  id, datum, bestandvorher, eingang, abgang, bestandnachher, zweck, uebergebender, uebernehmender: TField;
  l: TListItem;
  FDQuery: TFDQuery;
  StartDate, EndDate: TDate;
begin
  Screen.Cursor := crHourGlass; // Setze den Cursor auf das Stundenglas
  try
    ClearListView(lvMunTausch);

    StartDate := EncodeDate(Jahr, 1, 1);
    EndDate   := EncodeDate(Jahr, 12, 31);

    FDQuery := TFDQuery.Create(nil);
    try
      with FDQuery do
      begin
        Connection := fMain.FDConnection1;

        SQL.Text := 'SELECT id, datum, bestandvorher, eingang, abgang, bestandnachher, zweck, ' +
                    'uebergebender, uebernehmender ' +
                    'FROM munitionstausch ' +
                    'WHERE datum BETWEEN :StartDate AND :EndDate ' +
                    'ORDER BY datum ASC';

        Params.ParamByName('StartDate').AsDate := StartDate;
        Params.ParamByName('EndDate').AsDate := EndDate;

        Open;

        while not Eof do
        begin
          id := FDQuery.FieldByName('id');
          datum := FDQuery.FieldByName('datum');
          bestandvorher := FDQuery.FieldByName('bestandvorher');
          eingang := FDQuery.FieldByName('eingang');
          abgang := FDQuery.FieldByName('abgang');
          bestandnachher := FDQuery.FieldByName('bestandnachher');
          zweck := FDQuery.FieldByName('zweck');
          uebergebender := FDQuery.FieldByName('uebergebender');
          uebernehmender := FDQuery.FieldByName('uebernehmender');

          l := lvMunTausch.Items.Add;
          L.Caption := id.AsString;
          L.SubItems.Add(ConvertSQLDateToGermanDate(datum.AsString, false));
          L.SubItems.Add(bestandvorher.AsString);
          L.SubItems.Add(eingang.AsString);
          L.SubItems.Add(abgang.AsString);
          L.SubItems.Add(bestandnachher.AsString);
          L.SubItems.Add(zweck.AsString);
          L.SubItems.Add(uebergebender.AsString);
          L.SubItems.Add(uebernehmender.AsString);

          Next;
        end;
      end;
    finally
      FDQuery.Free;
    end;
  finally
    Screen.Cursor := crDefault; // Setze den Cursor zurück
  end;
end;




end.
