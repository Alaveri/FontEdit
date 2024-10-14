{$I COMPILER.INC}
unit FontInit;

interface

uses
  Actions,
  GraphDrv,
  AplObj,
  Controls,
  Dialogs,
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

  AppVersion = '0.5.0';

type
  PAboutDialog = ^TAboutDialog;

  TAboutDialog = object(TDialog)
  private
  public
    TitleLabel: PLabel;
    VersionLabel: PLabel;
    FreeConLabel: PLabel;
    FreeXmsLabel: PLabel;
    Separator: PHorzSeparator;
    constructor Create;
    procedure Init; virtual;
    procedure SetupControls; virtual;
  end;

procedure DoInitMenus(AApplication: PVeridianApp); far;
procedure DoInitActions(AActionList: PActionList); far;
procedure NewFont(AMaxWidth, AMaxHeight: byte; AFontType: TFontFormat); far;

implementation

uses
  MainApp,
  FontWind,
  Common,
  FontGrid,
  MemDrv,
  Drawing,
  KeyDrv,
  StrUtils,
  GraphApp,
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

procedure DrawSampleChar(ALabel: PLabel; AFont: PFont; AChar: char); far;
var
  x: integer;
  currentChar: PChar;
  index, len: integer;
  ptr: PChar;
  rect: TRect;
begin
  index := TString.IndexOf(ALabel^.Text, AChar);
  if index <> -1 then begin
    x := 0;
    ptr := ALabel^.Text;
    if not Assigned(ptr) then
      exit;
    ALabel^.StartDrawing;
    len := 1;
    while ptr^ <> #0 do begin
      if ptr^ = AChar then begin
        x := AFont^.TextWidthAny(ALabel^.Text, len - 1);
        ALabel^.GetScreenBounds(rect);
        rect.Width := AFont^.TextWidth(AChar);
        rect.Translate(x, 1);
        Graph8^.SetBackColor(ALabel^.BackColor);
        Graph8^.SetForeColor(ALabel^.ForeColor);
        Graph8^.FillRect(rect);
        Graph8^.State.Font := AFont;
        Graph8^.DrawText(rect.X, rect.Y, AChar);
      end;
      Inc(ptr);
      Inc(len);
    end;

    ALabel^.EndDrawing;
  end;
end;

procedure FontEditorCharacterChanged(ASender: PObject; var AEvent: TFontGridEvent); far;
var
  window: PFontWindow;
  grid: PFontGrid;
begin
  window := FontApp^.EditorWindow;
  grid := window^.FontGrid;
  grid^.DrawChar(AEvent.Character);
  DrawSampleChar(window^.SampleLabel1, grid^.CurrentFont, AEvent.Character);
  DrawSampleChar(window^.SampleLabel2, grid^.CurrentFont, AEvent.Character);
  DrawSampleChar(window^.SampleLabel3, grid^.CurrentFont, AEvent.Character);
end;

procedure NewFont(AMaxWidth, AMaxHeight: byte; AFontType: TFontFormat);
var
  yPos: integer;
