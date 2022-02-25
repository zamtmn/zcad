unit DEVICE_EL_VL_SCHEMA1_1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T19:String;(*'Распределительное устройство'*)

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