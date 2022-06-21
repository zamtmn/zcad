unit DEVICE_EL_VL_REPORT11_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Фидер'*)

T2:String;(*'Маркировка'*)
T3:String;(*'Тип кабеля'*)
T4:String;(*'Кол. жил, сечение'*)
T5:String;(*'Длина'*)

T6:String;(*'Спаренные кабеля'*)
T7:String;(*'Групповая прокладка'*)
T8:String;(*'Коэф. прокладка'*)
T9:String;(*'Коэф. температура'*)

T10:String;(*'Допустимый ток'*)
T11:String;(*'Ток прокладки'*)
T12:String;(*'Ток наибольшей фазы'*)

T13:String;(*'Кратность аппарата'*)
T14:String;(*'Ток по кратности'*)
T15:String;(*'Падение напряжения'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВК0';
NMO_BaseName:='ВК';
NMO_Suffix:='??';

T1:='??';

T2:='??';
T3:='??';
T4:='??';
T5:='??';

T6:='??';
T7:='??';
T8:='??';
T9:='??';

T10:='??';
T11:='??';
T12:='??';

T13:='??';
T14:='??';
T15:='??';

end.