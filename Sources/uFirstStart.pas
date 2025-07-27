unit uFirstStart;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, System.UITypes, System.hash,
  Vcl.Imaging.pngimage, AdvPageControl, Vcl.ComCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Mask;

type
  TfFirstStart = class(TForm)
    AdvPageControl1: TAdvPageControl;
    AdvTabSheet1: TAdvTabSheet;
    edOLNachname: TLabeledEdit;
    edOLVorname: TLabeledEdit;
    edObjektname: TLabeledEdit;
    edObjektPLZ: TLabeledEdit;
    edObjektOrt: TLabeledEdit;
    Shape2: TShape;
    Shape1: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Panel2: TPanel;
    Image2: TImage;
    AdvTabSheet2: TAdvTabSheet;
    Panel1: TPanel;
    edWaffenBestand: TLabeledEdit;
    edWaffenTyp: TLabeledEdit;
    edWachMunKaliber: TLabeledEdit;
    edBestandWachschiessenMun: TLabeledEdit;
    edBestandWachmun: TLabeledEdit;
    Shape5: TShape;
    Shape6: TShape;
    Shape8: TShape;
    Shape7: TShape;
    edBestandManoeverMun: TLabeledEdit;
    edBestandVerschussMun: TLabeledEdit;
    edVerschussMunKaliber: TLabeledEdit;
    edManoeverMunKaliber: TLabeledEdit;
    edMunitionWachschiessenKaliber: TLabeledEdit;
    edUsername: TLabeledEdit;
    Shape9: TShape;
    edPassword: TLabeledEdit;
    Shape10: TShape;
    Bevel1: TBevel;
    Label1: TLabel;
    Bevel2: TBevel;
    Label2: TLabel;
    Label3: TLabel;
    Bevel3: TBevel;
    Label4: TLabel;
    Bevel4: TBevel;
    btnSpeichern: TButton;
    btnWeiter: TButton;
    Image1: TImage;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnSpeichernClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure edObjektnameKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnWeiterClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  fFirstStart: TfFirstStart;
  NewObjektInserted, NewMitarbeiterInserted, WaffenMunInserted: boolean;

implementation


{$R *.dfm}
{$R Scripts.RES}


uses
  uMain, uFunktionen, uDBFunktionen, uAnmeldung;






procedure TfFirstStart.btnSpeichernClick(Sender: TObject);
var
  FDQuery: TFDQuery;
  objName, objPlz, objOrt, olNachname, olVorname: string;
  waffenbestand, wachmunbestand, wachschiessenmunbestand, manoevermunbestand, verschussmunbestand: integer;
  waffentyp, wachmunkaliber, wachschiessenmunkaliber, manoevermunkaliber, verschussmunkaliber: string;
