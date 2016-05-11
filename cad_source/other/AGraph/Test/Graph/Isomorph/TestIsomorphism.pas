unit TestIsomorphism;

interface

uses
  ExtType, AttrSet, Aliasv, Graphs, GraphIO, Isomorph, Pointerv;

procedure Test(const Name1, Name2: String; rep_count: Integer; FindAll, ShowMatch: Boolean);

implementation

uses Windows;

var
  G1, G2: TGraph;
  FShowMatch: Bool;

function MyVisitor(n: Integer; IsomorphousMap: TIntegerVector): Bool;
var
  I: Integer;
begin
  if FShowMatch then begin
    writeln(n);
    for I:=0 to G1.VertexCount - 1 do
      write('(', I, ',', IsomorphousMap[I], ') ');
    writeln;
  end
  else
    write(n, #13);
  Result:=False;
end;

{$WARNINGS OFF}
procedure Test(const Name1, Name2: String; rep_count: Integer; FindAll, ShowMatch: Boolean);
var
  IsomorphousMap: TIntegerVector;
  I, N, StartTime: Integer;
  b: Bool;
begin
  FShowMatch:=ShowMatch;
  if rep_count < 1 then rep_count:=1;
  if rep_count > 1 then writeln('Repeat count: ', rep_count);
  G1:=nil;
  G2:=nil;
  IsomorphousMap:=TIntegerVector.Create(0, 0);
  try
    G1:=CreateGraphFromGMLFile(Name1, True);
    G2:=CreateGraphFromGMLFile(Name2, True);
    if FindAll then begin
      StartTime:=GetTickCount;
      for I:=1 to rep_count do
        N:=FindMatches(g1, g2, @MyVisitor, CompareUserSets, CompareUserSets);
      writeln('Time: ', Abs(GetTickCount - StartTime) / 1000 :4:2, ' s');
      writeln('Found ', N, ' matches');
    end
    else begin
      StartTime:=GetTickCount;
      for I:=1 to rep_count do
        b:=FindMatch(G1, G2, IsomorphousMap, CompareUserSets, CompareUserSets);
      writeln('Time: ', Abs(GetTickCount - StartTime) / 1000 :4:2, ' s');
      if b then begin
        writeln('Isomorphism found');
        write('Checking... ');
        b:=G1.EqualToGraph(G2, IsomorphousMap, CompareUserSets, CompareUserSets);
        writeln(b);
        ExitCode:=Ord(not b);
        if b and ShowMatch then
          for I:=0 to G1.VertexCount - 1 do
            write('(', I, ',', IsomorphousMap[I], ') ');
      end
      else
        writeln('No isomorphism found');
    end;
    writeln;
  finally
    G1.Free;
    G2.Free;
    IsomorphousMap.Free;
  end;
end;
{$WARNINGS ON}

end.
