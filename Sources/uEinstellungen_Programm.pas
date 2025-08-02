unit uEinstellungen_Programm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  AdvEdit, AdvEdBtn, AdvDirectoryEdit, iniFiles;

type
  TfEinstellungen_Programm = class(TForm)
    Label1: TLabel;
    edWochenberichte: TAdvDirectoryEdit;
    lbWochenberichte: TLabel;
    btnSave: TButton;
    edWachpersonalliste: TAdvDirectoryEdit;
    lbWachpersonalliste: TLabel;
    edWaffenbestandsmeldungen: TAdvDirectoryEdit;
    lbWaffenbestandsmeldungen: TLabel;
    edAusbildungsunterlagenMonat: TAdvDirectoryEdit;
    lbAusbildungsunterlagenMonat: TLabel;
    edAusbildungsunterlagenQuartal: TAdvDirectoryEdit;
    lbAusbildungsunterlagenQuartal: TLabel;
    edWachschiessenQuartal: TAdvDirectoryEdit;
    Label2: TLabel;
    edWachtest: TAdvDirectoryEdit;
    Label3: TLabel;
    edWachschiessenJahr: TAdvDirectoryEdit;
    Label4: TLabel;
    edWachschiessenGutscheinAntrag: TAdvDirectoryEdit;
    Label5: TLabel;
    edZuordnungWaffenSchliessfach: TAdvDirectoryEdit;
    Label6: TLabel;
    edMunitionstausch: TAdvDirectoryEdit;
    Label7: TLabel;
    procedure btnSaveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  fEinstellungen_Programm: TfEinstellungen_Programm;

implementation

{$R *.dfm}

uses
  uMain;




procedure TfEinstellungen_Programm.btnSaveClick(Sender: TObject);
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(PATH + 'settings.ini');
  try
    ini.WriteString('PATH','Wochenberichte',edWochenberichte.Text);
    ini.WriteString('PATH','Wachpersonalliste',edWachpersonalliste.Text);
    ini.WriteString('PATH','Waffenbestandsmeldungen',edWaffenbestandsmeldungen.Text);
    ini.WriteString('PATH','AusbildungsunterlagenMonat',edAusbildungsunterlagenMonat.Text);
    ini.WriteString('PATH','AusbildungsunterlagenQuartal',edAusbildungsunterlagenQuartal.Text);
    ini.WriteString('PATH','Wachtest',edWachtest.Text);
    ini.WriteString('PATH','WachschiessenQuartal',edWachschiessenQuartal.Text);
    ini.WriteString('PATH','WachschiessenJahr',edWachschiessenJahr.Text);
    ini.WriteString('PATH','WachschiessenGutscheinAntrag',edWachschiessenGutscheinAntrag.Text);
    ini.WriteString('PATH','ZuordnungWaffenSchliessfach',edZuordnungWaffenSchliessfach.Text);
    ini.WriteString('PATH','Munitionstausch',edMunitionstausch.Text);

    SAVEPATH_Wochenberichte := edWochenberichte.Text;
    SAVEPATH_Wachpersonalliste := edWachpersonalliste.Text;
    SAVEPATH_Waffenbestandsmeldungen := edWaffenbestandsmeldungen.Text;
    SAVEPATH_AusbildungMonat := edAusbildungsunterlagenMonat.Text;
    SAVEPATH_Ausbildungquartal := edAusbildungsunterlagenQuartal.Text;
    SAVEPATH_WACHTEST := edWachtest.Text;
    SAVEPATH_WACHSCHIESSENQUARTAL := edWachschiessenQuartal.Text;
    SAVEPATH_WACHSCHIESSENJAHR := edWachschiessenJahr.Text;
    SAVEPATH_WachschiessenGutscheinAntrag := edWachschiessenGutscheinAntrag.Text;
    SAVEPATH_ZuordnungWaffeSchliessfach := edZuordnungWaffenSchliessfach.Text;
    SAVEPATH_Munitionstausch := edMunitionstausch.Text;
  finally
    ini.Free;
    close;
  end;
end;




procedure TfEinstellungen_Programm.FormShow(Sender: TObject);
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(PATH + 'settings.ini');
  try
    edWochenberichte.Text := ini.ReadString('PATH','Wochenberichte','');
    edWachpersonalliste.Text := ini.ReadString('PATH','Wachpersonalliste','');
    edWaffenbestandsmeldungen.Text := ini.ReadString('PATH','Waffenbestandsmeldungen','');
    edAusbildungsunterlagenMonat.Text := ini.ReadString('PATH','AusbildungsunterlagenMonat','');
    edAusbildungsunterlagenQuartal.Text := ini.ReadString('PATH','AusbildungsunterlagenQuartal','');
    edWachschiessenQuartal.Text := ini.ReadString('PATH','WachschiessenQuartal','');
    edWachschiessenJahr.Text := ini.ReadString('PATH','WachschiessenJahr','');
    edWachtest.Text := ini.ReadString('PATH','Wachtest','');
    edWachschiessenGutscheinAntrag.Text := ini.ReadString('PATH','WachschiessenGutscheinAntrag','');
    edZuordnungWaffenSchliessfach.Text  := ini.ReadString('PATH','ZuordnungWaffenSchliessfach','');
    edMunitionstausch.Text := ini.ReadString('PATH','Munitionstausch','');
  finally
    ini.Free;
  end;
end;

end.
