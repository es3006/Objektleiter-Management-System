unit uErrorLog;

interface

uses
  System.SysUtils, System.Classes, Vcl.Dialogs;

type
  TLogging = class
  public
    class procedure LogMessage(const objektnr, UnitName, ProcName, Msg: string);
  end;

implementation

uses
  uMain, uFunktionen;

class procedure TLogging.LogMessage(const objektnr, UnitName, ProcName, Msg: string);
var
  FLogFile: TextFile;
  s: string;
begin
  s := '';

  if(trim(objektnr) <> '') then
  begin
    if(WriteErrorsInFile = true) then
    begin
      AssignFile(FLogFile, 'application.log');
      if not FileExists('application.log') then
        Rewrite(FLogFile)
      else
        Append(FLogFile);

      s := ReplaceUmlaute(Msg);
      WriteLn(FLogFile, Format('[%s] [%s] [%s] [%s] [%s]', [DateTimeToStr(Now), objektnr, UnitName, ProcName, s]));
      Flush(FLogFile);
      CloseFile(FLogFile);
    end;
  end;
end;

end.
