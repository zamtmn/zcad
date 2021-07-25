unit DEVICE_EL_VL_DIAGRAM_FD3;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T7:GDBString;(*'P установленная'*)
T8:GDBString;(*'P расчетная'*)
T9:GDBString;(*'I фаза А'*)
T10:GDBString;(*'I фаза В'*)
T11:GDBString;(*'I фаза С'*)
T12:GDBString;(*'Cos Ф'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Фидер';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ФД0';
NMO_BaseName:='ФД';
NMO_Suffix:='??';

T7:='??';
T8:='??';
T9:='??';
T10:='??';
T11:='??';
T12:='??';

end.