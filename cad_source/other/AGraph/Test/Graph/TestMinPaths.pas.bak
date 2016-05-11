unit TestMinPaths;

interface

uses
  Graphs,
  MultiLst,
  Pointerv;

procedure Test;

implementation

procedure Test;
var
  G: TGraph;
  EdgePaths: TMultiList;
  E: TEdge;
  I, J: Integer;
begin
  writeln('*** Min Path ***');
  G:=TGraph.Create;
  EdgePaths:=TMultiList.Create(TClassList);
  try
    G.Features:=[Directed];
    G.AddVertices(5);
    G.AddEdges([0, 1,  0, 1,  0, 3,  0, 4,  1, 2,  1, 3,  1, 4,  3, 2,  2, 4]);
    I:=G.FindMinPaths(G[0], G[2], 0, EdgePaths);
    if I <> 3 then begin
      write('Error!');
      readln;
      Exit;
    end;
    writeln('Number of Min Paths: ', I);
    writeln('Paths:');
    for I:=0 to EdgePaths.Count - 1 do With EdgePaths[I] do begin
      for J:=0 to Count - 1 do begin
        E:=TEdge(Items[J]);
        write('(', E.V1.Index, ', ', E.V2.Index, ') ');
      end;
      writeln;
    end;
  finally
    G.Free;
    EdgePaths.Free;
  end;
end;

end.
 
