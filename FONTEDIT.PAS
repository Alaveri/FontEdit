{$I COMPILER.INC}
{$M 8192, 0, 655360}
program FontEdit;

uses
  AplObj,
  AplApps,
  AplGraph,
  AplGrIni,
  Veridian,
  FontAppl;

begin
  FontApp := New(PFontApp, Create(gdSVga8, 640, 480, 8));
  FontApp^.Run;
  FreeAndNil(FontApp);
end.
