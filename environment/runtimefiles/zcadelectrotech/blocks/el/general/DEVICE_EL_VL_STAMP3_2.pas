unit DEVICE_EL_VL_STAMP3_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:GDBString;(*'Лист'*)
T2:GDBString;(*'Наименование'*)
T3:GDBString;(*'Примечание'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Штамп';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВЧ0';
NMO_BaseName:='ВЧ';
NMO_Suffix:='??';

T1:='??';
T2:='??';
T3:='??';

end.