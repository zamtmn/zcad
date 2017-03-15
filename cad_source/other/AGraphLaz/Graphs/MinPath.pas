{ Version 000602. Copyright © Alexey A.Chernobaev, 1996-2000 }

unit MinPath;

interface

{$I VCheck.inc}

uses
  ExtType, Aliasv, F64v, Boolv, Pointerv, PStack, Graphs, VectErr;

function MinSimplePath(G: TGraph; FromVertex, ToVertex: TVertex;
  EdgePath: TClassList): Float;
{
  Находит простой путь минимального суммарного веса между заданными вершинами
  графа; допускаются отрицательные веса ребер (дуг); возвращает суммарный вес
  найденного пути или MaxFloat, если путь не существует; если EdgePath <> nil,
  то в EdgePath помещаются указатели на ребра, по которым проходит путь; граф
  интерпретируется как ориентированный или неориентированный в зависимости от
  Features; сложность алгоритма в худшем случае экспоненциальная.
}

implementation

function MinSimplePath(G: TGraph; FromVertex, ToVertex: TVertex;
  EdgePath: TClassList): Float;
var
  HiddenEdges: TClassList;

  function FindPath(V1, V2: TVertex; NegativeCount: Integer; BestPath: TClassList): Float;
  var
    I, J, N, HiddenCount: Integer;
    T: Float;
    E: TEdge;
    CurrentPath: TClassList;
    Weights: TFloatVector;
  begin
    if V2 <> V1 then
      if NegativeCount = 0 then
        Result:=G.FindMinWeightPath(V1, V2, BestPath)
      else begin
        Result:=MaxFloat;
        if G.FindMinPath(V1, V2, nil) < 0 then Exit;
        Weights:=nil;
        N:=V2.Degree;
        J:=0;
        HiddenCount:=0;
        try
          { "скрываем" ребра, инцидентные V2 }
          { hide incident edges }
          for I:=N - 1 downto 0 do begin
            E:=V2.IncidentEdge[I];
            if not (Directed in G.Features) or (V2 = E.V2) then begin
              T:=E.Weight;
              if T < 0 then Dec(NegativeCount);
              if Weights = nil then Weights:=TFloatVector.Create(N, 0);
              Weights[J]:=T;
              Inc(J);
              HiddenEdges.Add(E);
              Inc(HiddenCount);
              E.Hide;
            end;
          end; {for}
          if HiddenCount = 0 then Exit;
          { ищем рекурсивно пути и выбираем минимальный }
          { find paths recursively and select minimum }
          if BestPath <> nil then
            CurrentPath:=TClassList.Create
          else
            CurrentPath:=nil;
          try
            J:=0;
            for I:=HiddenEdges.Count - HiddenCount to HiddenEdges.Count - 1 do begin
              E:=HiddenEdges[I];
              T:=FindPath(V1, E.OtherVertex(V2), NegativeCount, CurrentPath);
              if T <> MaxFloat then begin
                T:=T + Weights[J];
                if T < Result then begin
                  if BestPath <> nil then begin
                    BestPath.Assign(CurrentPath);
                    BestPath.Add(E);
                  end;
                  Result:=T;
                end;
              end;
              Inc(J);
            end; {for}
            { восстанавливаем "скрытые" ребра }
            { restore hidden edges }
            for I:=HiddenEdges.Count - 1 downto HiddenEdges.Count - HiddenCount do
              TEdge(HiddenEdges[I]).Restore;
            HiddenEdges.Count:=HiddenEdges.Count - HiddenCount;
          finally
            CurrentPath.Free;
          end;
        finally
          Weights.Free;
        end;
      end
    else
      Result:=0;
  end;

var
  I, NegativeCount: Integer;
  Loops: TClassList;
begin
  if EdgePath <> nil then EdgePath.Clear;
  Loops:=TClassList.Create;
  try
    G.HideLoops(Loops);
    HiddenEdges:=nil;
    try
      HiddenEdges:=TClassList.Create;
      NegativeCount:=0;
      for I:=0 to G.EdgeCount - 1 do
        if TEdge(G.Edges[I]).Weight < 0 then Inc(NegativeCount);
      Result:=FindPath(FromVertex, ToVertex, NegativeCount, EdgePath);
    finally
      G.RestoreLoops(Loops);
      HiddenEdges.Free;
    end;
  finally
    Loops.Free;
  end;
end;

end.
