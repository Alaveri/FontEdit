{$I COMPILER.INC}
unit FontWind;

interface

uses
  AplObj,
  AplTypes,
  AplConst,
  Controls,
  Drawing,
  Graphics,
  FontGrid,
  FontType,
  Views;

type
  PFontWindow = ^TFontWindow;

  TFontWindow = object(TWindow)
  private
  public
    Grid: PFontGrid;
    CurrentFont: PFont;
    CurrentCharLabel: PLabel;
    CharAsciiLabel: PLabel;
    FontEditor: PFontEditor;
    SampleLabel1: PLabel;
    SampleLabel2: PLabel;
    SampleLabel3: PLabel;
    Changed: boolean;
    Filename: PChar;
    constructor Create(const AId, ATitle: string; AFont: PFont);
    destructor Free; virtual;
    function WindowType: string; virtual;
    function GetFilename: string;
    function WindowTitle: string;
    procedure SetFilename(const AValue: string);
    procedure Init; virtual;
    procedure Initialized; virtual;
    procedure LayoutRect(ARect: TRect); virtual;
    procedure DrawSampleChar(ALabel: PLabel; AFont: PFont; AChar: char);
    procedure UpdateTitle;
  end;

implementation

uses
  AplUtils,
  AplStr,
  Veridian,
  FontApp;

procedure FontGridSelectChar(var AEvent: TFontGridEvent); far;
var
  ascii: integer;
  window: PFontWindow;
  textWidth: integer;
  rect: TRect;
begin
  window := PFontWindow(PFontGrid(AEvent.Sender)^.Parent);
  with window^ do begin
    CurrentCharLabel^.SetCaption('Selected Char: ' + AEvent.Character);
    CharAsciiLabel^.SetCaption('ASCII: '
      + IntToStr(Ord(AEvent.Character)) + #32'(' +
      + IntToHex(Ord(AEvent.Character)) + ')');
    FontEditor^.SetCurrentChar(AEvent.Character);
  end;
end;

procedure TFontWindow.DrawSampleChar(ALabel: PLabel; AFont: PFont; AChar: char);
var
  cx: integer;
  currentChar: PChar;
  index, len: integer;
  ptr: PChar;
  rect: TRect;
begin
  index := TString.IndexOf(ALabel^.Caption, AChar);
  if index <> -1 then begin
    cx := 0;
    ptr := ALabel^.Caption;
    if not Assigned(ptr) then
      exit;
    ALabel^.BeginDrawing;
    len := 1;
    while ptr^ <> #0 do begin
      if ptr^ = AChar then begin
        cx := AFont^.TextWidthAny(ALabel^.Caption, len - 1);
        ALabel^.GetDrawRect(rect);
        rect.Width := AFont^.TextWidth(AChar);
        rect.Translate(cx, 0);
        Graph^.SetBackColor(ALabel^.BackColor);
        Graph^.SetForeColor(ALabel^.ForeColor);
        Graph^.FillRect(rect);
        Graph^.State^.Font := AFont;
        Graph^.DrawText(rect.X, rect.Y, AChar);
      end;
      Inc(ptr);
      Inc(len);
    end;
    ALabel^.EndDrawing;
  end;
end;

procedure FontEditorCharacterChanged(var AEvent: TFontEditorChangedEvent); far;
var
  grid: PFontGrid;
  window: PFontWindow;
  rect: TRect;

  function LabelContainsChar(ALabel: PLabel; AChar: char): boolean;
  var
    index: integer;
  begin
    index := TString.IndexOf(ALabel^.Caption, AChar);
    LabelContainsChar := index > -1;
  end;
begin
  window := PFontWindow(PFontGrid(AEvent.Sender)^.Parent);
  if not window^.Changed then begin
    window^.Changed := true;
    window^.UpdateTitle;
  end;
  with window^ do begin
    Grid^.GetDrawRect(rect);
    Grid^.DrawChar(rect, AEvent.Character, true);
    if AEvent.NewCharWidth = AEvent.OldCharWidth then begin
      DrawSampleChar(SampleLabel1, grid^.CurrentFont, AEvent.Character);
      DrawSampleChar(SampleLabel2, grid^.CurrentFont, AEvent.Character);
      DrawSampleChar(SampleLabel3, grid^.CurrentFont, AEvent.Character);
      exit;
    end;
    Desktop^.BeginDrawing;
    if LabelContainsChar(SampleLabel1, AEvent.Character) then
      SampleLabel1^.DrawDoubleBuffered;
    if LabelContainsChar(SampleLabel2, AEvent.Character) then
      SampleLabel2^.DrawDoubleBuffered;
    if LabelContainsChar(SampleLabel3, AEvent.Character) then
      SampleLabel3^.DrawDoubleBuffered;
    Desktop^.EndDrawing;
  end;
