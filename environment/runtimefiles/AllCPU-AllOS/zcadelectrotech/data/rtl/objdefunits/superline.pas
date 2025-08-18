unit superline;
interface
uses system,cables;
var
   NMO_Name:String;(*'Обозначение'*)
   CABLE_MountingMethod:TDCableMountingMethod;(*'Метод монтажа'*)
   CABLE_VSListCable:String;(*'Список кабелей'*)
   CABLE_VSLMarking:String;(*'Маркировка'*)
   CABLE_VSLType:String;(*'Тип'*)
   CABLE_VSLError:String;(*'Ошибка'*)   
implementation
begin
   NMO_Name:='??';
   {Cable_Mounting_Method:=TCT_PVCpipe;}
   CABLE_MountingMethod:='-';
   CABLE_VSListCable:='';
   CABLE_VSLMarking:='';
   CABLE_VSLType:='';
   CABLE_VSLError:='';   
   
end.

