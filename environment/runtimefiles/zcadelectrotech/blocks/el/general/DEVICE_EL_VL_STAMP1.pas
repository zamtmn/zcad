unit DEVICE_EL_VL_STAMP1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

Organization:GDBString;(*'Организация'*)
Code:GDBString;(*'Шифр'*)
Project:GDBString;(*'Проект'*)
Section:GDBString;(*'Раздел'*)
Drawing:GDBString;(*'Чертеж'*)
Stage:GDBString;(*'Стадия'*)
Sheet:GDBString;(*'Страница'*)
Sheets:GDBString;(*'Страниц'*)
Date:GDBString;(*'Дата'*)

Specialist1:GDBString;(*'Специалист 1'*)
Person1:GDBString;(*'Фамилия 1'*)
Specialist2:GDBString;(*'Специалист 2'*)
Person2:GDBString;(*'Фамилия 2'*)
Specialist3:GDBString;(*'Специалист 3'*)
Person3:GDBString;(*'Фамилия 3'*)
Specialist4:GDBString;(*'Специалист 4'*)
Person4:GDBString;(*'Фамилия 4'*)
Specialist5:GDBString;(*'Специалист 5'*)
Person5:GDBString;(*'Фамилия 5'*)
Specialist6:GDBString;(*'Специалист 6'*)
Person6:GDBString;(*'Фамилия 6'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Штамп';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ШТ0';
NMO_BaseName:='ШТ';
NMO_Suffix:='??';

Organization:='??';
Code:='??';
Project:='??';
Section:='??';
Drawing:='??';
Stage:='??';
Sheet:='??';
Sheets:='';
Date:='??';

Specialist1:='Разраб.';
Person1:='';
Specialist2:='Проверил';
Person2:='';
Specialist3:='ГИП';
Person3:='';
Specialist4:='';
Person4:='';
Specialist5:='Н.контр.';
Person5:='';
Specialist6:='Утв.';
Person6:='';

end.