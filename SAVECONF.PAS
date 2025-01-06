{$I COMPILER.INC}
unit SaveConf;

interface

uses
  AplObj,
  AplConst,
  AplTypes,
  Controls,
  Lists,
  Veridian,
  ListView,
  Views,
  VeriType,
  Drawing,
  Dialogs;

type
  PSaveConfirmDialog = ^TSaveConfirmDialog;

  TSaveConfirmDialog = object(TDialog)
  private
  public
    FileListView: PCheckListView;
    Windows: PControlList;
    constructor Create(var AWindows: PControlList);
    function Execute: TModalResult; virtual;
    procedure Init; virtual;
    procedure AfterShow; virtual;
    procedure Layout; virtual;
    destructor Free; virtual;
  end;

implementation

uses
  FontWind;

constructor TSaveConfirmDialog.Create(var AWindows: PControlList);
var
  index: integer;
begin
  Windows := AWindows;
  inherited Create('', 'Save Changes', [mbYes, mbNo, mbCancel]);
end;

function TSaveConfirmDialog.Execute: TModalResult;
begin
  Execute := ShowDialog;
end;

procedure TSaveConfirmDialog.Init;
var
  index: integer;
  window: PFontWindow;
  item: PCheckListItem;
begin
  inherited Init;
  VeridianApp^.DisableDrawing;
  FileListView := New(PCheckListView, CreateParent('FileListBox', @self));
  FileListView^.Padding.CreateValue(3);
  FileListView^.ScrollType := scAsNeeded;
  ButtonAlign := haCenter;
  for index := 0 to Windows^.Count - 1 do begin
    window := PFontWindow(Windows^.GetItem(index));
    item := FileListView^.AddItemValue(window^.CurrentFont^.GetId, window);
    item^.SetChecked(true);
  end;
  FileListView^.SetSelectedIndex(0);
  VeridianApp^.EnableDrawing;
  Include(WindowOptions, woResizeable);
  Width := 250;
  Height := 150;
end;

procedure TSaveConfirmDialog.AfterShow;
begin
  inherited AfterShow;
  FileListView^.TabOrder := 0;
  SetButtonTabOrders(1);
end;

procedure TSaveConfirmDialog.Layout;
var
  rect, buttonRect: TRect;
begin
  inherited Layout;
  GetContentRect(rect);
  GetButtonArea(buttonRect);
  FileListView^.Position := rpParentContent;
  FileListView^.SetBounds(
    0,
    0,
    rect.Width,
    rect.Height - buttonRect.Height - Padding.Bottom
  );
end;

destructor TSaveConfirmDialog.Free;
begin
  inherited Free;
end;

end.