begin
  FontApp^.EditorWindow := New(PFontWindow, Create('FontEditWindow', 'UNTITLED.FNT', Desktop));
  with FontApp^, EditorWindow^ do begin
    {CurrentFont := CreateFont(AMaxWidth, AMaxHeight, AFontType);}
    SetupControls;

    FreeAndNil(CurrentFont);
    CurrentFont := New(PProportionalFont, CreateLoadFile('System.fnt'));



    FontGrid := New(PFontGrid, Create(CurrentFont, 'FontGrid', EditorWindow));
    FontGrid^.CharsPerRow := 32;
    FontGrid^.Width := (CurrentFont^.MaxWidth + 1) * FontGrid^.CharsPerRow + 2 * FontGrid^.BorderWidth;
    FontGrid^.Height := (CurrentFont^.Height + 1) * (256 div FontGrid^.CharsPerRow) + 2 * FontGrid^.BorderWidth;
    FontGrid^.X := 10;
    FontGrid^.Y := Desktop^.MenuBar^.Height + 10;
    FontGrid^.OnSelectChar := @FontGridSelectChar;
    FontGrid^.SetupControls;

    CurrentCharLabel := New(PLabel, CreateText('CurrentCharLabel', 'Selected Char: ', EditorWindow));
    CurrentCharLabel^.X := FontGrid^.X;
    CurrentCharLabel^.Y := FontGrid^.Y + FontGrid^.Height + 4;

    CharAsciiLabel := New(PLabel, CreateText('CharAsciiLabel', 'ASCII: ', EditorWindow));
    CharAsciiLabel^.X := FontGrid^.X;
    CharAsciiLabel^.Y := CurrentCharLabel^.Y + CurrentCharLabel^.Height + 2;

    FontEditor := New(PFontEditor, Create(CurrentFont, 'FontEditor', EditorWindow));
    FontEditor^.SetupControls;
    FontEditor^.X := FontGrid^.X + FontGrid^.Width + 10;
    FontEditor^.Y := Desktop^.MenuBar^.Height + 10;
    FontEditor^.OnCharacterChanged := @FontEditorCharacterChanged;

    yPos := CharAsciiLabel^.Y + CharAsciiLabel^.Height + 10;

    SampleLabel1 := New(PLabel, CreateText('SampleLabel', 'the quick brown fox jumps over the lazy dog.', EditorWindow));
    SampleLabel1^.X := FontGrid^.X;
    SampleLabel1^.Y := yPos;
    SampleLabel1^.Font := CurrentFont;
    Inc(yPos, SampleLabel1^.Height + 4);

    SampleLabel2 := New(PLabel, CreateText('SampleLabel', 'THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG.', EditorWindow));
    SampleLabel2^.X := FontGrid^.X;
    SampleLabel2^.Y := yPos;
    SampleLabel2^.Font := CurrentFont;
    Inc(yPos, SampleLabel2^.Height + 4);

    SampleLabel3 := New(PLabel, CreateText('SampleLabel', '1234567890!@#$%^&*()-_=+;:''",<.>/?`~[{[]]}\|', EditorWindow));
    SampleLabel3^.X := FontGrid^.X;
    SampleLabel3^.Y := yPos;
    SampleLabel3^.Font := CurrentFont;

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
      NewSeparator;
      NewMenuItem('FontPropertiesMenuItem', acFontProperties);
    end;

    menu := MenuBar^.NewMenu('HelpMenu', '&Help');
    with menu^ do begin
      NewMenuItem('AboutMenuItem', acAbout);
    end;
  end;
end;

constructor TAboutDialog.Create;
begin
  inherited Create('AboutDialog', [mbOk]);
end;

procedure TAboutDialog.SetupControls;
var
  currentY: integer;
  currentX: integer;
  labelHeight: integer;
  rect: TRect;
begin
  inherited SetupControls;
  X := CenterX;
  Y := CenterY;
  labelHeight := Font^.Height;
  GetContentBounds(rect);

  currentX := rect.X;
  currentY := rect.Y + labelHeight;

  TitleLabel^.SetBounds(currentX, currentY, rect.Width - 1, Font^.Height);
  Inc(currentY, labelHeight);

  VersionLabel^.SetBounds(currentX, currentY, rect.Width - 1, Font^.Height);
  Inc(currentY, labelHeight * 2);

  Separator^.SetBounds(currentX, currentY, rect.Width, 1);
  Inc(currentY, labelHeight);

  FreeConLabel^.SetBounds(currentX, currentY, rect.Width - 1, Font^.Height);
  Inc(currentY, labelHeight);

  FreeXmsLabel^.SetBounds(currentX, currentY, rect.Width - 1, Font^.Height);
end;

procedure TAboutDialog.Init;
begin
  inherited Init;
  Width := VeridianApp^.Scale(20);
  Height := VeridianApp^.Scale(12);
  SetTitle('About');
  ButtonAlign := haCenter;

  TitleLabel := New(PLabel, CreateParent('TitleLabel', @self));
  with TitleLabel^ do begin
    Font := VeridianApp^.SystemFont;
    Autosize := false;
    TextAlign := haCenter;
    SetText('APL Font Editor');
  end;

  VersionLabel := New(PLabel, CreateParent('VersionLabel', @self));
  with VersionLabel^ do begin
    Font := VeridianApp^.SystemFont;
    Autosize := false;
    TextAlign := haCenter;
    SetText('Version ' + AppVersion);
  end;

  Separator := New(PHorzSeparator, CreateParent('Separator', @self));

  FreeConLabel := New(PLabel, CreateParent('FreeConLabel', @self));
  with FreeConLabel^ do begin
    Font := VeridianApp^.Fonts^.GetItemById('seattle');
    Margin := 8;
    Autosize := false;
    TextAlign := haLeft;
    SetText('Free Memory: ' + FormatLong(MemAvail) + ' bytes');
  end;

  FreeXmsLabel := New(PLabel, CreateParent('FreeXmsLabel', @self));
  with FreeXmsLabel^ do begin
    Font := VeridianApp^.Fonts^.GetItemById('seattle');
    Margin := 8;
    Autosize := false;
    TextAlign := haLeft;
    SetText('Free XMS Memory: ' + FormatLong(Memory.XmsMaxAvail) + ' bytes');
  end;
end;

begin
end.