unit DEVICE_EL_VL_STAMP4;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Организация'*)
T2:String;(*'Шифр'*)
T3:String;(*'Проект'*)
T4:String;(*'Раздел'*)
T5:String;(*'Чертеж'*)
T6:String;(*'Стадия'*)
T7:String;(*'Страница'*)
T8:String;(*'Страниц'*)
T9:String;(*'Дата'*)

T11:String;(*'Специалист 1'*)
T12:String;(*'Фамилия 1'*)
T13:String;(*'Специалист 2'*)
T14:String;(*'Фамилия 2'*)
T15:String;(*'Специалист 3'*)
T16:String;(*'Фамилия 3'*)
T17:String;(*'Специалист 4'*)
T18:String;(*'Фамилия 4'*)
T19:String;(*'Специалист 5'*)
T20:String;(*'Фамилия 5'*)

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