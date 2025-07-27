unit uDiensthunde;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, AdvListV, Vcl.StdCtrls,
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
    procedure lvDiensthundeSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure FormShow(Sender: TObject);
    procedure btnAddUpdateClick(Sender: TObject);
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


implementation

{$R *.dfm}

uses
  uMain;



procedure TfDiensthunde.btnAddUpdateClick(Sender: TObject);
var
  l: TListItem;
  i: integer;
begin
  if(NEWENTRY = true) then
  begin
    InsertNewEntryInDB;
    edDiensthundname.Clear;
    NEWENTRY := false;
    btnAddUpdate.Caption := 'Hinzufügen';
  end
  else
  begin
    i := lvDiensthunde.ItemIndex;
    if(i<>-1) then
    begin
      UpdateEntryInDB(StrToInt(lvDiensthunde.Items[i].SubItems[0]));
      edDiensthundname.Clear;
    end;

    lvDiensthunde.ItemIndex := -1;
    NEWENTRY := true;
    btnAddUpdate.Caption := 'Hinzufügen';
  end;
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





procedure TfDiensthunde.FormShow(Sender: TObject);
begin
  NEWENTRY := true;

  showAlleDiensthundeInListView;
end;

procedure TfDiensthunde.lvDiensthundeSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  i: integer;
begin
  i := lvDiensthunde.ItemIndex;

  if(i <> -1) then
  begin
    edDiensthundname.Text := lvDiensthunde.Items[i].Caption;
    NEWENTRY := false;
    btnAddUpdate.Caption := 'Speichern';
  end
  else
  begin
    NEWENTRY := true;
    btnAddUpdate.Caption := 'Hinzufügen';
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
