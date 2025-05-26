unit DEVICE_EL_VL_POWER_DEVICE2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;
usescopy objgroup;
usescopy addtocable;

var

VL_Power:String;(*'Мощность, кВт'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Устройство';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='Т0';
NMO_BaseName:='Т';
NMO_Suffix:='??';

VL_Power:='0';

SerialConnection:=1;
GC_HeadDevice:='ЩР??';
GC_HDShortName:='??';
GC_HDGroup:=0;

end.