{$I COMPILER.INC}
unit FontGrid;

interface

uses
  AplObj,
  AplTypes,
  Controls,
  Veridian;

type
  PFontGrid = ^TFontGrid;

  TFontGrid = object(TControl)
  private
  public
    procedure SetupControls; virtual;
    procedure Init; virtual;
    destructor Free; virtual;
  end;

implementation

procedure TFontGrid.SetupControls;
begin
  inherited SetupControls;
end;

procedure TFontGrid.Init;
begin
  inherited Init;
end;

destructor TFontGrid.Free;
begin
  inherited Free;
end;

begin
end.
