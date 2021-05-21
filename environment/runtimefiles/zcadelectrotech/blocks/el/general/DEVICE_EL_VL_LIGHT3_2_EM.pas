unit DEVICE_EL_VL_LIGHT3_2_EM;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;
usescopy objgroup;
usescopy addtocable;

var

Power:GDBDouble;(*'Мощность, кВт'*)
Code:GDBString;(*'Код'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_светильник';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='С0';
NMO_BaseName:='С';
NMO_Suffix:='??';
Power:=0.0;

SerialConnection:=1;
GC_HeadDevice:='ШР??';
GC_HDShortName:='??';
GC_HDGroup:=0;

end.