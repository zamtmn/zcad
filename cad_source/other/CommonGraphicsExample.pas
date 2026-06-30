program CommonGraphicsExample;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Types, SysUtils,
  Interfaces, // this includes the LCL widgetset
  Classes,Graphics,LCLType,LCLIntf,Forms,
  Common.Graphics;

type
  TForm1 = class(TForm)
    procedure FormPaint(Sender: TObject);
  end;

var
  Form1: TForm1;

procedure TForm1.FormPaint(Sender: TObject);
type
  TmyHighlight=specialize THighlight<integer>;
const
  TestString =
    'polylines? [Yes-turn into polyline/No-leave as is] <Yes-turn into polyline>:';
var
  R: TRect;
  Highlight: TmyHighlight;
  Item: TmyHighlight.THighlightItem;
begin
  R := Rect(20, 20, ClientWidth - 20, 45);
  Canvas.Font.Color := clWindowText;
  Canvas.Font.Size := 13;
  DrawText(Canvas.Handle, PChar(TestString), Length(TestString), R, DT_SINGLELINE);

  OffsetRect(R, 0, R.Height);
  Canvas.Brush.Color := clBlack;
  Canvas.FillRect(R);
  Canvas.Font.Color := clWhite;
  Highlight := TmyHighlight.Create;
  try
    // первая буква Y
    Item := Highlight.AddHighlight;
    Item.FontColor := RGB(216, 173, 80);
    Item.Start := 13;
    Item.Len := 1;
    Item.BrushColor := RGB(112, 120, 129);
    Item.UseBrush := True;
    // оставшееся слово "es-turn into polyline"
    Item := Highlight.AddHighlight;
    Item.FontColor := clWhite;
    Item.Start := 14;
    Item.Len := 21;
    Item.BrushColor := RGB(112, 120, 129);
    Item.UseBrush := True;

    // первая буква N
    Item := Highlight.AddHighlight;
    Item.FontColor := RGB(216, 173, 80);
    Item.Start := 36;
    Item.Len := 1;
    Item.BrushColor := RGB(112, 120, 129);
    Item.UseBrush := True;
    // оставшееся слово "o-leave as is"
    Item := Highlight.AddHighlight;
    Item.FontColor := clWhite;
    Item.Start := 37;
    Item.Len := 13;
    Item.BrushColor := RGB(112, 120, 129);
    Item.UseBrush := True;

    // первая буква Y
    Item := Highlight.AddHighlight;
    Item.FontColor := RGB(216, 173, 80);
    Item.Start := 53;
    Item.Len := 1;
    Item.BrushColor := RGB(112, 120, 129);
    Item.UseBrush := True;
    // оставшееся слово "es-turn into polyline"
    Item := Highlight.AddHighlight;
    Item.FontColor := clWhite;
    Item.Start := 54;
    Item.Len := 21;
    Item.BrushColor := RGB(112, 120, 129);
    Item.UseBrush := True;

    specialize DrawHighlitedText<integer>(Canvas, TestString, R, DT_SINGLELINE, Highlight);
  finally
    Highlight.Free;
  end;
end;


begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Form1:=TForm1.CreateNew(Application);
  Form1.OnPaint:=@Form1.FormPaint;
  Form1.Show;
  Application.Run;
end.

