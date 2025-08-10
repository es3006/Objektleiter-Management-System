unit uWochenberichtNeu;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  AdvPageControl, Vcl.ExtCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, DateUtils, Vcl.Buttons;

type
  TfWochenberichtNeu = class(TForm)
    Panel1: TPanel;
    lbVonBisDatum: TLabel;
    btnSaveNewWochenbericht: TButton;
    PageControl_Wochenbericht: TAdvPageControl;
    AdvTabSheet8: TAdvTabSheet;
    Label28: TLabel;
    Label26: TLabel;
    Label24: TLabel;
    Label22: TLabel;
    Label21: TLabel;
    Label23: TLabel;
    Label25: TLabel;
    Label27: TLabel;
    edKG1: TEdit;
    edKG2: TEdit;
    edKG3: TEdit;
    edPB1: TEdit;
    edPB2: TEdit;
    edMd1: TEdit;
    edMd2: TEdit;
    edVk1: TEdit;
    edVk2: TEdit;
    edSo2: TEdit;
    edSo1: TEdit;
    edAr2: TEdit;
    edAr1: TEdit;
    edAu2: TEdit;
    edAu1: TEdit;
    edKB3: TEdit;
    edKB2: TEdit;
    edKB1: TEdit;
    AdvTabSheet9: TAdvTabSheet;
    Label10: TLabel;
    Label11: TLabel;
    lbMoDatum: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    lbDiDatum: TLabel;
    lbMiDatum: TLabel;
    Label3: TLabel;
    lbFrDatum: TLabel;
    Label5: TLabel;
    Label4: TLabel;
    lbDoDatum: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    lbSaDatum: TLabel;
    Label6: TLabel;
    Label9: TLabel;
    lbSoDatum: TLabel;
    Label12: TLabel;
    edMoWer: TEdit;
    edMoWann: TEdit;
    edDiWann: TEdit;
    edDiWer: TEdit;
    edMiWer: TEdit;
    edMiWann: TEdit;
    edDoWer: TEdit;
    edFrWer: TEdit;
    edFrWann: TEdit;
    edDoWann: TEdit;
    edSaWer: TEdit;
    edSaWann: TEdit;
    edSoWann: TEdit;
    edSoWer: TEdit;
    pnlWochenberichtNeu: TPanel;
    Label18: TLabel;
    lbKW: TLabel;
    Label7: TLabel;
    dtpDatum: TDateTimePicker;
    SpeedButton1: TSpeedButton;
    lbSchonDa: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnSaveNewWochenberichtClick(Sender: TObject);
    procedure dtpDatumChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure edKG1Change(Sender: TObject);
  private
    procedure showDatumKontrollen;
  public
    { Public-Deklarationen }
  end;

var
  fWochenberichtNeu: TfWochenberichtNeu;
  SELYEAR, SELKW, MELDENDERID: integer;
  MELDENDER, MELDEDATUM,GESPMELDENDER, GESPMELDEDATUM: string;



implementation

{$R *.dfm}

uses uMain, uFunktionen, uDBFunktionen, uDatumMeldender;




procedure TfWochenberichtNeu.btnSaveNewWochenberichtClick(Sender: TObject);
var
  FDQuery: TFDQuery;
  LastInsertID, kw: integer;
  ERROR: boolean;
