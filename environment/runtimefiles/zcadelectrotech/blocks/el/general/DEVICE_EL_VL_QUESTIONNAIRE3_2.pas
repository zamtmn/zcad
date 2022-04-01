unit DEVICE_EL_VL_QUESTIONNAIRE3_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Порядковый номер'*)
T2:String;(*'Тип панели'*)
T3:String;(*'Номер вторичных цепей'*)
T4:String;(*'Назначение линии'*)
T5:String;(*'Авт.выключатель, тип'*)
T6:String;(*'Авт.выключатель, ном.ток'*)
T7:String;(*'Рубильник, тип'*)
T8:String;(*'Рубильник, ном.ток'*)
T9:String;(*'Ном. ток макс.расцепителя'*)
T10:String;(*'Расцепитель тепловой'*)
T11:String;(*'Расцепитель эл.магнитный'*)
T12:String;(*'Выдержка времени'*)
T13:String;(*'Предохранитель, ном.ток'*)
T14:String;(*'Трансф.тока, ном.ток'*)
T15:String;(*'Трансф.тока, кл.точности'*)
T16:String;(*'Амперметр, шкала'*)
T17:String;(*'Вольтметр шкала'*)
T18:String;(*'Реле'*)
T19:String;(*'Трансф.тока нулевой послед.'*)
T20:String;(*'Наличие АВР'*)
T21:String;(*'Счетчик'*)
T22:String;(*'Ограничитель перенапряжения'*)
T23:String;(*'Кол. и сечение кабелей'*)
T24:String;(*'Количество панелей'*)
T25:String;(*'Габаритные размеры'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Опросник';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ОП0';
NMO_BaseName:='ОП';
NMO_Suffix:='??';

T1:='';
T2:='';
T3:='';
T4:='';
T5:='';
T6:='';
T7:='';
T8:='';
T9:='';
T10:='';
T11:='';
T12:='';
T13:='';
T14:='';
T15:='';
T16:='';
T17:='';
T18:='';
T19:='';
T20:='';
T21:='';
T22:='';
T23:='';
T24:='';
T25:='';

end.