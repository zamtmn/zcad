unit DEVICE_EL_VL_REPORT12_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Name:String;(*'Обозначение'*)
VL_Start:String;(*'Начало'*)
VL_Finish:String;(*'Конец'*)
VL_Track:String;(*'Тип прокладки'*)
VL_Mark:String;(*'Марка'*)
VL_Number:String;(*'Кол. и сечение жил'*)
VL_Length:String;(*'Длина'*)
VL_Power:String;(*'Мощность'*)
VL_Current:String;(*'Ток'*)
VL_Fire:String;(*'Пожарный режим'*)
VL_Switch:String;(*'Аппарат'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='КЖ0';
NMO_BaseName:='КЖ';
NMO_Suffix:='??';

VL_Name:='??';
VL_Start:='??';
VL_Finish:='??';
VL_Track:='??';
VL_Mark:='??';
VL_Number:='??';
VL_Length:='??';
VL_Power:='??';
VL_Current:='??';
VL_Fire:='??';
VL_Switch:='??';

end.