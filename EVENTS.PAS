{$I COMPILER.INC}
unit Events;

interface

uses
  AplObj,
  FontGrid,
  AplTypes;

implementation

uses
  FontWind,
  Common,
  Controls,
  GraphDrv,
  Drawing,
  GraphApp,
  StrUtils,
  FontAppl;

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
        Graph8^.State^.Font := AFont;
        Graph8^.DrawText(rect.X, rect.Y, AChar);
      end;
      Inc(ptr);
      Inc(len);
    end;

    ALabel^.EndDrawing;
  end;
end;

procedure FontEditorCharacterChanged(ASender: PObject; var AEvent: TFontEditorChangedEvent); far;
var
  window: PFontWindow;
  grid: PFontGrid;
  alabel: PLabel;
  function LabelContainsChar(ALabel: PLabel; AChar: char): boolean;
  var
    index: integer;
  begin
    index := TString.IndexOf(ALabel^.Text, AChar);
    LabelContainsChar := index > -1;
  end;
begin
  window := FontApp^.EditorWindow;
  grid := window^.FontGrid;
  if AEvent.NewCharWidth = AEvent.OldCharWidth then begin
    grid^.DrawChar(AEvent.Character, true);
    DrawSampleChar(window^.SampleLabel1, grid^.CurrentFont, AEvent.Character);
    DrawSampleChar(window^.SampleLabel2, grid^.CurrentFont, AEvent.Character);
    DrawSampleChar(window^.SampleLabel3, grid^.CurrentFont, AEvent.Character);
    exit;
  end;
  alabel := nil;
  if LabelContainsChar(window^.SampleLabel1, AEvent.Character) then
    alabel := window^.SampleLabel1
  else if LabelContainsChar(window^.SampleLabel2, AEvent.Character) then
    alabel := window^.SampleLabel2
  else if LabelContainsChar(window^.SampleLabel3, AEvent.Character) then
    alabel := window^.SampleLabel3;
  if Assigned(alabel) then
    alabel^.SetText(TString.GetString(alabel^.Text));
end;

end.