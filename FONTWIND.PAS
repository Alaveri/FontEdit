{$I COMPILER.INC}
unit FontWind;

interface

uses
  AplObj,
  Lists,
  FontGrid,
  Veridian,
  Controls,
  Drawing,
  Views;

type
  PFontWindow = ^TFontWindow;

  TFontWindow = object(TWindow)
  private
  public
    FontGrid: PFontGrid;
    CurrentCharLabel: PLabel;
    CharAsciiLabel: PLabel;
    FontEditor: PFontEditor;
    SampleLabel1: PLabel;
    SampleLabel2: PLabel;
    SampleLabel3: PLabel;
    constructor Create(const AId, ATitle: string; AParent: PControl);
    procedure Init; virtual;
    procedure SetupControls; virtual;
    destructor Free; virtual;
  end;

implementation

uses
  GraphDrv,
  Desk;

constructor TFontWindow.Create(const AId, ATitle: string; AParent: PControl);
begin
  inherited CreateParent(AId, AParent);
  SetTitle(ATitle);
end;

procedure TFontWindow.Init;
var
  rect: TRect;
begin
  inherited init;
  CurrentCharLabel := nil;
  CharAsciiLabel := nil;
  FontGrid := nil;
  FontEditor := nil;
  SampleLabel1 := nil;
  SampleLabel2 := nil;
  SampleLabel3 := nil;
  Desktop^.GetClientRect(rect);
  Width := Graph^.Mode^.Width + 2;
  Height := rect.Height - Desktop^.MenuBar^.Height - Desktop^.StatusBar^.Height + 5;
  X := -1;
  Y := Desktop^.MenuBar^.Height - 1;
end;

procedure TFontWindow.SetupControls;
begin
  inherited SetupControls;
end;

destructor TFontWindow.Free;
begin
  inherited Free;
end;

begin
end.