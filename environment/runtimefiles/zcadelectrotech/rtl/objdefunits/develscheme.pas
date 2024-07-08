unit develscheme;
interface
uses system,cables;
var
   vIsELSchemaDev:Boolean;(*'Устройство на электрической модели'*)
   vEMGCHDGroup:string;(*'Номер группы в головном устройстве'*)
   vSumChildVertex:integer;(*'Сумма подчиненых вершин'*)
   ANALYSISEM_exporttoxlsx:boolean;(*'Экспорт в XLSX для анализа'*)   
implementation
begin
   vSumChildVertex:=0;
   vEMGCHDGroup:='0';
   vIsELSchemaDev:=true;
   ANALYSISEM_exporttoxlsx:=false;
end.
