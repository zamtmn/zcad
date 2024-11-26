program bratest;
{$Mode delphi}
uses
  SysUtils,
  PasVulkan.BufferRangeAllocator,
  gzctnrBufferAllocator;
const
  allocs1=1024*512;
  frees1=2;
  allocs2=2*1024*512;
  ctr='Allocs:%d Releares:%d Total:%d (~lines(3*D+3*D):%d) frarmentation:%0.g/%0.g';
type
  TAllArr=array [1..allocs1{+allocs2}] of ptrint;
var
  allarr:TAllArr;
type
  TTestFunc=function(AData:PtrUInt):string;
type
  TBufferAllocator=GBufferAllocator<PtrInt,PtrUInt,Integer>;
  PBufferAllocator=^TBufferAllocator;
function AllN2size(AllN:integer):integer;inline;
begin
  result:=((AllN mod 5)+1)*(sizeof(double)*3);
end;

function pvTpvBufferRangeAllocatorTest(AData:PtrUInt):string;
var
  i:integer;
  allarr:TAllArr;
  allocs,releases,current,total:integer;
  frgm1,frgm2:double;
begin
  allocs:=0;
  releases:=0;
  total:=0;
  for i:=1 to allocs1 do begin
    current:=AllN2size(i);
    allarr[i]:=TpvBufferRangeAllocator(AData).Allocate(current);
    total:=total+current;
    inc(allocs);
  end;
  for i:=1 to allocs1 do begin
    if (i mod frees1)=0 then begin
      current:=AllN2size(i);
      TpvBufferRangeAllocator(AData).Release(allarr[i],current);
      total:=total-current;
      inc(releases);
    end;
  end;
  frgm1:=TpvBufferRangeAllocator(AData).CalculateFragmentationFactor;
  TpvBufferRangeAllocator(AData).Defragment(nil);
  frgm2:=TpvBufferRangeAllocator(AData).CalculateFragmentationFactor;
  for i:=allocs1+1 to allocs1+allocs2 do begin
    current:=AllN2size(i);
    TpvBufferRangeAllocator(AData).Allocate(current);
    total:=total+current;
    inc(allocs);
  end;
  //ba.Defragment(nil);
  Result:=format(ctr,[allocs,releases,total,total div (sizeof(double)*6),frgm1,frgm2]);
end;

function MemAllocTest(AData:PtrUInt):string;
var
  i:integer;
  allarr:TAllArr;
  allocs,releases,current,total:integer;
begin
  allocs:=0;
  releases:=0;
  total:=0;
  for i:=1 to allocs1 do begin
    current:=AllN2size(i);
    pointer(allarr[i]):=getmem(current);
    total:=total+current;
    inc(allocs);
  end;
  for i:=1 to allocs1 do begin
    if (i mod frees1)=0 then begin
      current:=AllN2size(i);
      freemem(pointer(allarr[i]));
      total:=total-current;
      inc(releases);
    end;
  end;
  for i:=allocs1+1 to allocs1+allocs2 do begin
    current:=AllN2size(i);
    getmem(current);
    total:=total+current;
    inc(allocs);
  end;
  Result:=format(ctr,[allocs,releases,total,total div (sizeof(double)*6),0.0,0.0]);
end;

procedure MoveAllocadetRange(const oldI,newI:TBufferAllocator.TIndexInRanges;const AData:TBufferAllocator.TData);
begin
  if AData<>-1 then
     allarr[AData]:=newI;
end;

function BufferAllocatorTest(AData:PtrUInt):string;
var
  i:integer;
  allocs,releases,current,total:integer;
  frgm1,frgm2:double;

begin
  allocs:=0;
  releases:=0;
  total:=0;
  PBufferAllocator(AData).onMoveAllocadetRange:=@MoveAllocadetRange;
  for i:=1 to allocs1 do begin
    current:=AllN2size(i);
    allarr[i]:=PBufferAllocator(AData).Allocate(current,i);
    total:=total+current;
    inc(allocs);
  end;
  for i:=1 to allocs1 do begin
    if (i mod frees1)=0 then begin
      current:=AllN2size(i);
      PBufferAllocator(AData).Release(allarr[i]);
      total:=total-current;
      inc(releases);
    end;
  end;
  frgm1:=PBufferAllocator(AData).CalcFragmentation;
  for i:=allocs1+1 to allocs1+allocs2 do begin
    current:=AllN2size(i);
    PBufferAllocator(AData).Allocate(current,-1);
    total:=total+current;
    inc(allocs);
  end;
  frgm2:=PBufferAllocator(AData).CalcFragmentation;
  //ba.Defragment(nil);
  Result:=format(ctr,[allocs,releases,total,total div (sizeof(double)*6),frgm1,frgm2]);
end;

procedure DoTest(ATestFunc:TTestFunc;AData:PtrUInt;ATestName:string);
var
  TestResult:string;
  LPTime:Tdatetime;
begin
  writeln(ATestName,':');
  LPTime:=now();
  TestResult:=ATestFunc(AData);
  LPTime:=now()-LPTime;
  writeln('  Test result  = ',TestResult);
  writeln('  Time elapsed = '+inttostr(round(lptime*10e7))+'ms');
end;
var
  bra:TpvBufferRangeAllocator;
  ba:TBufferAllocator;
begin
  bra:=TpvBufferRangeAllocator.Create(150*1024*1024);
  DoTest(@pvTpvBufferRangeAllocatorTest,PtrUInt(bra),'TpvBufferRangeAllocator');
  bra.Free;
  DoTest(@MemAllocTest,0,'MemoryAllocator');
  ba.Init(150*1024*1024);
  DoTest(@BufferAllocatorTest,PtrUInt(@ba),'BufferAllocator');
  ba.done;
  readln;
end.

