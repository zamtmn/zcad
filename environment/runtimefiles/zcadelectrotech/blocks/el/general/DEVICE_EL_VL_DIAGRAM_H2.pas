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

NMO_Name:='Н0';
NMO_BaseName:='Н';
NMO_Suffix:='??';
NMO_Affix:='.1';

T1:='??';
T2:='??';

end.