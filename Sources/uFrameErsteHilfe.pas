unit uFrameErsteHilfe;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls, Vcl.ComCtrls, AdvListV, Vcl.StdCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Mask, MaskEdEx, DateUtils, System.UITypes,
  Vcl.Buttons;

type
  TFrameErsteHilfe = class(TFrame)
    Panel3: TPanel;
    Label4: TLabel;
    Label1: TLabel;
    cbMitarbeiter: TComboBox;
    dtpDatum: TDateTimePicker;
    lvErsteHilfe: TAdvListView;
    Panel2: TPanel;
    Image1: TImage;
    bnSaveInDB: TButton;
    Panel1: TPanel;
    lbHinweis: TLabel;
    sbWeiter: TSpeedButton;
    procedure Initialize;
    procedure lvErsteHilfeCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure lvErsteHilfeColumnClick(Sender: TObject; Column: TListColumn);
    procedure bnSaveInDBClick(Sender: TObject);
    procedure cbMitarbeiterSelect(Sender: TObject);
    procedure lvErsteHilfeClick(Sender: TObject);
    procedure lvErsteHilfeRightClickCell(Sender: TObject; iItem, iSubItem: Integer);
    procedure sbWeiterClick(Sender: TObject);
    procedure lvErsteHilfeSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    s1, s2, s3, s4: String;
    currentIndex: Integer;
    procedure DisplayHinweisString;
    procedure showErsteHilfeInListView(LV: TListView);
    procedure InsertNewEntryInDB(mitarbeiterID: integer);
    procedure DeleteEntryFromDB(SelEntry: integer);
    procedure InsertMitarbeiterInListView(lv: TListView; MitarbeiterID, ausbildungsart: integer);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public-Deklarationen }
  end;


var
  SelEntry, SelectedArt, SelMitarbeiterID: integer;



implementation

{$R *.dfm}



uses
  uMain, uFunktionen, uDBFunktionen, uWebBrowser;


procedure TFrameErsteHilfe.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_COMPOSITED;
end;



procedure TFrameErsteHilfe.Initialize;
begin
  showMitarbeiterInComboBox(cbMitarbeiter, MonthOf(now), YearOf(now), false, OBJEKTID, 3);
  showErsteHilfeInListView(lvErsteHilfe);

  SelEntry := -1;
  SelMitarbeiterID := -1;
  SelectedArt := 5; // 5 = Erste Hilfe Ausbildung

  // Hinweistexte für Timer
  s1 := 'Datum der Erste-Hilfe Ausbildung anpassen:'+#13#10+'Selektieren Sie den zu ändernden Eintrag und wählen Sie unten das neue Ausbildungsdatum.';
  s2 := 'Neuen Mitarbeiter einfügen'+#13#10+'Wählen Sie aus dem Auswahlfeld "Mitarbeiter" einen Namen der noch nicht in der Liste steht, passen Sie das Datum an und drücken Sie auf den Speichern Button';
  s3 := 'Löschen eines Eintrages mit rechter Maustaste';
  s4 := 'Hinweis:'+#13#10+'Das Gültigkeitsdatum wird automatisch angepasst und es wird rechtzeitig angezeigt wenn eine Ausbildung ihre Gültigkeit verliert.';
  currentIndex := 2;  // Setze den Index auf den ersten String
  lbHinweis.Caption := s1;
end;






procedure TFrameErsteHilfe.cbMitarbeiterSelect(Sender: TObject);
var
  i: integer;
begin
  i := TComboBox(Sender).ItemIndex;
  if i > 0 then
  begin
    if TComboBox(Sender).ItemIndex > 0 then
    begin
      SelMitarbeiterID := Integer(TComboBox(Sender).Items.Objects[i]);
      InsertMitarbeiterInListView(lvErsteHilfe, SelMitarbeiterID, SelectedArt); //id des Mitarbeiters aus der ComboBox übergeben
      SelectMitarbeiterInListView(lvErsteHilfe, SelMitarbeiterID);
    end;
  end
  else
  begin
    lvErsteHilfe.ItemIndex := -1;
  end;
end;




procedure TFrameErsteHilfe.sbWeiterClick(Sender: TObject);
begin
  DisplayHinweisString;
end;




procedure TFrameErsteHilfe.showErsteHilfeInListView(LV: TListView);
var
  FDQuery: TFDQuery;
  l: TListItem;
  id, mitarbeiterID: integer;
  mitarbeiterName: string;
  ausbildungsDatum, GueltigBis: string;

  gueltigBisDatum: TDateTime;
  aktuellesDatum: TDateTime;


  jahr, monat: integer;
