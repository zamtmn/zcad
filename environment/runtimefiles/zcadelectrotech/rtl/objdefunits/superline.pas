unit superline;
interface
uses system,cables;
var
   NMO_Name:String;(*'Обозначение'*)
   Cable_Mounting_Method:TDCableMountingMethod;(*'Метод монтажа'*)
implementation
begin
   NMO_Name:='??;
   {Cable_Mounting_Method:=TCT_PVCpipe;}
   Cable_Mounting_Method:="-";
end.

