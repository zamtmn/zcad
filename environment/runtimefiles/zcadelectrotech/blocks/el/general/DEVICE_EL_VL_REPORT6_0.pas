unit DEVICE_EL_VL_REPORT6_0;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T19:GDBString;(*'Распределительное устройство'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='РС0';
NMO_BaseName:='РС';
NMO_Suffix:='??';

T19:='??';

end.