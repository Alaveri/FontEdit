{$I COMPILER.INC}
unit FontCons;

interface

const
  AppVersion = '1.0.0';

function SettingsFilename: string;

implementation

uses
  AplUtils;

function SettingsFilename: string;
begin
  SettingsFilename := IncludeBackslash(AppDir) +  'settings.bin';
end;

end.