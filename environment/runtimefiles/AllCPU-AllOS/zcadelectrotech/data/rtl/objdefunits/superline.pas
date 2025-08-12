unit superline;
interface
uses system,cables;
var
   NMO_Name:String;(*'Обозначение'*)
   CABLE_MountingMethod:TDCableMountingMethod;(*'Метод монтажа'*)
   VSListCable:String;(*'Список кабелей'*)
   OTHER_VSLMarking:String;(*'Маркировка'*)
   OTHER_VSLType:String;(*'Тип'*)
   OTHER_VSLError:String;(*'Ошибка'*)   
implementation
begin
   NMO_Name:='??';
   {Cable_Mounting_Method:=TCT_PVCpipe;}
   CABLE_MountingMethod:='-';
   VSListCable:='';
   OTHER_VSLMarking:='';
   OTHER_VSLType:='';
   OTHER_VSLError:='';   
   
end.

