unit DEVICE_EL_VL_HIGH_FD2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Number:String;(*'Номер'*)
VL_Mark:String;(*'Обозначение'*)
VL_Goal:String;(*'Назначение'*)
VL_Type:String;(*'Ячейка'*)
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

VL_Number:='??';
VL_Mark:='??';
VL_Goal:='??';
VL_Type:='??';
VL_Pp:='??';
VL_Ip:='??';
VL_Cos:='??';

end.