end;

function TFontWindow.GetFilename: string;
begin
  GetFilename := TString.GetString(Filename);
end;

procedure TFontWindow.SetFilename(const AValue: string);
begin
  TString.AssignString(Filename, AValue);
end;

function TFontWindow.WindowTitle: string;
var
  name, result: string;
begin
  if Assigned(Filename) then
    name := ExtractFullName(GetFilename)
  else
    name := 'Untitled.fnt';
  result := CurrentFont^.GetId + ' (' + name  + ')';
  if Changed then
    result := result + #7;
  WindowTitle := result;
end;

procedure TFontWindow.UpdateTitle;
var
  rect: TRect;
begin
  TString.AssignString(TitleBar^.Caption, WindowTitle);
  TitleBar^.DrawDoubleBuffered;
  TString.AssignString(TaskButton^.Caption, WindowTitle);
  VeridianApp^.TaskBar^.DrawDoubleBuffered;
end;

constructor TFontWindow.Create(const AId, ATitle: string; AFont: PFont);
begin
  inherited Create(AId, ATitle, Desktop);
  CurrentFont := AFont;
end;

destructor TFontWindow.Free;
begin
  FreeAndNil(CurrentFont);
  TString.Free(Filename);
  inherited Free;
end;

procedure TFontWindow.Init;
begin
  Inherited Init;
  InitialLocation := wpDefault;
  Width := ScaleX(60);
  Height := ScaleY(80);
  ScrollType := scAsNeeded;
  Changed := false;
  Filename := nil;
  Grid := New(PFontGrid, Create(nil, 'FontGrid', @self));
  Grid^.OnSelectChar := @FontGridSelectChar;
  FontEditor := New(PFontEditor, Create(nil, 'FontEditor', @self));
  FontEditor^.OnCharacterChanged := @FontEditorCharacterChanged;
  CurrentCharLabel := New(PLabel, CreateCaption('CurrentCharLabel', 'Selected Char: ', @self));
  CharAsciiLabel := New(PLabel, CreateCaption('CharAsciiLabel', 'ASCII: ', @self));
  CurrentCharLabel^.TransparentBack := false;
  CharAsciiLabel^.TransparentBack := false;

  SampleLabel1 := New(PLabel, CreateCaption('SampleLabel1',
    'the quick brown fox jumps over the lazy dog.  ', @self));
  SampleLabel2 := New(PLabel, CreateCaption('SampleLabel2',
    'THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG.  ', @self));
  SampleLabel3 := New(PLabel, CreateCaption('SampleLabel3',
    '1234567890!@#$%^&*()-_=+;:''",<.>/?`~{[]}\|  ', @self));

  SampleLabel1^.TransparentBack := false;
  SampleLabel2^.TransparentBack := false;
  SampleLabel3^.TransparentBack := false;
end;

procedure TFontWindow.Initialized;
begin
  inherited Initialized;
end;

procedure TFontWindow.LayoutRect(ARect: TRect);
var
  yPos: integer;
  rect: TRect;
begin
  Grid^.CurrentFont := CurrentFont;
  Grid^.Layout;
  Grid^.SetXY(2, 2);

  FontEditor^.CurrentFont := CurrentFont;
  FontEditor^.Layout;
  FontEditor^.X := Grid^.X + Grid^.Width + 10;
  FontEditor^.Y := Grid^.Y;

  CurrentCharLabel^.X := FontEditor^.X;
  CurrentCharLabel^.Y := FontEditor^.Y + FontEditor^.Height + 4;

  CharAsciiLabel^.X := FontEditor^.X;
  CharAsciiLabel^.Y := CurrentCharLabel^.Y + CurrentCharLabel^.Height + 2;

  SampleLabel1^.Layout;
  SampleLabel1^.Font := CurrentFont;
  SampleLabel2^.Layout;
  SampleLabel2^.Font := CurrentFont;
  SampleLabel3^.Layout;
  SampleLabel3^.Font := CurrentFont;

  yPos := Grid^.Y + Grid^.Height + 8;

  SampleLabel1^.X := Grid^.X;
  SampleLabel1^.Y := yPos;
  Inc(yPos, SampleLabel1^.Height + 2);

  SampleLabel2^.X := Grid^.X;
  SampleLabel2^.Y := yPos;
  Inc(yPos, SampleLabel2^.Height + 2);

  SampleLabel3^.X := Grid^.X;
  SampleLabel3^.Y := yPos;
  inherited LayoutRect(ARect);
end;

function TFontWindow.WindowType: string;
begin
  WindowType := 'FontWindow';
end;

end.