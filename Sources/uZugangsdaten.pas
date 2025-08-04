unit uZugangsdaten;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, AdvListV, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, DateUtils, System.hash, System.UITypes, Vcl.Mask;

type
  TfZugangsdaten = class(TForm)
    Panel1: TPanel;
    Label7: TLabel;
    Label2: TLabel;
    lvZugangsdaten: TAdvListView;
    Panel2: TPanel;
    edPasswort: TLabeledEdit;
    btnSpeichern: TButton;
    Label1: TLabel;
    cbMitarbeiter: TComboBox;
    edUsername: TLabeledEdit;
    procedure FormShow(Sender: TObject);
    procedure lvZugangsdatenClick(Sender: TObject);
    procedure btnSpeichernClick(Sender: TObject);
    procedure cbMitarbeiterSelect(Sender: TObject);
    procedure lvZugangsdatenRightClickCell(Sender: TObject; iItem,
      iSubItem: Integer);
  private
    procedure showAdminsInListView(LV: TListView);
    procedure InsertIntoDB;
    procedure UpdateInDB;
  public
    { Public-Deklarationen }
  end;

var
  fZugangsdaten: TfZugangsdaten;
  NEWENTRY: boolean;
  ENTRYID: integer;
  MAID: integer;
  DBPW: string;

implementation

{$R *.dfm}

uses uMain, uFunktionen, uDBFunktionen;



{******************************************************************************************
  Alle Mitarbeiter aus Datenbank-Tabelle mitarbeiter auslesen und in ListView anzeigen    *
******************************************************************************************}
procedure TfZugangsdaten.btnSpeichernClick(Sender: TObject);
begin
  if(NEWENTRY = true) AND (ENTRYID = -1) then
  begin
    InsertIntoDB;
  end
  else if(NEWENTRY = false) AND (ENTRYID <> -1) then
  begin
    UpdateInDB;
  end;
end;






procedure TfZugangsdaten.InsertIntoDB;
var
  FDQuery: TFDQuery;
begin
  if(cbMitarbeiter.ItemIndex <=0) OR (trim(edUsername.Text)='') OR (trim(edPasswort.Text)='') then
  begin
    showmessage('Bitte wählen Sie einen Mitarbeiter aus und geben Sie einen Usernamen und ein Passwort ein!');
    exit;
  end;

  if(NEWENTRY = true) AND (ENTRYID = -1) then
  begin
    FDQuery := TFDquery.Create(nil);
    try
      FDQuery.Connection := fMain.FDConnection1;
      FDQuery.SQL.Text := 'INSERT INTO admins (mitarbeiterid, username, password) ' +
                          'VALUES (:MITARBEITERID, :USERNAME, :PASSWORT);';
      FDQuery.Params.ParamByName('MITARBEITERID').AsInteger := Integer(cbMitarbeiter.Items.Objects[cbMitarbeiter.ItemIndex]);
      FDQuery.Params.ParamByName('USERNAME').AsString := edUsername.Text;
      FDQuery.Params.ParamByName('PASSWORT').AsString := THashSHA1.GetHashString(trim(edPasswort.Text));

      try
        FDQuery.ExecSQL;
      except
        on E: Exception do
          ShowMessage('Fehler beim Speichern der Mitarbeiterdaten: ' + E.Message);
      end;
    finally
      FDQuery.Free;
      showAdminsInListView(lvZugangsdaten);
      NEWENTRY  := true;
      ENTRYID := -1;
      cbMitarbeiter.ItemIndex := 0;
      edUsername.clear;
      edPasswort.clear;
      lvZugangsdaten.ItemIndex := -1;
      btnSpeichern.Caption  := 'Hinzufügen';
    end;
  end;
end;








procedure TfZugangsdaten.UpdateInDB;
var
  FDQuery: TFDQuery;
begin
  if(cbMitarbeiter.ItemIndex <= 0) OR (trim(edPasswort.Text)='') then
  begin
    showmessage('Bitte geben Sie Username und Passwort ein!');
    exit;
  end;

  if(NEWENTRY = False) AND (ENTRYID <> -1) AND (DBPW <> '') then
  begin
    FDQuery := TFDquery.Create(nil);
    try
      FDQuery.Connection := fMain.FDConnection1;
      FDQuery.SQL.Text := 'UPDATE admins SET mitarbeiterID = :MITARBEITERID, username = :USERNAME, ' +
                          'password = :PASSWORT WHERE id = :ID;';
      FDQuery.Params.ParamByName('ID').AsInteger := ENTRYID;
      FDQuery.Params.ParamByName('MITARBEITERID').AsInteger := MAID;
      FDQuery.Params.ParamByName('USERNAME').AsString := trim(edUsername.Text);
      if(DBPW = edPasswort.Text) then
        FDQuery.Params.ParamByName('PASSWORT').AsString := edPasswort.Text
      else
        FDQuery.Params.ParamByName('PASSWORT').AsString := THashSHA1.GetHashString(trim(edPasswort.Text));

      try
        FDQuery.ExecSQL;
      except
        on E: Exception do
          ShowMessage('Fehler beim Speichern der Mitarbeiterdaten: ' + E.Message);
      end;
    finally
      FDQuery.Free;
      showAdminsInListView(lvZugangsdaten);
      NEWENTRY  := true;
      ENTRYID := -1;
      cbMitarbeiter.ItemIndex := 0;
      edUsername.clear;
      edPasswort.clear;
      lvZugangsdaten.ItemIndex := -1;
      btnSpeichern.Caption  := 'Hinzufügen';
    end;
  end;
