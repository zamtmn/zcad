unit DEVICE_EL_VL_REPORT6_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Name:String;(*'Наименование'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Условные_обозначения';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='УО0';
NMO_BaseName:='УО';
NMO_Suffix:='??';

VL_Name:='??';

end.