program zvectorsimpletest;
{$MODE DELPHI}
uses sysutils,TypInfo,uzctnrvectorsimple,gvector;

const
  MaxVectorLength=10000000;
  InitVectorLength={10000000}1;
type
  TMyTime=TDateTime;
function StartTimer:TMyTime;
begin
  result:=now();
end;
function GetElapsedTime(prewtime:TMyTime):Double;
begin
  result:=(now-prewtime)*10e4;
end;
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
  datatype=integer{ansistring};
  TZInegerVector=TZctnrVectorSimple<datatype>;
var
  InegerVector:TZInegerVector;
  i:integer;
  TypeData :PTypeData;
  TypeInfo :PTypeInfo;
  data:datatype;
  Time:TMyTime;

  procedure writeresult;
  var
    ii:integer;
  begin
    if InegerVector.count<200 then
    begin
    for ii:=0 to MaxVectorLength-1 do
     write(InegerVector.getData(ii),';');
    writeln;
    end;
  end;

begin
  writeln('Start test');
  writeln(' MaxVectorLength=',MaxVectorLength);
  writeln(' InitVectorLength=',InitVectorLength);
  Time:=StartTimer;
  InegerVector.init(InitVectorLength);

  for i:=0 to MaxVectorLength-1 do
  begin
   data:=CreateValue(i);
   InegerVector.PushBackData(data);
  end;
  Writeln(' Time to create and fill ',GetElapsedTime(Time):2:3,'sec');
  writeresult;
  Time:=StartTimer;
  InegerVector.Invert;
  Writeln(' Time to invert ',GetElapsedTime(Time):2:3,'sec');

  writeresult;

  Time:=StartTimer;
  InegerVector.done;
  Writeln(' Time to done ',GetElapsedTime(Time):2:3,'sec');
  writeln('End test');
end;

procedure TestIntegerGVector;
type
  datatype=integer{ansistring};
  TZInegerVector=Tvector<datatype>;
var
  InegerVector:TZInegerVector;
  i:integer;
  TypeData :PTypeData;
  TypeInfo :PTypeInfo;
  data:datatype;
  Time:TMyTime;
begin
  writeln('Start test');
  writeln(' MaxVectorLength=',MaxVectorLength);
  writeln(' InitVectorLength=',InitVectorLength);
  Time:=StartTimer;
  InegerVector:=TZInegerVector.Create;

  for i:=0 to MaxVectorLength-1 do
  begin
   data:=CreateValue(i);
   InegerVector.PushBack(data);
  end;
  Writeln(' Time to create and fill ',GetElapsedTime(Time):2:3,'sec');
  //writeresult;
  //Time:=StartTimer;
  //InegerVector.Invert;
  //Writeln(' Time to invert ',GetElapsedTime(Time):2:3,'sec');

  //writeresult;

  Time:=StartTimer;
  InegerVector.Destroy;
  Writeln(' Time to done ',GetElapsedTime(Time):2:3,'sec');
  writeln('End test');
end;

begin
  TestIntegerVector;
  TestIntegerVector;
  TestIntegerGVector;
  TestIntegerGVector;
  readln;
end.

