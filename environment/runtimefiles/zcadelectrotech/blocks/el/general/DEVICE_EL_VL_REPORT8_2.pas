unit DEVICE_EL_VL_REPORT8_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:GDBString;(*'Помещение'*)
T2:GDBString;(*'Освещенность'*)
T3:GDBString;(*'Светильник'*)
T4:GDBString;(*'Мощность'*)
T5:GDBString;(*'Количество'*)
T6:GDBString;(*'Высота'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВС0';
NMO_BaseName:='ВС';
NMO_Suffix:='??';

T1:='??';
T2:='??';
T3:='??';
T4:='??';
T5:='??';
T6:='??';

end.