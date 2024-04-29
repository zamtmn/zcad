unit DEVICE_EL_VL_STAMP5;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Number:String;(*'Сквозная нумерация'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Штамп';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ШТ0';
NMO_BaseName:='ШТ';
NMO_Suffix:='??';

VL_Number:='??';

end.