unit DEVICE_EL_VL_REPORT15_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Щит'*)
T2:String;(*'Нагрузка'*)
T3:String;(*'Расшифровка'*)
T4:String;(*'Фаза'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВЭ0';
NMO_BaseName:='ВЭ';
NMO_Suffix:='??';

T1:='??';
T2:='??';
T3:='??';
T4:='??';

end.