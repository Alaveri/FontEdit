{$I COMPILER.INC}
unit FontGrid;

interface

uses
  AplObj,
  AplTypes,
  Controls,
  Graphics,
  AplMath,
  VeriType,
  Drawing,
  Undo,
  Veridian;

type
  PFontGrid = ^TFontGrid;
  PFontGridEvent = ^TFontGridEvent;
  PFontEditor = ^TFontEditor;
  PFontEditorChangedEvent = ^TFontEditorChangedEvent;

  TFontGridEvent = object(TEvent)
  private
  public
    Character: char;
    procedure Init; virtual;
    procedure Assign(var ASource: TObject); virtual;
    procedure Clear; virtual;
  end;

  TFontEditorChangedEvent = object(TFontGridEvent)
  private
  public
    OldCharWidth: byte;
    NewCharWidth: byte;
    procedure Init; virtual;
    procedure Assign(var ASource: TObject); virtual;
    procedure Clear; virtual;
  end;

  TFontGrid = object(TPanel)
  private
    procedure DrawGridLines(ARect: TRect);
  public
    CurrentFont: PFont;
    CharsPerRow: integer;
    OnSelectChar: PEventProc;
    LineColor: byte;
    constructor Create(AFont: PFont; const AID: string; AParent: PControl);
    procedure DrawChar(ARect: TRect; ACH: char; AClear: boolean);
    procedure MouseDown(var AEvent: TMouseEvent); virtual;
    procedure Layout(ARect: TRect); virtual;
    procedure Init; virtual;
    procedure Paint(ARect: TRect); virtual;
    destructor Free; virtual;
  end;

  TFontEditor = object(TPanel)
  private
    FPreviousPixel: TPoint;
    FButton: TButtonState;
  public
    CurrentFont: PFont;
    CurrentChar: char;
    Scale: integer;
    OnCharacterChanged: PEventProc;
    constructor Create(AFont: PFont; const AID: string; AParent: PControl);
    destructor Free; virtual;
    procedure Paint(ARect: TRect); virtual;
    procedure Init; virtual;
    procedure Layout(ARect: TRect); virtual;
    procedure SetCurrentChar(AChar: char);
    procedure MouseDown(var AEvent: TMouseEvent); virtual;
    procedure MouseMove(var AEvent: TMouseEvent); virtual;
    procedure MouseUp(var AEvent: TMouseEvent); virtual;
    procedure PaintPixel(ARect: TRect; AX, AY: integer; APixelOn: boolean); virtual;
  end;

implementation

uses
  AplUtils,
  Palettes;

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
  inherited Clear;
  Character := #0;
end;

procedure TFontEditorChangedEvent.Init;
begin
  inherited Init;
  Clear;
end;

procedure TFontEditorChangedEvent.Assign(var ASource: TObject);
var
  source: PFontEditorChangedEvent;
begin
  inherited Assign(ASource);
  source := PFontEditorChangedEvent(@ASource);
  OldCharWidth := source^.OldCharWidth;
  NewCharWidth := source^.NewCharWidth;
end;

procedure TFontEditorChangedEvent.Clear;
begin
  inherited Clear;
  OldCharWidth := 0;
  NewCharWidth := 0;
end;

constructor TFontGrid.Create(AFont: PFont; const AID: string; AParent: PControl);
begin
  inherited CreateParent(AID, AParent);
  CurrentFont := AFont;
end;

procedure TFontGrid.Layout(ARect: TRect);
var
  rows: integer;
begin
  inherited Layout(ARect);
  Width := CharsPerRow * (CurrentFont^.MaxWidth + 1) + 2 * BorderWidth;
  rows := 256 div CharsPerRow;
  if 256 mod CharsPerRow > 0 then
    Inc(rows);
  Height := rows * (CurrentFont^.Height + 1) + 2 * BorderWidth;
end;

procedure TFontGrid.DrawGridLines(ARect: TRect);
var
  index: integer;
