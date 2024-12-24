{$I COMPILER.INC}
{$M 16384, 0, 655360}
program FontEdit;

uses
  GraphIni,
  AplConst,
  AplObj,
  FontApp;

begin
  FontApplication := New(PFontApplication, Create(gdSVga8, 640, 480 , 8));
  if not Assigned(FontApplication) then begin
    WriteLn('Not enough memory.');
    exit;
  end;
  if not FontApplication^.HasException then
    FontApplication^.Run
  else
    WriteLn(ErrorMessage(FontApplication^.Exception^.Code));
  FreeAndNil(FontApplication);
end.