unit uFrameWochenberichtEdit;

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
  FireDAC.Comp.Client, DateUtils, ShellApi, Vcl.Buttons;

type
  TFrameWochenberichtEdit = class(TFrame)
    pnlWochenberichtEdit: TPanel;
    Jahr: TLabel;
    Label29: TLabel;
    imgPDF: TImage;
    cbJahr: TComboBox;
    cbKalenderwoche: TComboBox;
    PageControl_Wochenbericht: TAdvPageControl;
    AdvTabSheet8: TAdvTabSheet;
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
    lbStartDatumEndDatum: TLabel;
    Panel2: TPanel;
    btnUpdateWochenbericht: TButton;
    btnNeuerWochenbericht: TButton;
    GridPanel1: TGridPanel;
    Panel4: TPanel;
    Label27: TLabel;
    Label25: TLabel;
    Label23: TLabel;
    Label21: TLabel;
    edKB1: TEdit;
    edKB2: TEdit;
    edKB3: TEdit;
    edAu1: TEdit;
    edAu2: TEdit;
    edAr1: TEdit;
    edAr2: TEdit;
    edSo1: TEdit;
    edSo2: TEdit;
    Panel3: TPanel;
    Label28: TLabel;
    Label26: TLabel;
    Label24: TLabel;
    Label22: TLabel;
    edKG1: TEdit;
    edKG2: TEdit;
    edKG3: TEdit;
    edPB1: TEdit;
    edPB2: TEdit;
    edMd1: TEdit;
    edMd2: TEdit;
    edVk1: TEdit;
    edVk2: TEdit;
    SaveDialog1: TSaveDialog;
    procedure Initialize;
    procedure cbJahrSelect(Sender: TObject);
    procedure cbKalenderwocheSelect(Sender: TObject);
    procedure imgPDFClick(Sender: TObject);
    procedure btnUpdateWochenberichtClick(Sender: TObject);
    procedure btnNeuerWochenberichtClick(Sender: TObject);
    procedure edKG1Change(Sender: TObject);
    procedure edKG1Exit(Sender: TObject);
  private
    procedure ClearWochenbericht;
    procedure ShowWochenbericht(id: integer);
    procedure GeneratePrintableWochenberichtFromDBByID(id, jahr: integer);
    procedure SetWeekDates(Year, Week: Integer; lbMoDatum, lbDiDatum, lbMiDatum, lbDoDatum, lbFrDatum, lbSaDatum, lbSoDatum: TLabel);
  public

  end;


var
  SELYEAR, SELKW, MELDENDERID, GESPMELDENDERID: integer;
  MELDENDER, MELDEDATUM,GESPMELDENDER, GESPMELDEDATUM: string;


implementation

{$R *.dfm}
{$R Wochenbericht.RES}


uses uMain, uFunktionen, uDBFunktionen, uWebBrowser, uWochenberichtNeu, uDatumMeldender;








procedure TFrameWochenberichtEdit.Initialize;
var
  CurrentYear, StartYear: Integer;
begin
  CurrentYear := YearOf(Now);  //Aktuelle Jahreszahl

  StartYear := 2023; //Startjahr für cbJahr
  //cbJahr befüllen mit Startjahr - aktuelles Jahr +1
  for StartYear := StartYear to CurrentYear + 1 do
    cbJahr.Items.Add(IntToStr(StartYear));

  cbJahr.ItemIndex := cbJahr.Items.IndexOf(IntToStr(CurrentYear)); //Aktuelles Jahr in cbJahr setzen
  cbJahrSelect(Self); //aktuelles Jahr in cbJahr auswählen udn procedure dahinter aufrufen

  PageControl_Wochenbericht.ActivePageIndex := 1;
end;





procedure TFrameWochenberichtEdit.ClearWochenbericht;
var
  I: Integer;
begin
  for I := 0 to Self.ComponentCount - 1 do
  begin
    if Components[I] is TEdit then
      TEdit(Components[I]).Text := ''
  end;
end;





procedure TFrameWochenberichtEdit.edKG1Change(Sender: TObject);
begin
  if Trim(TEdit(Sender).Text) <> '' then
    TEdit(Sender).Color := $00FEF0D6
  else
    TEdit(Sender).Color := clWindow;
end;

procedure TFrameWochenberichtEdit.edKG1Exit(Sender: TObject);
begin
  fMain.StatusBar1.Panels[1].Text := '';
end;




