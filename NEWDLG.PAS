{$I COMPILER.INC}
unit NewDlg;

interface

uses
  AplObj,
  AplTypes,
  AplConst,
  Standard,
  Dialogs,
  Controls,
  Editors,
  Views,
  Drawing,
  ListView,
  Graphics,
  GrCanvas,
  Veridian,
  VeriCons,
  VeriType,
  FontType;

type
  PNewFontDialog = ^TNewFontDialog;

  TNewFontDialog = object(TDialog)
  private
  public
    FontIdLabel: PLabel;
    FontIdEntry: PEdit;
    FontFormatLabel: PLabel;
    FontFormatEntry: PDropDownList;
    MaxWidthLabel: PLabel;
    MaxWidthEntry: PNumericUpDown;
    HeightLabel: PLabel;
    HeightEntry: PNumericUpDown;
    SpacingLabel: PLabel;
    SpacingEntry: PNumericUpDown;
    function Execute(var AProperties: PFontProperties): TModalResult; virtual;
    function CanExecute(AActionId: word): boolean; virtual;
    procedure Init; virtual;
    procedure Layout; virtual;
    procedure Paint(ARect: TRect; var ACanvas: TCanvas); virtual;
    procedure AfterShow; virtual;
  end;

implementation

uses
  AplStr,
  AplUtils,
  AplMath,
  Strings;

procedure FontFormatChanged(var AEvent: TIndexChangedEvent);
var
  formatEntry: PDropDownList;
  dialog: PNewFontDialog;
begin
  formatEntry := PDropDownList(AEvent.Sender);
  dialog := PNewFontDialog(formatEntry^.Parent);
  case TFontFormat(AEvent.NewIndex) of
    ffMonoSpace, ffProportional, ffColored: begin
      dialog^.MaxWidthEntry^.SetEnabled(true);
      dialog^.HeightEntry^.SetEnabled(true);
    end;
    ffSystem: begin
      VeridianApp^.DisableDrawing;
      dialog^.MaxWidthEntry^.SetValue(8);
      dialog^.HeightEntry^.SetValue(16);
      VeridianApp^.EnableDrawing;
      dialog^.MaxWidthEntry^.SetEnabled(false);
      dialog^.HeightEntry^.SetEnabled(false);
    end;
  end;
end;

procedure TNewFontDialog.Init;
var
  formatIndex: TFontFormat;
begin
  inherited Init;
  VeridianApp^.PushState;
  VeridianApp^.State.DrawEnabled := false;
  InitialLocation := wpScreenCenter;
  Exclude(WindowOptions, woResizeable);

  FontIdLabel := New(PLabel, CreateCaption('FontIdLabel', 'Font Id: ', @self));
  FontIdEntry := New(PEdit, CreateParent('FontIdEntry', @self));
  FontIdEntry^.MaxLength := 20;

  FontFormatLabel := New(PLabel, CreateCaption('FontFormatLabel', 'Type: ', @self));
  FontFormatEntry := New(PDropDownList, CreateParent('FontFormatEntry', @self));
  for formatIndex := Low(TFontFormat) to High(TFontFormat) do begin
    if formatIndex in SupportedFontFormats then
      FontFormatEntry^.List^.AddItemTag(FontFormatNames[formatIndex], byte(formatIndex));
  end;
  FontFormatEntry^.OnSelectedIndexChanged := @FontFormatChanged;

  MaxWidthLabel := New(PLabel, CreateCaption('MaxWidthLabel', 'Max Width: ', @self));
  MaxWidthEntry := New(PNumericUpDown, CreateParent('MaxWidthEntry', @self));
  MaxWidthEntry^.SetMinValue(2);
  MaxWidthEntry^.SetMaxValue(16);
  MaxWidthEntry^.SetValue(8);

  HeightLabel := New(PLabel, CreateCaption('HeightLabel', 'Height: ', @self));
  HeightEntry := New(PNumericUpDown, CreateParent('HeightEntry', @self));
  HeightEntry^.SetMinValue(2);
  HeightEntry^.SetMaxValue(24);
  HeightEntry^.SetValue(16);

  SpacingLabel := New(PLabel, CreateCaption('SpacingLabel', 'Spacing: ', @self));
  SpacingEntry := New(PNumericUpDown, CreateParent('SpacingEntry', @self));
  SpacingEntry^.SetMinValue(0);
  SpacingEntry^.SetMaxValue(8);
  SpacingEntry^.SetValue(1);

  Padding.CreateAll(4, 4, 4, 2);
  InitialLocation := wpScreenCenter;
  VeridianApp^.PopState;
