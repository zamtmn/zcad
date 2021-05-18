unit DEVICE_EL_YARV;
interface
uses system,devices;
usescopy blocktype;
var
   NMO_Template:GDBString;(*'Шаблон Обозначения'*) 
   NMO_Name:GDBString;(*'Обозначение'*)
   NMO_BaseName:GDBString;(*'Короткое Имя'*)
   NameNumber:GDBInteger;(*'Номер'*)


   Power:GDBDouble;(*'Мощность расчетная, кВт'*)
   PowerUst:GDBDouble;(*'Мощность установленная, кВт'*)
   Current:GDBDouble;(*'Ток расчетный, А'*)
   CurrentUst:GDBDouble;(*'Ток установленный, А'*)
   CosPHI:GDBDouble;(*'Cos(фи)'*)
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
   Device_Type:=TDT_SilaIst;
   BTY_TreeCoord:='PLAN_EM_Шкаф ЯРВ';
   Device_Class:=TDC_Shell;

   NMO_Name:='ЯРВ0';
   NMO_BaseName:='ЯРВ';
   NameNumber:=0;

   Power:=1.0;
   Current:=0;
   CosPHI:=0.7;
   Voltage:=_AC_380V_50Hz;

   DB_link:='El_Шкаф ЯРВ';

   NMO_Template:='@@[NMO_BaseName]@@[NameNumber]';
   EL_Cab_AddLength:=4;
   AmountI:=1;


   SerialConnection:=1;
   GC_HeadDevice:='??';
   GC_HDShortName:='??';
   GC_HDGroup:=0;

end.
