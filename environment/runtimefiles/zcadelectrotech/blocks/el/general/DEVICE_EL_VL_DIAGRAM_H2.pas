unit DEVICE_EL_VL_DIAGRAM_H2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:GDBString;(*'Маркировка'*)
T2:GDBString;(*'Тип'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Кабель';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='H0';
NMO_BaseName:='H1.';
NMO_Suffix:='??';

T1:='??';
T2:='??';

end.