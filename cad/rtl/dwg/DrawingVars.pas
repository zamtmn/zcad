unit DrawingVars;
uses system;
interface
var
   camera:GDBObjCamera;
   DWGProps:TDWGProps;

   DWG_CLayer:GDBInteger;
   DWG_CLinew:GDBInteger;

   DWG_DrawGrid:GDBBoolean;
   DWG_SnapGrid:GDBBoolean;
   DWG_DrawMode:GDBInteger;

  DWG_StepGrid:GDBvertex2D;
  DWG_OriginGrid:GDBvertex2D;


   Developer:GDBString;

implementation
begin

  DWG_StepGrid.x:=0.5;
  DWG_StepGrid.y:=0.5;
  DWG_OriginGrid.x:=0.0;
  DWG_OriginGrid.y:=0.0;
  DWG_DrawMode:=0;


  DWG_CLayer:=0;
  DWG_CLinew:=-1;

     camera.initnul;
     camera.fovy:=35.0;
     camera.prop.point.x:=0.0;
     camera.prop.point.y:=0.0;
     camera.prop.point.z:=-500.0;
     camera.prop.look.x:=0.0;
     camera.prop.look.y:=0.0;
     camera.prop.look.z:=-1.0;
     camera.prop.ydir.x:=0.0;
     camera.prop.ydir.y:=1.0;
     camera.prop.ydir.z:=0.0;
     camera.prop.xdir.x:=-1.0;
     camera.prop.xdir.y:=0.0;
     camera.prop.xdir.z:=0.0;
     camera.prop.zoom:=0.1;
     camera.anglx:=-3.14159265359;
     camera.angly:=-1.570796326795;
     camera.zmin:=1.0;
     camera.zmax:=100000.0;
     camera.fovy:=35.0;
     camera.notuseLCS:=False;

     DWGProps.Name:='Схема электрическая принципиальная';
     DWGProps.Number:=100;

     Developer:='Зубарев';
end.
