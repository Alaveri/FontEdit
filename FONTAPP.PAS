{$I COMPILER.INC}
unit FontApp;

interface

uses
  AplObj,
  AplTypes,
  AplConst,
  Actions,
  Graphics,
  GraphIni,
  Veridian,
  Controls,
  Menus,
  NewDlg,
  SaveConf,
  Views,
  FontType,
  FontWind,
  FontCons;

const
  { File Actions }
  acNew = 1000;
  acOpen = 1001;
  acSave = 1002;
  acSaveAs = 1003;
  acSaveAll = 1004;
  acClose = 1005;
  acCloseAll = 1006;
  acExit = 1999;

  { Edit Actions }
  acUndo = 2000;
  acRedo = 2001;
  acCut = 2002;
  acCopy = 2003;
  acPaste = 2004;
  acDelete = 2005;

  { Font Actions }
  acFontProperties = 3001;

  { Help Actions }
  acAbout = 4000;

type
  PFontApplication = ^TFontApplication;

  TFontApplication = object(TVeridianApp)
  private
  public
    AppSettings: TFontAppSettings;
    destructor Free; virtual;
    function CreateFontWindow(AFont: PFont): PFontWindow;
    function SaveFontAs(AWindow: PFontWindow): boolean;
    function SaveFont(AWindow: PFontWindow): boolean;
    function SaveAll: boolean;
    procedure Init; virtual;
    procedure InitActions; virtual;
    procedure InitControls; virtual;
    procedure InitMenus;
    procedure ActionExecute(ASender: PActionControl; AAction: PAction); virtual;
    procedure NewFont;
    procedure OpenFont;
    procedure CloseWindow;
    procedure CloseWindows;
    procedure ShowProperties;
    procedure UpdateActionControl(AControl: PActionControl); virtual;
  end;

var
  FontApplication: PFontApplication;

implementation

uses
  Dialogs,
  Drawing,
  AplUtils,
  AplStr,
  Streams,
  Strings,
  KeyDrv;

procedure ApplicationError(var ASender; ACode: word); far;
begin
  with FontApplication^ do begin
  end;
end;

procedure TFontApplication.Init;
begin
  FontApplication := @self;
  inherited Init;
  AppSettings.Create;
  AppSettings.LoadFromFile(SettingsFilename);
  AppSettings.ClearException;
  OnError := @ApplicationError;
end;

destructor TFontApplication.Free;
begin
  AppSettings.Free;
  inherited Free;
end;

function TFontApplication.CreateFontWindow(AFont: PFont): PFontWindow;
var
  window: PFontWindow;
  title: string;
begin
  title := AFont^.GetId;
  CreateFontWindow := nil;
  window := New(PFontWindow, Create('FontWindow' + title, title, AFont));
  if not Assigned(window) then begin
    Error(self, ecNotEnoughMemory);
    exit;
  end;
  CreateFontWindow := window;
end;

procedure TFontApplication.ShowProperties;
var
  dialog: TNewFontDialog;
  properties: PFontProperties;
  result: TModalResult;
  font: PFont;
  window: PFontWindow;
  rect: TRect;
begin
  if not (Assigned(ActiveWindow) and ActiveWindow^.IsWindowType('FontWindow')) then
    exit;
  properties := New(PFontProperties, Create);
  window := PFontWindow(ActiveWindow);
  properties^.AssignFromFont(window^.CurrentFont);
  dialog.Create('FontPropsDialog', 'Font Properties', [mbOk, mbCancel]);
  result := dialog.Execute(properties);
  if result = mrOk then begin
    window^.Changed := true;
    TString.Assign(window^.CurrentFont^.Id, properties^.Id);
    window^.SetTitle(window^.WindowTitle);
    TString.Assign(window^.TaskButton^.Caption, properties^.Id);
    window^.CurrentFont^.Spacing := properties^.Spacing;
    TaskBar^.Layout;
    window^.TaskButton^.DrawDoubleBuffered;
    window^.DrawDoubleBuffered;
  end;
  dialog.Free;
  FreeAndNil(properties);
end;

procedure TFontApplication.NewFont;
var
  dialog: TNewFontDialog;
  properties: PFontProperties;
  result: TModalResult;
  font: PFont;
  window: PFontWindow;
begin
  properties := nil;
  dialog.Create('NewFontDialog', 'New Font', [mbOk, mbCancel]);
  result := dialog.Execute(properties);
  if result = mrOk then begin
    font := properties^.CreateFont;
    window := CreateFontWindow(font);
    if not Assigned(window) then
      Error(self, ecNotEnoughMemory)
    else
      window^.Changed := true;
    window^.Activate;
    window^.Show;
  end;
  dialog.Free;
  FreeAndNil(properties);
end;

procedure TFontApplication.OpenFont;
var
  dialog: TFileDialog;
  result: TModalResult;
  font: PFont;
  window: PFontWindow;
