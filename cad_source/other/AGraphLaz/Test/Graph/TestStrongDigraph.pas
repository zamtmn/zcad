unit TestStrongDigraph;

interface

uses
  ExtType,
  Aliasv,
  Boolv,
  Pointerv,
  PStack,
  Graphs;

procedure Test;

implementation

function StronglyConnected(G: TGraph): Bool;
var
  Counter1, Counter2: Integer;
  SearchNumbers: TIntegerVector;
  InUnfinished: TBoolVector;
  Roots: TClassList;
  Unfinished: TPointerStack;

  function Search(FromVertex: TVertex): Bool;
  var
    I, SearchNumber: Integer;
    V: TVertex;
    E: TEdge;
  begin
    Inc(Counter1);
    SearchNumbers.IncItem(FromVertex.Index, Counter1);
    Unfinished.Push(FromVertex);
    InUnfinished[FromVertex.Index]:=True;
    Roots.Add(FromVertex);
    for I:=0 to FromVertex.Degree - 1 do begin
      E:=FromVertex.IncidentEdge[I];
      if E.V1 = FromVertex then begin
        V:=E.OtherVertex(FromVertex);
        SearchNumber:=SearchNumbers[V.Index];
        if SearchNumber = -1 then
          if not Search(V) then begin
            Result:=False;
            Exit;
          end
          else
        else
          if InUnfinished[V.Index] then
            while SearchNumbers[TVertex(Roots.Last).Index] > SearchNumber do
              Roots.Pop;
      end;
    end; {for}
    if FromVertex = Roots.Last then begin
      repeat
        V:=Unfinished.Pop;
        InUnfinished[V.Index]:=False;
      until FromVertex = V;
      Inc(Counter2);
      if Counter2 > 1 then begin
        Result:=False;
        Exit;
      end;
      Roots.Pop;
    end;
    Result:=True;
  end;

var
  I: Integer;
begin
  Counter1:=0;
  Counter2:=0;
  Result:=True;
  SearchNumbers:=TIntegerVector.Create(G.VertexCount, -1);
  Roots:=TClassList.Create;
  Unfinished:=TPointerStack.Create;
  InUnfinished:=TBoolVector.Create(G.VertexCount, False);
  try
    for I:=0 to G.VertexCount - 1 do
      if SearchNumbers[I] = -1 then
        if not Search(G[I]) then begin
          Result:=False;
          Exit;
        end;
  finally
    SearchNumbers.Free;
    Roots.Free;
    Unfinished.Free;
    InUnfinished.Free;
  end;
end;

procedure Test;
var
  G: TGraph;
begin
  writeln('*** Strong Components ***');
  G:=TGraph.Create;
  try
    G.Features:=[Directed];
    G.AddVertices(5);
    G.AddEdges([0, 1,  1, 1,  0, 3,  0, 4,  1, 2,  1, 3,  1, 4,  2, 0,  3, 2,
      2, 4,  2, 1,  4, 1]);
    writeln('Strongly Connected: ', StronglyConnected(G));
  finally
    G.Free;
  end;
end;

end.
