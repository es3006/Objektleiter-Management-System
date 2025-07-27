unit uFrameWochenbericht;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  AdvPageControl, Vcl.ComCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, DateUtils;

type
  TFrameWochenbericht = class(TFrame)
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
    btnSaveNewWochenbericht: TButton;
    pnlWochenberichtEdit: TPanel;
    Jahr: TLabel;
    Label29: TLabel;
    imgPDF: TImage;
    cbJahr: TComboBox;
    cbWochenberichte: TComboBox;
    btnUpdateWochenbericht: TButton;
    procedure btnUpdateWochenberichtClick(Sender: TObject);
    procedure btnSaveNewWochenberichtClick(Sender: TObject);
    procedure cbJahrSelect(Sender: TObject);
    procedure dtpDatumChange(Sender: TObject);
    procedure cbWochenberichteSelect(Sender: TObject);
    procedure imgPDFClick(Sender: TObject);
  private
    procedure ShowWochenbericht(id: integer);

  public
    procedure Initialize;
    procedure SetLabelCaption(const Value: string);
    procedure ClearWochenbericht;
  end;


var
  NEWWOCHENBERICHT: boolean;
  SELYEAR: integer;

implementation

{$R *.dfm}

uses uMain, uFunktionen, uDBFunktionen;



procedure TFrameWochenbericht.Initialize;
var
  CurrentYear, StartYear: Integer;
begin
  CurrentYear := YearOf(Now);
  StartYear := 2023;
  for StartYear := StartYear to CurrentYear + 1 do
    cbJahr.Items.Add(IntToStr(StartYear));

  cbJahr.ItemIndex := cbJahr.Items.IndexOf(IntToStr(CurrentYear)); // Aktuelles Jahr auswählen
  cbJahrSelect(Self); // Dokumente des aktuellen Jahres laden
end;




procedure TFrameWochenbericht.ClearWochenbericht;
var
  I: Integer;
begin
  for I := 0 to Self.ComponentCount - 1 do
  begin
    if Components[I] is TEdit then
      TEdit(Components[I]).Text := ''
   // else if Components[I] is TComboBox then
   //   TComboBox(Components[I]).ItemIndex := -1
   // else if Components[I] is TMemo then
   //   TMemo(Components[I]).Clear
   // else if Components[I] is TCheckBox then
   //   TCheckBox(Components[I]).Checked := False
   // else if Components[I] is TRadioButton then
   //   TRadioButton(Components[I]).Checked := False;
  end;
end;




procedure TFrameWochenbericht.SetLabelCaption(const Value: string);
begin
  Label28.Caption := Value;
end;




procedure TFrameWochenbericht.btnSaveNewWochenberichtClick(Sender: TObject);
var
  FDQuery: TFDQuery;
  LastInsertID: integer;
  ERROR: boolean;
  jahr, kw: integer;
begin
  kw := getWeekNumber(dtpDatum.Date);

  if(WochenberichtExists(kw, SELYEAR)) then
  begin
    ShowMessage('Es existiert  bereits ein Wochenbericht für die Kalenderwoche ' + IntToStr(kw));
    abort;
  end;

  jahr  := YearOf(dtpDatum.Date);

  ERROR := false;
  LastInsertID := -1;

  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;
      fMain.FDConnection1.Connected := true;

