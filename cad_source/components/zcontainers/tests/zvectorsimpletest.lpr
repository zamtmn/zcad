program zvectorsimpletest;
{$MODE DELPHI}
uses sysutils,TypInfo,uzctnrvectorsimple;

const
  MaxVectorLength=1000000;
  InitVectorLength=10;

function CreateValue(n:integer):integer;overload;
begin
  result:=n;
end;
function CreateValueS(n:integer):ansistring;overload;
begin
  result:=inttostr(n);
end;

procedure TestIntegerVector;
type
  datatype={integer}ansistring;
  TZInegerVector=TZctnrVectorSimple<datatype>;
var
  InegerVector:TZInegerVector;
  i:integer;
  TypeData :PTypeData;
  TypeInfo :PTypeInfo;
  data:datatype;

  procedure writeresult;
  var
    ii:integer;
  begin
    if InegerVector.count<200 then
    for ii:=0 to MaxVectorLength-1 do
     write(InegerVector.getData(ii),';');
    writeln;
  end;

begin
  writeln('Start test');
  InegerVector.init(InitVectorLength);

  for i:=0 to MaxVectorLength-1 do
  begin
   data:=CreateValues(i);
   InegerVector.PushBackData(data);
  end;

  writeresult;
  InegerVector.Invert;

  writeresult;

  InegerVector.done;
  writeln('End test');
end;

begin
  TestIntegerVector;
  readln;
end.

