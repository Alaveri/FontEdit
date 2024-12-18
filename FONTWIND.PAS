{$I COMPILER.INC}
unit FontWind;

interface

uses
  AplObj,
  AplTypes,
  AplConst,
  Controls,
  Drawing,
  Graphics,
  FontGrid,
  FontType,
  Views;

type
  PFontWindow = ^TFontWindow;

  TFontWindow = object(TWindow)
  private
  public
    Grid: PFontGrid;
    CurrentFont: PFont;
    constructor Create(const AId, ATitle: string; AFont: PFont);
    destructor Free; virtual;
    procedure Init; virtual;
    procedure Initialized; virtual;
    procedure Layout(ARect: TRect); virtual;
  end;

implementation

constructor TFontWindow.Create(const AId, ATitle: string; AFont: PFont);
begin
  inherited Create(AId, ATitle, Desktop);
  CurrentFont := AFont;
end;

destructor TFontWindow.Free;
begin
  FreeAndNil(CurrentFont);
  inherited Free;
end;

procedure TFontWindow.Init;
begin
  Inherited Init;
  InitialLocation := wpDefault;
  Width := ScaleX(60);
  Height := ScaleY(70);

{  Grid := New(PFontGrid, Create(}
end;

procedure TFontWindow.Initialized;
begin
  inherited Initialized;
end;

procedure TFontWindow.Layout(ARect: TRect);
begin
  inherited Layout(ARect);
end;

end.