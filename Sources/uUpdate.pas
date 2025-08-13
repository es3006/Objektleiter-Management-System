// Datei: uUpdate.pas
unit uUpdate;

interface

uses
  System.Hash, Winapi.Windows, StrUtils, System.SysUtils, System.UITypes, System.Math, Vcl.Dialogs, Vcl.Forms, IdHTTP, System.JSON, IdSSLOpenSSL,
  System.Generics.Collections, System.Classes, DateUtils, ShellApi, System.Threading, System.IOUtils,
  Vcl.StdCtrls, Vcl.Controls;


function VersionCompare(const V1, V2: string): Integer;
procedure CheckInternetAsync(const URL: string; OnResult: TProc<Boolean>);
procedure GetRemoteVersionAsync(const URL: string; Callback: TProc<string>);
procedure GetChangeLogAsync(const URL: string; Callback: TProc<string>);
procedure StarteUpdateProzessAsync;
procedure ReplaceAndRestart;
procedure CheckAndUpdateIfAvailableAsync(const VersionInstalled: string; const ShowNoUpdateMsg: Boolean = True);




implementation

uses
  uMain, uErrorLog;

const
  NETWORK_CONNECT_TIMEOUT = 3000;
  NETWORK_READ_TIMEOUT = 5000;
  NETWORK_RETRY_ATTEMPTS = 2;
  NETWORK_RETRY_DELAY = 1000;
  ONLINE_CHECK_INTERVAL = 30000;
  VERSION_FILE = 'version.txt';
  CHANGELOG_FILE = 'changelog.txt';





function BerechneSHA256(const DateiPfad: string): string;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(DateiPfad, fmOpenRead or fmShareDenyWrite);
  try
    Result := THashSHA2.GetHashString(Stream);
  finally
    Stream.Free;
  end;
end;



function LadeRemoteSHA256(const URL: string): string;
var
  HTTP: TIdHTTP;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  Inhalt: string;
begin
  Result := '';
  HTTP := TIdHTTP.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    SSL.SSLOptions.SSLVersions := [sslvTLSv1_2];
    HTTP.IOHandler := SSL;
    HTTP.HandleRedirects := True;
    HTTP.Request.UserAgent := PROGRAMMNAME;
    HTTP.ConnectTimeout := NETWORK_CONNECT_TIMEOUT;
    HTTP.ReadTimeout := NETWORK_READ_TIMEOUT;

    try
      Inhalt := HTTP.Get(URL);
      Result := Trim(Inhalt.Split([' '])[0]); // Nur der Hash-Teil
    except
      on E: Exception do
        Result := '';
    end;
  finally
    HTTP.Free;
    SSL.Free;
  end;
end;





function VersionCompare(const V1, V2: string): Integer;
var
  A1, A2: TArray<string>;
  I, N1, N2: Integer;
begin
  A1 := V1.Split(['.']);
  A2 := V2.Split(['.']);
  for I := 0 to Max(Length(A1), Length(A2)) - 1 do
  begin
    N1 := IfThen(I < Length(A1), StrToIntDef(A1[I], 0), 0);
    N2 := IfThen(I < Length(A2), StrToIntDef(A2[I], 0), 0);
    if N1 <> N2 then
      Exit(N1 - N2);
  end;
  Result := 0;
end;









