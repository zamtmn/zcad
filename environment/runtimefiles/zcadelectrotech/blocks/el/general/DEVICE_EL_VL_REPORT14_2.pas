unit DEVICE_EL_VL_REPORT14_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Наименование точки'*)
T2:String;(*'Координата X'*)
T3:String;(*'Координата Y'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВГ0';
NMO_BaseName:='ВГ';
NMO_Suffix:='??';

T1:='??';
T2:='??';
T3:='??';

end.