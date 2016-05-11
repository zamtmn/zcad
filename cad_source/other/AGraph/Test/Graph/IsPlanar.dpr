program IsPlanar;
{
  Определение планарности графа.
}

{$APPTYPE CONSOLE}

uses
  Graphs, Planar;

procedure ReadGraph(G: TGraph);
var
  N, N1, N2: Integer;
begin
  readln(N);
  G.AddVertices(N);
  while not Eof do begin
    readln(N1, N2);
    if (N1 < 1) or (N1 > N) or (N2 < 1) or (N2 > N) then begin
      writeln('Illegal data');
      Halt(2);
    end;
    G.AddEdgeI(N1 - 1, N2 - 1);
  end;
end;

procedure Main;
var
  G: TGraph;
begin
  G:=TGraph.Create;
  try
    ReadGraph(G);
    if not G.Connected then
      writeln('Warning: graph is not connected.');
    if PlanarGraph(G) then begin
      writeln('Graph is planar.');
      ExitCode:=1;
    end
    else
      writeln('Graph is not planar.');
  finally
    G.Free;
  end;
end;

begin
  Main;
end.