begin
  uDatumMeldender.MELDEDATUM := DateToStr(dtpDatum.Date);
  uDatumMeldender.MELDENDER  := OBJEKTLEITERNAME;
  uDatumMeldender.ABSENDER := 'uWochenberichtNeu';

  if fDatumMeldender.ShowModal = mrOk then
  begin
    kw      := getWeekNumber(dtpDatum.Date);
    SELYEAR := YearOf(dtpDatum.Date);

    if(WochenberichtExists(kw, SELYEAR)) then
    begin
      showmessage('Für KW [' + inttostr(kw) + '] wurde bereits ein Wochenbericht erstellt!');
      abort;
    end;


    FDQuery := TFDquery.Create(nil);
    try
      with FDQuery do
      begin
        Connection := fMain.FDConnection1;

  //Wochenbericht Daten in Tabelle wochenbericht_Data speichern
        SQL.Text := 'INSERT INTO wochenbericht_Data (kundengespr1, kundengespr2, kundengespr3, ' +
                    'kundenbeschw1, kundenbeschw2, kundenbeschw3, personalbedarf1, personalbedarf2, ' +
                    'ausbildungen1, ausbildungen2, mehrdienste1, mehrdienste2, ' +
                    'ausruestung1, ausruestung2, vorkommnisse1, vorkommnisse2, sonstiges1, sonstiges2, ' +
                    'mo_wann, mo_wer, di_wann, di_wer, mi_wann, mi_wer, do_wann, do_wer, ' +
                    'fr_wann, fr_wer, sa_wann, sa_wer, so_wann, so_wer, ' +
                    'ssvm, ssmw, ssmm)' +
                    'VALUES (:KG1, :KG2, :KG3, :KB1, :KB2, :KB3, :PB1, :PB2, :AU1, ' +
                    ':AU2, :MD1, :MD2, :AR1, :AR2, :VK1, :VK2, :SO1, :SO2, ' +
                    ':MOWANN, :MOWER, :DIWANN, :DIWER, :MIWANN, :MIWER, :DOWANN, :DOWER, ' +
                    ':FRWANN, :FRWER, :SAWANN, :SAWER, :SOWANN, :SOWER, ' +
                    ':SSVW, :SSMW, :SSMM);';

        Params.ParamByName('KG1').AsString := edKG1.Text;
        Params.ParamByName('KG2').AsString := edKG2.Text;
        Params.ParamByName('KG3').AsString := edKG3.Text;
        Params.ParamByName('KB1').AsString := edKB1.Text;
        Params.ParamByName('KB2').AsString := edKB2.Text;
        Params.ParamByName('KB3').AsString := edKB3.Text;
        Params.ParamByName('PB1').AsString := edPB1.Text;
        Params.ParamByName('PB2').AsString := edPB2.Text;
        Params.ParamByName('AU1').AsString := edAu1.Text;
        Params.ParamByName('AU2').AsString := edAu2.Text;
        Params.ParamByName('MD1').AsString := edMd1.Text;
        Params.ParamByName('MD2').AsString := edMd2.Text;
        Params.ParamByName('AR1').AsString := edAr1.Text;
        Params.ParamByName('AR2').AsString := edAr2.Text;
        Params.ParamByName('VK1').AsString := edVk1.Text;
        Params.ParamByName('VK2').AsString := edVk2.Text;
        Params.ParamByName('SO1').AsString := edSo1.Text;
        Params.ParamByName('SO2').AsString := edSo2.Text;

        if(length(trim(edMoWann.Text)) > 1) then
        begin
          Params.ParamByName('MOWANN').AsString := edMoWann.Text;
          Params.ParamByName('MOWER').AsString := edMoWer.Text;
        end
        else
        begin
          Params.ParamByName('MOWANN').AsString := '';
          Params.ParamByName('MOWER').AsString := '';
        end;

        if(length(trim(edDiWann.Text)) > 1) then
        begin
          Params.ParamByName('DIWANN').AsString := edDiWann.Text;
          Params.ParamByName('DIWER').AsString := edDiWer.Text;
        end
        else
        begin
          Params.ParamByName('DIWANN').AsString := '';
          Params.ParamByName('DIWER').AsString := '';
        end;

        if(length(trim(edMiWann.Text)) > 1) then
        begin
          Params.ParamByName('MIWANN').AsString := edMiWann.Text;
          Params.ParamByName('MIWER').AsString := edMiWer.Text;
        end
        else
        begin
          Params.ParamByName('MIWANN').AsString := '';
          Params.ParamByName('MIWER').AsString := '';
        end;

        if(length(trim(edDoWann.Text)) > 1) then
        begin
          Params.ParamByName('DOWANN').AsString := edDoWann.Text;
          Params.ParamByName('DOWER').AsString := edDoWer.Text;
        end
        else
        begin
          Params.ParamByName('DOWANN').AsString := '';
          Params.ParamByName('DOWER').AsString := '';
        end;

        if(length(trim(edFrWann.Text)) > 1) then
        begin
          Params.ParamByName('FRWANN').AsString := edFrWann.Text;
          Params.ParamByName('FRWER').AsString := edFrWer.Text;
        end
        else
        begin
          Params.ParamByName('FRWANN').AsString := '';
          Params.ParamByName('FRWER').AsString := '';
        end;

        if(length(trim(edSaWann.Text)) > 1) then
        begin
          Params.ParamByName('SAWANN').AsString := edSaWann.Text;
          Params.ParamByName('SAWER').AsString := edSaWer.Text;
        end
        else
        begin
          Params.ParamByName('SAWANN').AsString := '';
          Params.ParamByName('SAWER').AsString := '';
        end;

        if(length(trim(edSoWann.Text)) > 1) then
        begin
          Params.ParamByName('SOWANN').AsString := edSoWann.Text;
          Params.ParamByName('SOWER').AsString := edSoWer.Text;
        end
        else
        begin
          Params.ParamByName('SOWANN').AsString := '';
          Params.ParamByName('SOWER').AsString := '';
        end;

        Params.ParamByName('SSVW').AsString := '- ' + IntToStr(BESTANDWACHMUN) + ' -'; //SSVW.Text;
        Params.ParamByName('SSMW').AsString := '- ' + IntToStr(BESTANDWACHSCHIESSENMUN) + ' -'; //SSMW.Text;
        Params.ParamByName('SSMM').AsString := '- ' + IntToStr(BESTANDMANOEVERMUN) + ' -'; //SSMM.Text;

        ERROR := false;

        try
          ExecSQL;
        except
          on E: Exception do
          begin
            ERROR := true;
            ShowMessage('Fehler beim Speichern des neuen Wochenberichtes in der Tabelle "wochenbericht_data": ' + E.Message);
          end;
        end;

  //ID des zuletzt gespeicherten Wochenberichtes ermitteln (WochenberichtID)
        SQL.Text := 'SELECT last_insert_rowid() AS LastID';
        Open;
        LastInsertID := FieldByName('LastID').AsInteger;


        if(ERROR = true) then
        begin
          showmessage('Fehler beim speichern des Wochenberichtes in der Datenbank');
        end;


        if(ERROR = false) then
        begin
      //Wochenbericht in Tabelle wochenberichte speichern
          SQL.Text := 'INSERT INTO wochenberichte (wochenberichtID, meldenderID, kw, jahr, meldeDatum)' +
                      'VALUES (:WOCHENBERICHTID, :MELDENDERID, :KW, :JAHR, :MELDEDATUM);';

          Params.ParamByName('WOCHENBERICHTID').AsInteger := LastInsertID;
          Params.ParamByName('MELDENDERID').AsInteger     := MELDENDERID;
          Params.ParamByName('KW').AsInteger              := kw;
          Params.ParamByName('JAHR').AsInteger            := SELYEAR;
          Params.ParamByName('MELDEDATUM').AsString       := MELDEDATUM;

          try
            ExecSQL;
          except
            on E: Exception do
            begin
              ShowMessage('Fehler beim Speichern des neuen Wochenberichtes in der Tabelle "wochenberichte": ' + E.Message);
            end;
          end;
        end;
      end;
    finally
      FDQuery.Free;
      fMain.tbWochenberichtClick(nil);
      close;
    end;
  end;
