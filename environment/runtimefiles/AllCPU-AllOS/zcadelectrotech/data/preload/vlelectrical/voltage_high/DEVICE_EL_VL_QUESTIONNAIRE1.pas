unit DEVICE_EL_VL_QUESTIONNAIRE1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_T1:String;(*'Заказчик'*)
VL_T2:String;(*'Данные 1'*)
VL_T3:String;(*'Данные 2'*)
VL_T4:String;(*'Данные 3'*)
VL_T5:String;(*'Количество ТМ'*)
VL_T6:String;(*'Мощность ТМ'*)
VL_T7:String;(*'Напряжение'*)
VL_T8:String;(*'Номиналбный ток'*)
VL_T9:String;(*'Группа соедиенеий'*)
VL_T10:String;(*'Поставка ТМ'*)
VL_T11:String;(*'Тип ввода'*)
VL_T12:String;(*'Тип вывода'*)
VL_T13:String;(*'Поставка РЛНД'*)
VL_T14:String;(*'Компановка'*)
VL_T15:String;(*'Однолин. схема'*)
VL_T16:String;(*'Поставка цоколя'*)
VL_T17:String;(*'Высота цоколя'*)
VL_T18:String;(*'Площадка ТМ'*)
VL_T19:String;(*'Площадка РУВН/РУНН'*)
VL_T20:String;(*'Поставка маслопримеников'*)
VL_T21:String;(*'Система водослива'*)
VL_T22:String;(*'Уличное освещение'*)
VL_T23:String;(*'Пожарная сигнализация'*)
VL_T24:String;(*'Вид исполнения'*)
VL_T25:String;(*'Вентиляция трансф.отсека'*)
VL_T26:String;(*'Вентиляция РУВН'*)
VL_T27:String;(*'Вентиляция РУНН'*)
VL_T28:String;(*'Цвет крыши'*)
VL_T29:String;(*'Цвет стен'*)
VL_T30:String;(*'Цвет дверей, ворот'*)
VL_T31:String;(*'Цвет цоколя'*)
VL_T32:String;(*'Доп. требования'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Опросник';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ОВ.0';
NMO_BaseName:='ОВ.';
NMO_Suffix:='??';

VL_T1:='';
VL_T2:='';
VL_T3:='';
VL_T4:='';
VL_T5:='2';
VL_T6:='6/10';
VL_T7:='1000';
VL_T8:='ТМГ';
VL_T9:='Y/Yн-0 Д/Yн-11';
VL_T10:='Да';
VL_T11:='Кабельный';
VL_T12:='Кабельный';
VL_T13:='Нет';
VL_T14:='В приложении';
VL_T15:='В приложении';
VL_T16:='Да';
VL_T17:='1200';
VL_T18:='Да';
VL_T19:='Да';
VL_T20:='Да';
VL_T21:='Да';
VL_T22:='Да';
VL_T23:='Да';
VL_T24:='Утепленный';
VL_T25:='Принудительная';
VL_T26:='Принудительная';
VL_T27:='Принудительная';
VL_T28:='RAL 5005 синий';
VL_T29:='RAL 9003 Белый';
VL_T30:='RAL 5005 синий';
VL_T31:='RAL 5005 синий';
VL_T32:='';

end.