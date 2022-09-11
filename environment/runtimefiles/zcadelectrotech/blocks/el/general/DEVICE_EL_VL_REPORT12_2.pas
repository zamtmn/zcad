unit DEVICE_EL_VL_REPORT12_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Обозначение'*)
T2:String;(*'Начало'*)
T3:String;(*'Конец'*)
T4:String;(*'Тип прокладки'*)
T5:String;(*'Марка'*)
T6:String;(*'Кол. и сечение жил'*)
T7:String;(*'Длина'*)
T8:String;(*'Мощность'*)
T9:String;(*'Ток'*)
T10:String;(*'Аппарат'*)
T11:String;(*'Трансформатор'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='КЖ0';
NMO_BaseName:='КЖ';
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

end.