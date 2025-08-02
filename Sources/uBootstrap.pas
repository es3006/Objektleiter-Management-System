unit uBootstrap;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows;

procedure ExtractWebView2Loader;

implementation

{$R WebView2.RES}

procedure ExtractWebView2Loader;
var
  RS: TResourceStream;
  OutputPath: string;
begin
  OutputPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'WebView2Loader_x64.dll';

  if not FileExists(OutputPath) then
  begin
    RS := TResourceStream.Create(HInstance, 'WEBVIEW2LOADER', RT_RCDATA);
    try
      RS.SaveToFile(OutputPath);
    finally
      RS.Free;
    end;
  end;
end;

initialization
  ExtractWebView2Loader;

end.
