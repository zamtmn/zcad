unit DEVICE_EL_VL_DIAGRAM_BS1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T11:GDBInteger;(*'123'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Шина';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='Н0';
NMO_BaseName:='Н';
NMO_Suffix:='??';
NMO_Affix:='.1';

T11:=3;

end.