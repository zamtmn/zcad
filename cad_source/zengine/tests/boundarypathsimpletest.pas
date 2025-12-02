unit BoundaryPathSimpletest;

interface

{define stringdata}

uses
  SysUtils,TypInfo,
  fpcunit,
  uzeBoundaryPath in '../core/entities/uzeboundarypath',
  UGDBPolyLine2DArray,uzegeometrytypes,
  testregistry,
  math;

const
  MaxVectorLength=10000000;
  InitVectorLength=1;
  NeedSum=49994984640401;

type
  TBoundaryPathSimpleTest = class(TTestCase)
  Published
    Procedure BoundaryPath_BasicOperations;
    Procedure BoundaryPath_Clone;
  end;


implementation

procedure FillPath(var Path:TBoundaryPath);
var
  i,j:integer;
  ppl:PGDBPolyline2DArray;
  v:TzePoint2d;
  sine,cosine:double;
begin
  Path.paths.AllocData(1);
  for i:=0 to 0 do begin
    ppl:=path.paths.getDataMutable(i);
    ppl^.init(10,true);
    for j:=0 to 0 do begin
      SinCos(10*2*pi/(j+1),sine,cosine);
      v.x:=100*cosine/(i+1);
      v.y:=100*sine/(i+1);
      ppl^.PushBackData(v);
    end;
  end;
end;

procedure TBoundaryPathSimpleTest.BoundaryPath_BasicOperations;
var
  Path:TBoundaryPath;
  OldMem,NevMem:Cardinal;
begin
  OldMem:=GetHeapStatus.TotalAllocated;
  Path.init(10);
  FillPath(Path);
  Path.done;
  NevMem:=GetHeapStatus.TotalAllocated;
  if (oldmem-nevmem)<>0 then
    raise(Exception.CreateFmt('Memory leak : before Path.init TotalFree=%d, after Path.done TotalFree=%d',[OldMem,NevMem]));
end;

procedure TBoundaryPathSimpleTest.BoundaryPath_Clone;
var
  Path,Path2:TBoundaryPath;
  OldMem,NevMem:Cardinal;
begin
  OldMem:=GetHeapStatus.TotalAllocated;
  Path.init(10);
  FillPath(Path);
  Path2.init(10);
  Path.CloneTo(Path2);
  Path.done;
  Path2.done;
  NevMem:=GetHeapStatus.TotalAllocated;
  if (oldmem-nevmem)<>0 then
    raise(Exception.CreateFmt('Memory leak : before Path.init TotalFree=%d, after Path.done TotalFree=%d',[OldMem,NevMem]));
end;

begin
  RegisterTests([TBoundaryPathSimpleTest]);
end.

