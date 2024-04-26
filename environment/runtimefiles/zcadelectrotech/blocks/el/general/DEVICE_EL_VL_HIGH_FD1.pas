unit DEVICE_EL_VL_HIGH_FD1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Mark:String;(*'Обозначение'*)
VL_Type:String;(*'Камера'*)
VL_Number:String;(*'Номер'*)
VL_Pp:String;(*'P активная'*)
VL_Ip:String;(*'I расчетный'*)
VL_Cos:String;(*'Cos Ф'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Фидер';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ФВ0';
NMO_BaseName:='ФВ';
NMO_Suffix:='??';

VL_Mark:='??';
VL_Type:='??';
VL_Number:='??';
VL_Pp:='??';
VL_Ip:='??';
VL_Cos:='??';

end.