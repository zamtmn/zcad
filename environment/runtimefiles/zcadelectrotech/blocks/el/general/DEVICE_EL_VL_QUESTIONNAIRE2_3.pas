unit DEVICE_EL_VL_QUESTIONNAIRE2_3;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Number:String;(*'Номер по плану'*)
VL_Mark:String;(*'Назначение камеры'*)
VL_Name:String;(*'Наименование камеры'*)
VL_Main:String;(*'Номер главных цепей'*)
VL_Second:String;(*'Номер вторичных цепей'*)
VL_Q:String;(*'Выключатель вакуумный'*)
VL_QW:String;(*'Выключатель нагрузки'*)
VL_QS1:String;(*'Шинный разъединиитель'*)
VL_QS2:String;(*'Линейный разъединитель'*)
VL_TA:String;(*'Траснф. тока'*)
VL_TV:String;(*'Трансф. напряжения'*)
VL_TM:String;(*'Трансф. собственных нужд'*)
VL_FU:String;(*'Предохранители'*)
VL_TAN:String;(*'Трансф. тока нулевой послд.'*)
VL_Relay:String;(*'Тип устройства защиты'*)
VL_PA:String;(*'Апмерметр'*)
VL_Wh:String;(*'Счетчик'*)
VL_UR:String;(*'Ограничитель перенапряжения'*)
VL_LW:String;(*'Кабель'*)
VL_Panel:String;(*'Торцевая панель'*)
VL_Size:String;(*'Габаритные размеры'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Опросник';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ОВ0';
NMO_BaseName:='ОВ';
NMO_Suffix:='??';

VL_Number:='?';
VL_Mark:='?';
VL_Name:='?';
VL_Main:='?';
VL_Second:='?';
VL_Q:='?';
VL_QW:='?';
VL_QS1:='?';
VL_QS2:='?';
VL_TA:='?';
VL_TV:='?';
VL_TM:='?';
VL_FU:='?';
VL_TAN:='?';
VL_Relay:='?';
VL_PA:='?';
VL_Wh:='?';
VL_UR:='?';
VL_LW:='?';
VL_Panel:='?';
VL_Size:='?';

end.