end;






procedure TfZugangsdaten.cbMitarbeiterSelect(Sender: TObject);
var
  i: integer;
begin
  i := cbMitarbeiter.ItemIndex;
  if i <> -1 then
  begin
    if cbMitarbeiter.ItemIndex > 0 then
    begin
      MAID := Integer(cbMitarbeiter.Items.Objects[i]);
    end;
  end
  else
  begin
    showmessage('Bitte wählen Sie einen Mitarbeiter aus der Auswahlbox aus.');
  end;
end;






procedure TfZugangsdaten.FormShow(Sender: TObject);
begin
  NEWENTRY := true;
  ENTRYID := -1;
  DBPW := '';

  showMitarbeiterInComboBox(cbMitarbeiter, MonthOf(now), YearOf(now), true, false, OBJEKTID, 3);
  showAdminsInListView(lvZugangsdaten);
end;




procedure TfZugangsdaten.lvZugangsdatenClick(Sender: TObject);
var
  m, i: integer;
begin
  i := lvZugangsdaten.ItemIndex;
  if(i <> -1) then
  begin
    NEWENTRY := false;
    ENTRYID  := StrToInt(lvZugangsdaten.Items[i].Caption);
    MAID     := StrToInt(lvZugangsdaten.Items[i].SubItems[0]);
    btnSpeichern.Caption := 'Speichern';

    edUsername.Text := lvZugangsdaten.Items[i].SubItems[2];
    edPasswort.Text := lvZugangsdaten.Items[i].SubItems[3];
    DBPW := lvZugangsdaten.Items[i].SubItems[3];

    if(lvZugangsdaten.Items[i].SubItems[0] <> '') then
    begin
      for m := 0 to cbMitarbeiter.Items.Count - 1 do
      begin
        if Integer(cbMitarbeiter.Items.Objects[m]) = StrToInt(lvZugangsdaten.Items[i].SubItems[0]) then
        begin
          cbMitarbeiter.ItemIndex := m;
          Exit;
        end;
      end;
    end
    else
    begin
      cbMitarbeiter.ItemIndex := 0;
    end;
  end
  else
  begin
    NEWENTRY  := true;
    ENTRYID := -1;
    cbMitarbeiter.ItemIndex := 0;
    edUsername.clear;
    edPasswort.clear;
    lvZugangsdaten.ItemIndex := -1;
    btnSpeichern.Caption  := 'Hinzufügen';
  end;
end;





procedure TfZugangsdaten.lvZugangsdatenRightClickCell(Sender: TObject; iItem, iSubItem: Integer);
var
  FDQuery: TFDQuery;
begin
  if MessageDlg('Wollen Sie diesen Administrator wirklich löschen?',
      mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
  begin
    FDQuery := TFDquery.Create(nil);
    try
      FDQuery.Connection := fMain.FDConnection1;
      FDQuery.SQL.Text := 'DELETE FROM admins WHERE id = :ID;';
      FDQuery.Params.ParamByName('ID').AsInteger := StrToInt(lvZugangsdaten.Items[iItem].Caption);

      try
        FDQuery.ExecSQL;
      except
        on E: Exception do
          ShowMessage('Fehler beim Löschen des Admins: ' + E.Message);
      end;
    finally
      FDQuery.Free;
      lvZugangsdaten.DeleteSelected;
    end;
  end;
end;







procedure TfZugangsdaten.showAdminsInListView(LV: TListView);
var
  L: TListItem;
  FDQuery: TFDQuery;
begin
  ClearListView(LV);

  FDQuery := TFDquery.Create(nil);
  try
    FDQuery.Connection := fMain.FDConnection1;

    if(objektid > 0) then
    begin
      FDQuery.SQL.Text := 'SELECT A.id, A.username, A.password, M.id AS mitarbeiterID, M.nachname || " " || M.vorname AS Mitarbeiter ' +
                          'FROM admins AS A LEFT JOIN mitarbeiter AS M ON M.id = A.mitarbeiterID ' +
                          'ORDER BY A.username ASC;';
      FDQuery.Open;
    end
    else
    begin
      exit;
    end;

    while not FDQuery.Eof do
    begin
      l := LV.Items.Add;
      l.Caption := FDQuery.FieldByName('id').AsString;
      l.SubItems.Add(FDQuery.FieldByName('mitarbeiterID').AsString);
      l.SubItems.Add(FDQuery.FieldByName('Mitarbeiter').AsString);
      l.SubItems.Add(FDQuery.FieldByName('username').AsString);
      l.SubItems.Add(FDQuery.FieldByName('password').AsString);

      FDQuery.Next;
    end;
  finally
    FDQuery.free;
  end;
end;




end.
