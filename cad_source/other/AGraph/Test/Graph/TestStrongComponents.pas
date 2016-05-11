unit TestStrongComponents;

interface

uses
  Graphs,
  Aliasv;

procedure Test;

implementation

procedure Test;
var
  G: TGraph;
  ComponentNumbers: TIntegerVector;
  I: Integer;
begin
  writeln('*** Strong Components ***');
  G:=TGraph.Create;
  ComponentNumbers:=TIntegerVector.Create(0, 0);
  try
    G.Features:=[Directed];
    G.AddVertices(5);
    G.AddEdges([0, 1,  0, 1,  0, 3,  0, 4,  1, 2,  1, 3,  1, 4,  3, 2,  2, 4,
      2, 1]);
    I:=G.FindStrongComponents(ComponentNumbers);
    if I <> 3 then begin
      write('Error!');
      readln;
      Exit;
    end;
    writeln('Number of Strong Components: ', I);
    writeln('Component Numbers of Vertices:');
    for I:=0 to ComponentNumbers.Count - 1 do
      write(ComponentNumbers[I], ' ');
    writeln;
  finally
    G.Free;
    ComponentNumbers.Free;
  end;
end;

end.
 
