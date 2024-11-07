{$I COMPILER.INC}
unit FontType;

interface

uses
  AplObj,
  AplConst,
  AplStrms;

const
  AppVersion = '0.1.0';

type
  PFontSettings = ^TFontSettings;

  TFontSettings = object(TStatusObject)
  private
  public
    LastOpenDir: PChar;
    LastSaveDir: PChar;
    constructor LoadFromStream(AStream: PStream);
    constructor LoadFromFile(const AFilename: string);
    destructor Free; virtual;
    procedure Init; virtual;
    procedure Assign(var ASource: TObject); virtual;
    procedure SaveToStream(AStream: PStream);
    procedure SaveToFile(const AFilename: string);
  end;

function SettingsFilename: string; far;

implementation


uses
  AplUtils,
  Veridian,
  AplStr;

function SettingsFilename: string;
begin
  SettingsFilename := IncludeBackslash(AppDir) +  'settings.bin';
end;

procedure TFontSettings.Init;
begin
  inherited Init;
  LastOpenDir := nil;
  LastSaveDir := nil;
end;

procedure TFontSettings.Assign(var ASource: TObject);
var
  source: PFontSettings;
begin
  inherited Assign(ASource);
  source := PFontSettings(@ASource);
  TString.Reassign(LastOpenDir, source^.LastOpenDir);
  TString.Reassign(LastSaveDir, source^.LastSaveDir);
end;

constructor TFontSettings.LoadFromStream(AStream: PStream);
begin
  inherited Create;
  TString.Free(LastOpenDir);
  TString.Free(LastSaveDir);
  LastOpenDir := AStream^.ReadPChar;
  LastSaveDir := AStream^.ReadPChar;
  if CheckReraise(AStream) then begin
    TString.Free(LastOpenDir);
    TString.Free(LastSaveDir);
    LastOpenDir := TString.New(AppDir);
    LastSaveDir := TString.New(AppDir);
  end;
end;

constructor TFontSettings.LoadFromFile(const AFilename: string);
var
  stream: PFileStream;
begin
  inherited Create;
  stream := New(PFileStream, Create(AFilename, fmRead));
  if NilPtr(stream, ecNotEnoughMemory) then
    exit;
  if FileExists(AFilename) then begin
    LoadFromStream(stream);
    CheckReraise(stream);
    FreeAndNil(stream);
    exit;
  end;
  Raise(ecFileNotFound);
end;

procedure TFontSettings.SaveToFile(const AFilename: string);
var
  stream: PFileStream;
begin
  stream := New(PFileStream, Create(AFilename, fmWrite));
  if NilPtr(stream, ecNotEnoughMemory) then
    exit;
  SaveToStream(stream);
  CheckReraise(stream);
  FreeAndNil(stream);
end;

procedure TFontSettings.SaveToStream(AStream: PStream);
var
  len: word;
  start: longint;
begin
  len := TString.Length(LastOpenDir);
  AStream^.WritePChar(LastOpenDir);
  AStream^.WritePChar(LastSaveDir);
  VeridianApp^.Settings.SaveToStream(AStream);
  CheckReraise(AStream);
end;

destructor TFontSettings.Free;
begin
  TString.Free(LastOpenDir);
  TString.Free(LastSaveDir);
  inherited Free;
end;

end.