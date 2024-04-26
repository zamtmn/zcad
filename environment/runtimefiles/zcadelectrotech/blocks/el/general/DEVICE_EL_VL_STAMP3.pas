unit DEVICE_EL_VL_STAMP3;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Company:String;(*'Организация'*)
VL_Sheet:String;(*'Страница'*)
VL_Sheets:String;(*'Страниц'*)
VL_Date:String;(*'Дата'*)

VL_Name1:String;(*'Фамилия 1'*)
VL_Name2:String;(*'Фамилия 2'*)
VL_Name3:String;(*'Фамилия 3'*)
VL_Name4:String;(*'Фамилия 4'*)
VL_Name5:String;(*'Фамилия 5'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Штамп';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ШТ0';
NMO_BaseName:='ШТ';
NMO_Suffix:='??';

VL_Company:='??';
VL_Sheet:='??';
VL_Sheets:='??';
VL_Date:='??';

VL_Name1:='??';
VL_Name2:='??';
VL_Name3:='??';
VL_Name4:='??';
VL_Name5:='??';

end.