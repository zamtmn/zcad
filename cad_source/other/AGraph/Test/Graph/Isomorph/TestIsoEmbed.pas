unit TestIsoEmbed;

interface

uses
  ExtType, AttrSet, Aliasv, Graphs, GraphIO, Pointerv, ExtGraph, Isomorph;

procedure Test(const Name1, Name2: String; rep_count: Integer; FindAll, ShowMatch: Boolean);

implementation

uses Windows;

var
  SubG, G: TGraph;
  FShowMatch: Bool;

function MyVisitor(n: Integer; IsomorphousMap: TIntegerVector): Bool;
var
  I: Integer;
begin
  if FShowMatch then begin
    writeln(n);
    for I:=0 to SubG.VertexCount - 1 do
      write('(', I, ',', IsomorphousMap[I], ') ');
    writeln;
  end
  else
    write(n, #13);
  {$IFDEF CHECK}
  write('Checking... ');
  if G.HasLoops or SubG.HasLoops or G.HasParallelEdges or SubG.HasParallelEdges then
    writeln('There are loops and/or parallel edges - can''t check')
  else
    if not CheckEmbedding(SubG, G, IsomorphousMap, CompareUserSets, CompareUserSets)
    then begin
      write('Error!');
      readln;
    end
    else
      writeln('Ok');
  {$ENDIF}
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
  SubG:=nil;
  G:=nil;
  IsomorphousMap:=TIntegerVector.Create(0, 0);
  try
    SubG:=CreateGraphFromGMLFile(Name1, True);
    G:=CreateGraphFromGMLFile(Name2, True);
    if FindAll then begin
      StartTime:=GetTickCount;
      for I:=1 to rep_count do
        N:=FindEmbeddings(SubG, G, @MyVisitor, CompareUserSets, CompareUserSets);
      writeln('Time: ', Abs(GetTickCount - StartTime) / 1000 :4:2, ' s');
      writeln('Found ', N, ' embeddings');
    end
    else begin
      StartTime:=GetTickCount;
      for I:=1 to rep_count do
        b:=FindEmbedding(SubG, G, IsomorphousMap, CompareUserSets, CompareUserSets);
      writeln('Time: ', Abs(GetTickCount - StartTime) / 1000 :4:2, ' s');
      if b then begin
        writeln('Isomorphic embedding found');
        if b and ShowMatch then
          for I:=0 to SubG.VertexCount - 1 do
            write('(', I, ',', IsomorphousMap[I], ') ');
      end
      else
        writeln('No embeddings found');
    end;
    writeln;
  finally
    SubG.Free;
    G.Free;
    IsomorphousMap.Free;
  end;
end;
{$WARNINGS ON}

end.