//Mitarbeiterdaten in DB Tabelle mitarbeiter speichern
      SQL.Clear;
      SQL.Text := 'INSERT INTO wochenbericht (kw, jahr, datum, kundengespr1, kundengespr2, kundengespr3, ' +
                  'kundenbeschw1, kundenbeschw2, kundenbeschw3, personalbedarf1, personalbedarf2, ' +
                  'ausbildungen1, ausbildungen2, mehrdienste1, mehrdienste2, ' +
                  'ausruestung1, ausruestung2, vorkommnisse1, vorkommnisse2, sonstiges1, sonstiges2, ' +
                  'mo_wann, mo_wer, di_wann, di_wer, mi_wann, mi_wer, do_wann, do_wer, ' +
                  'fr_wann, fr_wer, sa_wann, sa_wer, so_wann, so_wer, ' +
                  'ssvm, ssmw, ssmm, meldender)' +
                  'VALUES (:KW, :JAHR, :DATUM, :KG1, :KG2, :KG3, :KB1, :KB2, :KB3, :PB1, :PB2, :AU1, ' +
                  ':AU2, :MD1, :MD2, :AR1, :AR2, :VK1, :VK2, :SO1, :SO2, ' +
                  ':MOWANN, :MOWER, :DIWANN, :DIWER, :MIWANN, :MIWER, :DOWANN, :DOWER, ' +
                  ':FRWANN, :FRWER, :SAWANN, :SAWER, :SOWANN, :SOWER, ' +
                  ':SSVW, :SSMW, :SSMM, :MELDENDER);';

      Params.ParamByName('KW').AsInteger := kw;
      Params.ParamByName('JAHR').AsInteger := jahr;
      Params.ParamByName('DATUM').AsString := ConvertGermanDateToSQLDate(DateToStr(dtpDatum.Date), false);
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

      Params.ParamByName('SSVW').AsString := '- 250 -';//SSVW.Text;
      Params.ParamByName('SSMW').AsString := '- 0 -';//SSMW.Text;
      Params.ParamByName('SSMM').AsString := '- 0 -';//SSMM.Text;
      Params.ParamByName('MELDENDER').AsString := 'Enrico Sadlowski'; //cbMeldender.Text;
      ExecSQL;

//ID des zuletzt erzeugten Datensatzes ermitteln (MitarbeiterID)
      SQL.Clear;
      SQL.Text := 'SELECT last_insert_rowid() AS LastID';
      Open;
      LastInsertID := FieldByName('LastID').AsInteger;
    end;
  except
      on E: Exception do
      begin
        ERROR := true;
        ShowMessage('Fehler beim Einfügen der Daten: ' + E.Message);
      end;
    end;


  if(ERROR = true) then
  begin
    showmessage('Fehler beim speichern des Wochenberichtes in der Datenbank');
  end;


  if(ERROR = false) then
  begin
    ClearWochenbericht;

    FDQuery.Free;
    fMain.FDConnection1.Connected := false;
  end;
end;
















procedure TFrameWochenbericht.btnUpdateWochenberichtClick(Sender: TObject);
var
  FDQuery: TFDQuery;
  ERROR: boolean;
begin
  ERROR := false;

  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;
      fMain.FDConnection1.Connected := true;

//Mitarbeiterdaten in DB Tabelle mitarbeiter speichern
      SQL.Clear;
      SQL.Text := 'UPDATE wochenbericht SET kw = :KW, datum = :DATUM, kundengespr1 = :KG1, kundengespr2 = :KG2, ' +
                  'kundengespr3 = :KG3, kundenbeschw1 = :KB1, kundenbeschw2 = :KB2, kundenbeschw3 = :KB3, ' +
                  'personalbedarf1 = :PB1, personalbedarf2 = :PB2, ausbildungen1 = :AU1, ausbildungen2 = :AU2, ' +
                  'mehrdienste1 = :MD1, mehrdienste2 = :MD2, ausruestung1 = :AR1, ausruestung2 = :AR2, ' +
                  'vorkommnisse1 = :VK1, vorkommnisse2 = :VK2, sonstiges1 = :SO1, sonstiges2 = :SO2, ' +
                  'mo_wann = :MOWANN, mo_wer = :MOWER, di_wann = :DIWANN, di_wer = :DIWER, ' +
                  'mi_wann = :MIWANN, mi_wer = :MIWER, do_wann = :DOWANN, do_wer = :DOWER, ' +
                  'fr_wann = :FRWANN, fr_wer = :FRWER, sa_wann = :SAWANN, sa_wer = :SAWER, so_wann = :SOWANN, ' +
                  'so_wer = :SOWER, ssvm = :SSVW, ssmw = :SSMW, ssmm = :SSMM, meldender = :MELDENDER ' +
                  'WHERE id = :ID;';

      Params.ParamByName('ID').AsInteger := WOCHENBERICHTID;
      Params.ParamByName('KW').AsInteger := getWeekNumber(dtpDatum.Date);
      Params.ParamByName('DATUM').AsString := ConvertGermanDateToSQLDate(DateToStr(dtpDatum.Date), false);
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

      Params.ParamByName('SSVW').AsString := '- 250 -'; //SSVW.Text;
      Params.ParamByName('SSMW').AsString := '- 0 -'; //SSMW.Text;
      Params.ParamByName('SSMM').AsString := '- 0 -'; //SSMM.Text;
      Params.ParamByName('MELDENDER').AsString := 'Enrico Sadlowski';//cbMeldender.Text;
      ExecSQL;
    end;
  except
      on E: Exception do
      begin
        ERROR := true;
        ShowMessage('Fehler beim Ändern der Daten: ' + E.Message);
      end;
    end;


  if(ERROR = true) then
  begin
    showmessage('Fehler beim ändern des Wochenberichtes in der Datenbank');
  end;


  if(ERROR = false) then
  begin
    ClearWochenbericht;

    cbJahr.ItemIndex := cbJahr.Items.IndexOf(IntToStr(YearOf(Now))); //Aktuelles Jahr in cbJahr auswählen
    cbJahrSelect(self); //cbJahrselect ausführen um Dokumente des aktuellen Jahres zu laden

    //gewählten Wochenbericht auswählen und aus Datenbank laden
    SelectComboBoxItem(cbWochenberichte, 'KW ' + IntToStr(SELECTEDKW));
    cbWochenberichteSelect(self);

    fMain.FDConnection1.Connected := false;
    FDQuery.Free;
  end;
