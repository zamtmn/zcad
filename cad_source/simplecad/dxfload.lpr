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
begin
  drawing.init(nil);
  dc:=drawing.CreateDrawingRC;
  zdc.CreateRec(drawing,drawing.pObjRoot^,TLOLoad,dc);
  addfromdxf(ParamStr(1),zdc);
  drawing.done;
end.

