unit DEVICE_EL_VL_VEDOMOSTI4_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Лист'*)
T2:String;(*'Наименование'*)
T3:String;(*'Примечание'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Штамп';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВЧ0';
NMO_BaseName:='ВЧ';
NMO_Suffix:='??';

T1:='??';
T2:='??';
T3:='??';

end.