begin
  jahr := YearOf(date);
  monat := MonthOf(date);

  // FormatSettings für das Format DD.MM.YYYY einstellen
  formatSettings := TFormatSettings.Create;
  formatSettings.DateSeparator := '.';
  formatSettings.ShortDateFormat := 'dd.MM.yyyy';

  LV.Items.Clear;

  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text :=
  'SELECT M.id AS MitarbeiterID, ' +
         'M.nachname || " " || SUBSTR(M.vorname, 1, 1) || "." AS Mitarbeiter, ' +
         'A.id, A.datum, DATE(A.datum, "+2 years") AS GueltigBis, ' +
         'strftime("%d.%m.%Y", A.datum) AS Ausbildung ' +
  'FROM mitarbeiter AS M ' +
  'INNER JOIN ausbildung AS A ON M.id = A.mitarbeiterid ' +
  'INNER JOIN ( ' +
      'SELECT A2.mitarbeiterid, MAX(A2.datum) AS MaxDatum ' +
      'FROM ausbildung A2 ' +
      'WHERE A2.ausbildungsartID = :AUSBILDUNGSARTID ' +
        'AND A2.objektid = :OBJEKTID ' +
      'GROUP BY A2.mitarbeiterid ' +
  ') AS LatestA ON A.mitarbeiterid = LatestA.mitarbeiterid AND A.datum = LatestA.MaxDatum ' +
  'WHERE A.ausbildungsartID = :AUSBILDUNGSARTID ' +
    'AND A.objektid = :OBJEKTID ' +
  'ORDER BY CASE WHEN M.objektid = :OBJEKTID THEN 0 ELSE 1 END, M.nachname;';

Params.ParamByName('OBJEKTID').AsInteger := objektID;
Params.ParamByName('AUSBILDUNGSARTID').AsInteger := 5;





      Open;

      while not Eof do
      begin
        id                := FieldByName('id').AsInteger;
        mitarbeiterID     := FieldByName('MitarbeiterID').AsInteger;
        mitarbeiterName   := FieldByName('Mitarbeiter').AsString;
        ausbildungsDatum  := ConvertSQLDateToGermanDate(FieldByName('datum').AsString, false);
        GueltigBis        := ConvertSQLDateToGermanDate(FieldByName('GueltigBis').AsString, false);

        l := LV.Items.Add;
        l.Caption := IntToStr(mitarbeiterID);
        l.SubItems.Add(IntToStr(id));
        l.SubItems.Add(mitarbeiterName);
        l.SubItems.Add(ausbildungsDatum);
        l.SubItems.Add(GueltigBis);


        // Ausgabe ob der Erste Hilfe Kurs abgelaufen ist
        if TryStrToDate(gueltigBis, gueltigBisDatum, formatSettings) then
        begin
          // Aktuelles Datum holen
          aktuellesDatum := Date;

          // Vergleich und Ergebnisanzeige
          if gueltigBisDatum < aktuellesDatum then
            l.SubItems.Add('Abgelaufen')
          else if MonthsBetween(aktuellesDatum, gueltigBisDatum) <= 1 then
            l.SubItems.Add('Läuft demnächst ab')
          else
            l.SubItems.Add('');
        end
        else
        begin
          ShowMessage('Ungültiges Datum.');
        end;

        Next;
      end;
    end;
  finally
    FDQuery.free;
  end;
end;





procedure TFrameErsteHilfe.bnSaveInDBClick(Sender: TObject);
var
  l: TListItem;
  i: integer;
  mitarbeiterID: integer;
begin
  i := lvErsteHilfe.ItemIndex;
  if i <> -1 then
  begin
    mitarbeiterID := StrToInt(lvErsteHilfe.Items[i].Caption);
    InsertNewEntryInDB(mitarbeiterID);
  end;

  exit;


  if(SelMitarbeiterID <> -1) then
  begin
    if (SelEntry = -1) then
    begin
      for i := 0 to lvErsteHilfe.Items.Count - 1 do
      begin
        l := lvErsteHilfe.Items[i];
        if l.SubItems[0] = IntToStr(SelMitarbeiterID) then
        begin
          lvErsteHilfe.ItemIndex := i;
          lvErsteHilfe.Selected := l;
          lvErsteHilfe.SetFocus;
          Exit;
        end;
      end;
      InsertNewEntryInDB(SelMitarbeiterID);
    end
    else
      begin
        fMain.tbErsteHilfeClick(nil);
      end;
  end;
end;






procedure TFrameErsteHilfe.InsertNewEntryInDB(MitarbeiterID: integer);
var
  FDQuery: TFDQuery;
  Datum: TDate;
begin
  Datum := dtpDatum.Date;

  FDQuery := TFDQuery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'INSERT INTO ausbildung (mitarbeiterid, objektid, ausbildungsartID, datum) ' +
                  'VALUES (:MAID, :OBID, :AUSBILDUNGSARTID, :DATUM);';

      Params.ParamByName('MAID').AsInteger  := MitarbeiterID;
      Params.ParamByName('OBID').AsInteger  := OBJEKTID;
      Params.ParamByName('AUSBILDUNGSARTID').AsInteger  := 5;
      Params.ParamByName('DATUM').AsString  := ConvertGermanDateToSQLDate(DateToStr(Datum), false);

      try
        ExecSQL;
      except
        on E: Exception do
        begin
          ShowMessage('Fehler beim Speichern des Eintrags!: ' + E.Message);
          Exit;
        end;
      end;
    end;
  finally
    FDQuery.Free;
  end;

  fMain.tbErsteHilfeClick(nil);
end;













