unit DEVICE_EL_VL_VEDOMOSTI3_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Change:String;(*'Изменение'*)
VL_Sheet:String;(*'Лист'*)
VL_Name:String;(*'Содержание'*)
VL_Number:String;(*'Код'*)
VL_Note:String;(*'Примечание'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Штамп';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='СД0';
NMO_BaseName:='СД';
NMO_Suffix:='??';

VL_Change:='??';
VL_Sheet:='??';
VL_Name:='??';
VL_Number:='??';
VL_Note:='??';

end.