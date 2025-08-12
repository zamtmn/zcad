unit superline;
interface
uses system,cables;
var
   NMO_Name:String;(*'Обозначение'*)
   CABLE_MountingMethod:TDCableMountingMethod;(*'Метод монтажа'*)
   VSListCable:String;(*'Список кабелей'*)
   VSLMarking:String;(*'Маркировка'*)
   VSLType:String;(*'Тип'*)
   VSLError:String;(*'Ошибка'*)   
implementation
begin
   NMO_Name:='??';
   {Cable_Mounting_Method:=TCT_PVCpipe;}
   CABLE_MountingMethod:='-';
   VSListCable:='';
   VSLMarking:='';
   VSLType:='';
   VSLError:='';   
   
end.