end;



procedure TFrameWochenbericht.cbJahrSelect(Sender: TObject);
var
  l: TListItem;
  FDQuery: TFDQuery;
  wbs: string;
  wbid: integer;
begin
  SELYEAR := StrToInt(cbJahr.Text);
  cbWochenberichte.Items.Clear;
  //ClearListView(lvWochenberichte);

  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;
      fMain.FDConnection1.Connected := true;

      SQL.Clear;
      SQL.Text := 'SELECT id, kw FROM wochenbericht WHERE jahr = :JAHR ORDER BY kw ASC;';
      Params.ParamByName('JAHR').AsInteger := StrToInt(cbJahr.Text);
      Open;

      while not Eof do
      begin
        wbid := FieldByName('id').AsInteger;
        wbs  := 'KW ' + FieldByName('kw').AsString;

        cbWochenberichte.Items.AddObject(wbs, TObject(wbid));

        Next;
      end;
    end;
  finally
    FDQuery.free;
    fMain.FDConnection1.Connected := false;
  end;

  dtpDatum.Date := date;
  lbKW.Caption := IntToStr(getWeekNumber(Date));

  if(cbWochenberichte.Items.Count > 0) then
  begin
    cbWochenberichte.ItemIndex := cbWochenberichte.Items.Count-1;
    cbWochenberichteSelect(self);
  end
  else
  begin
    clearWochenbericht;
  end;
end;







procedure TFrameWochenbericht.cbWochenberichteSelect(Sender: TObject);
begin
  WOCHENBERICHTID := integer(cbWochenberichte.Items.Objects[cbWochenberichte.ItemIndex]);
  ShowWochenbericht(WOCHENBERICHTID);
end;






procedure TFrameWochenbericht.dtpDatumChange(Sender: TObject);
var
  kw: Integer;
