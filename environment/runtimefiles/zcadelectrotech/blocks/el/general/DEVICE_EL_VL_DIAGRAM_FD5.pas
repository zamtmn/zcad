unit DEVICE_EL_VL_DIAGRAM_FD5;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Mark:String;(*'Обозначение'*)
VL_Py:String;(*'P установленная'*)
VL_U:String;(*'U падение напряжения'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Фидер';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ФД0';
NMO_BaseName:='ФД';
NMO_Suffix:='??';

VL_Mark:='??';
VL_Py:='??';
VL_U:='??';

end.