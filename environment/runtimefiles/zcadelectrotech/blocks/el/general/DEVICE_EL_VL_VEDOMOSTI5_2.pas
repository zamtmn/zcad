unit DEVICE_EL_VL_VEDOMOSTI5_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Номер п/п'*)
T2:String;(*'Обозначение'*)
T3:String;(*'Наименование'*)
T4:String;(*'Версия'*)
T5:String;(*'Изменение'*)
T6:String;(*'Примечание'*)
T7:String;(*'Дата 1'*)
T8:String;(*'Разработал'*)
T9:String;(*'Проверил'*)
T10:String;(*'ГИП'*)
T11:String;(*'Директор'*)
T12:String;(*'Дата 2'*)
T13:String;(*'Лист'*)
T14:String;(*'Листов'*)


implementation

begin

BTY_TreeCoord:='PLAN_EM_Штамп';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ШТ0';
NMO_BaseName:='ШТ';
NMO_Suffix:='??';

T1:='1';
T2:='??';
T3:='??';
T4:='1';
T5:='';
T6:='';
T7:='??';
T8:='Абрамов';
T9:='??';
T10:='??';
T11:='??';
T12:='??';
T13:='1';
T14:='1';

end.