unit elreceivers;
interface
uses system,devices;
usescopy ellocation;
var
   ANALYSISEM_icanbeheadunit:boolean;(*'Я могу быть ГУ?'*)
   nametemplatesxlsx:String;(*'Имя листа в шаблоне в Excel, для заполнения'*)
   labelondev:string;(*'Метка на устройстве'*)
   Position:String;(*'Позиция по заданию ТХ'*)

   CalcIP:TCalcIP;(*'Способ расчета'*)
   Power:Double;(*'Мощность, кВт'*)
   Current:Double;(*'Ток, А'*)
   CosPHI:Double;(*'Cos(фи)'*)
   Ks:Double;(*'Коэффициент спроса'*)
   PV:Double;(*'Продолжительность включения'*)
   Voltage:TVoltage;(*'Напряжение питания'*)
   Phase:TPhase;(*'Фаза'*)

implementation
begin
   ANALYSISEM_icanbeheadunit:=true;
   labelondev:='';
   Position:='-';
   nametemplatesxlsx:='-';

   Power:=1.0;
   Current:=0;
   CosPHI:=0.7;
   Ks:=1.0;
   PV:=1.0;
   Voltage:=_AC_380V_50Hz;
end.
