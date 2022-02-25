unit DEVICE_EL_VL_REPORT4_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Позиция'*)
T2:String;(*'Наименование'*)
T3:String;(*'Количество'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВУ0';
NMO_BaseName:='ВУ';
NMO_Suffix:='??';

T1:='??';
T2:='??';
T3:='??';

end.