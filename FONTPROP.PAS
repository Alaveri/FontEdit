{$I COMPILER.INC}
unit FontProp;

interface

uses
  AplObj,
  Actions,
  AplTypes,
  Controls,
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
    SpacingLabel: PLabel;
    SpacingEntry: PNumericUpDown;
    constructor Create(const ATitle: string);
    procedure HandleActionExecute(var AAction: PAction); virtual;
    procedure SetupControls; virtual;
    procedure BeforeShow; virtual;
    procedure AfterShow; virtual;
    procedure Init; virtual;
    destructor Free; virtual;
  end;

implementation

uses
  GraphDrv,
  Drawing;

constructor TFontPropertiesDialog.Create(const ATitle: string);
begin
  inherited Create('FontPropertiesDialog', [mbOk, mbCancel]);
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

  SpacingLabel^.SetBounds(rect.X + left, yPos, 100, 20);
  SpacingLabel^.SetupControls;
  SpacingEntry^.X := FontMaxWidthEntry^.X;
  SpacingEntry^.Y := yPos - 2;

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
  oldDrawEnabled := VeridianApp^.DrawEnabled;
  VeridianApp^.DrawEnabled := false;
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
  FontHeightEntry^.SetMaxValue(24);

  SpacingLabel := New(PLabel, CreateText('SpacingLabel', 'Spacing:', @self));
  SpacingLabel^.AutoSize := true;
  SpacingEntry := New(PNumericUpDown, CreateParent('SpacingEntry', @self));
  SpacingEntry^.SetValue(1);
  SpacingEntry^.SetMinValue(0);
  SpacingEntry^.SetMaxValue(4);

  VeridianApp^.DrawEnabled := oldDrawEnabled;
end;

destructor TFontPropertiesDialog.Free;
begin
  inherited Free;
end;

end.