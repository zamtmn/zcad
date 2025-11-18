unit DrawingVars;
uses system;
interface
var
   camera:GDBObjCamera;
   //DWGProps:TDWGProps;

   DWG_CLayer:PGDBLayerProp;
   DWG_CLinew:TGDBLineWeight;
   DWG_CColor:Integer;
   DWG_CLType:PGDBLtypeProp;
   DWG_CTStyle:PGDBTextStyle;
   DWG_CLTScale:Double;
   DWG_CDimStyle:PGDBDimStyle;

   DWG_DrawGrid:Boolean;{определена в коде}
   DWG_SnapGrid:Boolean;{определена в коде}
   DWG_DrawMode:Boolean;{определена в коде}

   DWG_Snap:GDBSnap2D;
   DWG_GridSpacing:TzePoint2d;

   DWG_LTScale:Double;

   DWG_LUnits:TLUnits;
   DWG_LUPrec:TUPrec;
   DWG_AUnits:TAUnits;
   DWG_AUPrec:TUPrec;
   DWG_AngDir:TAngDir;
   DWG_AngBase:GDBAngleDegDouble;
   DWG_UnitMode:TUnitMode;
   DWG_InsUnits:TInsUnits;

   DWG_TextSize:Double;


   Developer:String;

implementation
begin
  DWG_DrawMode:=False;

  DWG_CLayer:=0;
  DWG_CLinew:=-1;
  DWG_CColor:=256;
  DWG_CLType:=0;
  DWG_CDimStyle:=0;

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

     DWG_LTScale:=1;
     DWG_CLTScale:=1;

    DWG_LUnits:=LUDecimal;
    DWG_LUPrec:=UPrec4;
    DWG_AUnits:=AUDecimalDegrees;
    DWG_AUPrec:=UPrec0;
    DWG_AngDir:=ADCounterClockwise;
    DWG_AngBase:=0;
    DWG_UnitMode:=UMWithSpaces;
    DWG_InsUnits:=IUUnspecified;

    DWG_TextSize:=2.5;

    Developer:='Зубарев';
end.
