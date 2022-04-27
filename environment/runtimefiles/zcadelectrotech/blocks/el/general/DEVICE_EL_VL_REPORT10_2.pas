unit DEVICE_EL_VL_REPORT10_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Позция'*)
T2:String;(*'ЛСР'*)
T3:String;(*'Наименование работ'*)
T4:String;(*'Ед.изм.'*)
T5:String;(*'Кол-во'*)
T6:String;(*'Чертежи'*)
T7:String;(*'Группировка'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВР0';
NMO_BaseName:='ВР';
NMO_Suffix:='??';

T1:='??';
T2:='??';
T3:='??';
T4:='??';
T5:='??';
T6:='??';
T7:='??';

end.