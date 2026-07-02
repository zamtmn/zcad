unit DEVICE_EL_VL_REPORT11_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Feeder:String;(*'Фидер'*)
VL_Mark:String;(*'Маркировка'*)
VL_Cable:String;(*'Тип кабеля'*)
VL_Section:String;(*'Кол. жил, сечение'*)
VL_Length:String;(*'Длина'*)
VL_Paired:String;(*'Спаренные кабеля'*)
VL_Track:String;(*'Групповая прокладка'*)
VL_K1:String;(*'Коэф. прокладка'*)
VL_Inom:String;(*'Допустимый ток'*)
VL_Ipad:String;(*'Допустимый ток, по прокладке'*)
VL_Imax:String;(*'Ток наибольшей фазы'*)
VL_Ifire:String;(*'Ток в пожарном режиме'*)
VL_K3:String;(*'Кратность аппарата'*)
VL_Current:String;(*'Ток по кратности'*)
VL_Voltage:String;(*'Падение напряжения'*)
VL_Panel:String;(*'Электрощит'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВК0';
NMO_BaseName:='ВК';
NMO_Suffix:='??';

VL_Feeder:='??';
VL_Mark:='??';
VL_Cable:='??';
VL_Section:='??';
VL_Length:='??';
VL_Paired:='??';
VL_Track:='??';
VL_K1:='??';
VL_Inom:='??';
VL_Ipad:='??';
VL_Imax:='??';
VL_Ifire:='??';
VL_K3:='??';
VL_Current:='??';
VL_Voltage:='??';
VL_Panel:='??';

end.