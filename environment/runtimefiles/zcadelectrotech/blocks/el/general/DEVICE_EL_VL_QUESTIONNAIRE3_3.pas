unit DEVICE_EL_VL_QUESTIONNAIRE3_3;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Порядковый номер'*)
T2:String;(*'Тип панели'*)
T3:String;(*'Назначение линии'*)
T4:String;(*'Авт.выключатель, тип'*)
T5:String;(*'Авт.выключатель, ном.ток'*)
T6:String;(*'Рубильник, тип'*)
T7:String;(*'Рубильник, ном.ток'*)
T8:String;(*'Предохранитель, тип'*)
T9:String;(*'Предохранитель, ном.ток'*)
T10:String;(*'Расцепитель тепловой'*)
T11:String;(*'Расцепитель эл.магнитный'*)
T12:String;(*'Трансф.тока, тип'*)
T13:String;(*'Трансф.тока, ном.ток'*)
T14:String;(*'Амперметр, тип'*)
T15:String;(*'Амперметр, ном.ток'*)
T16:String;(*'Вольтмерт, тип'*)
T17:String;(*'Вольтметр, ном.напр'*)
T18:String;(*'Счетчик, тип'*)
T19:String;(*'Счетчик, ном.ток'*)
T20:String;(*'ОПН, тип'*)
T21:String;(*'ОПН, ном.напр'*)
T22:String;(*'Кабель, марка'*)
T23:String;(*'Кабель, сечение'*)
T24:String;(*'Габаритные размеры'*)
T25:String;(*'Наличие АВР'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Опросник';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ОН0';
NMO_BaseName:='ОН';
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
T22:='?';
T23:='?';
T24:='?';
T25:='?';

end.