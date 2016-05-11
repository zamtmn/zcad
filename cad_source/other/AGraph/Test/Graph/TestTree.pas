unit TestTree;

interface

uses
  AttrType,
  AttrSet,
  Pointerv,
  Graphs;

procedure Test;

implementation

procedure Test;
var
  G: TGraph;
  VertexPath: TClassList;

  procedure ShowPath(const CorrectPath: array of Integer);
  var
    I: Integer;
  begin
    for I:=0 to VertexPath.Count - 1 do
      if TVertex(VertexPath[I]).Index <> CorrectPath[I] then begin
        write('Error!');
        readln;
        Exit;
      end;
    for I:=0 to VertexPath.Count - 1 do
      write(TVertex(VertexPath[I]).Index, ' ');
    writeln;
  end;

begin
  writeln('*** Tree ***');
  G:=TGraph.Create;
  VertexPath:=TClassList.Create;
  try
    G.Features:=[Tree];
    G.CreateVertexAttr('t', AttrBool);
    G.Root:=G.AddVertex;
    With G.Root do begin
      With AddChild do begin
        With AddChild do begin
          AddChild.AsBool['t']:=True;
          AddChild;
        end;
        AddChild;
        AddChild.AddChild;
      end;
      AddChild;
    end;
    G.TreeTraversal(G.Root, VertexPath);
    ShowPath([0, 1, 2, 3, 4, 5, 6, 7, 8]);
    G.ArrangeTree(G.Root, TAttrSet.CompareUser, TAttrSet.CompareUser);
    G.TreeTraversal(G.Root, VertexPath);
    ShowPath([0, 8, 1, 5, 6, 7, 2, 4, 3]);
  finally
    G.Free;
    VertexPath.Free;
  end;
end;

end.
