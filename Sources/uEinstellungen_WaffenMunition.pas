unit uEinstellungen_WaffenMunition;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TfEinstellungen_WaffenMunition = class(TForm)
    edWaffenBestand: TLabeledEdit;
    edWaffenTyp: TLabeledEdit;
    Shape5: TShape;
    Shape6: TShape;
    edWachmunKaliber: TLabeledEdit;
    Shape8: TShape;
    Shape7: TShape;
    edBestandWachmun: TLabeledEdit;
    edBestandWachschiessenMun: TLabeledEdit;
    edBestandManoeverMun: TLabeledEdit;
    edBestandVerschussMenge: TLabeledEdit;
    edVerschussmengeMunKaliber: TLabeledEdit;
    edManoeverMunKaliber: TLabeledEdit;
    edWachschiessenMunKaliber: TLabeledEdit;
    btnSaveWaffenMunition: TButton;
    Panel1: TPanel;
    Image2: TImage;
    procedure FormShow(Sender: TObject);
    procedure btnSaveWaffenMunitionClick(Sender: TObject);
  private
    procedure LoadWaffenMunitionFromDB;
  public
    { Public-Deklarationen }
  end;

var
  fEinstellungen_WaffenMunition: TfEinstellungen_WaffenMunition;

implementation

{$R *.dfm}

uses
  uFunktionen, uDBFunktionen, uMain;




procedure TfEinstellungen_WaffenMunition.btnSaveWaffenMunitionClick(Sender: TObject);
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      try
        with FDQuery do
        begin
          SQL.Text := 'UPDATE einstellungen SET Waffenbestand = :WAFFENBESTAND, WaffenTyp = :WAFFENTYP, ' +
                      'BestandWachMun = :BESTANDWACHMUN, WachMunKaliber = :WACHMUNKALIBER, ' +
                      'BestandWachschiessenMun = :BESTANDWACHSCHIESSENMUN, WachschiessenMunKaliber = :WACHSCHIESSENMUNKALIBER, ' +
                      'BestandManoeverMun = :BESTANDMANOEVERMUN, ManoeverMunKaliber = :MANOEVERMUNKALIBER, ' +
                      'BestandVerschussMenge = :BESTANDVERSCHUSSMENGE, VerschussmengeMunKaliber = :VERSCHUSSMENGEMUNKALIBER;';
          Params.ParamByName('WAFFENBESTAND').AsInteger := StrToInt(edWaffenBestand.Text);
          Params.ParamByName('WAFFENTYP').AsString := edWaffenTyp.Text;
          Params.ParamByName('BESTANDWACHMUN').AsInteger := StrToInt(edBestandWachmun.Text);
          Params.ParamByName('WACHMUNKALIBER').AsString := edWachmunKaliber.Text;
          Params.ParamByName('BESTANDWACHSCHIESSENMUN').AsInteger := StrToInt(edBestandWachschiessenMun.Text);
          Params.ParamByName('WACHSCHIESSENMUNKALIBER').AsString := edWachschiessenMunKaliber.Text;
          Params.ParamByName('BESTANDMANOEVERMUN').AsInteger := StrToInt(edBestandManoeverMun.Text);
          Params.ParamByName('MANOEVERMUNKALIBER').AsString := edManoeverMunKaliber.Text;
          Params.ParamByName('BESTANDVERSCHUSSMENGE').AsInteger := StrToInt(edBestandVerschussMenge.Text);
          Params.ParamByName('VERSCHUSSMENGEMUNKALIBER').AsString := edVerschussmengeMunKaliber.Text;
          ExecSQL;
        end;
      except
        showmessage('Fehler beim ändern von Waffen- und Munition');
      end;
    end;
  finally
    FDQuery.free;
    ReadSettingsFromDB;
    close;
  end;
end;






procedure TfEinstellungen_WaffenMunition.FormShow(Sender: TObject);
begin
  LoadWaffenMunitionFromDB;
end;





procedure TfEinstellungen_WaffenMunition.LoadWaffenMunitionFromDB;
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      try
        with FDQuery do
        begin
          SQL.Text := 'SELECT Waffenbestand, WaffenTyp, BestandWachMun, WachMunKaliber, BestandWachschiessenMun, ' +
                      'WachschiessenMunKaliber, BestandManoeverMun, ManoeverMunKaliber, BestandVerschussMenge, ' +
                      'VerschussmengeMunKaliber FROM einstellungen;';
          Open;
        end;
      except
        showmessage('Fehler beim auslesen von Waffen- und Munition');
      end;

      with FDQuery do
      begin
        if(not FDQuery.IsEmpty) then
        begin
          edWaffenBestand.Text := FieldByName('Waffenbestand').AsString;
          edWaffenTyp.Text := FieldByName('WaffenTyp').AsString;
          edBestandWachmun.Text := FieldByName('BestandWachMun').AsString;
          edWachmunKaliber.Text := FieldByName('WachMunKaliber').AsString;
          edBestandWachschiessenMun.Text := FieldByName('BestandWachschiessenMun').AsString;
          edWachschiessenMunKaliber.Text := FieldByName('WachschiessenMunKaliber').AsString;
          edBestandManoeverMun.Text := FieldByName('BestandManoeverMun').AsString;
          edManoeverMunKaliber.Text := FieldByName('ManoeverMunKaliber').AsString;
          edBestandVerschussMenge.Text := FieldByName('BestandVerschussMenge').AsString;
          edVerschussmengeMunKaliber.Text := FieldByName('VerschussmengeMunKaliber').AsString;
        end;
      end;
    end;
  finally
    FDQuery.free;
  end;
end;




end.
