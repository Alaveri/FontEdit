{$I COMPILER.INC}
unit FontInit;

interface

uses
  Actions,
  Veridian;

const
  { File Actions }
  acNew = 1000;
  acOpen = 1001;
  acSave = 1002;
  acSaveAs = 1003;
  acClose = 1005;
  acExit = 1999;


procedure DoInitMenus(AApplication: PVeridianApp); far;
procedure DoInitActions(AActionList: PActionList); far;

implementation

uses
  MainApp,
  KeyDrv,
  Desk;

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
 end;
end;

begin
end.