unit DEVICE_EL_MOTOR;
interface
uses system,devices;
usescopy slcabagenmodul;
usescopy blocktype;
var
   NMO_Template:GDBString;(*'Шаблон Обозначения'*) 
   NMO_Name:GDBString;(*'Обозначение'*)
   NMO_BaseName:GDBString;(*'Короткое Имя'*)
   NameNumber:GDBInteger;(*'Номер'*)

   Position:GDBInteger;(*'Позиция по заданию ТХ'*)

   CalcIP:TCalcIP;(*'Способ расчета'*)
   Power:GDBDouble;(*'Мощность, кВт'*)
   Current:GDBDouble;(*'Ток, А'*)
   CosPHI:GDBDouble;(*'Cos(фи)'*)
   Ks:GDBDouble;(*'Коэффициент спроса'*)
   PV:GDBDouble;(*'Продолжительность включения'*)
   Voltage:TVoltage;(*'Напряжение питания'*)
   Phase:TPhase;(*'Фаза'*)

   DB_link:GDBString;(*'Материал'*)
   AmountI:GDBInteger;(*'Количество'*)
   
   GC_HeadDevice:GDBString;
   GC_HDShortName:GDBString;
   GC_HDGroup:GDBInteger;

   SerialConnection:GDBInteger;
   NumberInSleif:GDBInteger;


   EL_Cab_AddLength:GDBDouble;(*'Добавлять к длине кабеля'*)
implementation
begin
   BTY_TreeCoord:='PLAN_EM_Двигатель';
   Device_Type:=TDT_SilaPotr;
   Device_Class:=TDC_Shell;
   NMO_Name:='Д0';
   NMO_BaseName:='Д';
   NameNumber:=0;
   Position:=0;

   Power:=1.0;
   Current:=0;
   CosPHI:=0.7;
   Ks:=1.0;
   PV:=1.0;
   Voltage:=_AC_380V_50Hz;

   DB_link:='El_Motor';

   NMO_Template:='@@[NMO_BaseName]@@[NameNumber]';
   EL_Cab_AddLength:=0.1;
   AmountI:=1;


   SerialConnection:=1;
   GC_HeadDevice:='ARK??';
   GC_HDShortName:='??';
   GC_HDGroup:=0;

end.
