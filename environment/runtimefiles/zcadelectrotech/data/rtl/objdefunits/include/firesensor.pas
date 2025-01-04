unit firesensor;
interface
uses system,devices;
usescopy objname;
usescopy objmaterial;
usescopy objgroup;
usescopy blocktype;
var
   ANALYSISEM_icanbeheadunit:boolean;(*'Я могу быть ГУ?'*)
   ANALYSISEM_exporttoxlsx:boolean;(*'Экспорт в XLSX для анализа'*)
   Device_Type:TDeviceType;(*'Тип устройства'*) 

   AmountI:Integer;(*'Количество'*)
   
   EL_Cab_AddLength:Double;(*'Добавлять к длине кабеля'*)
implementation
begin
   ANALYSISEM_icanbeheadunit:=false;
   ANALYSISEM_exporttoxlsx:=true;
   BTY_TreeCoord:='PLAN_OPS_PSSENSORS_UNCAT';
   Device_Type:=TDT_SensorPS;
   NMO_Template:='@@[GC_HDShortName]@@[NMO_BaseName]@@[GC_HDGroup].@@[GC_NumberInGroup]';
   EL_Cab_AddLength:=0.5;
   AmountI:=1;


   SerialConnection:=1;
   GC_HeadDevice:='ARK??';
   GC_HDShortName:='??';
   GC_HDGroup:='0';

   ENTID_Type:='OBJT_Devices_OnPlans';
end.
