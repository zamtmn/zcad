unit DEVICE_EL_VL_REPORT1_2;

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

end.