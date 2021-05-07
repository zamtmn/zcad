unit DEVICE_EL_VL_MOTOR2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;
usescopy objgroup;
usescopy addtocable;

var

Position:GDBString;(*'Позиция по заданию ТХ'*)
Power:GDBDouble;(*'Мощность, кВт'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Двигатель';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='M0';
NMO_BaseName:='M';
NMO_Suffix:='??';
Position:='??';
Power:=1.0;

SerialConnection:=1;
GC_HeadDevice:='ШР??';
GC_HDShortName:='??';
GC_HDGroup:=0;

end.