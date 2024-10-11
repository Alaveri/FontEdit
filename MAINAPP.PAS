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
    Editor: PFontWindow;
    CurrentFont: PFont;
    FontGrid: PFontGrid;
    CurrentCharLabel: PLabel;
    CharAsciiLabel: PLabel;
    function HandleActionExecute(ASender: PObject; AAction: PAction): boolean; virtual;
    function CreateFont(AMaxWidth, AMaxHeight: byte; AFontType: TFontFormat): PFont;
    procedure UpdateActionControl(AControl: PActionControl); virtual;
    procedure InitControls; virtual;
    procedure InitActions; virtual;
    procedure Init; virtual;
    procedure NewExecute;
    procedure NewFont(AMaxWidth, AMaxHeight: byte; AFontType: TFontFormat);
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
  CurrentCharLabel := nil;
  CharAsciiLabel := nil;
  Editor := nil;
  FontGrid := nil;
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

procedure FontGridSelectChar(ASender: PObject; var AEvent: TFontGridEvent);
var
  ascii: integer;
begin
  FontApp^.CurrentCharLabel^.Hide;
  FontApp^.CurrentCharLabel^.SetText('Selected Char: ' + AEvent.Character);
  FontApp^.CurrentCharLabel^.Show;
  FontApp^.CharAsciiLabel^.Hide;
  FontApp^.CharAsciiLabel^.SetText('ASCII: '
    + IntToStr(Ord(AEvent.Character)) + #32'(' +
    + IntToHex(Ord(AEvent.Character)) + ')');
  FontApp^.CharAsciiLabel^.Show;
end;

procedure TFontApp.NewFont(AMaxWidth, AMaxHeight: byte; AFontType: TFontFormat);
begin
  CurrentFont := CreateFont(AMaxWidth, AMaxHeight, AFontType);
  Editor := New(PFontWindow, Create('FontEditWindow', 'UNTITLED.FNT', Desktop));
  Editor^.SetupControls;

  FreeAndNil(CurrentFont);
  CurrentFont := New(PProportionalFont, CreateLoadFile('System.fnt'));

  FontGrid := New(PFontGrid, Create(CurrentFont, 'FontGrid', Editor));
  FontGrid^.CharsPerRow := 16;
  FontGrid^.Width := (CurrentFont^.MaxWidth + 1) * FontGrid^.CharsPerRow + 2 * FontGrid^.BorderWidth;
  FontGrid^.Height := (CurrentFont^.Height + 1) * 16 + 2 * FontGrid^.BorderWidth;
  FontGrid^.X := Desktop^.Width - FontGrid^.Width - 10;
  FontGrid^.Y := Editor^.Titlebar^.Height + 12;
  FontGrid^.OnSelectChar := @FontGridSelectChar;
  FontGrid^.SEtupControls;

  CurrentCharLabel := New(PLabel, CreateText('CurrentCharLabel', 'Selected Char: ', Editor));
  CurrentCharLabel^.X := FontGrid^.X;
  CurrentCharLabel^.Y := FontGrid^.Y + FontGrid^.Height + 4;

  CharAsciiLabel := New(PLabel, CreateText('CharAsciiLabel', 'ASCII: ', Editor));
  CharAsciiLabel^.X := FontGrid^.X;
  CharAsciiLabel^.Y := CurrentCharLabel^.Y + CurrentCharLabel^.Height + 2;

  Editor^.Show;
  Editor^.Activate;
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