unit superline;
interface
uses system,cables;
var
   NMO_Name:String;(*'Обозначение'*)
   CABLE_MountingMethod:TDCableMountingMethod;(*'Метод монтажа'*)
implementation
begin
   NMO_Name:='??';
   {Cable_Mounting_Method:=TCT_PVCpipe;}
   CABLE_MountingMethod:='-';
end.

