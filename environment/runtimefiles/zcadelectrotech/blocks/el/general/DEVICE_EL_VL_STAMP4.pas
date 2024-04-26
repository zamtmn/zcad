unit DEVICE_EL_VL_STAMP4;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Company:String;(*'Организация'*)
VL_Code:String;(*'Шифр'*)
VL_Project:String;(*'Проект'*)
VL_Chapter:String;(*'Раздел'*)
VL_Plan:String;(*'Чертеж'*)
VL_Stage:String;(*'Стадия'*)
VL_Sheet:String;(*'Страница'*)
VL_Sheets:String;(*'Страниц'*)
VL_Date:String;(*'Дата'*)

VL_Worker1:String;(*'Специалист 1'*)
VL_Name1:String;(*'Фамилия 1'*)
VL_Worker2:String;(*'Специалист 2'*)
VL_Name2:String;(*'Фамилия 2'*)
VL_Worker3:String;(*'Специалист 3'*)
VL_Name3:String;(*'Фамилия 3'*)
VL_Worker4:String;(*'Специалист 4'*)
VL_Name4:String;(*'Фамилия 4'*)
VL_Worker5:String;(*'Специалист 5'*)
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
VL_Code:='??';
VL_Project:='??';
VL_Chapter:='??';
VL_Plan:='??';
VL_Stage:='??';
VL_Sheet:='??';
VL_Sheets:='??';
VL_Date:='??';

VL_Worker1:='??';
VL_Name1:='??';
VL_Worker2:='??';
VL_Name2:='??';
VL_Worker3:='??';
VL_Name3:='??';
VL_Worker4:='??';
VL_Name4:='??';
VL_Worker5:='??';
VL_Name5:='??';

end.