procedure TFrameWochenberichtEdit.btnNeuerWochenberichtClick(Sender: TObject);
begin
  uWochenberichtNeu.SELKW   := SELKW;
  uWochenberichtNeu.SELYEAR := SELYEAR;
  fWochenberichtNeu.Show;
end;





procedure TFrameWochenberichtEdit.btnUpdateWochenberichtClick(Sender: TObject);
var
  FDQuery: TFDQuery;
  ERROR: boolean;
begin
  uDatumMeldender.MELDENDER  := MELDENDER;
  uDatumMeldender.MELDEDATUM := ConvertSQLDateToGermanDate(MELDEDATUM, false);
  uDatumMeldender.ABSENDER := 'uFrameWochenberichtEdit';
  fDatumMeldender.ShowModal;

  ERROR := false;


  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'UPDATE wochenbericht_Data SET kundengespr1 = :KG1, kundengespr2 = :KG2, ' +
                  'kundengespr3 = :KG3, kundenbeschw1 = :KB1, kundenbeschw2 = :KB2, kundenbeschw3 = :KB3, ' +
                  'personalbedarf1 = :PB1, personalbedarf2 = :PB2, ausbildungen1 = :AU1, ausbildungen2 = :AU2, ' +
                  'mehrdienste1 = :MD1, mehrdienste2 = :MD2, ausruestung1 = :AR1, ausruestung2 = :AR2, ' +
                  'vorkommnisse1 = :VK1, vorkommnisse2 = :VK2, sonstiges1 = :SO1, sonstiges2 = :SO2, ' +
                  'mo_wann = :MOWANN, mo_wer = :MOWER, di_wann = :DIWANN, di_wer = :DIWER, ' +
                  'mi_wann = :MIWANN, mi_wer = :MIWER, do_wann = :DOWANN, do_wer = :DOWER, ' +
                  'fr_wann = :FRWANN, fr_wer = :FRWER, sa_wann = :SAWANN, sa_wer = :SAWER, so_wann = :SOWANN, ' +
                  'so_wer = :SOWER, ssvm = :SSVW, ssmw = :SSMW, ssmm = :SSMM ' +
                  'WHERE id = :WOCHENBERICHTID;';


      Params.ParamByName('WOCHENBERICHTID').AsInteger := WOCHENBERICHTID;
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

      Params.ParamByName('SSVW').AsString := '- ' + IntToStr(BESTANDWACHMUN) + ' -';
      Params.ParamByName('SSMW').AsString := '- ' + IntToStr(BESTANDWACHSCHIESSENMUN) + ' -';
      Params.ParamByName('SSMM').AsString := '- ' + IntToStr(BESTANDMANOEVERMUN) + ' -';

      try
        ExecSQL;
      except
        on E: Exception do
        begin
          ERROR := true;
          ShowMessage('Fehler beim Ändern des Wochenberichtes in der Tabelle wochenbericht_Data: ' + E.Message);
        end;
      end;



      SQL.Text := 'UPDATE wochenberichte SET meldeDatum = :MELDEDATUM, meldenderID = :MELDENDERID ' +
                  'WHERE wochenberichtID = :WOCHENBERICHTID;';
      Params.ParamByName('MELDENDERID').AsInteger     := MELDENDERID;
      Params.ParamByName('MELDEDATUM').AsString       := MELDEDATUM;
      Params.ParamByName('WOCHENBERICHTID').AsInteger := WOCHENBERICHTID;

      try
        ExecSQL;
      Except
        on E: Exception do
        begin
          ERROR := true;
          ShowMessage('Fehler beim Ändern des Wochenberichtes in der Tabelle wochenberichte: ' + E.Message);
        end;
      end;
    end;
  finally
    FDQuery.Free;
  end;
end;









procedure TFrameWochenberichtEdit.cbJahrSelect(Sender: TObject);
var
  FDQuery: TFDQuery;
  wbs: string;
  wbid: integer;
