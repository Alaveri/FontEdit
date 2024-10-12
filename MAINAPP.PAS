{$I COMPILER.INC}
unit MainApp;

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
  FontWind,
  FontGrid;

type
  PFontApp = ^TFontApp;

  TFontApp = object(TVeridianApp)
  private
  public
    EditorWindow: PFontWindow;
    CurrentFont: PFont;
    function HandleActionExecute(ASender: PObject; AAction: PAction): boolean; virtual;
    function CreateFont(AMaxWidth, AMaxHeight: byte; AFontType: TFontFormat): PFont;
    procedure UpdateActionControl(AControl: PActionControl); virtual;
    procedure InitControls; virtual;
    procedure InitActions; virtual;
    procedure Init; virtual;
    procedure NewExecute;
  end;

var
  FontApp: PFontApp;

implementation

uses
  FontProp,
  AplTypes,
  Drawing,
  Desk;

procedure TFontApp.Init;
begin
  FontApp := @self;
  inherited Init;
  CurrentFont := nil;
  EditorWindow := nil;
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
    NewFont(maxWidth, height, fontType);
  end;
  FreeAndNil(dialog);
end;

function TFontApp.HandleActionExecute(ASender: PObject; AAction: PAction): boolean;
begin
  if inherited HandleActionExecute(ASender, AAction) then
    exit;
  case AAction^.ActionId of
    acNew: NewExecute;
{    acSave: SaveExecute;
    acClose: CloseTabExecute;
    acCloseAll: CloseAllTabsExecute;
    acOpen: OpenExecute;
    acSaveAs: SaveAsExecute;
    acAbout: AboutExecute;
    acSettings: EditSettingsExecute;}
    acExit: Close;
  end;
end;

begin
  FontApp := nil;
end.