procedure CheckAndUpdateIfAvailableAsync(const VersionInstalled: string; const ShowNoUpdateMsg: Boolean = True);
begin
  GetRemoteVersionAsync(UPDATEURL + VERSION_FILE,
    procedure(RemoteVersion: string)
    var
      cmp: Integer;
      verInstalledTrim, verRemoteTrim: string;
    begin
      verInstalledTrim := Trim(VersionInstalled);
      verRemoteTrim    := Trim(RemoteVersion);

      if verRemoteTrim = '' then
      begin
        if ShowNoUpdateMsg then
          TThread.Queue(nil, procedure begin
            ShowMessage('Die Online-Version konnte nicht ermittelt werden.');
          end);
        Exit;
      end;

      cmp := VersionCompare(verInstalledTrim, verRemoteTrim);

      // Bereits aktuell oder neuer -> Meldung (optional)
      if cmp >= 0 then
      begin
        if ShowNoUpdateMsg then
          TThread.Queue(nil, procedure begin
            ShowMessage(Format('Sie nutzen bereits die aktuellste Version (%s).', [verInstalledTrim]));
          end);
        Exit;
      end;

      // Update verfügbar -> Changelog holen und fragen
      GetChangeLogAsync(UPDATEURL + CHANGELOG_FILE,
        procedure(Changelog: string)
        begin
          TThread.Queue(nil, procedure
          var
            txt: string;
          begin
            txt := 'Ein Update auf Version ' + verRemoteTrim + ' ist verfügbar.' + sLineBreak +
                   'Änderungen:' + sLineBreak + Changelog + sLineBreak + sLineBreak +
                   'Möchten Sie das Update jetzt installieren?';

            if MessageDlg(txt, mtInformation, [mbYes, mbNo], 0) = mrYes then
            begin
              ShowMessage('Bitte warten... Update wird heruntergeladen und installiert.' + sLineBreak +
                          'Das Programm wird anschließend neu gestartet.');
              StarteUpdateProzessAsync;  // falls das UI anfasst, ggf. ebenfalls über TThread.Queue
            end
            else if ShowNoUpdateMsg then
            begin
              ShowMessage('Update wurde abgelehnt. Sie bleiben auf Version ' + verInstalledTrim + '.');
            end;
          end);
        end);
    end);
end;





function ExecuteWithRetryBoolean(const Operation: TFunc<Boolean>; MaxRetries: Integer = NETWORK_RETRY_ATTEMPTS): Boolean;
var
  Attempt: Integer;
begin
  Result := False;
  Attempt := 0;
  while Attempt <= MaxRetries do
  begin
    try
      Result := Operation();
      Exit;
    except
      on E: Exception do
      begin
        Inc(Attempt);
        if Attempt > MaxRetries then raise
        else
        begin
          TLogging.LogMessage(OLUSERNAME, 'uUpdate', 'ExecuteWithRetryBoolean',
            Format('Versuch %d fehlgeschlagen, wiederhole in %dms: %s', [Attempt, NETWORK_RETRY_DELAY, E.Message]));
          Sleep(NETWORK_RETRY_DELAY);
        end;
      end;
    end;
  end;
end;





function ExecuteWithRetryString(const Operation: TFunc<string>; MaxRetries: Integer = NETWORK_RETRY_ATTEMPTS): string;
var
  Attempt: Integer;
begin
  Attempt := 0;
  while Attempt <= MaxRetries do
  begin
    try
      Result := Operation();
      Exit;
    except
      on E: Exception do
      begin
        Inc(Attempt);
        if Attempt > MaxRetries then raise
        else
        begin
          TLogging.LogMessage(OLUSERNAME, 'uUpdate', 'ExecuteWithRetryString',
            Format('Versuch %d fehlgeschlagen, wiederhole in %dms: %s', [Attempt, NETWORK_RETRY_DELAY, E.Message]));
          Sleep(NETWORK_RETRY_DELAY);
        end;
      end;
    end;
  end;
end;

procedure SleepUntilUnlocked(const FileName: string; MaxWaitMS: Integer);
var
  hFile: THandle;
  Waited: Integer;
