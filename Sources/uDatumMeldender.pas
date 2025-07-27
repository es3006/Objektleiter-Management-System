unit uDatumMeldender;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, DateUtils;

type
  TfDatumMeldender = class(TForm)
    dtpDatum: TDateTimePicker;
    cbMitarbeiter: TComboBox;
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private

  public
    FSaved: Boolean;
  end;

var
  fDatumMeldender: TfDatumMeldender;
  SelMonth, SelYear: integer;
  ABSENDER, MELDENDER, MELDEDATUM: string;
  ABBRUCH: boolean;



implementation

{$R *.dfm}


uses
  uMain, uFrameWaffenbestandsmeldung, uFunktionen, uDBFunktionen,
  uFrameWachpersonal, uFrameWochenberichtEdit, uWochenberichtNeu;


procedure TfDatumMeldender.Button1Click(Sender: TObject);
var
  datum: string;
begin
  Datum := ConvertGermanDateToSQLDate(DateToStr(dtpDatum.Date), false);

  if(cbMitarbeiter.ItemIndex > 0) then
  begin
    if(ABSENDER = 'uFrameWaffenbestandsmeldung') then
    begin
      uFrameWaffenbestandsmeldung.MELDENDERID := Integer(cbMitarbeiter.Items.Objects[cbMitarbeiter.ItemIndex]);
      uFrameWaffenbestandsmeldung.MELDENDER   := cbMitarbeiter.Text;
      uFrameWaffenbestandsmeldung.MELDEDATUM  := Datum;
      ModalResult := mrOk;
    end;


    if (ABSENDER = 'uFrameWachpersonal') then
    begin
      uFrameWachpersonal.MELDENDERID := Integer(cbMitarbeiter.Items.Objects[cbMitarbeiter.ItemIndex]);
      uFrameWachpersonal.MELDENDER   := cbMitarbeiter.Text;
      uFrameWachpersonal.MELDEDATUM  := Datum;
      ModalResult := mrOk;
    end;


    if(ABSENDER = 'uFrameWochenberichtEdit') then
    begin
      uFrameWochenberichtEdit.MELDENDERID := Integer(cbMitarbeiter.Items.Objects[cbMitarbeiter.ItemIndex]);
      uFrameWochenberichtEdit.MELDENDER   := cbMitarbeiter.Text;
      uFrameWochenberichtEdit.MELDEDATUM  := Datum;
      ModalResult := mrOk;
    end;


    if(ABSENDER = 'uWochenberichtNeu') then
    begin
      uWochenberichtNeu.MELDENDERID := Integer(cbMitarbeiter.Items.Objects[cbMitarbeiter.ItemIndex]);
      uWochenberichtNeu.MELDENDER   := cbMitarbeiter.Text;
      uWochenberichtNeu.MELDEDATUM  := Datum;
      ModalResult := mrOk;
    end
  end
  else
  begin
    showmessage('Bitte wählen Sie den Namen des Mitarbeiters aus, der unter dem Dokument stehen soll!');
  end;
end;





procedure TfDatumMeldender.FormShow(Sender: TObject);
begin
  dtpDatum.Date := date; //Datum auf aktuelles Datum setzen
  SelMonth      := MonthOf(dtpDatum.Date);
  SelYear       := YearOf(dtpDatum.Date);

  if(OBJEKTID = 0) then
    showMitarbeiterInComboBox(cbMitarbeiter, SelMonth, SelYear, false, 0, 3) //1 = Alle wenn als esd angemeldet
  else
    showMitarbeiterInComboBox(cbMitarbeiter, SelMonth, SelYear, false, OBJEKTID, 1); //1 = Stamm  wenn als ol angemeldet

  //Datum auf gespeichertes Datum setzen das übergeben wird.
  dtpDatum.Date := StrToDate(MELDEDATUM);

  //Mitarbeiter selektieren dessen ID übergeben wurde
  SucheMitarbeiterUndAnzeigen(cbMitarbeiter, MELDENDER);
end;

end.