end;

procedure TNewFontDialog.Layout;
var
  xPos, yPos: integer;
  entryWidth, entryHeight: integer;
  numEntryX, offset: integer;
  size: integer;
begin
  inherited Layout;
  VeridianApp^.PushState;
  VeridianApp^.State.DrawEnabled := false;
  xPos := 0;
  yPos := 3;
  entryHeight := FontIdLabel^.Font^.Height + 6;

  size := 55;
  entryWidth := 100;
  offset := 4;
  if Graph^.Mode^.Width < 512 then begin
    size := 35;
    entryWidth := 75;
    offset := 3;
  end;

  FontIdLabel^.SetXY(xPos, yPos + 4);
  Inc(xPos, FontIdLabel^.Width + offset);
  FontIdEntry^.SetBounds(xPos, yPos + 1, entryWidth, entryHeight);
  FontIdEntry^.ValidChars := AlphaNumericSpace;
  FontIdEntry^.MaxLength := 20;
  xPos := 0;
  Inc(yPos, FontIdEntry^.Height + 6);

  FontFormatLabel^.SetXY(xPos, yPos + 3);
  FontFormatEntry^.Height := entryHeight;
  FontFormatEntry^.SetXY(FontIdEntry^.X, yPos);
  Inc(yPos, FontFormatEntry^.Height + 6);

  MaxWidthLabel^.SetXY(xPos, yPos + offset);
  Inc(xPos, MaxWidthLabel^.Width + offset);
  numEntryX := xPos;
  MaxWidthEntry^.SetBounds(xPos, yPos, size, entryHeight);
  xPos := 0;
  Inc(yPos, MaxWidthEntry^.Height + 6);

  HeightLabel^.SetXY(xPos, yPos + offset);
  HeightEntry^.SetBounds(numEntryX, yPos, size, entryHeight);
  Inc(yPos, HeightEntry^.Height + 6);

  SpacingLabel^.SetXY(xPos, yPos + offset);
  SpacingEntry^.SetBounds(numEntryX, yPos, size, entryHeight);
  Inc(yPos, SpacingEntry^.Height + 6);

  Width := 200;
  Height := 180;
  if Graph^.Mode^.Width < 512 then begin
    Width := 145;
    Height := 120;
  end;
  VeridianApp^.PopState;
end;

procedure TNewFontDialog.Paint(ARect: TRect; var ACanvas: TCanvas);
begin
  inherited Paint(ARect, ACanvas);
end;

procedure TNewFontDialog.AfterShow;
begin
  inherited AfterShow;
  FontIdEntry^.TabOrder := 0;
  FontFormatEntry^.TabOrder := 1;
  MaxWidthEntry^.TabOrder := 2;
  HeightEntry^.TabOrder := 3;
  SpacingEntry^.TabOrder := 4;
  SetButtonTabOrders(5);
  FontIdEntry^.Focus;
end;

function TNewFontDialog.CanExecute(AActionId: word): boolean;
begin
  CanExecute := inherited CanExecute(AActionId);
  case AActionId of
    acDialogOk: begin
      if IsWhiteSpace(FontIdEntry^.GetText) then begin
        ShowMessage('Invalid Entry', 'Font ID cannot be empty.');
        CanExecute := false;
      end;
    end;
  end;
end;

function TNewFontDialog.Execute(var AProperties: PFontProperties): TModalResult;
var
  result: TModalResult;
begin
  if not Assigned(AProperties) then
    AProperties := New(PFontProperties, Create);

  VeridianApp^.PushState;
  VeridianApp^.State.DrawEnabled := false;
  if Assigned(AProperties^.Id) then
    FontIdEntry^.SetText(StrPas(AProperties^.Id));
  FontFormatEntry^.SetSelectedIndex(ord(AProperties^.Format));
  MaxWidthEntry^.SetValue(AProperties^.MaxWidth);
  HeightEntry^.SetValue(AProperties^.Height);
  SpacingEntry^.SetValue(AProperties^.Spacing);
  VeridianApp^.PopState;

  result := ShowDialog;
  if result = mrOK then begin
    TString.AssignString(AProperties^.Id, FontIdEntry^.GetText);
    AProperties^.Format := TFontFormat(FontFormatEntry^.SelectedIndex);
    AProperties^.MaxWidth := MaxWidthEntry^.Value;
    AProperties^.Height := HeightEntry^.Value;
    AProperties^.Spacing := SpacingEntry^.Value;
  end;
  Execute := result;
end;

end.