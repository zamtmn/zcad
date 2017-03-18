program GraphTestMinWeightPath2;

{$MODE Delphi}

uses
  SysUtils,
  TestMinWeightPath2;

{$APPTYPE CONSOLE}

var
  NumVertices, NumEdges: Integer;
begin
  if ParamCount > 0 then NumVertices:=StrToInt(ParamStr(1)) else NumVertices:=100;
  if ParamCount > 1 then NumEdges:=StrToInt(ParamStr(2)) else NumEdges:=200;
  if ParamCount > 2 then RandSeed:=StrToInt(ParamStr(3)) else Randomize;
  Test(NumVertices, NumEdges);
end.
