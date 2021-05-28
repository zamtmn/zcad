unit DEVICE_EL_VL_REFERENCE1_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

Reference:GDBString;(*'Обозначение'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Условные_обозначения';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='УО0';
NMO_BaseName:='УО';
NMO_Suffix:='??';

Reference:='??';

end.