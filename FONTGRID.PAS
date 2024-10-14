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
  public
    CurrentFont: PFont;
    CharsPerRow: integer;
    OnSelectChar: PFontGridEventProc;
    LineColor: byte;
    constructor Create(AFont: PFont; const AID: string; AParent: PControl);
    procedure DrawChar(ch: char);
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
    OnCharacterChanged: PFontGridEventProc;
    constructor Create(AFont: PFont; const AID: string; AParent: PControl);
    destructor Free; virtual;
    procedure Paint; virtual;
    procedure Init; virtual;
    procedure SetupControls; virtual;
    procedure SetCurrentChar(AChar: char);
    procedure MouseDown(var AEvent: TMouseEvent); virtual;
    procedure MouseMove(var AEvent: TMouseEvent); virtual;
    procedure MouseUp(var AEvent: TMouseEvent); virtual;
    procedure PaintPixel(AX, AY: integer); virtual;
  end;

implementation

uses
  Drawing,
  Common,
  GraphApp,
  Palettes,
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
  drawRect.Grow(-2 * BorderWidth, -2 * BorderWidth);
  drawRect.Translate(BorderWidth, BorderWidth);
  for index := 1 to CharsPerRow - 1 do begin
    Graph^.VLine(drawRect.X + index * (CurrentFont^.MaxWidth + 1) - 1,  drawRect.Y, drawRect.Height);
  end;
  for index := 1 to 255 div CharsPerRow do begin
    Graph^.HLine(drawRect.X, drawRect.Y + index * (CurrentFont^.Height + 1) - 1,
      drawRect.Width);
  end;
end;

procedure TFontGrid.DrawChar(ch: char);
var
  row, column, cx, cy: integer;
  drawRect: TRect;
begin
  StartDrawing;
  GetScreenBounds(drawRect);
  row := ord(ch) div CharsPerRow;
  column := ord(ch) mod CharsPerRow;
  cx := column * (CurrentFont^.MaxWidth + 1) + BorderWidth;
  cy := row * (CurrentFont^.Height + 1) + BorderWidth;
  Graph^.State.Font := CurrentFont;
  Graph^.State.ViewPort := drawRect;
  Graph^.DrawText(drawRect.X + cx, drawRect.Y + cy, ch);
  EndDrawing;
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
  Graph^.State.Font := CurrentFont;
  for ch := #0 to #255 do
    DrawChar(ch);
  Graph^.SetForeColor(LineColor);
  DrawGridLines;
end;

procedure TFontGrid.MouseDown(var AEvent: TMouseEvent);
var
  ch: char;
  index: integer;
  event: TFontGridEvent;
begin
  if AEvent.Handled then
    exit;
  index := AEvent.X div (CurrentFont^.MaxWidth + 1) +
    (AEvent.Y div (CurrentFont^.Height + 1)) * CharsPerRow;
  index := EnsureRange(index, 0, 255);
  ch := char(index);
  DrawChar(ch);
  event.Create;
  event.Character := ch;
  Invoke(OnSelectChar, event);
  inherited MouseDown(AEvent);
end;

procedure TFontGrid.Init;
begin
  inherited Init;
  CurrentFont := nil;
  CharsPerRow := 16;
  LineColor := egaDarkGray;
  ForeColor := egaWhite;
  BackColor := 0;
  BorderStyle := bsNone;
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

procedure TFontEditor.PaintPixel(AX, AY: integer);
var
  rect, drawRect: TRect;
begin
  if CurrentFont = nil then
    exit;
  if not GetVisible then
    exit;
  Graph^.State.Font := CurrentFont;
  Graph^.SetBackColor(ForeColor);
  GetScreenBounds(rect);
  rect.Grow(-BorderWidth, -BorderWidth);
  rect.Translate(BorderWidth, BorderWidth);
  AX := AX * Scale + rect.X;
  AY := AY * Scale + rect.Y;
  drawRect.CreateDims(AX, AY, Scale, Scale);
  Graph^.FillRect(drawRect);
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
  for yIndex := 0 to CurrentFont^.Height - 1 do begin
    for xIndex := 0 to CurrentFont^.MaxWidth - 1 do begin
      if CurrentFont^.IsPixelSet(CurrentChar, xIndex, yIndex) then begin
        CurrentFont^.SetPixel(CurrentChar, xIndex, yIndex);
        PaintPixel(xIndex, yIndex);
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
  ForeColor := egaWhite;
  BackColor := 0;
  Scale := 8;
  OnCharacterChanged := nil;
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

procedure TFontEditor.MouseDown(var AEvent: TMouseEvent);
var
  xIndex, yIndex: integer;
  rect: TRect;
  event: TFontGridEvent;
begin
  if AEvent.Handled then
    exit;
  GetScreenBounds(rect);
  xIndex := (AEvent.X - BorderWidth) div Scale;
  yIndex := (AEvent.Y - BorderWidth) div Scale;
  if (xIndex < 0) or (xIndex >= CurrentFont^.MaxWidth) or
    (yIndex < 0) or (yIndex >= CurrentFont^.Height) then
    exit;
  if AEvent.NewMouseState.ButtonState = [bsLeft] then begin
    CurrentFont^.SetPixel(CurrentChar, xIndex, yIndex);
    StartDrawing;
    PaintPixel(xIndex, yIndex);
    EndDrawing;
    event.Create;
    event.Character := CurrentChar;
    Invoke(OnCharacterChanged, event);
  end;
  inherited MouseDown(AEvent);
end;

procedure TFontEditor.MouseMove(var AEvent: TMouseEvent);
var
  xIndex, yIndex: integer;
  rect: TRect;
begin
  if AEvent.Handled then
    exit;
  inherited MouseMove(AEvent);
end;

procedure TFontEditor.MouseUp(var AEvent: TMouseEvent);
begin
  if AEvent.Handled then
    exit;
  inherited MouseUp(AEvent);
end;

destructor TFontEditor.Free;
begin
  inherited Free;
end;

begin
end.
