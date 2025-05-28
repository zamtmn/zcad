unit cableelscheme;
interface
uses system,cables;
var
   NMO_Name:String;(*'Обозначение'*)
   isELSchemaCable:Boolean;(*'Кабель на электрической модели'*)
   CABLE_MountingMethod:TDCableMountingMethod;(*'Метод монтажа'*)
   AmountD:Double;(*'Длина'*)
   GC_HeadDevice:String;(*'Головное устройство'*)
   GC_HDGroup:String;(*'Группа в головном устройстве'*)
implementation
begin
   NMO_Name:='??';
   AmountD:=0.0;
   CABLE_MountingMethod:='Не менять!';
   isELSchemaCable:=true;
   GC_HeadDevice:='??';
   GC_HDGroup:='0';
end.
