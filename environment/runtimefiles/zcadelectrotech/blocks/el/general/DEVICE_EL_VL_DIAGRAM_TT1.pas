unit DEVICE_EL_VL_DIAGRAM_TT1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:GDBString;(*'Обозначение'*)
T2:GDBString;(*'Марка'*)
T3:GDBString;(*'Параметры'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Аппаратура';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='A0';
NMO_BaseName:='A4.';
NMO_Suffix:='??';

T1:='??';
T2:='??';
T3:='??';

end.