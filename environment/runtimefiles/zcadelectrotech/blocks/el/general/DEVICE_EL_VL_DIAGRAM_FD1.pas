unit DEVICE_EL_VL_DIAGRAM_FD1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:GDBString;(*'Обозначение'*)
T2:GDBString;(*'P активная'*)
T3:GDBString;(*'Q реактивная'*)
T4:GDBString;(*'I hасчетный'*)
T5:GDBString;(*'Cos Ф'*)
T6:GDBString;(*'Наименование'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Фидер';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='F0';
NMO_BaseName:='F';
NMO_Suffix:='??';

T1:='??';
T2:='??';
T3:='??';
T4:='??';
T5:='??';
T6:='??';

end.