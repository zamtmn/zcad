unit DEVICE_EL_YARV;
interface
uses system,devices;
usescopy blocktype;
var
   NMO_Template:String;(*'Шаблон Обозначения'*) 
   NMO_Name:String;(*'Обозначение'*)
   NMO_BaseName:String;(*'Короткое Имя'*)
   NameNumber:Integer;(*'Номер'*)


   Power:Double;(*'Мощность расчетная, кВт'*)
   PowerUst:Double;(*'Мощность установленная, кВт'*)
   Current:Double;(*'Ток расчетный, А'*)
   CurrentUst:Double;(*'Ток установленный, А'*)
   CosPHI:Double;(*'Cos(фи)'*)
   Voltage:TVoltage;(*'Напряжение питания'*)
   Phase:TPhase;(*'Фаза'*)

   DB_link:String;(*'Материал'*)
   AmountI:Integer;(*'Количество'*)
   
   GC_HeadDevice:String;
   GC_HDShortName:String;
   GC_HDGroup:Integer;

   SerialConnection:Integer;
   NumberInSleif:Integer;


   EL_Cab_AddLength:Double;(*'Добавлять к длине кабеля'*)
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
