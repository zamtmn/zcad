unit superline;
interface
uses system,cables;
var
   NMO_Name:String;(*'Обозначение'*)
   CABLE_MountingMethod:TDCableMountingMethod;(*'Метод монтажа'*)
   VSListCable:String;(*'Список кабелей'*)
implementation
begin
   NMO_Name:='??';
   {Cable_Mounting_Method:=TCT_PVCpipe;}
   CABLE_MountingMethod:='-';
   VSListCable:='';
end.

