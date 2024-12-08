{$I COMPILER.INC}
unit FontProp;

interface

uses
  AplObj,
  AplAct,
  AplTypes,
  Controls,
  VTypes,
  Veridian,
  Combos,
  Dialogs;

type
  PFontPropertiesDialog = ^TFontPropertiesDialog;

  TFontPropertiesDialog = object(TDialog)
  private
  public
    FontTypeLabel: PLabel;
    FontTypeEntry: PDropDownList;
    FontHeightLabel: PLabel;
    FontHeightEntry: PNumericUpDown;
    FontMaxWidthLabel: PLabel;
    FontMaxWidthEntry: PNumericUpDown;
    FontSpacingLabel: PLabel;
    FontSpacingEntry: PNumericUpDown;
    constructor Create(const ATitle: string);
    constructor CreateParent(const ATitle: string; AParent: PControl);
    procedure HandleActionExecute(var AAction: PAction); virtual;
    procedure SetupControls; virtual;
    procedure BeforeShow; virtual;
    procedure AfterShow; virtual;
    procedure Init; virtual;
    destructor Free; virtual;
  end;

implementation

uses
  AplGraph,
  AplDraw;

constructor TFontPropertiesDialog.Create(const ATitle: string);
begin
  inherited Create('FontPropertiesDialog', [mbOk, mbCancel]);
  SetTitle(ATitle);
end;

constructor TFontPropertiesDialog.CreateParent(const ATitle: string; AParent: PControl);
begin
  inherited CreateParent('FontPropertiesDialog', AParent, [mbOk, mbCancel]);
  SetTitle(ATitle);
end;

procedure TFontPropertiesDialog.HandleActionExecute(var AAction: PAction);
begin
  inherited HandleActionExecute(AAction);
end;

procedure TFontPropertiesDialog.SetupControls;
var
  rect: TRect;
  left: integer;
  yPos: integer;
begin
  inherited SetupControls;
  left := 5;
  X := CenterX;
  Y := CenterY;
  GetContentBounds(rect);

  yPos := rect.Y + 10;
  FontTypeLabel^.SetBounds(rect.X + left, yPos, 100, Font^.Height);
  FontTypeLabel^.SetupControls;
  FontTypeEntry^.SetBounds(rect.X + left + Font^.TextWidth(FontTypeLabel^.GetText) + 4, yPos - 1, 100, Font^.Height);
  FontTypeEntry^.SetupControls;

  Inc(yPos, 30);

  FontMaxWidthLabel^.SetBounds(rect.X + left, yPos, 100, 20);
  FontMaxWidthLabel^.SetupControls;
  FontMaxWidthEntry^.X := rect.X + left + Font^.TextWidth(FontMaxWidthLabel^.GetText) + 10;
  FontMaxWidthEntry^.Y := yPos - 2;

  Inc(yPos, 30);

  FontHeightLabel^.SetBounds(rect.X + left, yPos, 100, 20);
  FontHeightLabel^.SetupControls;
  FontHeightEntry^.X := FontMaxWidthEntry^.X;
  FontHeightEntry^.Y := yPos - 2;

  Inc(yPos, 30);

  FontSpacingLabel^.SetBounds(rect.X + left, yPos, 100, 20);
  FontSpacingLabel^.SetupControls;
  FontSpacingEntry^.X := FontMaxWidthEntry^.X;
  FontSpacingEntry^.Y := yPos - 2;

end;

procedure TFontPropertiesDialog.BeforeShow;
begin
  inherited BeforeShow;
end;

procedure TFontPropertiesDialog.AfterShow;
begin
  inherited AfterShow;
end;

procedure TFontPropertiesDialog.Init;
var
  oldDrawEnabled: boolean;
begin
  inherited Init;
  VeridianApp^.PushState;
  VeridianApp^.State.DrawEnabled := false;
  Width := VeridianApp^.Scale(20);
  Height := VeridianApp^.Scale(12);
  ButtonAlign := haRight;
  FontTypeLabel := New(PLabel, CreateText('FontTypeLabel', 'Select a font type:', @self));
  FontTypeLabel^.AutoSize := true;

  FontTypeEntry := New(PDropDownList, CreateParent('FontTypeEntry', 0, @self));
  FontTypeEntry^.AutoSize := true;
  FontTypeEntry^.Items^.AddItemTag('Proportional', byte(ffProportional));
  FontTypeEntry^.Items^.AddItemTag('Monospace', byte(ffMonospace));
  FontTypeEntry^.Items^.AddItemTag('Colored Proportional', byte(ffColored));
  FontTypeEntry^.Items^.AddItemTag('System', byte(ffSystem));
  FontTypeEntry^.SetSelectedIndex(0);

  FontMaxWidthLabel := New(PLabel, CreateText('FontMaxWidthLabel', 'Max Width:', @self));
  FontMaxWidthLabel^.AutoSize := true;

  FontMaxWidthEntry := New(PNumericUpDown, CreateParent('FontMaxWidthEntry', @self));
  FontMaxWidthEntry^.SetValue(8);
  FontMaxWidthEntry^.SetMinValue(2);
  FontMaxWidthEntry^.SetMaxValue(16);

  FontHeightLabel := New(PLabel, CreateText('FontHeightLabel', 'Height:', @self));
  FontHeightLabel^.AutoSize := true;

  FontHeightEntry := New(PNumericUpDown, CreateParent('FontHeightEntry', @self));
  FontHeightEntry^.SetValue(16);
  FontHeightEntry^.SetMinValue(2);
  FontHeightEntry^.SetMaxValue(22);

  FontSpacingLabel := New(PLabel, CreateText('SpacingLabel', 'Spacing:', @self));
  FontSpacingLabel^.AutoSize := true;
  FontSpacingEntry := New(PNumericUpDown, CreateParent('SpacingEntry', @self));
  FontSpacingEntry^.SetValue(1);
  FontSpacingEntry^.SetMinValue(0);
  FontSpacingEntry^.SetMaxValue(4);

  VeridianApp^.PopState;
end;

destructor TFontPropertiesDialog.Free;
begin
  inherited Free;
end;

end.