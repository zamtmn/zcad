program zvectorsimpletest;
{$MODE DELPHI}
uses sysutils,TypInfo,uzctnrvectorsimple,gvector;

const
  MaxVectorLength=10000000;
  InitVectorLength={10000000}1;
type
  TMyTime=TDateTime;

  datatype={byte}{integer}ansistring;
var
  typi:pointer;
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
  TZInegerVector=TZctnrVectorSimple<datatype>;
var
  InegerVector:TZInegerVector;
  i:integer;
  data:datatype;
  Time:TMyTime;
  pti:PTypeInfo;

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
  writeln('Start test for TZctnrVectorSimple');
  pti:=TypeInfo(datatype);
  writeln(' Specialized by ',pti^.Name);
  writeln(' SizeOf=',sizeof(TZInegerVector));
  writeln(' MaxVectorLength=',MaxVectorLength);
  writeln(' InitVectorLength=',InitVectorLength);

  Time:=StartTimer;
  InegerVector.init(InitVectorLength);

  for i:=0 to MaxVectorLength-1 do
  begin
   data:=CreateValues(i);
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
  TZInegerVector=Tvector<datatype>;
var
  InegerVector:TZInegerVector;
  i,j:integer;
  data:datatype;
  Time:TMyTime;
  pti:PTypeInfo;
  tdata:datatype;
begin
  writeln('Start test for gvector.TVector');
  pti:=TypeInfo(datatype);
  writeln(' Specialized by ',pti^.Name);
  writeln(' InstanceSize=',TZInegerVector.InstanceSize);
  writeln(' MaxVectorLength=',MaxVectorLength);
  writeln(' InitVectorLength=',InitVectorLength);
  Time:=StartTimer;
  InegerVector:=TZInegerVector.Create;

  for i:=0 to MaxVectorLength-1 do
  begin
   data:=CreateValues(i);
   InegerVector.PushBack(data);
  end;
  Writeln(' Time to create and fill ',GetElapsedTime(Time):2:3,'sec');

  Time:=StartTimer;
  j:=InegerVector.Size-1;
  for i:=0 to (InegerVector.Size-1)div 2 do
  begin
       tdata:=InegerVector[i];
       InegerVector[i]:=InegerVector[j];
       InegerVector[j]:=tdata;
  end;
  Writeln(' Time to invert ',GetElapsedTime(Time):2:3,'sec');

  //writeresult;

  Time:=StartTimer;
  InegerVector.Destroy;
  Writeln(' Time to done ',GetElapsedTime(Time):2:3,'sec');
  writeln('End test');
end;

begin
  TestIntegerGVector;
  TestIntegerGVector;

  TestIntegerVector;
  TestIntegerVector;
  readln;
end.