begin
  SELYEAR := StrToInt(cbJahr.Text); //ausgewähltes Jahr in SELYEAR speichern
  cbKalenderwoche.Items.Clear; //cbKalenderwoche leeren
  ClearWochenbericht; //Wochenbericht leeren


  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Clear;
      SQL.Text := 'SELECT id, kw FROM wochenberichte WHERE jahr = :JAHR ORDER BY kw DESC;';
      Params.ParamByName('JAHR').AsInteger := StrToInt(cbJahr.Text);
      Open;

      while not Eof do
      begin
        wbid := FieldByName('id').AsInteger;
        wbs  := FieldByName('kw').AsString;

        cbKalenderwoche.Items.AddObject(wbs, TObject(wbid));

        Next;
      end;
    end;
  finally
    FDQuery.free;
  end;

  if(cbKalenderwoche.Items.Count > 0) then
  begin
    cbKalenderwoche.ItemIndex := 0;
    cbKalenderwocheSelect(self);
    btnUpdateWochenbericht.Enabled := true;
  end
  else
  begin
    clearWochenbericht;
    btnUpdateWochenbericht.Enabled := false;
  end;
end;




procedure TFrameWochenberichtEdit.cbKalenderwocheSelect(Sender: TObject);
var
  DatumString: String;
  i: integer;
begin
  i := cbKalenderwoche.ItemIndex;
  if i <> -1 then
  begin
    SELKW := StrToInt(cbKalenderwoche.Items[i]);

    DatumString := GetStartEndOfWeek(SELKW, SELYEAR);
    lbStartDatumEndDatum.Caption := '('+DatumString+')';

    SetWeekDates(SELYEAR, SELKW, lbMoDatum, lbDiDatum, lbMiDatum, lbDoDatum, lbFrDatum, lbSaDatum, lbSoDatum);

    WOCHENBERICHTID := integer(cbKalenderwoche.Items.Objects[i]);   //ID des wochenberichtes aus Tabelle wochenberichte

    ShowWochenbericht(WOCHENBERICHTID);
  end;
end;




procedure TFrameWochenberichtEdit.imgPDFClick(Sender: TObject);
var
  i, id: integer;
begin
  i := cbKalenderwoche.ItemIndex;
  if(i>-1) then
  begin
    id := WOCHENBERICHTID;
    GeneratePrintableWochenberichtFromDBByID(id, StrToInt(cbJahr.Text));
  end
  else
    showmessage('Kein Wochenbericht ausgewählt');
end;







procedure TFrameWochenberichtEdit.ShowWochenbericht(id: integer);
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT D.*, W.wochenberichtID, W.meldenderID, W.meldeDatum, M.nachname || " " || M.vorname AS Meldender ' +
                  'FROM wochenberichte AS W LEFT JOIN wochenbericht_data AS D ON W.wochenberichtID = D.id ' +
                  'LEFT JOIN mitarbeiter AS M ON M.id = W.meldenderID ' +
                  'WHERE W.id = :ID LIMIT 0, 1;';
      Params.ParamByName('ID').AsInteger := id;
      Open;

      if not IsEmpty then
      begin
        MELDENDERID        := FieldByName('MeldenderID').AsInteger;
        MELDENDER          := FieldByName('Meldender').AsString;
        MELDEDATUM         := FieldByName('meldeDatum').AsString;
        WOCHENBERICHTID    := FieldByName('wochenberichtID').AsInteger;
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
        MELDENDER          := FieldByName('meldender').AsString;
      end;
    end;
  finally
    FDQuery.Free;
  end;
end;





procedure TFrameWochenberichtEdit.SetWeekDates(Year, Week: Integer; lbMoDatum, lbDiDatum, lbMiDatum, lbDoDatum, lbFrDatum, lbSaDatum, lbSoDatum: TLabel);
var
  StartDate: TDateTime;
begin
  // Berechne das Startdatum der angegebenen Kalenderwoche und des Jahres
  StartDate := StartOfAWeek(Year, Week);

  // Weist den Labels die jeweiligen Daten zu
  lbMoDatum.Caption := DateToStr(StartDate);
  lbDiDatum.Caption := DateToStr(StartDate + 1);
  lbMiDatum.Caption := DateToStr(StartDate + 2);
  lbDoDatum.Caption := DateToStr(StartDate + 3);
  lbFrDatum.Caption := DateToStr(StartDate + 4);
  lbSaDatum.Caption := DateToStr(StartDate + 5);
  lbSoDatum.Caption := DateToStr(StartDate + 6);
end;







procedure TFrameWochenberichtEdit.GeneratePrintableWochenberichtFromDBByID(id, jahr: integer);
var
  FDQuery: TFDQuery;
  stl: TStringList;
  res: TResourceStream;
  i: integer;
  filename: string;
  KG1, KG2, KG3, KB1, KB2, KB3, PB1, PB2, AU1, AU2, MD1, MD2, AR1, AR2, VK1, VK2, SO1, SO2: string;
  MOWANN, MOWER, DIWANN, DIWER, MIWANN, MIWER, DOWANN, DOWER: string;
  FRWANN, FRWER, SAWANN, SAWER, SOWANN, SOWER: string;
  VWM, MFW, SMM, KW, MEL, DAT: string;
  kontrollewann, kontrollewer: string;