begin
  dialog.Create('OpenFontDialog', 'Open Font');
  with dialog do begin
    SetInitialPath(TString.GetString(AppSettings.LastOpenDir) + '*.fnt');
    FileOptions := [foFileMustExist];
    DefaultFilter := dialog.AddFilter('APL Font Files', '*.fnt');
    result := ShowDialog;
  end;
  if result = mrOk then begin
    font := FontManager.CreateFromFile(dialog.GetFilename);
    if not Assigned(font) then
      Error(self, ecNotEnoughMemory)
    else if CheckReRaise(@FontManager) then begin
      FreeAndNil(font);
      Error(self, Exception^.Code);
    end
    else begin
      TString.AssignString(AppSettings.LastOpenDir, ExtractDirectory(dialog.GetFilename));
      AppSettings.SaveToFile(SettingsFilename);
      window := CreateFontWindow(font);
      TString.Assign(window^.Filename, dialog.Filename);
      window^.SetTitle(window^.WindowTitle);
      window^.Activate;
      window^.Show;
    end;
  end;
  dialog.Free;
end;

function TFontApplication.SaveFontAs(AWindow: PFontWindow): boolean;
var
  dialog: TFileDialog;
  result: TModalResult;
begin
  SaveFontAs := false;
  if not Assigned(AWindow) then
    AWindow := PFontWindow(ActiveWindow);
  dialog.Create('SaveFontDialog', 'Save Font "' + AWindow^.CurrentFont^.GetId + '"');
  with dialog do begin
    SetInitialPath(TString.GetString(AppSettings.LastSaveDir) + '*.fnt');
    FileOptions := [foOverwritePrompt];
    DefaultFilter := dialog.AddFilter('APL Font Files', '*.fnt');
    result := ShowDialog;
  end;
  if result = mrOk then begin
    AWindow^.CurrentFont^.SaveToFile(dialog.GetFilename);
    SaveFontAs := true;
    if CheckReraise(AWindow) then begin
      Error(self, Exception^.Code);
      ClearException;
    end
    else begin
      TString.AssignString(AppSettings.LastSaveDir, ExtractDirectory(dialog.GetFilename));
      AppSettings.SaveToFile(SettingsFilename);
      TString.Assign(AWindow^.Filename, dialog.Filename);
      AWindow^.Changed := false;
      AWindow^.UpdateTitle;
    end;
  end;
  dialog.Free;
end;

function TFontApplication.SaveFont(AWindow: PFontWindow): boolean;
begin
  SaveFont := false;
  if not Assigned(AWindow) then
    AWindow := PFontWindow(ActiveWindow);
  if not Assigned(AWindow^.Filename) then
    SaveFont := SaveFontAs(AWindow)
  else begin
    AWindow^.CurrentFont^.SaveToFile(AWindow^.GetFilename);
    AWindow^.SetTitle(AWindow^.WindowTitle);
    SaveFont := true;
    AWindow^.Changed := false;
    AWindow^.UpdateTitle;
  end;
end;

procedure TFontApplication.CloseWindow;
var
  dialog: TShowMessageDialog;
  window: PFontWindow;
  result: TModalResult;
  closeOk: boolean;
begin
  if not (Assigned(ActiveWindow) and (ActiveWindow^.IsWindowType('FontWindow'))) then
    exit;
  window := PFontWindow(ActiveWindow);
  closeOk := true;
  if window^.Changed then begin
    dialog.Create('Save Changes', 'Save changes to font "' + window^.CurrentFont^.GetId + '"?',
       [mbYes, mbNo, mbCancel]);
    result := dialog.ShowDialog;
    if result = mrNo then
      closeOk := true
    else if (result = mrYes) and SaveFont(nil) then
      closeOk := true
    else
      closeOk := false;
    dialog.Free;
  end;
  if closeOk then
    window^.Close(@self);
end;

procedure TFontApplication.CloseWindows;
var
  index: integer;
  control: PControl;
  window: PFontWindow;
begin
  if not SaveAll then
    exit;
  for index := 0 to Desktop^.Controls^.Count - 1 do begin
    control := Desktop^.Controls^.GetItem(index);
    if not (control^.IsWindow and PWindow(control)^.IsWindowType('FontWindow')) then
      continue;
    window := PFontWindow(control);
    window^.Close(@self);
  end;
end;

function TFontApplication.SaveAll: boolean;
var
  index: integer;
  control: PControl;
  window: PFontWindow;
begin
  SaveAll := true;
  for index := 0 to Desktop^.Controls^.Count - 1 do begin
    control := Desktop^.Controls^.GetItem(index);
    if not (control^.IsWindow and PWindow(control)^.IsWindowType('FontWindow')) then
      continue;
    window := PFontWindow(control);
    if not SaveFont(window) then begin
      SaveAll := false;
      exit;
    end;
  end;
end;

procedure TFontApplication.InitActions;
var
  action: PAction;
