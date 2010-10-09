unit DrawingVars;
uses system;
interface
var
   camera:GDBObjCamera;
   DWGProps:TDWGProps;

   Developer:GDBString;

implementation
begin
     camera.initnul;
     camera.fovy:=35.0;
     camera.point.x:=0.0;
     camera.point.y:=0.0;
     camera.point.z:=-500.0;
     camera.look.x:=0.0;
     camera.look.y:=0.0;
     camera.look.z:=-1.0;
     camera.ydir.x:=0.0;
     camera.ydir.y:=1.0;
     camera.ydir.z:=0.0;
     camera.xdir.x:=-1.0;
     camera.xdir.y:=0.0;
     camera.xdir.z:=0.0;
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
