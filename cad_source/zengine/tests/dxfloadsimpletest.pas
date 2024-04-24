unit dxfloadsimpletest;

interface

{define stringdata}

uses
  SysUtils,TypInfo,
  fpcunit,
  testregistry,
  Interfaces,
  uzedrawingsimple,uzeffmanager,uzgldrawcontext,uzbtypes,uzeffdxf,

 uzeent3Dface,uzeentlwpolyline,uzeentpolyline,uzeenttext,uzeentline,
 uzeentcircle,uzeentarc,uzeentmtext,uzeentdimensiongeneric,uzeentdimaligned,
 uzeentdimrotated,uzeentsolid;

type
  TDXFLoadSimpleTest = class(TTestCase)
  Published
    Procedure DXFLoad;
  end;


implementation

procedure TDXFLoadSimpleTest.DXFLoad;
var
  drawing:TSimpleDrawing;
  dc:TDrawContext;
  zdc:TZDrawingContext;
  OldMem,NevMem:Cardinal;
begin
  OldMem:=GetHeapStatus.TotalAllocated;
  drawing.init(nil);
  dc:=drawing.CreateDrawingRC;
  zdc.CreateRec(drawing,drawing.pObjRoot^,TLOLoad,dc);
  addfromdxf('../../../cad/examples/test_dxf/sample_base.dxf',zdc);
  drawing.done;
  NevMem:=GetHeapStatus.TotalAllocated;
  //if (oldmem-nevmem)<>0 then
  //  raise(Exception.CreateFmt('Memory leak : before TotalFree=%d, after TotalFree=%d',[OldMem,NevMem]));
end;

begin
  RegisterTests([TDXFLoadSimpleTest]);
end.

