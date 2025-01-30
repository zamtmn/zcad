unit elreceivers;
interface
uses system,devices;
usescopy xlsxgenerator;
var
   realnamedev:String;(*'Реальное имя устройства подключения'*)

   labelondev:string;(*'Метка на устройстве'*)
   Position:TCalculatedString;(*'Позиция по заданию ТХ'*)

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
   labelondev:='';
   realnamedev:='';

   Position.value:='-';
   Position.format:='@@[NMO_BaseName]';

   Power:=1.0;
   Current:=0;
   CosPHI:=0.7;
   Ks:=1.0;
   PV:=1.0;
   Voltage:=_AC_380V_50Hz;
end.
