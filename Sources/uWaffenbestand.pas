unit uWaffenbestand;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, AdvListV, ExtCtrls, StdCtrls, Menus, ActnList,
  System.Actions, Vcl.Imaging.pngimage, System.ImageList,
  Vcl.ImgList, System.UITypes, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Stan.Param;

type
  TfWaffenbestand = class(TForm)
    Panel1: TPanel;
    lvWaffenbestand: TAdvListView;
    StatusBar1: TStatusBar;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    Label7: TLabel;
    edPos: TEdit;
    edNrWBK: TEdit;
    edWaffentyp: TEdit;
    edSeriennummer: TEdit;
    edFach: TEdit;
    btnSpeichern: TButton;
    Label5: TLabel;
    Label4: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    Label6: TLabel;
    btnNeueWaffe: TButton;
    btnEntferneWaffe: TButton;
    Label8: TLabel;
    Bevel1: TBevel;
    procedure btnSpeichernClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvWaffenbestandColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvWaffenbestandCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure lvWaffenbestandSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure lvWaffenbestandKeyPress(Sender: TObject; var Key: Char);
    procedure lvWaffenbestandKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnNeueWaffeClick(Sender: TObject);
    procedure btnEntferneWaffeClick(Sender: TObject);
  private
    procedure showWaffenbestandInListView(LV: TListView);
    procedure NeueWaffeEingeben;
  public
    { Public-Deklarationen }
  end;

var
  fWaffenbestand: TfWaffenbestand;
  NEUEWAFFE: boolean;
  SELID: integer;

implementation

uses uMain, uFunktionen;

{$R *.dfm}

procedure TfWaffenbestand.btnSpeichernClick(Sender: TObject);
var
  FDQuery: TFDQuery;
  l: TListItem;
  Pos, NrWBK, Waffentyp, SerienNr, Fach: string;
  ID, LastID: integer;
  SeriennummerVorhanden: Boolean;