end;








procedure TfWochenberichtNeu.dtpDatumChange(Sender: TObject);
var
  DatumString: string;
begin
  SELKW   := getWeekNumber(dtpDatum.Date);
  SELYEAR := YearOf(dtpDatum.Date);

  lbKW.Caption := IntToStr(SELKW);
  DatumString := GetStartEndOfWeek(SELKW, SELYEAR);

  lbKW.Caption := '('+IntToStr(SELKW)+') '+DatumString;

  showDatumKontrollen;

  if(WochenberichtExists(SELKW, SELYEAR) = true) then
  begin
    PlayResourceMP3('WRONGPW', 'TEMP\LoginError.wav');
    lbSchonDa.Caption := 'Der Wochenbericht für KW' + IntToStr(SELKW) + ' wurde bereits erstellt';
    lbSchonDa.Visible := true;
    btnSaveNewWochenbericht.Enabled := false;
  end
  else
  begin
    lbSchonDa.Visible := false;
    btnSaveNewWochenbericht.Enabled := true;
  end;
end;






procedure TfWochenberichtNeu.edKG1Change(Sender: TObject);
begin
  if Trim(TEdit(Sender).Text) <> '' then
    TEdit(Sender).Color := $00FEF0D6
  else
    TEdit(Sender).Color := clWindow;
end;

procedure TfWochenberichtNeu.FormShow(Sender: TObject);
var
  I: Integer;
  DatumString: string;
  KW: integer;
begin
  for I := 0 to Self.ComponentCount - 1 do
  begin
    if Components[I] is TEdit then
      TEdit(Components[I]).Text := '';
  end;

  KW := getWeekNumber(Date); //Kalenderwoche aus dem aktuellen Datum bestimmen

  DatumString := GetEndOfWeek(KW, SELYEAR);

  dtpDatum.Date := StrToDate(DatumString);
  dtpDatumChange(self);

  PageControl_Wochenbericht.ActivePageIndex := 0;

  edKG1.Text := '-----';
  edKB1.Text := '-----';
  edPB1.Text := '-----';
  edAU1.Text := '-----';
  edMD1.Text := '-----';
  edAR1.Text := '-----';
  edVK1.Text := '-----';
  edSO1.Text := '-----';
end;






procedure TfWochenberichtNeu.showDatumKontrollen;
var
  i: integer;
  mondayDate: TDate;
begin
  // Datum des Montags dieser Woche berechnen
  mondayDate := dtpDatum.Date - (DayOfWeek(dtpDatum.Date) + 5) mod 7;

  // Labels mit Datumsangabe unter den Wochentagen aktualisieren
  for i := 0 to 6 do
  begin
    case i of
      0: lbMoDatum.Caption := Format('%s', [DateToStr(mondayDate)]);
      1: lbDiDatum.Caption := Format('%s', [DateToStr(mondayDate + 1)]);
      2: lbMiDatum.Caption := Format('%s', [DateToStr(mondayDate + 2)]);
      3: lbDoDatum.Caption := Format('%s', [DateToStr(mondayDate + 3)]);
      4: lbFrDatum.Caption := Format('%s', [DateToStr(mondayDate + 4)]);
      5: lbSaDatum.Caption := Format('%s', [DateToStr(mondayDate + 5)]);
      6: lbSoDatum.Caption := Format('%s', [DateToStr(mondayDate + 6)]);
    end;
  end;
end;


procedure TfWochenberichtNeu.SpeedButton1Click(Sender: TObject);
begin
  showmessage('Wählen Sie bitte das Datum, dass unter dem Wochenbericht als Meldedatum stehen soll.');
end;









end.
