program dxfload;
uses
 SysUtils,Interfaces,
 uzedrawingsimple,uzeffmanager,uzgldrawcontext,uzbtypes,uzeffdxf,

 uzeent3Dface,uzeentlwpolyline,uzeentpolyline,uzeenttext,uzeentline,
 uzeentcircle,uzeentarc,uzeentmtext,uzeentdimensiongeneric,uzeentdimaligned,
 uzeentdimrotated,uzeentsolid;

var
  drawing:TSimpleDrawing;
  dc:TDrawContext;
  zdc:TZDrawingContext;
  filename:string='../../../cad/examples/test_dxf/sample_base.dxf';
begin
  drawing.init(nil);
  dc:=drawing.CreateDrawingRC;
  zdc.CreateRec(drawing,drawing.pObjRoot^,TLOLoad,dc);
  if ParamStr(1)<>''then
    filename:=ParamStr(1);
  addfromdxf(filename,zdc);
  drawing.done;
end.

