program Objektleiter_Management;

uses
  uBootstrap,
  Vcl.Forms,
  uMain in 'uMain.pas' {fMain},
  uFirstStart in 'uFirstStart.pas' {fFirstStart},
  uFunktionen in 'uFunktionen.pas',
  uDBFunktionen in 'uDBFunktionen.pas',
  uDBSettings in 'uDBSettings.pas' {fDBSettings},
  uMitarbeiterEdit in 'uMitarbeiterEdit.pas' {fMitarbeiterEdit},
  uMitarbeiterNeu in 'uMitarbeiterNeu.pas' {fMitarbeiterNeu},
  uObjekte in 'uObjekte.pas' {fObjekte},
  uWaffenbestand in 'uWaffenbestand.pas' {fWaffenbestand},
  uWebBrowser in 'uWebBrowser.pas' {fWebBrowser},
  uObjekteNeu in 'uObjekteNeu.pas' {fObjekteNeu},
  uObjekteBearbeiten in 'uObjekteBearbeiten.pas' {fObjekteBearbeiten},
  uFrameWochenberichtEdit in 'uFrameWochenberichtEdit.pas' {FrameWochenberichtEdit: TFrame},
  uFrameWachpersonal in 'uFrameWachpersonal.pas' {FrameWachpersonal: TFrame},
  uFrameGesamtausbildung in 'uFrameGesamtausbildung.pas' {FrameGesamtausbildung: TFrame},
  uFrameWachtest in 'uFrameWachtest.pas' {FrameWachtest: TFrame},
  uFrameWachschiessen in 'uFrameWachschiessen.pas' {FrameWachschiessen: TFrame},
  uMitarbeiter in 'uMitarbeiter.pas' {fMitarbeiter},
  uFrameWaffenbestandsmeldung in 'uFrameWaffenbestandsmeldung.pas' {FrameWaffenbestandsmeldung: TFrame},
  uFrameTheorieausbildung in 'uFrameTheorieausbildung.pas' {FrameTheorieausbildung: TFrame},
  uFrameErsteHilfe in 'uFrameErsteHilfe.pas' {FrameErsteHilfe: TFrame},
  uEinstellungen_WaffenMunition in 'uEinstellungen_WaffenMunition.pas' {fEinstellungen_WaffenMunition},
  uWochenberichtNeu in 'uWochenberichtNeu.pas' {fWochenberichtNeu},
  uDatumMeldender in 'uDatumMeldender.pas' {fDatumMeldender},
  uAnmeldung in 'uAnmeldung.pas' {fAnmeldung},
  uFrameMunTausch in 'uFrameMunTausch.pas' {FrameMunTausch: TFrame},
  uEinstellungen_Objekt in 'uEinstellungen_Objekt.pas' {fEinstellungen_Objekt},
  uZugangsdaten in 'uZugangsdaten.pas' {fZugangsdaten},
  uDiensthunde in 'uDiensthunde.pas' {fDiensthunde},
  uEinstellungen_Programm in 'uEinstellungen_Programm.pas' {fEinstellungen_Programm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.CreateForm(TfFirstStart, fFirstStart);
  Application.CreateForm(TfDBSettings, fDBSettings);
  Application.CreateForm(TfMitarbeiterEdit, fMitarbeiterEdit);
  Application.CreateForm(TfMitarbeiterNeu, fMitarbeiterNeu);
  Application.CreateForm(TfObjekte, fObjekte);
  Application.CreateForm(TfWaffenbestand, fWaffenbestand);
  Application.CreateForm(TfWebBrowser, fWebBrowser);
  Application.CreateForm(TfObjekteNeu, fObjekteNeu);
  Application.CreateForm(TfObjekteBearbeiten, fObjekteBearbeiten);
  Application.CreateForm(TfMitarbeiter, fMitarbeiter);
  Application.CreateForm(TfEinstellungen_WaffenMunition, fEinstellungen_WaffenMunition);
  Application.CreateForm(TfWochenberichtNeu, fWochenberichtNeu);
  Application.CreateForm(TfDatumMeldender, fDatumMeldender);
  Application.CreateForm(TfAnmeldung, fAnmeldung);
  Application.CreateForm(TfEinstellungen_Objekt, fEinstellungen_Objekt);
  Application.CreateForm(TfZugangsdaten, fZugangsdaten);
  Application.CreateForm(TfDiensthunde, fDiensthunde);
  Application.CreateForm(TfEinstellungen_Programm, fEinstellungen_Programm);
  Application.Run;
end.
