unit TestFundamentalRings;

interface

uses
  MultiLst,
  Pointerv,
  Graphs;

procedure Test;

implementation

procedure Test;
var
  G: TGraph;
  M: TMultiList;

  procedure ShowRings;
  var
    I, J: Integer;
  begin
    writeln('Cyclomatic Number: ', G.CyclomaticNumber);
    writeln('Fundamental Rings: ', M.Count, #10);
    for I:=0 to M.Count - 1 do begin
      writeln('Ring: ', Succ(I));
      for J:=0 to M[I].Count - 1 do With TEdge(M[I][J]) do
        write('(', V1.Index, ',', V2.Index, ') ');
      writeln;
    end;
    if M.Count > 0 then writeln;
  end;

  procedure FindRings(N: Integer);
  begin
    if N <> G.FindFundamentalRings(M) then begin
      write('Error!');
      readln;
    end;
  end;

begin
  writeln('*** Fundamental Rings ***'#10);
  G:=TGraph.Create;
  M:=TMultiList.Create(TClassList);
  try
    G.AddVertices(19);
    G.AddEdges([1, 2,  2, 3,  2, 7,  3, 4,  4, 5,  5, 6,  5, 8,  6, 7,
      6, 14,  8, 9,  8, 13,  13, 14,  9, 10,  10, 11,  11, 12,  11, 16,
      12, 13,  12, 15,  16, 17,  16, 18,  0, 17]);
    FindRings(3);
    ShowRings;
    G.Features:=[Directed]; { не влияет на результат }
    FindRings(3);
    G.Clear;
    G.AddVertices(9);
    G.AddEdges([0, 1,  0, 3,  1, 2,  1, 4,  2, 5,  3, 4,  3, 6,  4, 5,  4, 7,
      5, 8,  6, 7,  7, 8]);
    FindRings(4);
    ShowRings;
  finally
    G.Free;
    M.Free;
  end;
end;

end.