unit DEVICE_EL_VL_VEDOMOSTI3_1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Code:String;(*'Шифр'*)
VL_Project:String;(*'Проект'*)
VL_Plan:String;(*'Разрешение'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Штамп';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ШТ0';
NMO_BaseName:='ШТ';
NMO_Suffix:='??';

VL_Code:='??';
VL_Project:='??';
VL_Plan:='??';

end.