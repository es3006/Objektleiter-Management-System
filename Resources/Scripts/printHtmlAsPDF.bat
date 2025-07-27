@echo off
setlocal

REM Dieses Script kann wie folgt über ein Terminal oder aus Delphi heraus aufgerufen werden
REM ./printHtmlAsPDF.bat "Waffenbestandsmeldung.html" "Waffenbestandsmeldung.pdf"


REM Übernehmen Sie die Pfade zur HTML-Datei und zur Ausgabe-PDF-Datei als Parameter
set "HTMLDatei=%1"
set "PDFDatei=%2"

REM Überprüfen, ob beide Parameter übergeben wurden
if "%HTMLDatei%"=="" (
    echo Bitte geben Sie den Pfad zur HTML-Datei als ersten Parameter an.
    goto :eof
)

if "%PDFDatei%"=="" (
    echo Bitte geben Sie den Pfad zur PDF-Datei als zweiten Parameter an.
    goto :eof
)

REM Setzen Sie den Pfad zur wkhtmltopdf.exe in doppelte Anführungszeichen
set wkhtmltopdfPath=wkhtmltopdf.exe
REM set "wkhtmltopdfPath=D:\PROGRAMMIERUNG\Delphi\Projekte\Firma\EmbeddedDB\SCRIPTS\wkhtmltopdf.exe"


REM Führen Sie den wkhtmltopdf-Befehl aus, um die HTML-Datei in eine PDF-Datei umzuwandeln
"%wkhtmltopdfPath%" "%HTMLDatei%" "%PDFDatei%"

echo HTML-Datei wurde als PDF-Datei gedruckt: %PDFDatei%

endlocal

PAUSE