begin
  kw := getWeekNumber(dtpDatum.Date);
  SELYEAR := YearOf(dtpDatum.Date);


  if(WochenberichtExists(kw, SELYEAR) = true) then
  begin
    if MessageDlg('Es existiert bereits ein Wochenbericht für KW ' + inttostr(kw) + '!' + #13#10+'Wollen Sie den Wochenbericht für KW ' + IntToStr(kw) + '  bearbeiten?', mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
    begin
        NEWWOCHENBERICHT := false;
        pnlWochenberichtEdit.Visible := true;
        pnlWochenberichtNeu.Visible := false;

        //Aktuelles jahr auswählen
        cbJahr.ItemIndex := cbJahr.Items.IndexOf(IntToStr(YearOf(Now)));
        cbJahrSelect(self);

        //gewählten Wochenbericht auswählen und aus Datenbank laden
        SelectComboBoxItem(cbWochenberichte, 'KW ' + IntToStr(kw));
        cbWochenberichteSelect(self);
    end
    else
    begin
      dtpDatum.Date := Date;
      lbKW.Caption := IntToStr(getWeekNumber(dtpDatum.Date));
    end;
  end
  else
  begin
    lbKW.Caption := IntToStr(getWeekNumber(dtpDatum.Date));
  end;
end;





procedure TFrameWochenbericht.imgPDFClick(Sender: TObject);
var
  i, id: integer;
begin
  i := cbWochenberichte.ItemIndex;
  if(i>-1) then
  begin
    id := WOCHENBERICHTID;
  //  StrToInt(lvWochenberichte.Items[lvWochenberichte.ItemIndex].Caption);

    GeneratePrintableWochenberichtFromDBByID(id, StrToInt(cbJahr.Text));
  //  fMain.tbWochenberichtClick(fMain.tbWochenbericht);
  end
  else
    showmessage('Kein Wochenbericht ausgewählt');
end;

procedure TFrameWochenbericht.ShowWochenbericht(id: integer);
var
  mondayDate: TDateTime;
  i, KW: Integer;
  FDQuery: TFDQuery;
begin
 // PageControl1.ActivePageIndex := 0;
  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;
      fMain.FDConnection1.Connected := true;

      SQL.Clear;
      SQL.Add('SELECT * FROM wochenbericht WHERE id = :ID;');
      Params.ParamByName('ID').AsInteger := ID;
      Open;

      while not Eof do
      begin
        KW                 := FieldByName('kw').AsInteger;
        SELECTEDKW         := KW;
        dtpDatum.Date      := StrToDate(ConvertSQLDateToGermanDate(FieldByName('datum').AsString, false));
       // cbMeldender.ItemIndex := cbMeldender.Items.IndexOf(FieldByName('meldender').AsString);
        edKG1.Text         := FieldByName('kundengespr1').AsString;
        edKG2.Text         := FieldByName('kundengespr2').AsString;
        edKG3.Text         := FieldByName('kundengespr3').AsString;
        edKB1.Text         := FieldByName('kundenbeschw1').AsString;
        edKB2.Text         := FieldByName('kundenbeschw2').AsString;
        edKB3.Text         := FieldByName('kundenbeschw3').AsString;
        edPB1.Text         := FieldByName('personalbedarf1').AsString;
        edPB2.Text         := FieldByName('personalbedarf2').AsString;
        edAU1.Text         := FieldByName('ausbildungen1').AsString;
        edAU2.Text         := FieldByName('ausbildungen2').AsString;
        edMD1.Text         := FieldByName('mehrdienste1').AsString;
        edMD2.Text         := FieldByName('mehrdienste2').AsString;
        edAR1.Text         := FieldByName('ausruestung1').AsString;
        edAR2.Text         := FieldByName('ausruestung2').AsString;
        edVK1.Text         := FieldByName('vorkommnisse1').AsString;
        edVK2.Text         := FieldByName('vorkommnisse2').AsString;
        edSO1.Text         := FieldByName('sonstiges1').AsString;
        edSO2.Text         := FieldByName('sonstiges2').AsString;
        edMoWann.Text      := FieldByName('mo_wann').AsString;
        edMoWer.Text       := FieldByName('mo_wer').AsString;
        edDiWann.Text      := FieldByName('di_wann').AsString;
        edDiWer.Text       := FieldByName('di_wer').AsString;
        edMiWann.Text      := FieldByName('mi_wann').AsString;
        edMiWer.Text       := FieldByName('mi_wer').AsString;
        edDoWann.Text      := FieldByName('do_wann').AsString;
        edDoWer.Text       := FieldByName('do_wer').AsString;
        edFrWann.Text      := FieldByName('fr_wann').AsString;
        edFrWer.Text       := FieldByName('fr_wer').AsString;
        edSaWann.Text      := FieldByName('sa_wann').AsString;
        edSaWer.Text       := FieldByName('sa_wer').AsString;
        edSoWann.Text      := FieldByName('so_wann').AsString;
        edSoWer.Text       := FieldByName('so_wer').AsString;
       // SSVW.Text          := FieldByName('ssvm').AsString;
       // SSMW.Text          := FieldByName('ssmw').AsString;
       // SSMM.Text          := FieldByName('ssmm').AsString;
        Next;
      end;
    end;
  finally
    FDQuery.Free;
    fMain.FDConnection1.Connected := false;
  end;

  //Kalenderwoche dem Label oben rechts zuweisen
  lbKW.Caption := IntToStr(KW);

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

end.
