unit cableelscheme;
interface
uses system,cables;
var
   isELSchemaCable:Boolean;(*'Кабель на электрической модели'*)
   CABLE_MountingMethod:TDCableMountingMethod;(*'Метод монтажа'*)
   AmountD:Double;(*'Длина'*)
implementation
begin
   AmountD:=0.0;
   CABLE_MountingMethod:='Не менять!';
   isELSchemaCable:=true;
end.
