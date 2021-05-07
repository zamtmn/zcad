unit DEVICE_EL_VL_HEATER2;

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

BTY_TreeCoord:='PLAN_EM_Тэн';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='Т0';
NMO_BaseName:='Т';
NMO_Suffix:='??';
Power:=1.0;

SerialConnection:=1;
GC_HeadDevice:='ШР??';
GC_HDShortName:='??';
GC_HDGroup:=0;

end.