begin
  ID        := SELID;
  Pos       := trim(edPos.Text);
  NrWBK     := trim(edNrWBK.Text);
  Waffentyp := trim(edWaffentyp.Text);
  SerienNr  := trim(edSeriennummer.Text);
  Fach      := trim(edFach.Text);

  // Prüfen ob Pflichtfelder ausgefüllt wurden
  if (NrWBK = '') OR (Waffentyp = '') OR (SerienNr = '') then
  begin
    showmessage('Bitte füllen Sie die Pflichtfelder aus!'+#13#10+'Pflichtfelder sind fett markiert');
    exit;
  end;

  // FDQuery initialisieren
  FDQuery := TFDquery.Create(nil);
  try
    // Verbindung herstellen
    FDQuery.Connection := fMain.FDConnection1;

    // Seriennummer nur bei neuen Datensätzen (INSERT) prüfen
    if (NEUEWAFFE = true) AND (SELID = -1) then
    begin
      // Überprüfen, ob die Seriennummer bereits existiert
      FDQuery.SQL.Text := 'SELECT COUNT(*) AS SeriennummerCount FROM waffenbestand WHERE seriennr = :SERIENNR;';
      FDQuery.Params.ParamByName('SERIENNR').AsString := SerienNr;
      FDQuery.Open;

      SeriennummerVorhanden := FDQuery.FieldByName('SeriennummerCount').AsInteger > 0;
      FDQuery.Close;

      if SeriennummerVorhanden then
      begin
        ShowMessage('Es existiert bereits ein Eintrag mit dieser Seriennummer.');
        Exit; // Insert-Vorgang abbrechen
      end;

      // Waffe in Datenbank einfügen, da Seriennummer nicht vorhanden ist
      FDQuery.SQL.Text := 'INSERT INTO waffenbestand (pos, nrwbk, waffentyp, seriennr, fach) ' +
                          'VALUES (:POS, :NRWBK, :WAFFENTYP, :SERIENNR, :FACH);';
      FDQuery.Params.ParamByName('POS').AsString := Pos;
      FDQuery.Params.ParamByName('NRWBK').AsString := NrWBK;
      FDQuery.Params.ParamByName('WAFFENTYP').AsString := Waffentyp;
      FDQuery.Params.ParamByName('SERIENNR').AsString := SerienNr;
      FDQuery.Params.ParamByName('FACH').AsString := Fach;
      FDQuery.ExecSQL;

      // ID des zuletzt eingefügten Datensatzes abrufen
      FDQuery.SQL.Text := 'SELECT last_insert_rowid() AS LastID';
      FDQuery.Open;
      LastID := FDQuery.FieldByName('LastID').AsInteger;
      FDQuery.Close;

      // Neuen Eintrag in die ListView einfügen
      l := lvWaffenbestand.Items.Add;
      l.Caption := Pos;
      l.SubItems.Add(NrWBK);
      l.SubItems.Add(Waffentyp);
      l.SubItems.Add(SerienNr);
      l.SubItems.Add(Fach);
      l.SubItems.Add(IntToStr(LastID));
    end
    else
    begin
      // Bestehende Waffe aktualisieren (kein INSERT)
      FDQuery.SQL.Text := 'UPDATE waffenbestand SET pos = :POS, nrwbk = :NRWBK, waffentyp = :WAFFENTYP, ' +
                          'seriennr = :SERIENNR, fach = :FACH ' +
                          'WHERE id = :ID;';
      FDQuery.Params.ParamByName('ID').AsInteger := ID;
      FDQuery.Params.ParamByName('POS').AsString := Pos;
      FDQuery.Params.ParamByName('NRWBK').AsString := NrWBK;
      FDQuery.Params.ParamByName('WAFFENTYP').AsString := Waffentyp;
      FDQuery.Params.ParamByName('SERIENNR').AsString := SerienNr;
      FDQuery.Params.ParamByName('FACH').AsString := Fach;
      FDQuery.ExecSQL;

      // ListView aktualisieren
      with lvWaffenbestand.Items[lvWaffenbestand.ItemIndex] do
      begin
        Caption := Pos;
        SubItems[0] := NrWBK;
        SubItems[1] := Waffentyp;
        SubItems[2] := SerienNr;
        SubItems[3] := Fach;
        SubItems[4] := IntToStr(ID);
      end;
    end;
  finally
    FDQuery.Free;
  end;

  // Schaltflächenstatus aktualisieren
  if (lvWaffenbestand.Items.Count = WAFFENBESTAND) then
  begin
    btnSpeichern.Enabled := false;
    btnNeueWaffe.Enabled := false;
  end
  else
  begin
    btnSpeichern.Enabled := true;
    btnNeueWaffe.Enabled := true;
  end;

  NeueWaffeEingeben;
end;





procedure TfWaffenbestand.btnEntferneWaffeClick(Sender: TObject);
var
  FDQuery: TFDQuery;
begin
  if(lvWaffenbestand.ItemIndex <> -1) then
  begin
    if MessageDlg('Wollen Sie diese Waffe wirklich aus der Datenbank entfernen?', mtConfirmation, [mbyes, mbno], 0) = mrYes then
    begin
      FDQuery := TFDquery.Create(nil);
      try
        with FDQuery do
        begin
          Connection := fMain.FDConnection1;

          SQL.Text := 'DELETE FROM waffenbestand WHERE id = :ID;';

          Params.ParamByName('ID').AsInteger := StrToInt(lvWaffenbestand.Items[lvWaffenbestand.ItemIndex].SubItems[4]);
          ExecSQL;
        end;
      finally
        FDQuery.free;
      end;
      lvWaffenbestand.DeleteSelected;
    end;
    if(lvWaffenbestand.Items.Count = WAFFENBESTAND) then
    begin
      btnSpeichern.Enabled := false;
      btnNeueWaffe.Enabled := false;
    end
    else
    begin
      btnSpeichern.Enabled := true;
      btnNeueWaffe.Enabled := true;
    end;
  end;
end;




procedure TfWaffenbestand.btnNeueWaffeClick(Sender: TObject);
begin
  if(lvWaffenbestand.Items.Count < WAFFENBESTAND) then
  begin
    NeueWaffeEingeben;
  end
  else
  begin
    btnSpeichern.Enabled := false;
    btnNeueWaffe.Enabled := false;
    showmessage('Sie können keine weitere Waffe eingeben.'+#13#10+#13#10+'Sie haben bereits ' + IntToStr(WAFFENBESTAND)+ ' Waffen eingegeben.'+#13#10+'Dies ist die Anzahl, die Sie als Waffenbestand in diesem Objekt angegeben haben!');

    exit;
  end;
end;


{********************************************************
  Alle Waffen aus der Datenbanktabelle "Waffenbestand"  *
  auslesen und in ListView anzeigen                     *
********************************************************}
procedure TfWaffenbestand.FormShow(Sender: TObject);
begin
  showWaffenbestandInListView(lvWaffenbestand);
  NeueWaffeEingeben;

  if(lvWaffenbestand.Items.Count = WAFFENBESTAND) then
  begin
    btnSpeichern.Enabled := false;
    btnNeueWaffe.Enabled := false;
  end
  else
  begin
    btnSpeichern.Enabled := true;
    btnNeueWaffe.Enabled := true;
  end;
end;




procedure TfWaffenbestand.lvWaffenbestandColumnClick(Sender: TObject; Column: TListColumn);
begin
  lvColumnClickForSort(Sender, Column);
end;



procedure TfWaffenbestand.lvWaffenbestandCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  lvCompareForSort(Sender, Item1, Item2, Data, Compare);
end;







//Die Position von Einträgen mit der + oder - Taste verändern
procedure TfWaffenbestand.lvWaffenbestandKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  i, id, posVorher, posNachher: integer;
  FDQuery: TFDQuery;
  UPDATEDB: boolean;
begin
  posNachher := 0;
  UPDATEDB   := false;

  if lvWaffenbestand.Selected <> nil then
  begin
    i  := lvWaffenbestand.ItemIndex;
    id := StrToInt(lvWaffenbestand.Items[i].SubItems[4]);


    if Key = VK_OEM_PLUS then
    begin
      posVorher  := StrToInt(lvWaffenbestand.Items[i].Caption);
      posNachher := posVorher + 1;
      UPDATEDB   := true;
    end
    else if Key = VK_OEM_MINUS then
    begin
      posVorher := StrToInt(lvWaffenbestand.Items[i].Caption);
      if(posVorher > 0) then posNachher := posVorher - 1 else posNachher := 0;
      UPDATEDB := true;
    end;


    if(UPDATEDB = true) then
    begin
      FDQuery := TFDquery.Create(nil);
      try
        with FDQuery do
        begin
          Connection := fMain.FDConnection1;

          SQL.Text := 'UPDATE waffenbestand SET pos = :POS ' +
                      'WHERE id = :ID;';

          Params.ParamByName('ID').AsInteger := id;
          Params.ParamByName('POS').AsInteger := posNachher;

          ExecSQL;

          lvWaffenbestand.Items[i].Caption := IntToStr(posNachher);
        end;
      finally
        FDQuery.free;
      end;
    end;
  end;
  ColumnToSort := 0; //Spalte 0=Caption, 1=erstes SubItem
  SortDir      := 0; //Aufsteigend- oder absteigend sortieren 0 = A-Z, 1 = Z-A
  lvWaffenbestand.AlphaSort; //Sortierung anwenden
end;







procedure TfWaffenbestand.lvWaffenbestandKeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
end;

procedure TfWaffenbestand.lvWaffenbestandSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if(Selected) then
  begin
    NEUEWAFFE := false;
    btnSpeichern.Caption := 'Speichern';
    btnSpeichern.Enabled := true;
    edPos.Text := Item.Caption;
    edNrWBK.Text := Item.SubItems[0];
    edWaffentyp.Text := Item.SubItems[1];
    edSeriennummer.Text := Item.SubItems[2];
    edFach.Text := Item.SubItems[3];
    SELID := StrToInt(Item.SubItems[4]);
    btnEntferneWaffe.Enabled := true;
  end
  else
  begin
    NeueWaffeEingeben;
  end;
end;




procedure TfWaffenbestand.showWaffenbestandInListView(LV: TListView);
var
  l: TListItem;
  FDQuery: TFDQuery;
begin
  ClearListView(LV);

  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT id, pos, nrwbk, waffentyp, seriennr, fach ' +
                  'FROM waffenbestand ORDER BY pos ASC;';
      Open;

      while not Eof do
      begin
        l := LV.Items.Add;
        l.Caption := FieldByName('pos').AsString;
        l.SubItems.Add(FieldByName('nrwbk').AsString);
        l.SubItems.Add(FieldByName('waffentyp').AsString);
        l.SubItems.Add(FieldByName('seriennr').AsString);
        l.SubItems.Add(FieldByName('fach').AsString);
        l.SubItems.Add(FieldByName('id').AsString);
        Next;
      end;
    end;
  finally
    FDQuery.free;
  end;
end;





procedure TfWaffenbestand.NeueWaffeEingeben;
var
  newPos: integer;
  anzahl: integer;
begin
  NEUEWAFFE := true;
  SELID := -1;
  btnSpeichern.Caption := 'Hinzufügen';
  lvWaffenbestand.ItemIndex := -1;
  edNrWBK.Clear;
  edWaffentyp.Text := 'H+K P8';
  edSeriennummer.Clear;
  edFach.Clear;
  edNrWBK.SetFocus;

  anzahl := lvWaffenbestand.Items.Count-1;
  if(anzahl <> -1) then
    newPos := StrToInt(lvWaffenbestand.Items[lvWaffenbestand.Items.Count-1].Caption)+1
  else
    newPos := 1;

  edPos.Text := IntToStr(newPos);

  btnEntferneWaffe.Enabled := false;
end;


end.