begin
  for index := 1 to CharsPerRow - 1 do begin
    Graph^.VLine(ARect.X + index * (CurrentFont^.MaxWidth + 1) - 1,  ARect.Y, ARect.Height);
  end;
  for index := 1 to 255 div CharsPerRow do begin
    Graph^.HLine(ARect.X, ARect.Y + index * (CurrentFont^.Height + 1) - 1,
      ARect.Width);
  end;
end;

procedure TFontGrid.DrawChar(ARect: TRect; ACH: char; AClear: boolean);
var
  row, column, cx, cy: integer;
  charRect: TRect;
  buffer: PByte;
begin
  BeginDrawing;
  row := ord(ACH) div CharsPerRow;
  column := ord(ACH) mod CharsPerRow;
  cx := column * (CurrentFont^.MaxWidth + 1) + BorderWidth;
  cy := row * (CurrentFont^.Height + 1) + BorderWidth;
  Graph^.State^.Font := CurrentFont;
  Graph^.State^.ViewPort := ARect;
  Graph^.SetForeColor(ForeColor);
  Graph^.SetBackColor(BackColor);
  charRect.CreateDims(ARect.X + cx, ARect.Y + cy,
    CurrentFont^.MaxWidth, CurrentFont^.Height);
  if AClear then begin
    Graph^.PushState;
    buffer := nil;
    Graph^.BeginDrawBuffer(buffer, charRect);
    Graph^.FillRect(charRect);
    Graph^.DrawText(charRect.X, charRect.Y, ACH);
    Graph^.EndDrawBuffer;
    Graph^.PopState;
    Graph^.DrawImage(ARect.X + cx, ARect.Y + cy,
      charRect.Width, charRect.Height, buffer);
    FreeMem(buffer, charRect.Width * charRect.Height);
  end
  else
    Graph^.DrawText(ARect.X + cx, ARect.Y + cy, ACH);
  EndDrawing;
end;

procedure TFontGrid.Paint(ARect: TRect);
var
  ch: char;
begin
  inherited Paint(ARect);
  if CurrentFont = nil then
    exit;
  Graph^.SetForeColor(ForeColor);
  Graph^.SetBackColor(BackColor);
  Graph^.State^.Font := CurrentFont;
  for ch := #0 to #255 do
    DrawChar(ARect, ch, false);
  Graph^.SetForeColor(LineColor);
  DrawGridLines(ARect);
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
  index := Clamp(index, 0, 255);
  ch := char(index);
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

procedure TFontEditor.PaintPixel(ARect: TRect; AX, AY: integer; APixelOn: boolean);
var
  drawRect: TRect;
begin
  if CurrentFont = nil then
    exit;
  if not IsVisible then
    exit;
  Graph^.State^.Font := CurrentFont;
  if APixelOn then
    Graph^.SetBackColor(ForeColor)
  else
    Graph^.SetBackColor(BackColor);
  AX := AX * Scale + ARect.X;
  AY := AY * Scale + ARect.Y;
  drawRect.CreateDims(AX, AY, Scale, Scale);
  Graph^.FillRect(drawRect);
end;

procedure TFontEditor.Paint(ARect: TRect);
var
  xIndex, yIndex: integer;
begin
  inherited Paint(ARect);
  if CurrentFont = nil then
    exit;
  if not IsVisible then
    exit;
  Graph^.State^.Font := CurrentFont;
  Graph^.SetBackColor(ForeColor);
  for yIndex := 0 to CurrentFont^.Height - 1 do begin
    for xIndex := 0 to CurrentFont^.MaxWidth - 1 do begin
      if CurrentFont^.IsPixelSet(CurrentChar, xIndex, yIndex) then begin
        PaintPixel(ARect, xIndex, yIndex, true);
      end;
    end;
  end;
end;

procedure TFontEditor.Init;
begin
  inherited Init;
  CurrentFont := nil;
  CurrentChar := #0;
  ForeColor := egaWhite;
  BackColor := 0;
  Scale := 8;
  OnCharacterChanged := nil;
  FPreviousPixel.Create;
  FButton := bsLeft;
end;

