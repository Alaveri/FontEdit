{$I COMPILER.INC}
unit FontGrid;

interface

uses
  AplObj,
  AplTypes,
  Controls,
  GraphDrv,
  UndoStk,
  Veridian;

type
  PFontGrid = ^TFontGrid;
  PFontGridEvent = ^TFontGridEvent;
  PFontGridEventProc = ^TFontGridEventProc;
  PFontEditor = ^TFontEditor;

  TFontGridEvent = object(TEvent)
  private
  public
    Character: char;
    procedure Init; virtual;
    procedure Assign(var ASource: TObject); virtual;
    procedure Clear; virtual;
  end;

  TFontGridEventProc = procedure(ASender: PObject; var AEvent: TFontGridEvent);

  TFontGrid = object(TPanel)
  private
    procedure DrawGridLines;
    procedure DrawChar(ch: char);
  public
    CurrentFont: PFont;
    CharsPerRow: integer;
    OnSelectChar: PFontGridEventProc;
    constructor Create(AFont: PFont; const AID: string; AParent: PControl);
    procedure MouseDown(var AEvent: TMouseEvent); virtual;
    procedure SetupControls; virtual;
    procedure Init; virtual;
    procedure Paint; virtual;
    destructor Free; virtual;
  end;

  TFontEditor = object(TPanel)
  private
  public
    CurrentFont: PFont;
    CurrentChar: char;
    Scale: integer;
    constructor Create(AFont: PFont; const AID: string; AParent: PControl);
    destructor Free; virtual;
    procedure Paint; virtual;
    procedure Init; virtual;
    procedure SetupControls; virtual;
    procedure SetCurrentChar(AChar: char);
  end;

implementation

uses
  Drawing,
  Common,
  Desk;

procedure TFontGridEvent.Init;
begin
  inherited Init;
end;

procedure TFontGridEvent.Assign(var ASource: TObject);
var
  source: PFontGridEvent;
begin
  inherited Assign(ASource);
  source := PFontGridEvent(@ASource);
  Character := source^.Character;
end;

procedure TFontGridEvent.Clear;
begin
  Character := #0;
end;

constructor TFontGrid.Create(AFont: PFont; const AID: string; AParent: PControl);
begin
  inherited CreateParent(AID, AParent);
  CurrentFont := AFont;
end;

procedure TFontGrid.SetupControls;
var
  rows: integer;
begin
  inherited SetupControls;
  Width := CharsPerRow * (CurrentFont^.MaxWidth + 1) + 2 * BorderWidth;
  rows := 256 div CharsPerRow;
  if 256 mod CharsPerRow > 0 then
    Inc(rows);
  Height := rows * (CurrentFont^.Height + 1) + 2 * BorderWidth;
end;

procedure TFontGrid.DrawGridLines;
var
  index: integer;
  drawRect: TRect;
begin
  GetScreenBounds(drawRect);
  for index := 1 to CharsPerRow - 1 do begin
    Graph^.VLine(drawRect.X + index * (CurrentFont^.MaxWidth + 1),
      drawRect.Y + BorderWidth, drawRect.Height - 2 * BorderWidth);
  end;
  for index := 1 to 255 div CharsPerRow do begin
    Graph^.HLine(drawRect.X + BorderWidth, drawRect.Y + index * (CurrentFont^.Height + 1) - 1,
      drawRect.Width - 2 * BorderWidth);
  end;
end;

procedure TFontGrid.DrawChar(ch: char);
var
  row, column, cx, cy: integer;
  drawRect: TRect;
begin
  GetScreenBounds(drawRect);
  row := ord(ch) div CharsPerRow;
  column := ord(ch) mod CharsPerRow;
  cx := column * (CurrentFont^.MaxWidth + 1);
  cy := row * (CurrentFont^.Height + 1);
  Graph^.DrawText(drawRect.X + cx + BorderWidth, drawRect.Y + cy + BorderWidth, ch);
end;

procedure TFontGrid.Paint;
var
  ch: char;
begin
  inherited Paint;
  if CurrentFont = nil then
    exit;
  Graph^.SetForeColor(ForeColor);
  Graph^.SetBackColor(BackColor);
  DrawGridLines;
  Graph^.State.Font := CurrentFont;
  for ch := #0 to #255 do
    DrawChar(ch);
end;

procedure TFontGrid.MouseDown(var AEvent: TMouseEvent);
var
  ch: char;
  index: integer;
  selectCharEvent: TFontGridEvent;
begin
  if AEvent.Handled then
    exit;
  index := AEvent.X div (CurrentFont^.MaxWidth + 1) +
    (AEvent.Y div (CurrentFont^.Height + 1)) * CharsPerRow;
  index := EnsureRange(index, 0, 255);
  ch := char(index);
  DrawChar(ch);
  selectCharEvent.Create;
  selectCharEvent.Character := ch;
  InvokeSelf(OnSelectChar, @selectCharEvent);
  inherited MouseDown(AEvent);
end;

procedure TFontGrid.Init;
begin
  inherited Init;
  CurrentFont := nil;
  CharsPerRow := 16;
  ForeColor := Desktop^.Colors^.Focused;
  BackColor := Desktop^.Colors^.FocusedBack;
  BorderStyle := bsSingle;
  OnSelectChar := nil;
end;

destructor TFontGrid.Free;
begin
  inherited Free;
end;

constructor TFontEditor.Create(AFont: PFont; const AID: string; AParent: PControl);
begin
  inherited CreateParent(AID, AParent);
  CurrentFont := AFont;
end;

procedure TFontEditor.Paint;
var
  xIndex, yIndex: integer;
  rect, drawRect: TRect;
begin
  inherited Paint;
  if CurrentFont = nil then
    exit;
  if not GetVisible then
    exit;
  Graph^.State.Font := CurrentFont;
  Graph^.SetBackColor(ForeColor);
  GetScreenBounds(rect);
  rect.Grow(-BorderWidth, -BorderWidth);
  rect.Translate(BorderWidth, BorderWidth);
  for yIndex := 0 to CurrentFont^.Height - 1 do begin
    for xIndex := 0 to CurrentFont^.MaxWidth - 1 do begin
      if CurrentFont^.PixelSet(CurrentChar, xIndex, yIndex) then begin
        drawRect.CreateDims(rect.X + xIndex * Scale, rect.Y + yIndex * Scale, Scale, Scale);
        Graph^.FillRect(drawRect);
      end;
    end;
  end;
end;

procedure TFontEditor.Init;
begin
  inherited Init;
  CurrentFont := nil;
  CurrentChar := #0;
  CanUndo := true;
  ForeColor := Desktop^.Colors^.Focused;
  BackColor := Desktop^.Colors^.FocusedBack;
  Scale := 8;
end;

procedure TFontEditor.SetupControls;
begin
  inherited SetupControls;
  Width := CurrentFont^.MaxWidth * Scale + 2 * BorderWidth;
  Height := CurrentFont^.Height * Scale + 2 * BorderWidth;
end;

procedure TFontEditor.SetCurrentChar(AChar: char);
begin
  CurrentChar := AChar;
  Draw;
end;

destructor TFontEditor.Free;
begin
  inherited Free;
end;

begin
end.
