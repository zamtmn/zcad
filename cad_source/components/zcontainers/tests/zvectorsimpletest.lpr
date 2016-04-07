program zvectorsimpletest;
{$MODE DELPHI}
uses sysutils,TypInfo,uzctnrvectorsimple,gvector,strutils;

const
  MaxVectorLength=10000000;
  InitVectorLength={10000000}1;
 {define stringdata}
type
  TMyTime=TDateTime;

  datatype={$ifndef stringdata}{byte}integer{$else}ansistring{$endif};
function StartTimer:TMyTime;
begin
  result:=now();
end;
function GetElapsedTime(prewtime:TMyTime):Double;
begin
  result:=(now-prewtime)*10e4;
end;
procedure WriteElapsedTime(Time:TMyTime;procname:ansistring);
begin
  writeln(procname,GetElapsedTime(Time):2:3,'sec');
end;
procedure writedata(data:datatype);
begin
  {$ifndef stringdata}
    write(data:2,';')
  {$else}
    data:=PadLeft(data,2);
    write(data,';')
  {$endif};
end;

function CreateValue(n:integer):{$ifndef stringdata}integer{$else}string{$endif};
begin
  result:={$ifndef stringdata}n{$else}inttostr(n){$endif};;
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
    ii:=InegerVector.count;
    if ii<200 then
    begin
    for ii:=0 to InegerVector.count-1 do
     writedata(InegerVector.getData(ii));
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
   data:=CreateValue(i);
   InegerVector.PushBackData(data);
  end;
  WriteElapsedTime(Time,' Time to create and fill ');
  writeresult;
  Time:=StartTimer;
  InegerVector.Invert;
  WriteElapsedTime(Time,' Time to invert ');
  writeresult;

  (*Time:=StartTimer;
  for i:=0 to MaxVectorLength-1 do
    InegerVector.deleteelement({0}InegerVector.count-1);
  WriteElapsedTime(Time,' Time to del all elements ');
  writeresult;*)

  Time:=StartTimer;
  for i:=0 to 100 do
    InegerVector.InsertElement(0,CreateValue(i+100));
  WriteElapsedTime(Time,' Time to insert ');
  writeresult;

  Time:=StartTimer;
  InegerVector.done;
  WriteElapsedTime(Time,' Time to done ');
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

  procedure writeresult;
  var
    ii:integer;
  begin
    i:=InegerVector.Size;
    if i<200 then
    begin
    for ii:=0 to InegerVector.Size-1 do
     writedata(InegerVector.items[ii]);
    writeln;
    end;
  end;
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
   data:=CreateValue(i);
   InegerVector.PushBack(data);
  end;
  WriteElapsedTime(Time,' Time to create and fill ');
  writeresult;

  Time:=StartTimer;
  j:=InegerVector.Size-1;
  for i:=0 to (InegerVector.Size-1)div 2 do
  begin
       tdata:=InegerVector[i];
       InegerVector[i]:=InegerVector[j];
       InegerVector[j]:=tdata;
       dec(j);
  end;
  WriteElapsedTime(Time,' Time to invert ');
  writeresult;

  (*Time:=StartTimer;
  for i:=0 to MaxVectorLength-1 do
  InegerVector.Erase({0}InegerVector.Size-1);
  WriteElapsedTime(Time,' Time to del all elements ');
  writeresult;*)
  Time:=StartTimer;
  for i:=0 to 100 do
    InegerVector.Insert(0,CreateValue(i+100));
  WriteElapsedTime(Time,' Time to insert ');
  writeresult;

  Time:=StartTimer;
  InegerVector.Destroy;
  WriteElapsedTime(Time,' Time to done ');
  writeln('End test');
end;

begin
  TestIntegerGVector;
  //TestIntegerGVector;

  TestIntegerVector;
  //TestIntegerVector;

  TestIntegerGVector;
  //TestIntegerGVector;

  TestIntegerVector;
  //TestIntegerVector;
  readln;
end.

