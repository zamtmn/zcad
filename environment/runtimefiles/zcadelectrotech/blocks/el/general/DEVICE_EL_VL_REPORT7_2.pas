unit DEVICE_EL_VL_REPORT7_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Характеристики'*)
T2:String;(*'Количество'*)
T3:String;(*'Мощность одного, кВт'*)
T4:String;(*'Мощность общая, кВт'*)
T5:String;(*'Напряжение, кВ'*)
T6:String;(*'Нормативный документ'*)
T7:String;(*'Коэффициент Кс'*)
T8:String;(*'Коэффициент КПД'*)
T9:String;(*'Коэффициент Cos'*)
T10:String;(*'Резерв'*)
T11:String;(*'Резерв'*)
T12:String;(*'Расчетная мощность, кВт'*)
T13:String;(*'Расчетный ток, А'*)
T14:String;(*'Группа'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВН0';
NMO_BaseName:='ВН';
NMO_Suffix:='??';

T1:='??';
T2:='??';
T3:='??';
T4:='??';
T5:='??';
T6:='??';
T7:='??';
T8:='??';
T9:='??';
T10:='??';
T11:='??';
T12:='??';
T13:='??';
T14:='??';

end.