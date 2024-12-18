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
  FontType,
  FontCons;

const
  { File Actions }
  acNew = 1000;
  acOpen = 1001;
  acSave = 1002;
  acSaveAs = 1003;
  acClose = 1005;
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
    procedure Init; virtual;
    procedure InitActions; virtual;
    procedure InitControls; virtual;
    procedure InitMenus;
    procedure ActionExecute(ASender: PActionControl; AAction: PAction); virtual;
    procedure NewFont;
    procedure OpenFont;
    procedure UpdateActionControl(AControl: PActionControl); virtual;
    procedure CreateFontWindow(AFont: PFont);
  end;

var
  FontApplication: PFontApplication;

implementation

uses
  Dialogs,
  FontWind,
  AplUtils,
  AplStr,
  Strings,
  KeyDrv;

procedure TFontApplication.Init;
begin
  FontApplication := @self;
  inherited Init;
  AppSettings.Create;
  AppSettings.LoadFromFile(SettingsFilename);
  AppSettings.ClearException;
end;

destructor TFontApplication.Free;
begin
  AppSettings.Free;
  inherited Free;
end;

procedure TFontApplication.CreateFontWindow(AFont: PFont);
var
  window: PFontWindow;
  title: string;
begin
  title := AFont^.GetId;
  window := New(PFontWindow, Create('FontWindow' + title, title, AFont));
  window^.Activate;
  window^.Show;
end;

procedure TFontApplication.NewFont;
var
  dialog: TNewFontDialog;
  properties: PFontProperties;
  result: TModalResult;
  font: PFont;
begin
  properties := nil;
  dialog.Create('NewFontDialog', 'New Font', [mbOk, mbCancel]);
  result := dialog.Execute(properties);
  if result = mrOk then begin
    font := properties^.CreateFont;
    CreateFontWindow(font);
  end;
  dialog.Free;
  FreeAndNil(properties);
end;

procedure TFontApplication.OpenFont;
var
  dialog: TFileDialog;
  result: TModalResult;
  font: PFont;
begin
  TString.Free(AppSettings.LastOpenDir);
  dialog.Create('OpenFontDialog', 'Open Font');
  with dialog do begin
    SetInitialPath(TString.GetString(AppSettings.LastOpenDir) + '*.fnt');
    FileOptions := [doFileMustExist];
    DefaultFilter := dialog.AddFilter('APL Font Files', '*.fnt');
    result := ShowDialog;
  end;
  if result = mrOk then begin
    font := FontManager.CreateFromFile(dialog.GetFilename);
    if CheckReRaise(@FontManager) then
      FreeAndNil(font)
    else if not NilPtr(font, ecNotEnoughMemory) then begin
      TString.AssignString(AppSettings.LastOpenDir, ExtractDirectory(dialog.GetFilename));
      AppSettings.SaveToFile(SettingsFilename);
      CreateFontWindow(font);
    end;
  end;
  dialog.Free;
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
    Add(New(PAction, Create(acSaveAs, 'Save Font &As...', 0)));
    Add(New(PAction, Create(acClose, '&Close File', kyCtrlF4)));
    Add(New(PAction, Create(acExit, 'E&xit', kyAltX)));
    Add(New(PAction, Create(acUndo, '&Undo', kyCtrlZ)));
    Add(New(PAction, Create(acRedo, '&Redo', kyCtrlY)));
    Add(New(PAction, Create(acCut, 'Cu&t', kyCtrlX)));
    Add(New(PAction, Create(acCopy, '&Copy', kyCtrlC)));
    Add(New(PAction, Create(acPaste, '&Paste', kyCtrlV)));
    Add(New(PAction, Create(acDelete, '&Delete', kyDel)));
    Add(New(PAction, Create(acFontProperties, 'Font &Properties...', 0)));
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
    NewSeparator;
    NewMenuItem('CloseMenuItem', acClose);
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
    acSave: ;
    acSaveAs: ;
    acClose: ;
    acExit: Close;
    acUndo: ;
    acRedo: ;
    acCut: ;
    acCopy: ;
    acPaste: ;
    acDelete: ;
    acFontProperties: ;
    acAbout: ;
  end;
end;

procedure TFontApplication.UpdateActionControl(AControl: PActionControl);
begin
  inherited UpdateActionControl(AControl);
end;

end.