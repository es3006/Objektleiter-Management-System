unit uDBSettings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, inifiles, AdvEdit,
  AdvEdBtn, AdvDirectoryEdit, AdvFileNameEdit;

type
  TfDBSettings = class(TForm)
    edHost: TEdit;
    Label1: TLabel;
    edUser: TEdit;
    Label2: TLabel;
    edPasswort: TEdit;
    Label3: TLabel;
    edPort: TEdit;
    Label4: TLabel;
    btnSave: TButton;
    edDBName: TEdit;
    Label5: TLabel;
    edProtocol: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    edLibraryLocation: TAdvFileNameEdit;
    procedure FormShow(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure edLibraryLocationChange(Sender: TObject);
  private
    { Private-Deklarationen }
  public

  end;

var
  fDBSettings: TfDBSettings;

implementation

uses
  uMain;

{$R *.dfm}








procedure TfDBSettings.edLibraryLocationChange(Sender: TObject);
begin
  edLibraryLocation.Text := extractFileName(edLibraryLocation.text);
end;




procedure TfDBSettings.btnSaveClick(Sender: TObject);
var ini: Tinifile;
begin
  ini := TIniFile.Create(PATH+'settings.ini');
  try
    ini.WriteString('DB','Host',edHost.Text);
    ini.WriteString('DB','User',edUser.Text);
    ini.WriteString('DB','Passwort',edPasswort.Text);
    ini.WriteString('DB','Port',edPort.Text);
    ini.WriteString('DB','DBName',edDBName.Text);
    ini.WriteString('DB','Protocol',edProtocol.Text);
    ini.WriteString('DB','LibLocation',edLibraryLocation.Text);
  finally
    ini.free;
  end;

  close;
end;



procedure TfDBSettings.FormShow(Sender: TObject);
var ini: Tinifile;
begin
  edLibraryLocation.InitialDir := PATH;

  ini := TIniFile.Create(PATH+'settings.ini');
  try
    edHost.Text := ini.ReadString('DB','Host','localhost');
    edUser.Text := ini.ReadString('DB','User','');
    edPasswort.Text := ini.ReadString('DB','Passwort','');
    edPort.Text := ini.ReadString('DB','Port','3306');
    edDBName.Text := ini.ReadString('DB','DBName','');
    edProtocol.Text := ini.ReadString('DB','Protocol','mysqld-5');
    edLibraryLocation.Text := ini.ReadString('DB','LibLocation','libmysql.dll');
  finally
    ini.free;
  end;
end;

end.
