unit DEVICE_EL_VL_STAMP3;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Организация'*)
T7:String;(*'Страница'*)
T8:String;(*'Страниц'*)
T9:String;(*'Дата'*)

T12:String;(*'Фамилия 1'*)
T14:String;(*'Фамилия 2'*)
T16:String;(*'Фамилия 3'*)
T18:String;(*'Фамилия 4'*)
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
T7:='??';
T9:='??';

T12:='';
T14:='';
T18:='';
T20:='';

end.