procedure TFrameErsteHilfe.DeleteEntryFromDB(SelEntry: integer);
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDQuery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      showmessage('ID: ' + IntToStr(SelEntry));
      SQL.Text := 'DELETE FROM ausbildung WHERE id = :ID;';

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

  lvErsteHilfe.DeleteSelected;
end;






procedure TFrameErsteHilfe.lvErsteHilfeClick(Sender: TObject);
var
  i, a: Integer;
begin
  a := lvErsteHilfe.ItemIndex;

  if a <> -1 then
  begin
    SelEntry := StrToInt(lvErsteHilfe.Items[a].SubItems[0]);

    for i := 0 to cbMitarbeiter.Items.Count - 1 do
    begin
      if (cbMitarbeiter.Items.Objects[i] is TObject) then
      begin
        if Integer(cbMitarbeiter.Items.Objects[i]) = SelEntry then
        begin
          cbMitarbeiter.ItemIndex := i;
          dtpDatum.Date := StrToDate(lvErsteHilfe.Items[a].SubItems[2]);
          SelEntry         := StrToInt(lvErsteHilfe.Items[a].SubItems[0]);
          SelMitarbeiterID := StrToInt(lvErsteHilfe.Items[a].Caption);
          Exit;
        end;
      end;
    end;
  end
  else
  begin
    cbMitarbeiter.ItemIndex := -1;
    dtpDatum.Date := Date;
  end;
end;





procedure TFrameErsteHilfe.lvErsteHilfeColumnClick(Sender: TObject; Column: TListColumn);
begin
  lvColumnClickForSort(Sender, Column);
end;




procedure TFrameErsteHilfe.lvErsteHilfeCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  lvCompareForSort(Sender, Item1, Item2, Data, Compare);
end;




procedure TFrameErsteHilfe.lvErsteHilfeRightClickCell(Sender: TObject; iItem, iSubItem: Integer);
var
  i, spalte, SelEntry: integer;
begin
  i := lvErsteHilfe.ItemIndex;

  spalte := iSubItem - 1;

  if spalte > 0 then
  begin
    if MessageDlg('Wollen Sie diese Zeile wirklich entfernen', mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
    begin
      SelEntry := StrToInt(lvErsteHilfe.Items[i].SubItems[0]);
      DeleteEntryFromDB(SelEntry);
      fMain.tbErsteHilfeClick(nil);
    end;
  end;
end;






procedure TFrameErsteHilfe.lvErsteHilfeSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  i, a, maid: Integer;
begin
  a := lvErsteHilfe.ItemIndex;

  if a <> -1 then
  begin
    maid := StrToInt(lvErsteHilfe.Items[a].Caption);
    SelMitarbeiterID := maid;

    for i := 0 to cbMitarbeiter.Items.Count - 1 do
    begin
      if (cbMitarbeiter.Items.Objects[i] is TObject) then
      begin
        if Integer(cbMitarbeiter.Items.Objects[i]) = maid then
        begin
          cbMitarbeiter.ItemIndex := i;
          Exit;
        end;
      end;
    end;
  end
  else
  begin
    cbMitarbeiter.ItemIndex := 0;
    dtpDatum.Date := date;
    cbMitarbeiter.SetFocus;
  end;
end;









procedure TFrameErsteHilfe.DisplayHinweisString;
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








procedure TFrameErsteHilfe.InsertMitarbeiterInListView(lv: TListView; MitarbeiterID, ausbildungsart: integer);
var
  FDQuery: TFDQuery;
  l: TListItem;
  mitarbeitername: string;
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
                  'AND ausbildungsartID = :AUSBILDUNGSARTID;';

      Params.ParamByName('MITARBEITERID').AsInteger := MitarbeiterID; // ID aus ComboBox
      Params.ParamByName('AUSBILDUNGSARTID').AsInteger := ausbildungsart;

      Open;




//Mitarbeiter steht noch nicht in einer der Tabellen "ausbildung_theorie", "ausbildung_szenario" oder "ausbildung_waffenhandhabung"
      if(RecordCount = 0) then
      begin

//Mitarbeiterdaten aus den Tabellen "ausbildung_theorie", "ausbildung_szenario" oder "ausbildung_waffenhandhabung" auslesen
        SQL.Text := 'SELECT id, nachname || " " || SUBSTR(vorname, 1, 1) || "." AS Mitarbeiter ' +
                    'FROM mitarbeiter WHERE id = :MITARBEITERID;';

        Params.ParamByName('MITARBEITERID').AsInteger := MitarbeiterID;
        Open;


//Mitarbeiter in ListView eintragen
        if(MitarbeiterID > 0) then
        begin
          mitarbeiterid   := FieldByName('id').AsInteger;
          mitarbeitername := FieldByName('Mitarbeiter').AsString;

          l := LV.Items.Add;
          l.Caption := IntToStr(mitarbeiterid);  //ID
          l.SubItems.Add('x');  //MitarbeiterID
          l.SubItems.Add(mitarbeitername); //mitarbeitername
        end;
      end
      else
      begin
        SelectMitarbeiterInListView(lvErsteHilfe, mitarbeiterid);
      end;
    end;
  finally
    FDQuery.free;
  end;
end;








end.
