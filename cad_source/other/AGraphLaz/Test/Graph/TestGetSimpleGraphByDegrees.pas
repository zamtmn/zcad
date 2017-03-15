unit TestGetSimpleGraphByDegrees;

interface

uses
  ExtType,
  Aliasv,
  Graphs,
  ExtGraph,
  GraphIO;

procedure Test;

implementation

procedure Test;
var
  G: TGraph;
  Degrees: TIntegerVector;
  I, J, N: Integer;
  B: Bool;
  S: String;
begin
  G:=TGraph.Create;
  Degrees:=TIntegerVector.Create(0, 0);
  try
    write('Enter number of vertices: ');
    readln(N);
    Degrees.Count:=N;
    write('Enter degrees: ');
    for I:=0 to N - 2 do begin
      read(J);
      Degrees[I]:=J;
    end;
    readln(J);
    Degrees[N - 1]:=J;
    write('GetSimpleGraphByDegrees: ');
    B:=GetSimpleGraphByDegrees(G, Degrees);
    writeln(B);
    if B then begin
      Degrees.Free;
      Degrees:=G.CreateDegreesVector;
      write('Degrees: ');
      Degrees.DebugWrite;
      write('Enter file name: ');
      readln(S);
      WriteGraphToGMLFile(G, S, False);
    end;
  finally
    G.Free;
    Degrees.Free;
  end;
end;

end.