begin
  objName    := trim(edobjektname.Text);
  objPlz     := trim(edObjektPLZ.Text);
  objOrt     := trim(edObjektOrt.Text);
  olNachname := trim(edOlNachname.Text);
  olVorname  := trim(edOLVorname.Text);

  waffenbestand := StrToInt(edWaffenbestand.Text);
  wachmunbestand := StrToInt(edBestandWachmun.Text);
  wachschiessenmunbestand := StrToInt(edBestandWachschiessenMun.Text);
  manoevermunbestand := StrToInt(edBestandManoeverMun.Text);
  verschussmunbestand := StrToInt(edBestandVerschussMun.Text);

  waffentyp := trim(edWaffentyp.Text);
  wachmunkaliber := trim(edWachMunKaliber.Text);
  wachschiessenmunkaliber := trim(edMunitionWachschiessenKaliber.Text);
  manoevermunkaliber := trim(edManoeverMunKaliber.Text);
  verschussmunkaliber := trim(edVerschussMunKaliber.Text);

  if(length(objName) > 0) AND (length(objOrt) > 0) AND (length(olnachname) > 0) AND (length(olVorname) > 0) then
  begin
    FDQuery := TFDquery.Create(nil);
    try
      with FDQuery do
      begin
        Connection := fMain.FDConnection1;

        //Stammobjekt des Objektleiters in Datenbank einfügen
        SQL.Text := 'INSERT INTO objekte (objektname, plz, ort) VALUES (:OBJEKTNAME, :OBJEKTPLZ, :OBJEKTORT)';
        ParamByName('OBJEKTNAME').AsString := objName;
        ParamByName('OBJEKTPLZ').AsString  := objPlz;
        ParamByName('OBJEKTORT').AsString  := objOrt;
        try
          ExecSQL;
          NewObjektInserted := true;
        except
          on E: Exception do
            ShowMessage('Fehler beim Anlegen des Stammobjektes: ' + E.Message);
        end;


        //Objekt "_kein festes Objekt_"  anlegen
        SQL.Text := 'INSERT INTO objekte (objektname) VALUES (:OBJEKTNAME)';
        ParamByName('OBJEKTNAME').AsString := '_Kein festes Objekt_';
        try
          ExecSQL;
        except
          on E: Exception do
            ShowMessage('Fehler beim einfügen des Objektes in die Tabelle objekte: ' + E.Message);
        end;


        //Objektleiter in Datenbank schreiben
        if NewObjektInserted = true then
        begin
          SQL.Text := 'INSERT INTO mitarbeiter (objektid, nachname, vorname) ' +
                      'VALUES (:OBJEKTID, :OLNACHNAME, :OLVORNAME);';
          ParamByName('OBJEKTID').AsInteger  := 1;
          ParamByName('OLNACHNAME').AsString := olNachname;
          ParamByName('OLVORNAME').AsString  := olVorname;
          try
            ExecSQL;
            NewMitarbeiterInserted := true;
          except
            on E: Exception do
              ShowMessage('Fehler beim Anlegen des Mitarbeiters: ' + E.Message);
          end;
        end;



        //Objekt "_kein festes Objekt_"  anlegen
        SQL.Text := 'INSERT INTO mitarbeiter_objekte (mitarbeiterid, objektid) VALUES (:MITARBEITERID, :OBJEKTID)';
        ParamByName('MITARBEITERID').AsInteger := 1;
        ParamByName('OBJEKTID').AsInteger := 1;
        try
          ExecSQL;
        except
          on E: Exception do
            ShowMessage('Fehler beim einfügen der Daten in die Tabelle mitarbeiter_objekte: ' + E.Message);
        end;



        //Standard ESD Admin in Tabelle Admins einfügen
        SQL.Text := 'INSERT INTO admins (mitarbeiterid, username, password) ' +
                    'VALUES (:MITARBEITERID, :USERNAME, :PASSWORD)';
        ParamByName('MITARBEITERID').AsInteger := 0;
        ParamByName('USERNAME').AsString := 'esd';
        ParamByName('PASSWORD').AsString := THashSHA1.GetHashString('ESD123esd');
        try
          ExecSQL;
        except
          on E: Exception do
            ShowMessage('Fehler beim einfügen des Standard ESD Admin Accounts in die Tabelle admins: ' + E.Message);
        end;

        //Objektleiter in Tabelle admins eintragen
        SQL.Text := 'INSERT INTO admins (mitarbeiterid, username, password) ' +
                    'VALUES (:MITARBEITERID, :USERNAME, :PASSWORD)';
        ParamByName('MITARBEITERID').AsInteger := 1;
        ParamByName('USERNAME').AsString := edUsername.Text;
        ParamByName('PASSWORD').AsString := THashSHA1.GetHashString(trim(edPassword.Text));
        try
          ExecSQL;
        except
          on E: Exception do
            ShowMessage('Fehler beim einfügen des Objektleiters in die Tabelle admins: ' + E.Message);
        end;




        //Waffen und Munition in Datenbank schreiben
        if NewMitarbeiterInserted = true then
        begin
          SQL.Text := 'INSERT INTO einstellungen (ObjektID, ObjektleiterID, StellvObjektleiterID, Waffenbestand, Waffentyp, BestandWachMun, WachmunKaliber, ' +
                      'BestandWachschiessenMun, WachschiessenMunKaliber, BestandManoeverMun, ManoeverMunKaliber, ' +
                      'BestandVerschussmenge, VerschussmengeMunKaliber) VALUES ( ' +
                      ':OBJEKTID, :OBJEKTLEITERID, :STELLVOBJEKTLEITERID, ' +
                      ':Waffenbestand, :Waffentyp, :BestandWachMun, :WachmunKaliber, ' +
                      ':BestandWachschiessenMun, :WachschiessenMunKaliber, :BestandManoeverMun, :ManoeverMunKaliber, ' +
                      ':BestandVerschussmenge, :VerschussmengeMunKaliber);';
          ParamByName('OBJEKTID').AsInteger                := 1;
          ParamByName('OBJEKTLEITERID').AsInteger          := 1;
          ParamByName('STELLVOBJEKTLEITERID').AsInteger    := 0;
          ParamByName('Waffenbestand').AsInteger           := waffenbestand;
          ParamByName('Waffentyp').AsString                := waffentyp;
          ParamByName('BestandWachMun').AsInteger          := wachmunbestand;
          ParamByName('WachmunKaliber').AsString           := wachmunkaliber;
          ParamByName('BestandWachschiessenMun').AsInteger := wachschiessenmunbestand;
          ParamByName('WachschiessenMunKaliber').AsString  := wachschiessenmunkaliber;
          ParamByName('BestandManoeverMun').AsInteger      := manoevermunbestand;
          ParamByName('ManoeverMunKaliber').AsString       := manoevermunkaliber;
          ParamByName('BestandVerschussmenge').AsInteger   := verschussmunbestand;
          ParamByName('VerschussmengeMunKaliber').AsString := verschussmunkaliber;
          try
            ExecSQL;
            WaffenMunInserted        := true;
            BESTANDWACHMUN           := wachmunbestand;
            BESTANDWACHSCHIESSENMUN  := wachschiessenmunbestand;
            BESTANDMANOEVERMUN       := manoevermunbestand;
            BESTANDVERSCHUSSMENGE    := verschussmunbestand;
            WACHMUNKALIBER           := wachmunkaliber;
            WACHSCHIESSENMUNKALIBER  := wachschiessenmunkaliber;
            MANOEVERMUNKALIBER       := manoevermunkaliber;
            VERSCHUSSMENGEMUNKALIBER := verschussmunkaliber;
          except
            on E: Exception do
              ShowMessage('Fehler beim Speichern in die Tabelle einstellungen: ' + E.Message);
          end;
        end;
      end;
    finally
      FDQuery.free;
    end;
  end
  else
  begin
    showmessage('Bitte füllen Sie alle grün markierten Eingabefelder aus!');
    exit;
  end;

  fFirstStart.Visible := false;

  ReadSettingsFromDB; //Objekt, Objektleiter, Waffen und Munition

  ReadObjektleiterObjektSettings;

  fAnmeldung.Show;
  fAnmeldung.edUsername.Text := edUsername.Text;
  fFirstStart.close;