begin
  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT D.*, W.meldenderID, W.kw, W.jahr, W.meldeDatum, M.nachname || " " || M.vorname AS Meldender ' +
                  'FROM wochenberichte AS W LEFT JOIN wochenbericht_data AS D ON W.wochenberichtID = D.id ' +
                  'LEFT JOIN mitarbeiter AS M ON M.id = W.meldenderID ' +
                  'WHERE W.wochenberichtID = :ID LIMIT 0, 1;';

      Params.ParamByName('ID').AsInteger := id;
      Open;

      if(RecordCount = 1) then
      begin
        KW  := FieldByName('kw').AsString;
        DAT := ConvertSQLDateToGermanDate(FieldByName('meldeDatum').AsString, false);
        MEL := FieldByName('meldender').AsString;
        KG1 := FieldByName('kundengespr1').AsString;
        KG2 := FieldByName('kundengespr2').AsString;
        KG3 := FieldByName('kundengespr3').AsString;
        KB1 := FieldByName('kundenbeschw1').AsString;
        KB2 := FieldByName('kundenbeschw2').AsString;
        KB3 := FieldByName('kundenbeschw3').AsString;
        PB1 := FieldByName('personalbedarf1').AsString;
        PB2 := FieldByName('personalbedarf2').AsString;
        AU1 := FieldByName('ausbildungen1').AsString;
        AU2 := FieldByName('ausbildungen2').AsString;
        MD1 := FieldByName('mehrdienste1').AsString;
        MD2 := FieldByName('mehrdienste2').AsString;
        AR1 := FieldByName('ausruestung1').AsString;
        AR2 := FieldByName('ausruestung2').AsString;
        VK1 := FieldByName('vorkommnisse1').AsString;
        VK2 := FieldByName('vorkommnisse2').AsString;
        SO1 := FieldByName('sonstiges1').AsString;
        SO2 := FieldByName('sonstiges2').AsString;
        MOWANN := FieldByName('mo_wann').AsString;
        MOWER := FieldByName('mo_wer').AsString;
        DIWANN := FieldByName('di_wann').AsString;
        DIWER := FieldByName('di_wer').AsString;
        MIWANN := FieldByName('mi_wann').AsString;
        MIWER := FieldByName('mi_wer').AsString;
        DOWANN := FieldByName('do_wann').AsString;
        DOWER := FieldByName('do_wer').AsString;
        FRWANN := FieldByName('fr_wann').AsString;
        FRWER := FieldByName('fr_wer').AsString;
        SAWANN := FieldByName('sa_wann').AsString;
        SAWER := FieldByName('sa_wer').AsString;
        SOWANN := FieldByName('so_wann').AsString;
        SOWER := FieldByName('so_wer').AsString;
        VWM  := FieldByName('ssvm').AsString;
        MFW  := FieldByName('ssmw').AsString;
        SMM  := FieldByName('ssmm').AsString;
      end;
    end;

    if(length(KW) = 1) then KW := '0'+KW;