begin
  inherited InitActions;
  with Desktop^.ActionList^ do begin
    Add(New(PAction, Create(acNew, '&New Font...', kyCtrlN)));
    Add(New(PAction, Create(acOpen, '&Open Font...', kyCtrlO)));
    Add(New(PAction, Create(acSave, '&Save Font', kyCtrlS)));
    Add(New(PAction, Create(acSaveAs, 'Save Font &As...', kyShiftAltS)));
    Add(New(PAction, Create(acSaveAll, 'Save A&ll', kyCtrlL)));
    Add(New(PAction, Create(acClose, '&Close Font', kyCtrlF4)));
    Add(New(PAction, Create(acCloseAll, 'Clos&e All', 0)));
    Add(New(PAction, Create(acExit, 'E&xit', kyAltX)));
    Add(New(PAction, Create(acUndo, '&Undo', kyCtrlZ)));
    Add(New(PAction, Create(acRedo, '&Redo', kyCtrlY)));
    Add(New(PAction, Create(acCut, 'Cu&t', kyCtrlX)));
    Add(New(PAction, Create(acCopy, '&Copy', kyCtrlC)));
    Add(New(PAction, Create(acPaste, '&Paste', kyCtrlV)));
    Add(New(PAction, Create(acDelete, '&Delete', kyDel)));
    Add(New(PAction, Create(acFontProperties, '&Font Properties...', 0)));
    Add(New(PAction, Create(acAbout, '&About...', 0)));
  end;
end;

procedure TFontApplication.InitMenus;
var
  menu: PMenu;
begin
  menu := MenuBar^.NewMenu('FileMenu', '&File');
  with menu^ do begin
    NewMenuItem('NewMenuItem', acNew);
    NewSeparator;
    NewMenuItem('OpenMenuItem', acOpen);
    NewSeparator;
    NewMenuItem('SaveMenuItem', acSave);
    NewMenuItem('SaveAsMenuItem', acSaveAs);
    NewMenuItem('SaveAllMenuItem', acSaveAll);
    NewSeparator;
    NewMenuItem('CloseMenuItem', acClose);
    NewMenuItem('CloseAllMenuItem', acCloseAll);
    NewSeparator;
    NewMenuItem('ExitMenuItem', acExit);
  end;

  menu := MenuBar^.NewMenu('EditMenu', '&Edit');
  with menu^ do begin
    NewMenuItem('UndoMenuItem', acUndo);
    NewMenuItem('RedoMenuItem', acRedo);
    NewSeparator;
    NewMenuItem('CutMenuItem', acCut);
    NewMenuItem('CopyMenuItem', acCopy);
    NewMenuItem('PasteMenuItem', acPaste);
    NewMenuItem('DeleteMenuItem', acDelete);
    NewSeparator;
    NewMenuItem('FontPropertiesMenuItem', acFontProperties);
  end;

  menu := MenuBar^.NewMenu('HelpMenu', '&Help');
  with menu^ do begin
    NewMenuItem('AboutMenuItem', acAbout);
  end;
end;

procedure TFontApplication.InitControls;
begin
  inherited InitControls;
  InitMenus;
end;

procedure TFontApplication.ActionExecute(ASender: PActionControl; AAction: PAction);
begin
  case AAction^.ActionId of
    acNew: NewFont;
    acOpen: OpenFont;
    acSave: SaveFont(nil);
    acSaveAs: SaveFontAs(nil);
    acSaveAll: SaveAll;
    acClose: CloseWindow;
    acCloseAll: CloseWindows;
    acExit: Close;
    acUndo: ;
    acRedo: ;
    acCut: ;
    acCopy: ;
    acPaste: ;
    acDelete: ;
    acFontProperties: ShowProperties;
    acAbout: ;
  end;
end;

procedure TFontApplication.UpdateActionControl(AControl: PActionControl);
var
  isFontWindow: boolean;
  fontWindow: PFontWindow;
  index: integer;
  control: PControl;
  anyChanged, anyWindows: boolean;
begin
  inherited UpdateActionControl(AControl);
  anyWindows := false;
  anyChanged := false;
  for index := 0 to Desktop^.Controls^.Count - 1 do begin
    control := Desktop^.Controls^.GetItem(index);
    if (not control^.IsVisible) or (not control^.IsWindow) or
      (not PWindow(control)^.IsWindowType('FontWindow')) then
      continue;
    anyWindows := true;
    fontWindow := PFontWindow(control);
    if fontWindow^.Changed then begin
      anyChanged := true;
      break;
    end;
  end;
  isFontWindow := Assigned(ActiveWindow) and ActiveWindow^.IsWindowType('FontWindow');
  if isFontWindow then
    fontWindow := PFontWindow(activeWindow);
  case AControl^.Action^.ActionId of
    acSave: AControl^.Action^.Enabled := isFontWindow and fontWindow^.Changed;
    acSaveAs: AControl^.Action^.Enabled := isFontWindow;
    acSaveAll: AControl^.Action^.Enabled := anyChanged;
    acClose: AControl^.Action^.Enabled := Assigned(ActiveWindow);
    acCloseAll: AControl^.Action^.Enabled := anyWindows;
    acUndo: ;
    acRedo: ;
    acCut: ;
    acCopy: ;
    acPaste: ;
    acDelete: ;
    acFontProperties: AControl^.Action^.Enabled := isFontWindow;
    acAbout: ;
  end;
end;

end.