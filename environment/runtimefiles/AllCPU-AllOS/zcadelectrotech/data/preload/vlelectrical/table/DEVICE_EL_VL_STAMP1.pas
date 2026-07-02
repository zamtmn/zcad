unit DEVICE_EL_VL_STAMP1;

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

VL_Changes11:String;(*'Номер 1'*)
VL_Changes12:String;(*'Лист 1'*)
VL_Changes13:String;(*'Документ 1'*)
VL_Changes14:String;(*'Дата 1'*)
VL_Changes21:String;(*'Номер 2'*)
VL_Changes22:String;(*'Лист 2'*)
VL_Changes23:String;(*'Документ 2'*)
VL_Changes24:String;(*'Дата 2'*)
VL_Changes31:String;(*'Номер 3'*)
VL_Changes32:String;(*'Лист 3'*)
VL_Changes33:String;(*'Документ 3'*)
VL_Changes34:String;(*'Дата 3'*)
VL_Changes41:String;(*'Номер 4'*)
VL_Changes42:String;(*'Лист 4'*)
VL_Changes43:String;(*'Документ 4'*)
VL_Changes44:String;(*'Дата 4'*)

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

VL_Changes11:='??';
VL_Changes12:='??';
VL_Changes13:='??';
VL_Changes14:='??';
VL_Changes21:='??';
VL_Changes22:='??';
VL_Changes23:='??';
VL_Changes24:='??';
VL_Changes31:='??';
VL_Changes32:='??';
VL_Changes33:='??';
VL_Changes34:='??';
VL_Changes41:='??';
VL_Changes42:='??';
VL_Changes43:='??';
VL_Changes44:='??';

end.