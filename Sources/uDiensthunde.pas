unit uDiensthunde;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, AdvListV, Vcl.StdCtrls, System.UITypes,
  Vcl.ExtCtrls, FireDAC.Stan.Param, FireDAC.Phys.SQLite, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfDiensthunde = class(TForm)
    Panel1: TPanel;
    Label12: TLabel;
    Label2: TLabel;
    lvDiensthunde: TAdvListView;
    Label1: TLabel;
    edDiensthundname: TEdit;
    btnAddUpdate: TButton;
    btnNew: TButton;
    procedure lvDiensthundeSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure FormShow(Sender: TObject);
    procedure btnAddUpdateClick(Sender: TObject);
    procedure lvDiensthundeRightClickCell(Sender: TObject; iItem, iSubItem: Integer);
    procedure btnNewClick(Sender: TObject);
    procedure edDiensthundnameChange(Sender: TObject);
  private
    procedure InsertNewEntryInDB;
    procedure UpdateEntryInDB(ID: integer);
    procedure showAlleDiensthundeInListView;
  public
    { Public-Deklarationen }
  end;

var
  fDiensthunde: TfDiensthunde;
  NEWENTRY: boolean;
  SelDiensthundID: integer;



implementation

{$R *.dfm}

uses
  uMain;



procedure TfDiensthunde.btnAddUpdateClick(Sender: TObject);
var
  i: integer;
begin
  if(NEWENTRY = true) then
  begin
    showmessage('INSERT');
    InsertNewEntryInDB;
  end;

  if(NEWENTRY = false) then
  begin
    showmessage('UPDATE');
    i := lvDiensthunde.ItemIndex;
    if(i<>-1) then
    begin
      UpdateEntryInDB(StrToInt(lvDiensthunde.Items[i].SubItems[0]));
    end;
  end;

  NEWENTRY := true;

  edDiensthundname.Clear;
  edDiensthundname.SetFocus;
  btnAddUpdate.Enabled := false;
end;






procedure TfDiensthunde.InsertNewEntryInDB;
var
  FDQuery: TFDQuery;
  LastInsertID: integer;
  l: TListItem;
begin
  FDQuery := TFDQuery.Create(nil);
  with FDQuery do
  begin
    Connection := fMain.FDConnection1;

    SQL.Text := 'INSERT INTO diensthunde (diensthundname) ' +
                'VALUES(:DIENSTHUNDNAME);';
    Params.ParamByName('DIENSTHUNDNAME').AsString := edDiensthundname.Text;
    try
      ExecSQL;
    except
      on E: Exception do
        ShowMessage('Fehler beim Speichern des neuen Diensthundes: ' + E.Message);
    end;

    SQL.Text := 'SELECT last_insert_rowid() AS LastID';
    Open;
    LastInsertID := FieldByName('LastID').AsInteger;

    l := lvDiensthunde.Items.Add;
    l.Caption := edDiensthundname.Text;
    l.SubItems.Add(IntToStr(LastInsertID));
  end;
end;





procedure TfDiensthunde.UpdateEntryInDB(ID: integer);
var
  FDQuery: TFDQuery;
  i: integer;
begin
  FDQuery := TFDQuery.Create(nil);
  with FDQuery do
  begin
    Connection := fMain.FDConnection1;

    SQL.Text := 'UPDATE diensthunde SET diensthundname = :DIENSTHUNDNAME WHERE ID = :ID';
    Params.ParamByName('DIENSTHUNDNAME').AsString := edDiensthundname.Text;
    Params.ParamByName('ID').AsInteger := ID;

    try
      ExecSQL;
    except
      on E: Exception do
        ShowMessage('Fehler beim Ändern des Diensthundes: ' + E.Message);
    end;

    i := lvDiensthunde.ItemIndex;
    if(i <> -1) then
    begin
      lvDiensthunde.Items[i].Caption := edDiensthundname.Text;
    end;
  end;
end;





procedure TfDiensthunde.btnNewClick(Sender: TObject);
begin
  NEWENTRY := true;
  lvDiensthunde.ItemIndex := -1;
  edDiensthundname.Clear;
  edDiensthundname.SetFocus;
  btnAddUpdate.Caption := 'Hinzufügen';
end;




procedure TfDiensthunde.edDiensthundnameChange(Sender: TObject);
begin
  btnAddUpdate.Enabled := true;
end;

procedure TfDiensthunde.FormShow(Sender: TObject);
begin
  NEWENTRY := true;

  showAlleDiensthundeInListView;
end;





procedure TfDiensthunde.lvDiensthundeRightClickCell(Sender: TObject; iItem, iSubItem: Integer);
var
  FDQuery: TFDQuery;
begin
  if(MessageDlg('Wollen Sie diesen Diensthund wirklich löschen?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    FDQuery := TFDquery.Create(nil);
    try
      FDQuery.Connection := fMain.FDConnection1;

      with FDQuery do
      begin
        SQL.Text := 'DELETE FROM diensthunde WHERE id = :ID;';
        Params.ParamByName('ID').AsInteger := SelDiensthundID;

        try
          ExecSQL;
        except
          on E: Exception do
            ShowMessage('Fehler beim löschen des Diensthundes aus der Tabelle "diensthunde": ' + E.Message);
        end;

      end;
    finally
      lvDiensthunde.DeleteSelected;
      FDQuery.Free;
    end;
  end;
end;




procedure TfDiensthunde.lvDiensthundeSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  i: integer;
begin
  i := lvDiensthunde.ItemIndex;

  if(i <> -1) then
  begin
    NEWENTRY := false;
    SelDiensthundID := StrToInt(lvDiensthunde.Items[i].SubItems[0]);
    btnAddUpdate.Caption := 'Speichern';
    edDiensthundname.Text := lvDiensthunde.Items[i].Caption;
    edDiensthundname.SetFocus;
  end
  else
  begin
    NEWENTRY := true;
    SelDiensthundID := 0;
    btnAddUpdate.Caption := 'Hinzufügen';
    edDiensthundname.Clear;
    edDiensthundname.SetFocus;
    btnAddUpdate.Enabled := false;
  end;
end;





procedure TfDiensthunde.showAlleDiensthundeInListView;
var
  L: TListItem;
  FDQuery: TFDQuery;
begin
  lvDiensthunde.Items.Clear;

  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT ID, Diensthundname FROM diensthunde ORDER BY diensthundname ASC';
      Open;

      while not Eof do
      begin
        l := lvDiensthunde.Items.Add;
        l.Caption := FieldByName('diensthundname').AsString;
        l.SubItems.Add(FieldByName('id').AsString);
        Next;
      end;
    end;
  finally
    FDQuery.free;
  end;
end;


end.
