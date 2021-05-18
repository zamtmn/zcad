unit DEVICE_EL_VL_CONNECTOR2_1P_3;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;
usescopy objgroup;
usescopy addtocable;

var

Power:GDBDouble;(*'Мощность, кВт'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Розетка';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='Т0';
NMO_BaseName:='Т';
NMO_Suffix:='??';
Power:=0.0;

SerialConnection:=1;
GC_HeadDevice:='ШР??';
GC_HDShortName:='??';
GC_HDGroup:=0;

end.