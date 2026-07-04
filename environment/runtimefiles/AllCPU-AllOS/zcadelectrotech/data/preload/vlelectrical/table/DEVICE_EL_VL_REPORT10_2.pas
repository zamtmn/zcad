unit DEVICE_EL_VL_REPORT10_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Position:String;(*'Позция'*)
VL_Number:String;(*'ЛСР'*)
VL_Name:String;(*'Наименование работ'*)
VL_Units:String;(*'Ед.изм.'*)
VL_Quantity:String;(*'Кол-во'*)
VL_Link:String;(*'Чертежи'*)
VL_Grouping:String;(*'Группировка'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВР0';
NMO_BaseName:='ВР';
NMO_Suffix:='??';

VL_Position:='??';
VL_Number:='??';
VL_Name:='??';
VL_Units:='??';
VL_Quantity:='??';
VL_Link:='??';
VL_Grouping:='??';

end.