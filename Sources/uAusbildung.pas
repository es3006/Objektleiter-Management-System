unit uAusbildung;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, AdvListV, TaskDialog,
  Vcl.StdCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls, DateUtils, AdvCustomControl,
  AdvWebBrowser, AdvDateTimePicker, inifiles, ShellApi, Vcl.Menus,
  System.Actions, Vcl.ActnList, System.UITypes, Math,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param;

type
  TfAusbildung = class(TForm)
    Panel1: TPanel;
    Label7: TLabel;
    Label8: TLabel;
    StatusBar1: TStatusBar;
    Panel3: TPanel;
    btnSpeichern: TButton;
    Panel2: TPanel;
    Label1: TLabel;
    Label9: TLabel;
    cbMonat: TComboBox;
    cbJahr: TComboBox;
    ActionList1: TActionList;
    acDelEntry: TAction;
    pmAusbildung: TPopupMenu;
    Eintraglschen1: TMenuItem;
    Image1: TImage;
    lvAusbildung: TAdvListView;
    Label2: TLabel;
    dtpDatum: TAdvDateTimePicker;
    cbMitarbeiter: TComboBox;
    cbAusbildungsarten: TComboBox;
    lbDatum: TLabel;
    Label3: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnSpeichernClick(Sender: TObject);
    procedure cbMonatSelect(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure acDelEntryUpdate(Sender: TObject);
    procedure acDelEntryExecute(Sender: TObject);
    procedure lvAusbildungColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvAusbildungCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure cbMitarbeiterSelect(Sender: TObject);
    procedure lvMitarbeiterAusbildungClick(Sender: TObject);
    procedure lvMitarbeiterAusbildungColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvMitarbeiterAusbildungCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure dtpDatumKeyPress(Sender: TObject; var Key: Char);
  private
    procedure ShowAusbildungsdatenInListViews;
  public
    { Public-Deklarationen }
  end;

var
  fAusbildung: TfAusbildung;
  NEWENTRY: boolean;
  SELID, SEITE: integer;
  TITEL: string;
  mitarbeiterid: integer;
  Nachname, Vorname, AusbSchiessen, AusbWaffenhandh, AusbTheorie, AusbSzenario, AusbErsteh: string;
  PersonalNr, swanr, ehdatum: string;
  Eintrittsdatum, Austrittsdatum, WaffenNr, Ausweisnr, SaNr: string;




implementation

uses
  uMain, uDBFunktionen, uFunktionen;

{$R *.dfm}
{$R Gesamtausbildung.res}




procedure TfAusbildung.acDelEntryExecute(Sender: TObject);
var
  q: TFDQuery;
begin
  //showmessage(inttostr(lvAusbildung.Items.Count));
  if MessageDlg('Wollen Sie diesen Eintrag wirklich löschen?', mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
  begin
    q := TFDquery.Create(nil);
    try
      with q do
      begin
        Connection := fMain.FDConnection1;
        fMain.FDConnection1.Connected := true;

        SQL.Clear;
        SQL.Add('DELETE FROM ausbildung WHERE id = :ID');
        Params.ParamByName('ID').AsInteger := SELID;
        ExecSQL;

        fMain.FDConnection1.Connected := false;
      end;
    finally
      q.Free;
    end;
    ShowAusbildungsdatenInListViews;
  end;
end;





procedure TfAusbildung.acDelEntryUpdate(Sender: TObject);
begin
  if(lvAusbildung.ItemIndex<>-1) then
    acDelEntry.Enabled := true
  else
    acDelEntry.Enabled := false;
end;






procedure TfAusbildung.btnSpeichernClick(Sender: TObject);
var
  q: TFDQuery;
  Datum: TDate;
  i, a, AusbArtID, MitarbeiterID, Monat, Jahr: integer;
  Mitarbeiter: string;
begin
  i := cbMitarbeiter.ItemIndex;
  a := cbAusbildungsarten.ItemIndex;

  if(i > 0) AND (a > -1) then
  begin
    Monat         := MonthOf(dtpDatum.Date);
    Jahr          := YearOf(dtpDatum.Date);
    MitarbeiterID := Integer(cbMitarbeiter.Items.Objects[i]);
    AusbArtID     := Integer(cbAusbildungsarten.Items.Objects[cbAusbildungsarten.ItemIndex]);
    Mitarbeiter   := cbMitarbeiter.Text;
    Datum         := dtpDatum.Date;

    //INSERT
    if(SELID = -1) then
    begin
      q := TFDquery.Create(nil);
      try
        with q do
        begin
          Connection := fMain.FDConnection1;
          fMain.FDConnection1.Connected := true;

          SQL.Clear;
          SQL.Add('INSERT INTO ausbildung (ausbildungsartid, mitarbeiterid, datum)');
          SQL.Add('VALUES (:AID, :MAID, :DATUM);');
          Params.ParamByName('AID').AsInteger  := AusbArtID;
          Params.ParamByName('MAID').AsInteger := MitarbeiterID;
          Params.ParamByName('DATUM').AsDate   := dtpDatum.Date;
          ExecSQL;

          fMain.FDConnection1.Connected := false;
       end;
      finally
        q.Free;
      end;
    end;


    //UPDATE
    if(SELID > -1) then
    begin
      q := TFDquery.Create(nil);
      try
        with q do
        begin
          Connection := fMain.FDConnection1;
          fMain.FDConnection1.Connected := true;

          SQL.Clear;
          SQL.Add('UPDATE ausbildung SET ausbildungsartid = :AID, datum = :DATUM WHERE id = :ID');
          Params.ParamByName('ID').AsInteger := SELID;
          Params.ParamByName('AID').AsInteger := AusbArtID;
          Params.ParamByName('DATUM').AsDate := dtpDatum.Date;
          ExecSQL;

          fMain.FDConnection1.Connected := false;
        end;
      finally
        q.Free;
      end;
    end;

    ShowAusbildungsdatenInListViews;
  end
  else
  begin
    showmessage('Bitte füllen Sie die Pflichtfelder aus!'+#13#10+'Pflichtfelder sind fett markiert');
    exit;
  end;
end;







procedure TfAusbildung.ShowAusbildungsdatenInListViews;
var
  q: TFDQuery;
  l: TListItem;
  i, maid, monat, jahr: integer;
  selectedMonth, selectedYear: Integer;
  currentDate: TDateTime;
  updatedDate: TDateTime;
begin
  selectedMonth := cbMonat.ItemIndex+1;
  selectedYear  := StrToIntDef(cbJahr.Text, YearOf(Now));
  currentDate   := now;

  updatedDate   := EncodeDate(selectedYear, selectedMonth, DayOf(currentDate));
  dtpDatum.Date := updatedDate;



  i := cbMitarbeiter.ItemIndex;
  if(i<>-1) then
  begin
    maid := Integer(cbMitarbeiter.Items.Objects[i]);
    if(maid <> -1) then
    begin
      monat := cbMonat.ItemIndex+1;
      jahr  := StrToInt(cbJahr.Text);

      lvAusbildung.Items.Clear;

      q := TFDquery.Create(nil);
      try
        with q do
        begin
          Connection := fMain.FDConnection1;
          fMain.FDConnection1.Connected := true;

          SQL.Clear;
          SQL.Add('SELECT A.id, A.datum, B.ausbildungsart');
          SQL.Add('FROM ausbildung AS A LEFT JOIN ausbildungsarten AS B ON B.id = A.ausbildungsartid');
          SQL.Add('WHERE (A.mitarbeiterid = :MAID) AND (');
          SQL.Add('(MONTH(A.datum) = :MONAT AND YEAR(A.datum) = :JAHR))');
          SQL.Add('ORDER BY datum ASC');
          Params.ParamByName('MAID').AsInteger  := maid;
          Params.ParamByName('MONAT').AsInteger := Monat;
          Params.ParamByName('JAHR').AsInteger  := Jahr;
          Open;

          while not Eof do
          begin
            l := lvAusbildung.Items.Add;
            l.Caption := FieldByName('id').AsString;

            if(FieldByName('datum').AsString <> '01.01.0001') then
              l.SubItems.Add(FieldByName('datum').AsString)
            else l.SubItems.Add('-----');

           l.SubItems.Add(FieldByName('ausbildungsart').AsString);

            Next;
          end;

          fMain.FDConnection1.Connected := false;
        end;
      finally
        q.free;
      end;
    end;
  end;
end;















procedure TfAusbildung.cbMitarbeiterSelect(Sender: TObject);
begin
  ShowAusbildungsdatenInListViews;
end;

procedure TfAusbildung.cbMonatSelect(Sender: TObject);
begin
  ShowAusbildungsdatenInListViews;
  SELID := -1;
  cbAusbildungsarten.ItemIndex := -1;
  btnSpeichern.Caption := 'Eintrag hinzufügen';
end;





procedure TfAusbildung.dtpDatumKeyPress(Sender: TObject; var Key: Char);
begin
  if(Key = #13) then
  begin
    btnSpeichernClick(self);
    Key := #0;
  end;
end;




procedure TfAusbildung.FormShow(Sender: TObject);
var
  CurrentMonth, CurrentYear, StartYear: Integer;
  Index: Integer;
begin
  NEWENTRY := true;
  SELID    := -1;

  CurrentMonth := MonthOf(Now); // Den aktuellen Monat ermitteln (1 bis 12)
  cbMonat.ItemIndex := CurrentMonth - 1;

  //Die Jahre von 2023 bis aktuelles Jahr + 1 in cbJahr anzeigen
  CurrentYear := YearOf(Now);
  StartYear := 2023;
  for CurrentYear := StartYear to CurrentYear + 1 do
    cbJahr.Items.Add(IntToStr(CurrentYear));

  //Das aktuelle Jahr auswählen
  CurrentYear := YearOf(Now);
  Index := cbJahr.Items.IndexOf(IntToStr(CurrentYear));
  if Index <> -1 then cbJahr.ItemIndex := Index;

  showAusbildungsartenInComboBox(cbAusbildungsarten);

  showMitarbeiterInComboBox(cbMitarbeiter, CurrentMonth, CurrentYear, false, OBJEKTID);

  ClearListView(lvAusbildung);

  ShowAusbildungsdatenInListViews;

  dtpDatum.Date := now;
end;




procedure TfAusbildung.Image1Click(Sender: TObject);
var
  selectedMonth, selectedYear: Integer;
  currentDate: TDateTime;
  updatedDate: TDateTime;
begin
  selectedMonth := cbMonat.ItemIndex+1;
  selectedYear  := StrToIntDef(cbJahr.Text, YearOf(Now));
  currentDate   := now;
  updatedDate   := EncodeDate(selectedYear, selectedMonth, DayOf(currentDate));

  SELID := -1;
  cbAusbildungsarten.ItemIndex := -1;
  dtpDatum.Date := updatedDate;
  caption := 'Neuen Eintrag einfügen...';
  btnSpeichern.Caption := 'Eintrag hinzufügen';
  cbMitarbeiter.SetFocus;
  lvAusbildung.ItemIndex := -1;
end;







procedure TfAusbildung.lvMitarbeiterAusbildungClick(Sender: TObject);
var
  i: Integer;
  selectedMonth, selectedYear: Integer;
  currentDate: TDateTime;
  updatedDate: TDateTime;
begin
  selectedMonth := cbMonat.ItemIndex+1;
  selectedYear  := StrToIntDef(cbJahr.Text, YearOf(Now));
  currentDate   := now;
  updatedDate   := EncodeDate(selectedYear, selectedMonth, DayOf(currentDate));

  i := lvAusbildung.ItemIndex;
  if(i<>-1) then
  begin
    SELID := StrToInt(lvAusbildung.Items[i].Caption);

    //Datum
    if(lvAusbildung.Items[i].SubItems[0] <> '-----') then
      dtpDatum.Date := StrToDate(lvAusbildung.Items[i].SubItems[0])
    else
      dtpDatum.Date := now;

    //Ausbildungsart
    cbAusbildungsarten.ItemIndex := cbAusbildungsarten.Items.IndexOf(lvAusbildung.Items[i].SubItems[1]);


    caption := 'Eintrag bearbeiten...';
    btnSpeichern.Caption := 'Änderung speichern';
  end
  else
  begin
    SELID := -1;
    cbAusbildungsarten.ItemIndex := -1;
    dtpDatum.Date := updatedDate;
    caption := 'Neuen Eintrag einfügen...';
    btnSpeichern.Caption := 'Eintrag hinzufügen';
  end;
end;






procedure TfAusbildung.lvMitarbeiterAusbildungColumnClick(Sender: TObject; Column: TListColumn);
begin
  lvColumnClickForSort(Sender, Column);
end;






procedure TfAusbildung.lvMitarbeiterAusbildungCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  lvCompareForSort(Sender, Item1, Item2, Data, Compare);
end;





procedure TfAusbildung.lvAusbildungColumnClick(Sender: TObject; Column: TListColumn);
begin
  lvColumnClickForSort(Sender, Column);
end;






procedure TfAusbildung.lvAusbildungCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  lvCompareForSort(Sender, Item1, Item2, Data, Compare);
end;




end.
