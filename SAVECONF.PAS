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
  VeriType,
  Drawing,
  Dialogs;

type
  PSaveConfirmDialog = ^TSaveConfirmDialog;

  TSaveConfirmDialog = object(TDialog)
  private
  public
    FileListView: PCheckListView;
    FileList: TStringList;
    IndexList: PLongIntList;
    constructor Create(const AId, ATitle: string; AFileList: array of string);
    function Execute(AIndexList: PLongIntList): TModalResult; virtual;
    procedure Init; virtual;
    procedure LayoutRect(ARect: TRect); virtual;
    destructor Free; virtual;
  end;

implementation

constructor TSaveConfirmDialog.Create(const AId, ATitle: string; AFileList: array of string);
var
  index: integer;
begin
  FileList.Create;
  for index := Low(AFileList) to High(AFileList) do
    FileList.AddString(AFileList[index]);
  inherited Create(AId, ATitle, [mbYes, mbNo, mbCancel]);
end;

function TSaveConfirmDialog.Execute(AIndexList: PLongIntList): TModalResult;
var
  index: integer;
  result: TModalResult;
begin
  VeridianApp^.PushState;
  VeridianApp^.State.DrawEnabled := False;
  IndexList := AIndexList;
  IndexList^.Clear;
  VeridianApp^.PopState;
  result := ShowDialog;
  if result = mrYes then begin
    for index := 0 to FileListView^.Items^.Count - 1 do begin
      if FileListView^.Checked(index) then
        IndexList^.Add(index);
    end;
  end;
end;

procedure TSaveConfirmDialog.Init;
var
  index: integer;
begin
  inherited Init;
  FileListView := New(PCheckListView, CreateParent('FileListBox', @self));
  FileListView^.Padding.CreateValue(3);
  for index := 0 to FileList.Count - 1 do
    FileListView^.AddItemTag(FileList.GetString(index), index);
end;

procedure TSaveConfirmDialog.LayoutRect(ARect: TRect);
var
  buttonRect: TRect;
begin
  inherited LayoutRect(ARect);
  Width := 200;
  Height := 400;
  GetContentRect(ARect);
  GetButtonArea(buttonRect);
  FileListView^.Position := rpParentContent;
  FileListView^.SetBounds(
    0,
    0,
    ARect.Width,
    ARect.Height - buttonRect.Height - Padding.Bottom
  );
end;

destructor TSaveConfirmDialog.Free;
begin
  FileList.Free;
  inherited Free;
end;

end.