begin
  Waited := 0;
  repeat
    hFile := CreateFile(PChar(FileName), GENERIC_READ, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    if hFile <> INVALID_HANDLE_VALUE then
    begin
      CloseHandle(hFile);
      Exit;
    end;
    Sleep(500);
    Inc(Waited, 500);
  until Waited >= MaxWaitMS;
end;





procedure ReplaceAndRestart;
var
  AppDir, OldExe, NewExe, BackupExe: string;
begin
  AppDir := ExtractFilePath(ParamStr(0));
  OldExe := AppDir + PROGRAMMNAME + '.exe';
  NewExe := AppDir + PROGRAMMNAME + '.tmp';
  BackupExe := AppDir + PROGRAMMNAME + '_old.exe';

  Sleep(1000); // Optional: etwas warten

  if FileExists(BackupExe) then
    DeleteFile(BackupExe);

  RenameFile(OldExe, BackupExe);
  RenameFile(NewExe, OldExe);

  ShellExecute(0, 'open', PChar(OldExe), nil, nil, SW_SHOWNORMAL);
  Application.Terminate;
end;






procedure StarteUpdateProzessAsync;
var
  ProgressForm: TForm;
  ProgressLabel: TLabel;
begin
  TThread.Synchronize(nil,
    procedure
    begin
      Application.MainForm.Enabled := False;

      ProgressForm := TForm.Create(nil);
      ProgressForm.BorderStyle := bsDialog;
      ProgressForm.Caption := 'Update wird installiert...';
      ProgressForm.Position := poScreenCenter;
      ProgressForm.ClientWidth := 400;
      ProgressForm.ClientHeight := 100;
      ProgressForm.FormStyle := fsStayOnTop;

      ProgressLabel := TLabel.Create(ProgressForm);
      ProgressLabel.Parent := ProgressForm;
      ProgressLabel.Align := alClient;
      ProgressLabel.Alignment := taCenter;
      ProgressLabel.Layout := tlCenter;
      ProgressLabel.Caption := 'Bitte warten... Update wird vorbereitet.';
      ProgressLabel.Font.Size := 10;

      ProgressForm.Show;
      ProgressForm.Update;
    end);

  TTask.Run(procedure
  var
    UpdatePfad, DateiURL, Fehler, LokalerHash, RemoteHash: string;
    HTTP: TIdHTTP;
    SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
    FileStream: TFileStream;
    StartTime: TDateTime;
  begin
    DateiURL := UPDATEURL + PROGRAMMNAME + '.exe';
    UpdatePfad := TPath.Combine(ExtractFilePath(ParamStr(0)), PROGRAMMNAME + '.tmp');
    Fehler := '';

    TThread.Synchronize(nil, procedure
    begin
      ProgressLabel.Caption := 'Verbinde mit Server...';
    end);

    try
      Fehler := ExecuteWithRetryString(
        function: string
        begin
          HTTP := TIdHTTP.Create(nil);
          SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
          try
            SSLHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
            HTTP.IOHandler := SSLHandler;
            HTTP.HandleRedirects := True;
            HTTP.Request.UserAgent := Format('%s/%s', [PROGRAMMNAME, PROGRAMMVERSION]);
            HTTP.ConnectTimeout := NETWORK_CONNECT_TIMEOUT;
            HTTP.ReadTimeout := NETWORK_READ_TIMEOUT;

            try
              FileStream := TFileStream.Create(UpdatePfad, fmCreate);
              try
                TThread.Synchronize(nil, procedure
                begin
                  ProgressLabel.Caption := 'Lade Update-Datei herunter...';
                end);

                HTTP.Get(DateiURL, FileStream);
              finally
                FileStream.Free;
              end;
            except
              on E: Exception do
                Exit('Download-Fehler: ' + E.Message);
            end;
          finally
            SSLHandler.Free;
            HTTP.Free;
          end;

          Result := '';
        end);
    except
      on E: Exception do
        Fehler := 'Update-Prozess fehlgeschlagen: ' + E.Message;
    end;

    // SHA-256 Prüfen
    if Fehler = '' then
    begin
      TThread.Synchronize(nil, procedure
      begin
        ProgressLabel.Caption := 'Prüfe Integrität der Update-Datei...';
      end);

      LokalerHash := BerechneSHA256(UpdatePfad);
      RemoteHash := LadeRemoteSHA256(UPDATEURL + PROGRAMMNAME + '.sha256.txt');

      if (RemoteHash = '') or (LokalerHash <> RemoteHash) then
      begin
        Fehler := 'Update-Datei beschädigt oder manipuliert!' + sLineBreak +
                  'Erwarteter Hash: ' + RemoteHash + sLineBreak +
                  'Gefundener Hash: ' + LokalerHash;
      end;
    end;

    // Abschluss im UI-Thread
    TThread.Synchronize(nil, procedure
    begin
      try
        if Fehler <> '' then
        begin
          ProgressLabel.Caption := 'Fehler: ' + Fehler;
          Sleep(2000);
          ShowMessage('Update fehlgeschlagen:' + sLineBreak + Fehler);
          Exit;
        end;

        if not FileExists(UpdatePfad) then
        begin
          ProgressLabel.Caption := 'Fehler: Update-Datei fehlt.';
          Sleep(1500);
          ShowMessage('Update-Datei fehlt: ' + UpdatePfad);
          Exit;
        end;

        ProgressLabel.Caption := 'Update erfolgreich geladen. Starte Neuinstallation...';
        Sleep(1500);
        ProgressForm.Close;

        ReplaceAndRestart;
      finally
        ProgressForm.Free;
        Application.MainForm.Enabled := True;
      end;
    end);
  end);
end;















procedure CheckInternetAsync(const URL: string; OnResult: TProc<Boolean>);
begin
  TTask.Run(
    procedure
    var
      HTTP: TIdHTTP;
      SSL: TIdSSLIOHandlerSocketOpenSSL;
      Erfolg: Boolean;
    begin
      Erfolg := False;
      try
        Erfolg := ExecuteWithRetryBoolean(
          function: Boolean
          begin
            HTTP := TIdHTTP.Create(nil);
            SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
            try
              SSL.SSLOptions.Method := sslvTLSv1_2;
              SSL.SSLOptions.SSLVersions := [sslvTLSv1_2];
              SSL.SSLOptions.VerifyMode := [];
              SSL.SSLOptions.VerifyDepth := 0;

              HTTP.IOHandler := SSL;
              HTTP.Request.UserAgent := PROGRAMMNAME;
              HTTP.HandleRedirects := True;
              HTTP.ConnectTimeout := NETWORK_CONNECT_TIMEOUT;
              HTTP.ReadTimeout := NETWORK_READ_TIMEOUT;
              try
                HTTP.Head(URL);
                Result := HTTP.ResponseCode = 200;
              except
                on E: Exception do
                  Result := False;
              end;
            finally
              SSL.Free;
              HTTP.Free;
            end;
          end);
      except
        Erfolg := False;
      end;
      TThread.Synchronize(nil, procedure begin OnResult(Erfolg); end);
    end);
end;





procedure GetRemoteVersionAsync(const URL: string; Callback: TProc<string>);
begin
  TTask.Run(
    procedure
    var
      Inhalt: string;
    begin
      try
        Inhalt := ExecuteWithRetryString(
          function: string
          var
            HTTP: TIdHTTP;
            SSL: TIdSSLIOHandlerSocketOpenSSL;
          begin
            HTTP := TIdHTTP.Create(nil);
            SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
            try
              SSL.SSLOptions.SSLVersions := [sslvTLSv1_2];
              HTTP.IOHandler := SSL;
              HTTP.Request.UserAgent := PROGRAMMNAME;
              HTTP.HandleRedirects := True;
              HTTP.ConnectTimeout := NETWORK_CONNECT_TIMEOUT;
              HTTP.ReadTimeout := NETWORK_READ_TIMEOUT;
              Result := Trim(HTTP.Get(URL));
            finally
              SSL.Free;
              HTTP.Free;
            end;
          end);
      except
        Inhalt := '';
      end;
      TThread.Synchronize(nil, procedure begin Callback(Inhalt); end);
    end);
end;

procedure GetChangeLogAsync(const URL: string; Callback: TProc<string>);
begin
  TTask.Run(
    procedure
    var
      Inhalt: string;
    begin
      try
        Inhalt := ExecuteWithRetryString(
          function: string
          var
            HTTP: TIdHTTP;
            SSL: TIdSSLIOHandlerSocketOpenSSL;
          begin
            HTTP := TIdHTTP.Create(nil);
            SSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
            try
              SSL.SSLOptions.SSLVersions := [sslvTLSv1_2];
              HTTP.IOHandler := SSL;
              HTTP.Request.UserAgent := PROGRAMMNAME;
              HTTP.HandleRedirects := True;
              HTTP.ConnectTimeout := NETWORK_CONNECT_TIMEOUT;
              HTTP.ReadTimeout := NETWORK_READ_TIMEOUT;
              Result := HTTP.Get(URL);
            finally
              SSL.Free;
              HTTP.Free;
            end;
          end);
      except
        Inhalt := '';
      end;
      TThread.Synchronize(nil, procedure begin Callback(Inhalt); end);
    end);
end;

end.
