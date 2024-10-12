{$I COMPILER.INC}
unit FontInit;

interface

uses
  Actions,
  GraphDrv,
  AplObj,
  Veridian;

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

procedure DoInitMenus(AApplication: PVeridianApp); far;
procedure DoInitActions(AActionList: PActionList); far;
procedure NewFont(AMaxWidth, AMaxHeight: byte; AFontType: TFontFormat); far;

implementation

uses
  MainApp,
  FontWind,
  Common,
  Controls,
  FontGrid,
  KeyDrv,
  Desk;

procedure FontGridSelectChar(ASender: PObject; var AEvent: TFontGridEvent); far;
var
  ascii: integer;
  window: PFontWindow;
begin
  window := FontApp^.EditorWindow;
  window^.CurrentCharLabel^.SetText('Selected Char: ' + AEvent.Character);
  window^.CharAsciiLabel^.SetText('ASCII: '
    + IntToStr(Ord(AEvent.Character)) + #32'(' +
    + IntToHex(Ord(AEvent.Character)) + ')');
  window^.FontEditor^.SetCurrentChar(AEvent.Character);
end;

procedure NewFont(AMaxWidth, AMaxHeight: byte; AFontType: TFontFormat);
begin
  FontApp^.EditorWindow := New(PFontWindow, Create('FontEditWindow', 'UNTITLED.FNT', Desktop));
  with FontApp^, EditorWindow^ do begin
    CurrentFont := CreateFont(AMaxWidth, AMaxHeight, AFontType);
    SetupControls;

    FreeAndNil(CurrentFont);
    CurrentFont := New(PProportionalFont, CreateLoadFile('System.fnt'));



    FontGrid := New(PFontGrid, Create(CurrentFont, 'FontGrid', EditorWindow));
    FontGrid^.CharsPerRow := 16;
    FontGrid^.Width := (CurrentFont^.MaxWidth + 1) * FontGrid^.CharsPerRow + 2 * FontGrid^.BorderWidth;
    FontGrid^.Height := (CurrentFont^.Height + 1) * 16 + 2 * FontGrid^.BorderWidth;
    FontGrid^.X := 10;
    FontGrid^.Y := EditorWindow^.Titlebar^.Height + 10;
    FontGrid^.OnSelectChar := @FontGridSelectChar;
    FontGrid^.SetupControls;

    CurrentCharLabel := New(PLabel, CreateText('CurrentCharLabel', 'Selected Char: ', EditorWindow));
    CurrentCharLabel^.X := FontGrid^.X;
    CurrentCharLabel^.Y := FontGrid^.Y + FontGrid^.Height + 4;

    CharAsciiLabel := New(PLabel, CreateText('CharAsciiLabel', 'ASCII: ', EditorWindow));
    CharAsciiLabel^.X := FontGrid^.X;
    CharAsciiLabel^.Y := CurrentCharLabel^.Y + CurrentCharLabel^.Height + 2;

    FontEditor := New(PFontEditor, Create(CurrentFont, 'FontEditor', EditorWindow));
    FontEditor^.X := FontGrid^.X + FontGrid^.Width + 10;
    FontEditor^.Y := EditorWindow^.Titlebar^.Height + 10;

    EditorWindow^.Show;
    EditorWindow^.Activate;
  end;
end;

procedure DoInitActions(AActionList: PActionList);
var
  action: PAction;
begin
  with AActionList^ do begin
    action := New(PAction, Create(acNew, '&New Font...', kyCtrlN));
    action^.SetHelpText('Create a new font file');
    Add(action);

    action := New(PAction, Create(acOpen, '&Open Font...', kyAltO));
    action^.SetHelpText('Open an existing font file');
    Add(action);

    action := New(PAction, Create(acSave, '&Save Font', kyAltS));
    action^.SetHelpText('Save the current font file');
    Add(action);

    action := New(PAction, Create(acSaveAs, 'Save Font &As...', 0));
    action^.SetHelpText('Save the current font file with a new name');
    Add(action);

    action := New(PAction, Create(acClose, '&Close', kyCtrlF4));
    action^.SetHelpText('Close the current font file');
    Add(action);

    action := New(PAction, Create(acExit, 'E&xit', kyAltX));
    action^.SetHelpText('Exit this program');
    Add(action);

    action := New(PAction, Create(acUndo, '&Undo', kyCtrlZ));
    action^.SetHelpText('Undo the last action');
    Add(action);

    action := New(PAction, Create(acRedo, '&Redo', kyCtrlY));
    action^.SetHelpText('Redo the last undone action');
    Add(action);

    action := New(PAction, Create(acCut, 'Cu&t', kyCtrlX));
    action^.SetHelpText('Copy and cut the current selection');
    Add(action);

    action := New(PAction, Create(acCopy, '&Copy', kyCtrlC));
    action^.SetHelpText('Copy the current selection');
    Add(action);

    action := New(PAction, Create(acPaste, '&Paste', kyCtrlV));
    action^.SetHelpText('Paste item on the clipboard');
    Add(action);

    action := New(PAction, Create(acDelete, '&Delete', kyDel));
    action^.SetHelpText('Delete the current selection');
    Add(action);

    action := New(PAction, Create(acFontProperties, 'Font &Properties...', 0));
    action^.SetHelpText('View or edit font properties');
    Add(action);

    action := New(PAction, Create(acAbout, '&About...', 0));
    action^.SetHelpText('About this program');
    Add(action);

  end;
end;

procedure DoInitMenus(AApplication: PVeridianApp);
var
  menu: PMenu;
begin
  with PFontApp(AApplication)^ do begin
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
    end;

    menu := MenuBar^.NewMenu('FontMenu', 'Fon&t');
    with menu^ do begin
      NewMenuItem('FontPropertiesMenuItem', acFontProperties);
    end;

    menu := MenuBar^.NewMenu('HelpMenu', '&Help');
    with menu^ do begin
      NewMenuItem('AboutMenuItem', acAbout);
    end;
  end;
end;

begin
end.