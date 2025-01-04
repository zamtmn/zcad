unit DEVICE_EL_VL_QUESTIONNAIRE3_3;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Number:String;(*'Порядковый номер'*)
VL_Type:String;(*'Тип панели'*)
VL_Mark:String;(*'Назначение линии'*)
VL_QF1:String;(*'Авт.выключатель, тип'*)
VL_QF2:String;(*'Авт.выключатель, ном.ток'*)
VL_QS1:String;(*'Рубильник, тип'*)
VL_QS2:String;(*'Рубильник, ном.ток'*)
VL_FU1:String;(*'Предохранитель, тип'*)
VL_FU2:String;(*'Предохранитель, ном.ток'*)
VL_Term:String;(*'Расцепитель тепловой'*)
VL_ElMag:String;(*'Расцепитель эл.магнитный'*)
VL_TT1:String;(*'Трансф.тока, тип'*)
VL_TT2:String;(*'Трансф.тока, ном.ток'*)
VL_PI1:String;(*'Амперметр, тип'*)
VL_PI2:String;(*'Амперметр, ном.ток'*)
VL_PV1:String;(*'Вольтмерт, тип'*)
VL_PV2:String;(*'Вольтметр, ном.напр'*)
VL_Wh1:String;(*'Счетчик, тип'*)
VL_Wh2:String;(*'Счетчик, ном.ток'*)
VL_UR1:String;(*'ОПН, тип'*)
VL_UR2:String;(*'ОПН, ном.напр'*)
VL_L1:String;(*'Кабель, марка'*)
VL_L2:String;(*'Кабель, сечение'*)
VL_Size:String;(*'Габаритные размеры'*)
VL_AVR:String;(*'Наличие АВР'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Опросник';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ОН0';
NMO_BaseName:='ОН';
NMO_Suffix:='??';

VL_Number:='?';
VL_Type:='?';
VL_Mark:='?';
VL_QF1:='?';
VL_QF2:='?';
VL_QS1:='?';
VL_QS2:='?';
VL_FU1:='?';
VL_FU2:='?';
VL_Term:='?';
VL_ElMag:='?';
VL_TT1:='?';
VL_TT2:='?';
VL_PI1:='?';
VL_PI2:='?';
VL_PV1:='?';
VL_PV2:='?';
VL_Wh1:='?';
VL_Wh2:='?';
VL_UR1:='?';
VL_UR2:='?';
VL_L1:='?';
VL_L2:='?';
VL_Size:='?';
VL_AVR:='?';

end.