program GenSimpleGraph;
{ создание простого случайного графа с заданным количеством вершин и ребер }

uses
  SysUtils,
  Graphs,
  ExtGraph,
  GraphIO;

{$APPTYPE CONSOLE}

procedure Main;
var
  G: TGraph;
begin
  G:=TGraph.Create;
  try
    if ParamCount >= 4 then RandSeed:=StrToInt(ParamStr(4))
    else Randomize;
    GetSimpleRandomGraph(G, StrToInt(ParamStr(2)), StrToInt(ParamStr(3)));
    WriteGraphToGMLFile(G, ParamStr(1), False);
  finally
    G.Free;
  end;
end;

begin
  if ParamCount >= 3 then
    Main
  else
    writeln('Usage: gengraph filename vertexcount edgecount [randseed]');
end.
