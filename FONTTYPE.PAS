{$I COMPILER.INC}
unit FontType;

interface

uses
  AplObj,
  AplTypes,
  Streams,
  Graphics;

type
  PFontProperties = ^TFontProperties;
  PFontAppSettings = ^TFontAppSettings;

  TFontProperties = object(TIdentifiable)
  private
  public
    Format: TFontFormat;
    MaxWidth: integer;
    Height: integer;
    Spacing: integer;
    function CreateFont: PFont;
    procedure Init; virtual;
    procedure Assign(var ASource: TObject); virtual;
  end;

  TFontAppSettings = object(TPersistent)
  private
  public
    LastOpenDir: PChar;
    LastSaveDir: PChar;
    procedure LoadFromStream(AStream: PStream); virtual;
    procedure SaveToStream(AStream: PStream); virtual;
    destructor Free; virtual;
    procedure Init; virtual;
    procedure Assign(var ASource: TObject); virtual;
  end;

const
  SupportedFontFormats: TFontFormats = [
    ffMonoSpace,
    ffProportional,
    ffSystem,
    ffColored
  ];

implementation

uses
  AplUtils,
  AplStr;

procedure TFontProperties.Init;
begin
  Id := nil;
  Format := ffProportional;
  MaxWidth := 8;
  Height := 16;
  Spacing := 1;
end;

procedure TFontProperties.Assign(var ASource: TObject);
var
  source: PFontProperties;
begin
  inherited Assign(ASource);
  source := PFontProperties(@ASource);
  TString.Assign(Id, source^.Id);
  Format := Source^.Format;
  MaxWidth := Source^.MaxWidth;
  Height := Source^.Height;
  Spacing := Source^.Spacing;
end;

function TFontProperties.CreateFont: PFont;
var
  result: PFont;
begin
  case Format of
    ffMonoSpace: result := New(PMonospaceFont, CreateSize(MaxWidth, Height, Spacing));
    ffProportional: result := New(PProportionalFont, CreateSize(MaxWidth, Height, Spacing));
    ffSystem: result := New(PSystemFont, Create);
    ffColored: result := New(PColoredFont, CreateSize(MaxWidth, Height, Spacing));
  end;
  result^.Id := TString.Copy(Id);
  result^.SetFormat(Format);
  CreateFont := result;
end;

procedure TFontAppSettings.Init;
begin
  inherited Init;
  LastOpenDir := TString.New(AppDir);
  LastSaveDir := TString.New(AppDir);
end;

procedure TFontAppSettings.Assign(var ASource: TObject);
var
  source: PFontAppSettings;
begin
  inherited Assign(ASource);
  source := PFontAppSettings(@ASource);
  TString.Assign(LastOpenDir, source^.LastOpenDir);
  TString.Assign(LastSaveDir, source^.LastSaveDir);
end;

procedure TFontAppSettings.LoadFromStream(AStream: PStream);
begin
  inherited Create;
  TString.Free(LastOpenDir);
  TString.Free(LastSaveDir);
  LastOpenDir := AStream^.ReadPChar;
  LastSaveDir := AStream^.ReadPChar;
end;

procedure TFontAppSettings.SaveToStream(AStream: PStream);
begin
  AStream^.WritePChar(LastOpenDir);
  AStream^.WritePChar(LastSaveDir);
  CheckReRaise(AStream);
end;

destructor TFontAppSettings.Free;
begin
  TString.Free(LastOpenDir);
  TString.Free(LastSaveDir);
  inherited Free;
end;

end.