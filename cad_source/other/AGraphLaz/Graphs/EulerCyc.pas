{ Version 990825. Copyright © Alexey A.Chernobaev, 1996-1999 }

unit EulerCyc;

interface

{$I VCheck.inc}

uses
  ExtType, AttrType, Graphs, Pointerv;

function FindEulerCycle(G: TGraph; FromVertex: TVertex; EdgePath: TClassList): Bool;
{ Находит некоторый эйлеров цикл (цикл, проходящий через каждое ребро графа
  ровно один раз) в графе G (который интерпретируется как неориентированный),
  начиная с вершины FromVertex. Если эйлеров цикл найден, то функция возвращает
  True и помещает в EdgePath ребра графа в той последовательности, в которой они
  входят в цикл; иначе возвращается False.

  Необходимое и достаточное условие существования эйлерова цикла: граф связен и
  степени всех его вершин чётны.

  Агоритм (агоритм Флёри): начиная с вершины FromVertex, проходим по любому
  инцидентному этой вершине ребру и удаляем его, если только удаление этого
  ребра не приведет к разбиению графа на связные компоненты, содержащие более
  чем одну вершину. }

implementation

{$IFDEF NOWARN}{$WARNINGS OFF}{$ENDIF}
function FindEulerCycle(G: TGraph; FromVertex: TVertex; EdgePath: TClassList): Bool;
const
  OriginalIndex = 'iEulerCyc';
var
  I, OriginalIndexOfs: Integer;
  TempGraph: TGraph;
  V, Neighbour: TVertex;
  E: TEdge;
begin
  Result:=False;
  if G.Connected then begin
    for I:=0 to G.VertexCount - 1 do
      if Odd(G.Vertices[I].Degree) then Exit;
    EdgePath.Clear;
    TempGraph:=TGraph.Create;
    try
      TempGraph.AssignSceleton(G);
      OriginalIndexOfs:=TempGraph.CreateEdgeAttr(OriginalIndex, AttrInt32);
      for I:=0 to TempGraph.EdgeCount - 1 do
        TempGraph.Edges[I].AsInt32ByOfs[OriginalIndexOfs]:=I;
      FromVertex:=TempGraph.Vertices[FromVertex.Index];
      V:=FromVertex;
      repeat
        for I:=0 to V.Degree - 1 do begin
          E:=V.IncidentEdge[I];
          Neighbour:=E.OtherVertex(V);
          if (Neighbour.Degree = 1) or E.RingEdge then Break;
        end;
        EdgePath.Add(G.Edges[E.AsInt32ByOfs[OriginalIndexOfs]]);
        E.Free;
        V:=Neighbour;
      until TempGraph.EdgeCount = 0;
      Result:=True;
    finally
      TempGraph.Free;
    end;
  end;
end;
{$IFDEF NOWARN}{$WARNINGS ON}{$ENDIF}

end.
