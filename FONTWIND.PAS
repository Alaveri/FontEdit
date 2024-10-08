{$I COMPILER.INC}
unit FontWind;

interface

uses
  AplObj,
  Lists,
  Veridian,
  Controls,
  Drawing,
  Views;

type
  PFontWindow = ^TFontWindow;

  TFontWindow = object(TWindow)
  private
  public
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