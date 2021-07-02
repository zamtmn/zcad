unit DEVICE_EL_VL_STAMP1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:GDBString;(*'Организация'*)
T2:GDBString;(*'Шифр'*)
T3:GDBString;(*'Проект'*)
T4:GDBString;(*'Раздел'*)
T5:GDBString;(*'Чертеж'*)
T6:GDBString;(*'Стадия'*)
T7:GDBString;(*'Страница'*)
T8:GDBString;(*'Страниц'*)
T9:GDBString;(*'Дата'*)

T11:GDBString;(*'Специалист 1'*)
T12:GDBString;(*'Фамилия 1'*)
T13:GDBString;(*'Специалист 2'*)
T14:GDBString;(*'Фамилия 2'*)
T15:GDBString;(*'Специалист 3'*)
T16:GDBString;(*'Фамилия 3'*)
T17:GDBString;(*'Специалист 4'*)
T18:GDBString;(*'Фамилия 4'*)
T19:GDBString;(*'Специалист 5'*)
T20:GDBString;(*'Фамилия 5'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Штамп';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ШТ0';
NMO_BaseName:='ШТ';
NMO_Suffix:='??';

T1:='??';
T2:='??';
T3:='??';
T4:='??';
T6:='??';
T7:='??';
T9:='??';

T11:='';
T12:='';
T13:='';
T14:='';
T15:='';
T17:='';
T18:='';
T19:='';
T20:='';

end.