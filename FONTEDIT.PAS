{$I COMPILER.INC}
{$M 8192, 0, 655360}
program FontEdit;

uses
  AplObj,
  AplApps,
  GraphApp,
  GraphIni,
  Veridian,
  MainApp;

begin
  FontApp := New(PFontApp, Create(gdSVgaBgi8, 640, 480, 8));
  FontApp^.Run;
  FreeAndNil(FontApp);
end.
