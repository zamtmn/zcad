unit DEVICE_EL_VL_STAMP3_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T10:GDBString;(*'Лист'*)
T5:GDBString;(*'Наименование'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Штамп';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ШТ0';
NMO_BaseName:='ШТ';
NMO_Suffix:='??';

T10:='??';
T5:='??';

end.