procedure TFontEditor.Layout(ARect: TRect);
begin
  inherited Layout(ARect);
  Width := CurrentFont^.MaxWidth * Scale + 2 * BorderWidth;
  Height := CurrentFont^.Height * Scale + 2 * BorderWidth;
end;

procedure TFontEditor.SetCurrentChar(AChar: char);
begin
  CurrentChar := AChar;
  Draw;
end;

procedure DoSetPixel(ARect: TRect; AX, AY: integer; AData: pointer); far;
var
  fontEditor: PFontEditor;
  currentFont: PFont;
  currentChar: char;
begin
  fontEditor := PFontEditor(AData);
  currentFont := fontEditor^.CurrentFont;
  currentChar := fontEditor^.CurrentChar;
  if fontEditor^.FButton = bsLeft then begin
    currentFont^.SetPixel(currentChar, AX, AY);
    fontEditor^.PaintPixel(ARect, AX, AY, true);
  end
  else begin
    currentFont^.ClearPixel(currentChar, AX, AY);
    fontEditor^.PaintPixel(ARect, AX, AY, false);
  end;
end;

procedure TFontEditor.MouseDown(var AEvent: TMouseEvent);
var
  xIndex, yIndex: integer;
  rect: TRect;
  event: TFontEditorChangedEvent;
begin
  if AEvent.Handled then
    exit;
  GetScreenBounds(rect);
  xIndex := (AEvent.X - BorderWidth) div Scale;
  yIndex := (AEvent.Y - BorderWidth) div Scale;
  if (xIndex < 0) or (xIndex >= CurrentFont^.MaxWidth) or
    (yIndex < 0) or (yIndex >= CurrentFont^.Height) then
    exit;
  FPreviousPixel.SetCoords(xIndex, yIndex);

  event.Create;
  event.Character := currentChar;
  event.OldCharWidth := currentFont^.CharWidth(CurrentChar);
  BeginDrawing;
  if AEvent.NewMouseState.ButtonState = [bsLeft] then begin
    FButton := bsLeft;
    DoSetPixel(rect, xIndex, yIndex, @self);
  end
  else if AEvent.NewMouseState.ButtonState = [bsRight] then begin
    FButton := bsRight;
    DoSetPixel(rect, xIndex, yIndex, @self);
  end;
  EndDrawing;
  currentFont^.SetCharWidths;
  event.NewCharWidth := currentFont^.CharWidth(CurrentChar);
  Invoke(OnCharacterChanged, event);
  inherited MouseDown(AEvent);
end;

procedure TFontEditor.MouseMove(var AEvent: TMouseEvent);
var
  xIndex, yIndex: integer;
  rect: TRect;
  event: TFontEditorChangedEvent;
begin
  if AEvent.Handled then
    exit;
  if not ((VeridianApp^.LeftMouseDownControl = @self) or
    (VeridianApp^.RightMouseDownControl = @self)) then
    exit;
  xIndex := (AEvent.X - BorderWidth) div Scale;
  yIndex := (AEvent.Y - BorderWidth) div Scale;
  if FPreviousPixel.EqualsCoords(xIndex, yIndex) then
    exit;
  if (xIndex < 0) or (xIndex >= CurrentFont^.MaxWidth) or
    (yIndex < 0) or (yIndex >= CurrentFont^.Height) then
    exit;
  event.Create;
  event.Character := currentChar;
  event.OldCharWidth := currentFont^.CharWidth(CurrentChar);
  rect.CreateDims(0, 0, CurrentFont^.MaxWidth, CurrentFont^.Height);
  BeginDrawing;
  if VeridianApp^.LeftMouseDownControl = @self then
    FButton := bsLeft
  else if VeridianApp^.RightMouseDownControl = @self then
    FButton := bsRight;
  LineDraw(FPreviousPixel.X, FPreviousPixel.Y, xIndex, yIndex,
    rect, @DoSetPixel, @self);
  EndDrawing;
  currentFont^.SetCharWidths;
  event.NewCharWidth := currentFont^.CharWidth(CurrentChar);
  Invoke(OnCharacterChanged, event);
  FPreviousPixel.SetCoords(xIndex, yIndex);
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
