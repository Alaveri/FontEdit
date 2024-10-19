{$I COMPILER.INC}
unit FontAppl;

interface

uses
  AplObj,
  GraphDrv,
  Veridian,
  Common,
  Actions,
  Errors,
  Controls,
  FontInit,
  FontType,
  FontWind,
  FontGrid;

type
  PFontApp = ^TFontApp;

  TFontApp = object(TVeridianApp)
  private
    AppSettings: TFontSettings;
  public
    EditorWindow: PFontWindow;
    CurrentFont: PFont;
    function HandleActionExecute(ASender: PObject; AAction: PAction): boolean; virtual;
    function CreateFont(AMaxWidth, AMaxHeight: byte; AFontType: TFontFormat): PFont;
    function LastOpenPath: string;
    procedure UpdateActionControl(AControl: PActionControl); virtual;
    procedure InitControls; virtual;
    procedure InitActions; virtual;
    procedure Init; virtual;
    procedure NewExecute;
    procedure OpenExecute;
    procedure SaveExecute;
    procedure SaveAsExecute;
    procedure AboutExecute;
  end;

var
  FontApp: PFontApp;

implementation

uses
  FontProp,
  AplTypes,
  Dialogs,
  StrUtils,
  Drawing,
  Desk;

procedure TFontApp.Init;
begin
  FontApp := @self;
  inherited Init;
  CurrentFont := nil;
  EditorWindow := nil;
  AppSettings.LoadFromFile(SettingsFilename);
  AppSettings.ClearException;
end;

procedure TFontApp.InitActions;
begin
  inherited InitActions;
  DoInitActions(Desktop^.ActionList);
end;

procedure TFontApp.InitControls;
begin
  inherited InitControls;
  StatusBar^.NewHelpPanel;
  DoInitMenus(FontApp);
end;

procedure TFontApp.UpdateActionControl(AControl: PActionControl);
{var
  action: PAction;
  fileOpen: boolean;}
begin
{  action := AControl^.Action;
  fileOpen := Tabs^.Count > 0;
  case action^.ActionId of
    acSave: action^.Enabled := fileOpen;
    acSaveAs: action^.Enabled := fileOpen;
    acCloseAll: action^.Enabled := fileOpen;
    acClose: action^.Enabled := fileOpen and (Tabs^.TabIndex >= 0);
  end;}
end;

function TFontApp.CreateFont(AMaxWidth, AMaxHeight: byte; AFontType: TFontFormat): PFont;
begin
  case AFontType of
    ffProportional: CreateFont := New(PProportionalFont, CreateSize(AMaxWidth, AMaxHeight));
    ffMonospace: CreateFont := New(PMonospaceFont, Create);
    ffColored: CreateFont := New(PColoredFont, CreateSize(AMaxWidth, AMaxHeight));
  end;
end;

procedure TFontApp.NewExecute;
var
  dialog: PFontPropertiesDialog;
  result: TModalResult;
  maxWidth, height, spacing: byte;
  fontType: TFontFormat;
begin
  dialog := New(PFontPropertiesDialog, Create('New Font'));
  result := dialog^.ShowModal;
  if result = mrOk then begin
    maxWidth := dialog^.FontMaxWidthEntry^.Value;
    height := dialog^.FontHeightEntry^.Value;
    fontType := TFontFormat(dialog^.FontTypeEntry^.SelectedItem^.Tag);
    spacing := dialog^.FontSpacingEntry^.Value;
    NewFont(nil, maxWidth, height, fontType);
  end;
  FreeAndNil(dialog);
end;

procedure TFontApp.AboutExecute;
var
  dialog: PAboutDialog;
begin
  dialog := New(PAboutDialog, Create);
  dialog^.ShowModal;
  FreeAndNil(dialog);
end;

function TFontApp.LastOpenPath: string;
begin
  LastOpenPath := IncludeBackslash(AppDir) + '*.fnt';
end;

procedure TFontApp.OpenExecute;
var
  dialog: PFileDialog;
  result: TModalResult;
begin
  dialog := New(PFileDialog, Create('Open Font', LastOpenPath));
  dialog^.Options := [doFileMustExist];
  dialog^.DefaultExt := '.fnt';
  result := dialog^.ShowModal;
  if result = mrOk then begin
    FreeAndNil(CurrentFont);
    CurrentFont := New(PProportionalFont, CreateLoadFile(dialog^.Filename));
    if not CheckError(CurrentFont) then begin
      FreeAndNil(CurrentFont);
      exit;
    end;
    NewFont(CurrentFont, CurrentFont^.MaxWidth, CurrentFont^.Height, ffProportional);
    TString.Assign(AppSettings.LastOpenDir, ExtractDirectory(dialog^.Filename));
    AppSettings.SaveToFile(SettingsFilename);
  end;
  FreeAndNil(dialog);
end;

procedure TFontApp.SaveAsExecute;
begin
end;

procedure TFontApp.SaveExecute;
var
  dialog: PFileDialog;
  result: TModalResult;
begin
  dialog := New(PFileDialog, Create('Save Font', LastOpenPath));
  dialog^.Options := [doOverwritePrompt];
  dialog^.DefaultExt := '.fnt';
  result := dialog^.ShowModal;
  if result = mrOk then begin
    CurrentFont^.SaveToFile(dialog^.Filename);
  end;
  FreeAndNil(dialog);
end;

function TFontApp.HandleActionExecute(ASender: PObject; AAction: PAction): boolean;
begin
  if inherited HandleActionExecute(ASender, AAction) then
    exit;
  case AAction^.ActionId of
    acNew: NewExecute;
    acOpen: OpenExecute;
    acAbout: AboutExecute;
    acSave: SaveExecute;
    acSaveAs: SaveAsExecute;
{    acClose: CloseTabExecute;
    acCloseAll: CloseAllTabsExecute;
    acSettings: EditSettingsExecute;}
    acExit: Close;
  end;
end;

begin
  FontApp := nil;
end.