end;




procedure TfFirstStart.btnWeiterClick(Sender: TObject);
begin
  AdvPageControl1.ActivePageIndex := 1;
  edWaffenbestand.SetFocus;
end;

procedure TfFirstStart.edObjektnameKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then  // Überprüfung, ob die Enter-Taste gedrückt wurde
  begin
    Key := #0;  // Unterdrücken des normalen Enter-Tasten-Verhaltens
    Perform(WM_NEXTDLGCTL, 0, 0);  // Fokus auf das nächste Steuerelement verschieben
  end;
end;






procedure TfFirstStart.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (NewObjektInserted) AND (NewMitarbeiterInserted) AND (WaffenMunInserted) then
  begin
    CanClose := true;
  end
  else
  begin
    if MessageDlg('ACHTUNG, Sie sollten hier auf jeden Fall alle Eingaben vornehmen da Sie das Programm sonst nicht verwenden können.'+#13#10+#13#10+
    'Wollen Sie jetzt die Daten eingeben?', mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
    begin
      CanClose := False;
    end
    else
    begin
      if(FileExists(DBNAME)) then
      begin
        if DeleteFile(DBNAME) then
        begin
          if(fMain.FDConnection1.Connected) then fMain.FDConnection1.Connected := false; //Verbindung zur Datenbank trennen
          DeleteFile(DBNAME);
          Application.Terminate
        end
        else
        begin
          ShowMessage('Fehler beim Löschen der Datenbank: ' + DBNAME + #13#10+'Bitte löschen Sie die Datei ' + DBNAME + ' aus dem Programmverzeichnis bevor Sie das Programm das nächste Mal öffnen!');
          Application.Terminate;
        end;
      end;
    end;
  end;
end;




procedure TfFirstStart.FormCreate(Sender: TObject);
begin
  CreateDirectoriesAndExtractFilesFromRes;
end;





procedure TfFirstStart.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
  begin
    Close;
  end;
end;






procedure TfFirstStart.FormShow(Sender: TObject);
begin
  edWaffenbestand.Text := '0';
  edBestandWachmun.Text := '0';
  edBestandWachschiessenMun.Text := '0';
  edBestandManoeverMun.Text := '0';
  edBestandVerschussMun.Text := '0';

  AdvPageControl1.ActivePageIndex := 0;
  edObjektname.SetFocus;
end;





end.