//Hier nur das was einmal für alle Seiten geladen werden muss (HtmlHeader, HtmlFooter)

      res := TResourceStream.Create(HInstance, 'Wochenbericht', 'TXT');
      stl := TStringList.Create;

      stl.LoadFromStream(res);

      stl.Text := StringReplace(stl.Text, '[KW]',    KW, [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[OBJEKTORT]', OBJEKTNAME, [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[KGZ1]',  KG1+'&nbsp;',  [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[KGZ2]',  KG2+'&nbsp;',  [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[KGZ3]',  KG3+'&nbsp;',  [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[KBZ1]',  KB1+'&nbsp;',  [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[KBZ2]',  KB2+'&nbsp;',  [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[KBZ3]',  KB3+'&nbsp;',  [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[PBZ1]',  PB1+'&nbsp;',  [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[PBZ2]',  PB2+'&nbsp;',  [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[BAUZ1]', AU1+'&nbsp;',  [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[BAUZ2]', AU2+'&nbsp;',  [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[MMZ1]',  MD1+'&nbsp;',  [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[MMZ2]',  MD2+'&nbsp;',  [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[BAZ1]',  AR1+'&nbsp;',  [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[BAZ2]',  AR2+'&nbsp;',  [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[BVZ1]',  VK1+'&nbsp;',  [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[BVZ2]',  VK2+'&nbsp;',  [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[SOZ1]',  SO1+'&nbsp;',  [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[SOZ2]',  SO2+'&nbsp;',  [rfReplaceAll]);



      if(MOWANN<>'') then
      begin
        kontrollewann := MOWANN;
        kontrollewer  := MOWER;
      end
      else
      begin
        kontrollewann := '&nbsp;';
        kontrollewer  := '&nbsp;';
      end;
      stl.Text := StringReplace(stl.Text, '[KZMO]',  kontrollewann, [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[KNMO]',  kontrollewer, [rfReplaceAll]);


      if(DIWANN<>'') then
      begin
        kontrollewann := DIWANN;
        kontrollewer  := DIWER;
      end
      else
      begin
        kontrollewann := '&nbsp;';
        kontrollewer  := '&nbsp;';
      end;
      stl.Text := StringReplace(stl.Text, '[KZDI]',  kontrollewann, [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[KNDI]',  kontrollewer, [rfReplaceAll]);


      if(MIWANN<>'') then
      begin
        kontrollewann := MIWANN;
        kontrollewer  := MIWER;
      end
      else
      begin
        kontrollewann := '&nbsp;';
        kontrollewer  := '&nbsp;';
      end;
      stl.Text := StringReplace(stl.Text, '[KZMI]',  kontrollewann, [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[KNMI]',  kontrollewer, [rfReplaceAll]);


      if(DOWANN<>'') then
      begin
        kontrollewann := DOWANN;
        kontrollewer  := DOWER;
      end
      else
      begin
        kontrollewann := '&nbsp;';
        kontrollewer  := '&nbsp;';
      end;
      stl.Text := StringReplace(stl.Text, '[KZDO]',  kontrollewann, [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[KNDO]',  kontrollewer, [rfReplaceAll]);



      if(FRWANN<>'') then
      begin
        kontrollewann := FRWANN;
        kontrollewer  := FRWER;
      end
      else
      begin
        kontrollewann := '&nbsp;';
        kontrollewer  := '&nbsp;';
      end;
      stl.Text := StringReplace(stl.Text, '[KZFR]',  kontrollewann, [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[KNFR]',  kontrollewer, [rfReplaceAll]);


      if(SAWANN<>'') then
      begin
        kontrollewann := SAWANN;
        kontrollewer  := SAWER;
      end
      else
      begin
        kontrollewann := '&nbsp;';
        kontrollewer  := '&nbsp;';
      end;
      stl.Text := StringReplace(stl.Text, '[KZSA]',  kontrollewann, [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[KNSA]',  kontrollewer, [rfReplaceAll]);

      if(SOWANN<>'') then
      begin
        kontrollewann := SOWANN;
        kontrollewer  := SOWER;
      end
      else
      begin
        kontrollewann := '&nbsp;';
        kontrollewer  := '&nbsp;';
      end;
      stl.Text := StringReplace(stl.Text, '[KZSO]',  kontrollewann, [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[KNSO]',  kontrollewer, [rfReplaceAll]);

      stl.Text := StringReplace(stl.Text, '[SVWM]',  VWM,  [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[SMFW]',  MFW,  [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[SMM]',   SMM,  [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[DATUM]', DAT, [rfReplaceAll]);
      stl.Text := StringReplace(stl.Text, '[MELDENDERNAME]', MEL, [rfReplaceAll]);

      //Alle Umlaute in der StringList ersetzen durch html code
      for i := 0 to stl.Count - 1 do
      begin
        stl[i] := ReplaceUmlauteWithHtmlEntities(stl[i]);
      end;


      //Dateiname für zu speichernde Datei erzeugen
      filename := 'Wochenbericht KW ' + KW + ' ' + IntToStr(jahr) + ' ' + OBJEKTNAME + ' ' + OBJEKTORT;

      //Aus Resource-Datei temporäre Html-Datei und daraus eine PDF-Datei im TEMP Verzeichnis erzeugen
      CreateHtmlAndPdfFileFromResource(filename, stl, 'print_portrait.bat');

      //PDF Datei aus Temp Verzeichnis im Zielverzeichnis speichern
      SpeicherePDFDatei(filename, SAVEPATH_Wochenberichte);
  finally
    FDQuery.Free;
    stl.Free;
    res.Free;
  end;
end;






end.



