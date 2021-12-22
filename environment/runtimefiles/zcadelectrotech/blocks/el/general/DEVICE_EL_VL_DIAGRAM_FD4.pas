unit DEVICE_EL_VL_DIAGRAM_FD4;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:GDBString;(*'Обозначение'*)
T11:GDBString;(*'P установленная'*)
T12:GDBString;(*'U падение напряжения'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Фидер';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ФД0';
NMO_BaseName:='ФД';
NMO_Suffix:='??';

T1:='??';
T11:='??';
T12:='??';

end.