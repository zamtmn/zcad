unit develscheme;
interface
uses system,cables;
var
   vIsELSchemaDev:Boolean;(*'Устройство на электрической модели'*)
   vEMGCHDGroup:string;(*'Номер группы в головном устройстве'*)
   vSumChildVertex:integer;(*'Сумма подчиненых вершин'*)
implementation
begin
   vSumChildVertex:=0;
   vEMGCHDGroup:='0';
   vIsELSchemaDev:=true;
end.
