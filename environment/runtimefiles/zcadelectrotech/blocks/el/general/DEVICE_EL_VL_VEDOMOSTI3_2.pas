unit DEVICE_EL_VL_VEDOMOSTI3_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Изменение'*)
T2:String;(*'Лист'*)
T4:String;(*'Содержание'*)
T5:String;(*'Код'*)
T6:String;(*'Примечание'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Штамп';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='СД0';
NMO_BaseName:='СД';
NMO_Suffix:='??';

T1:='??';
T2:='??';
T4:='??';
T5:='??';
T6:='??';

end.