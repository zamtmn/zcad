unit DEVICE_EL_VL_REPORT1_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:GDBString;(*'Обозначение'*)
T2:GDBString;(*'Начало'*)
T3:GDBString;(*'Конец'*)
T4:GDBString;(*'Тип прокладки'*)
T5:GDBString;(*'Марка'*)
T6:GDBString;(*'Кол. и сечение жил'*)
T7:GDBString;(*'Длина'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='КЖ0';
NMO_BaseName:='КЖ';
NMO_Suffix:='??';

T1:='??';
T2:='??';
T3:='??';
T4:='??';
T5:='??';
T6:='??';
T7:='??';

end.