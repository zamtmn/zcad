unit DEVICE_EL_VL_DIAGRAM_T1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:GDBString;(*'Тип'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Трансформатор';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='T0';
NMO_BaseName:='T.';
NMO_Suffix:='??';

T1:='??';

end.