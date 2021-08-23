unit DEVICE_EL_VL_REPORT7_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:GDBString;(*'Характеристики'*)
T2:GDBString;(*'Количество'*)
T3:GDBString;(*'Мощность одного, кВт'*)
T4:GDBString;(*'Мощность общая, кВт'*)
T5:GDBString;(*'Напряжение, кВ'*)
T6:GDBString;(*'Нормативный документ'*)
T7:GDBString;(*'Коэффициент Кс'*)
T8:GDBString;(*'Коэффициент КПД'*)
T9:GDBString;(*'Коэффициент Cos'*)
T10:GDBString;(*'Резерв'*)
T11:GDBString;(*'Резерв'*)
T12:GDBString;(*'Расчетная мощность, кВт'*)
T13:GDBString;(*'Расчетный ток, А'*)
T14:GDBString;(*'Группа'*)

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