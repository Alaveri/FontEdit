{$I COMPILER.INC}
{$M 16384, 0, 655360}
program FontEdit;

uses
  GraphIni,
  AplConst,
  AplObj,
  FontApp;

begin
  FontApplication := New(PFontApplication, Create(gdSVga8, 640, 480, 8));
  if not Assigned(FontApplication) then begin
    WriteLn(ErrorMessage(ecNotEnoughMemory) + '.');
    Halt(ecNotEnoughMemory);
  end;
  if not FontApplication^.HasException then
    FontApplication^.Run
  else begin
    WriteLn(ErrorMessage(FontApplication^.Exception^.Code) + '.');
    Halt(FontApplication^.Exception^.Code);
  end;
  FreeAndNil(FontApplication);
end.