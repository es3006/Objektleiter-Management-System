unit uAnmeldung;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.hash, Vcl.StdCtrls, Vcl.ExtCtrls, FireDAC.Stan.Param,
  Vcl.Imaging.jpeg, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.SQLite,
  Vcl.Imaging.pngimage, Vcl.Buttons, Vcl.Mask;

type
  TfAnmeldung = class(TForm)
    edUsername: TLabeledEdit;
    edPassword: TLabeledEdit;
    btnAnmelden: TButton;
    Image1: TImage;
    Timer1: TTimer;
    procedure btnAnmeldenClick(Sender: TObject);
    procedure edUsernameKeyPress(Sender: TObject; var Key: Char);
    procedure edPasswordKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure sbShowPWMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure sbShowPWMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
  private
    procedure ShakeForm;
  public
    ABSENDER: string;
    LOGGEDIN: boolean;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

var
  fAnmeldung: TfAnmeldung;



implementation

{$R *.dfm}



uses uMain, uFunktionen, uWaffenbestand;




procedure TfAnmeldung.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle   := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := GetDesktopWindow;
end;



procedure TfAnmeldung.btnAnmeldenClick(Sender: TObject);
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      FDQuery.SQL.Text := 'SELECT A.id, A.mitarbeiterID, M.nachname || " " || M.vorname AS objektleitername, ' +
                          'CASE WHEN M.id IS NOT NULL THEN M.nachname || " " || M.vorname ELSE "Kein Mitarbeiter" END AS Mitarbeiter, ' +
                          'M.objektid ' +
                          'FROM admins AS A ' +
                          'LEFT JOIN mitarbeiter AS M ON M.id = A.mitarbeiterID ' +
                          'WHERE A.username = :USERNAME AND ' +
                          'A.password = :PASSWORT ' +
                          'LIMIT 1';

      FDQuery.ParamByName('USERNAME').AsString := Trim(edUsername.Text);
      FDQuery.ParamByName('PASSWORT').AsString := THashSHA1.GetHashString(Trim(edPassword.Text));


      Open();

      if(RecordCount = 1) then
      begin
        PlayResourceMP3('WHOOSH', 'TEMP\Whoosh.wav');

        OBJEKTLEITERNAME := FDQuery.FieldByName('objektleitername').AsString;
        OLUSERNAME := Trim(edUsername.Text);

        LOGGEDIN := true;

        fMain.tbWochenberichtClick(nil);
        Timer1.Enabled := true;

        fMain.TrayIcon1.Visible := true;

        exit;
      end
      else
      begin
        PlayResourceMP3('WRONGPW', 'TEMP\LoginError.wav');
        ShakeForm;

        OLUSERNAME := '';
        LOGGEDIN := false;
        edUsername.SetFocus;

        exit;
      end;
      fMain.tbWochenberichtClick(nil);
      Close;
    end;
  finally
    FDQuery.Free;
    if(FIRSTSTART = true) then
    begin
      showmessage('Bitte geben Sie als nächstes alle ' + inttostr(waffenbestand) + ' Waffen ein!');
      fWaffenbestand.ShowModal;
    end;
  end;
end;




procedure TfAnmeldung.edUsernameKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    edPassword.SetFocus;
  end;
end;

procedure TfAnmeldung.edPasswordKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    btnAnmeldenClick(self);
  end;
end;

procedure TfAnmeldung.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if(LOGGEDIN = false) then
    Application.Terminate;
end;

procedure TfAnmeldung.FormCreate(Sender: TObject);
begin
  LOGGEDIN := false;
end;

procedure TfAnmeldung.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
  begin
    Key := #0;
    Close;
  end;
end;

procedure TfAnmeldung.FormShow(Sender: TObject);
begin
  if(edUsername.Text = '') then
    edUsername.SetFocus
  else
    edPassword.SetFocus;
end;

procedure TfAnmeldung.sbShowPWMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  edPassword.PasswordChar := #0;
end;

procedure TfAnmeldung.sbShowPWMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  edPassword.PasswordChar := '*';
end;

procedure TfAnmeldung.Timer1Timer(Sender: TObject);
begin
  fAnmeldung.Top := fAnmeldung.Top - 50;
  if(fAnmeldung.Top <= -100) then
  begin
    timer1.Enabled := false;
    fAnmeldung.Close;
  end;
end;



procedure TfAnmeldung.ShakeForm;
const
  ShakeCount  = 10;  // Anzahl der Schüttelbewegungen (5 nach links und 5 nach rechts)
  ShakeOffset = 10; // Abstand, um den die Form verschoben wird
  ShakeDelay  = 15;  // Wartezeit in Millisekunden zwischen den Schüttelbewegungen
var
  OriginalLeft: Integer;
  I: Integer;
begin
  OriginalLeft := Self.Left;
  for I := 1 to ShakeCount do
  begin
    if I mod 2 = 0 then
      Self.Left := OriginalLeft + ShakeOffset
    else
      Self.Left := OriginalLeft - ShakeOffset;
    Sleep(ShakeDelay);
    Application.ProcessMessages; // Ermöglicht das Aktualisieren der GUI
  end;
  Self.Left := OriginalLeft; // Zurück zur ursprünglichen Position
end;
















end.
