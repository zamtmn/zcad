unit DEVICE_EL_VL_VEDOMOSTI3_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T5:String;(*'Содержание'*)
T7:String;(*'Лист'*)
T10:String;(*'Примечание'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Штамп';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ШТ0';
NMO_BaseName:='ШТ';
NMO_Suffix:='??';

T5:='??';
T7:='??';
T10:='??';

end.