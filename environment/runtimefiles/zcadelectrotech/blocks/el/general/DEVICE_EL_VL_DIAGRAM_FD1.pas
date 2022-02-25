unit DEVICE_EL_VL_DIAGRAM_FD1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Обозначение'*)
T2:String;(*'P активная'*)
T3:String;(*'I расчетный'*)
T4:String;(*'Наименование'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Фидер';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ФД0';
NMO_BaseName:='ФД';
NMO_Suffix:='??';

T1:='??';
T2:='??';
T3:='??';
T4:='??';

end.