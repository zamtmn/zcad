unit DEVICE_EL_VL_STAMP2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Code:String;(*'Шифр'*)
VL_Sheet:String;(*'Страница'*)

VL_Changes11:String;(*'Номер 1'*)
VL_Changes12:String;(*'Лист 1'*)
VL_Changes13:String;(*'Документ 1'*)
VL_Changes14:String;(*'Дата 1'*)
VL_Changes21:String;(*'Номер 2'*)
VL_Changes22:String;(*'Лист 2'*)
VL_Changes23:String;(*'Документ 2'*)
VL_Changes24:String;(*'Дата 2'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Штамп';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ШТ0';
NMO_BaseName:='ШТ';
NMO_Suffix:='??';

VL_Code:='??';
VL_Sheet:='??';

VL_Changes11:='??';
VL_Changes12:='??';
VL_Changes13:='??';
VL_Changes14:='??';
VL_Changes21:='??';
VL_Changes22:='??';
VL_Changes23:='??';
VL_Changes24:='??';

end.