unit xlsxgenerator;
interface
uses system,devices;
var
   ANALYSISEM_icanbeheadunit:boolean;(*'Я могу быть ГУ?'*)
   ANALYSISEM_exporttoxlsx:boolean;(*'Экспорт в XLSX для анализа'*)
   nametemplatesxlsx:String;(*'Имя шаблон в XLSX, для заполнения'*)
implementation
begin
   ANALYSISEM_icanbeheadunit:=false;
   ANALYSISEM_exporttoxlsx:=true;
   nametemplatesxlsx:='-';
end.
