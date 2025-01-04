unit DEVICE_EL_VL_DIAGRAM_FD1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Mark:String;(*'Обозначение'*)
VL_PyPp:String;(*'P активная'*)
VL_Ip:String;(*'I расчетный'*)
VL_Load:String;(*'Наименование'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Фидер';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ФД0';
NMO_BaseName:='ФД';
NMO_Suffix:='??';

VL_Mark:='??';
VL_PyPp:='??';
VL_Ip:='??';
VL_Load:='??';

end.