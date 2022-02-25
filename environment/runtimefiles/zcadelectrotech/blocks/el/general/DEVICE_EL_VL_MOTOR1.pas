unit DEVICE_EL_VL_MOTOR1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;
usescopy objgroup;
usescopy addtocable;

var

T1:String;(*'Мощность, кВт'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Двигатель';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='М0';
NMO_BaseName:='М';
NMO_Suffix:='??';
Position:='??';

T1:='0';

SerialConnection:=1;
GC_HeadDevice:='ЩР??';
GC_HDShortName:='??';
GC_HDGroup:=0;

end.