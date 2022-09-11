unit DEVICE_EL_VL_QUESTIONNAIRE2_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Номер по плану'*)
T2:String;(*'Назначение камеры'*)
T3:String;(*'Наименование камеры'*)
T4:String;(*'Номер главных цепей'*)
T5:String;(*'Номер вторичных цепей'*)
T6:String;(*'Выключатель вакуумный'*)
T7:String;(*'Выключатель нагрузки'*)
T8:String;(*'Шинный разъединиитель'*)
T9:String;(*'Линейный разъединитель'*)
T10:String;(*'Траснф. тока'*)
T11:String;(*'Трансф. напряжения'*)
T12:String;(*'Трансф. собственных нужд'*)
T13:String;(*'Предохранители'*)
T14:String;(*'Трансф. тока нулевой послд.'*)
T15:String;(*'Тип устройства защиты'*)
T16:String;(*'Апмерметр'*)
T17:String;(*'Счетчик'*)
T18:String;(*'Ограничитель перенапряжения'*)
T19:String;(*'Кабель'*)
T20:String;(*'Торцевая панель'*)
T21:String;(*'Габаритные размеры'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Опросник';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ОВ0';
NMO_BaseName:='ОВ';
NMO_Suffix:='??';

T1:='?';
T2:='?';
T3:='?';
T4:='?';
T5:='?';
T6:='?';
T7:='?';
T8:='?';
T9:='?';
T10:='?';
T11:='?';
T12:='?';
T13:='?';
T14:='?';
T15:='?';
T16:='?';
T17:='?';
T18:='?';
T19:='?';
T20:='?';
T21:='?';

end.