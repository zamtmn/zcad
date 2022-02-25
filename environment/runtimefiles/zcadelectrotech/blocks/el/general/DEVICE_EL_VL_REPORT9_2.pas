unit DEVICE_EL_VL_REPORT9_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Помещение'*)
T2:String;(*'Наименование'*)
T3:String;(*'Площадь'*)
T4:String;(*'Категория'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ЭК0';
NMO_BaseName:='ЭК';
NMO_Suffix:='??';

T1:='??';
T2:='??';
T3:='??';
T4:='??';


end.