unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  Pointerv, Graphs, Steiner;

type
  TForm1 = class(TForm)
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    Button1: TButton;
    Label1: TLabel;
    procedure PaintBox1Paint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    G: TGraph;
    SteinerVertices, SteinerEdges: TClassList;
    DX, DY, NX, NY: Integer;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

const
  Delta = 16;
  PointColor = 0;
  NodeColor = $808000;

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  I, IX, IY: Integer;
  OldColor: TColor;
begin
  for I:=0 to G.VertexCount - 1 do With G.Vertices[I] do
    PaintBox1.Canvas.Pixels[Trunc(X), Trunc(Y)]:=PointColor;
  PaintBox1.Canvas.Pen.Width:=3;
  for I:=0 to SteinerEdges.Count - 1 do With TEdge(SteinerEdges[I]) do begin
    PaintBox1.Canvas.MoveTo(Trunc(V1.X), Trunc(V1.Y));
    PaintBox1.Canvas.LineTo(Trunc(V2.X), Trunc(V2.Y));
  end;
  PaintBox1.Canvas.Pen.Width:=1;
  OldColor:=PaintBox1.Canvas.Brush.Color;
  PaintBox1.Canvas.Brush.Color:=NodeColor;
  for I:=0 to SteinerVertices.Count - 1 do
    With TVertex(SteinerVertices[I]) do begin
      IX:=Trunc(X);
      IY:=Trunc(Y);
      PaintBox1.Canvas.Ellipse(IX - Delta div 2, IY - Delta div 2,
        IX + Delta div 2, IY + Delta div 2);
    end;
  PaintBox1.Canvas.Brush.Color:=OldColor;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  V: TVertex;
  I, J: Integer;
begin
  G:=TGraph.Create;
  G.Features:=[Geom2D, Weighted];
  NX:=PaintBox1.Width div Delta + 1;
  DX:=PaintBox1.Width mod Delta div 2;
  NY:=PaintBox1.Height div Delta + 1;
  DY:=PaintBox1.Height mod Delta div 2;
  G.AddVertices(NX * NY);
  for I:=0 to NY - 1 do
    for J:=0 to NX - 1 do begin
      V:=G.Vertices[I * NX + J];
      V.X:=DX + J * Delta;
      V.Y:=DY + I * Delta;
      if J < NX - 1 then begin
        G.AddEdge(V, G.Vertices[I * NX + J + 1]).Weight:=1;
        if I < NY - 1 then
          G.AddEdge(V, G.Vertices[(I + 1) * NX + J + 1]).Weight:=Sqrt(2);
      end;
      if I < NY - 1 then begin
        G.AddEdge(V, G.Vertices[(I + 1) * NX + J]).Weight:=1;
        if J > 0 then
          G.AddEdge(V, G.Vertices[(I + 1) * NX + J - 1]).Weight:=Sqrt(2);
      end;
    end;
  SteinerVertices:=TClassList.Create;
  SteinerEdges:=TClassList.Create;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  G.Free;
  SteinerVertices.Free;
  SteinerEdges.Free;
end;

procedure TForm1.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  I, Col, Row: Integer;
  V: TVertex;
begin
  Col:=Round((X - DX) / Delta);
  Row:=Round((Y - DY) / Delta);
  if (Col in [0..NX - 1]) and (Row in [0..NY - 1]) then begin
    V:=G.Vertices[Row * NX + Col];
    I:=SteinerVertices.IndexOf(V);
    if I < 0 then SteinerVertices.Add(V) else SteinerVertices.Delete(I);
    Screen.Cursor:=crHourGlass;
    try
      ApproximateSteinerTree(G, SteinerVertices, SteinerEdges);
    finally
      Screen.Cursor:=crDefault;
    end;
    PaintBox1.Invalidate;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if SteinerVertices.Count > 0 then begin
    SteinerVertices.Clear;
    SteinerEdges.Clear;
    PaintBox1.Invalidate;
  end;
end;

end.
