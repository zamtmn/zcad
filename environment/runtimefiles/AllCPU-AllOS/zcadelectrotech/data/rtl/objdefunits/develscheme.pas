unit develscheme;
interface
uses system,cables;
var
   vIsELSchemaDev:Boolean;(*'Устройство на электрической модели'*)
   vEMGCHeadDevice:string;(*'Имя ГУ к которому сейчас подключается устройство'*)
   vEMGCHDGroup:string;(*'Номер группы в головном устройстве'*)
   vEMGCvelecNumConnectDevice:integer;(*'Номер подключения внутри устройства'*)   
   vSumChildVertex:integer;(*'Сумма подчиненых вершин'*)
   ANALYSISEM_exporttoxlsx:boolean;(*'Экспорт в XLSX для анализа'*)   
implementation
begin
   vSumChildVertex:=0;
   vEMGCHeadDevice:='?NOT?';
   vEMGCHDGroup:='0';
   vEMGCvelecNumConnectDevice:=-1;
   vIsELSchemaDev:=true;
   ANALYSISEM_exporttoxlsx:=false;
end.
