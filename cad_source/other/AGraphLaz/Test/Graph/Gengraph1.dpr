program Gengraph1;
{
  Создание случайного графа, количество вершин и ребер в котором не превосходит
  заданных значений.
}

uses
  SysUtils,
  Graphs,
  ExtGraph,
  GraphIO,
  Windows;

{$APPTYPE CONSOLE}

procedure Main;
var
  G: TGraph;
begin
  G:=TGraph.Create;
  try
    if ParamCount >= 4 then RandSeed:=StrToInt(ParamStr(4)) else Randomize;
    GetRandomGraph(G,
      Random(StrToInt(ParamStr(2))) + 1,
      Random(StrToInt(ParamStr(3))) + 1);
    WriteGraphToGMLFile(G, ParamStr(1), False);
  finally
    G.Free;
  end;
end;

begin
  if ParamCount >= 3 then
    Main
  else
    writeln('Usage: gengraph1 filename maxvertexcount maxedgecount [randseed]');
end.
