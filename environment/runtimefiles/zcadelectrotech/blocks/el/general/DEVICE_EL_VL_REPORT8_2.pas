unit DEVICE_EL_VL_REPORT8_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Помещение'*)
T2:String;(*'Освещенность'*)
T3:String;(*'Светильник'*)
T4:String;(*'Мощность'*)
T5:String;(*'Количество'*)
T6:String;(*'Высота'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВС0';
NMO_BaseName:='ВС';
NMO_Suffix:='??';

T1:='??';
T2:='??';
T3:='??';
T4:='??';
T5:='??';
T6:='??';

end.