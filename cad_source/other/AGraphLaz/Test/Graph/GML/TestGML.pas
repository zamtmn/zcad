unit TestGML;

interface

uses
  Graphs, GraphIO;

procedure Test(const FromName, ToName: String);

implementation

procedure Test(const FromName, ToName: String);
var
  G: TGraph;
begin
  G:=CreateGraphFromGMLFile(FromName, True);
  try
    WriteGraphToGMLFile(G, ToName, True);
  finally
    G.Free;
  end;
end;

end.
