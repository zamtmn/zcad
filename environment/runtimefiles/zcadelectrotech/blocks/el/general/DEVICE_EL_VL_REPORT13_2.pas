unit DEVICE_EL_VL_REPORT13_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Фидер'*)

T2:String;(*'Маркировка'*)
T3:String;(*'Тип аппарата'*)
T4:String;(*'Номинальный ток'*)
T5:String;(*'Теп. расцепитель'*)
T6:String;(*'Эл.маг. расцепитель'*)

T7:String;(*'Наибольший ток'*)
T8:String;(*'Коэф. запаса'*)
T9:String;(*'Ток с учетом запаса'*)

T10:String;(*'3-ф ток КЗ'*)
T11:String;(*'Ударный ток КЗ'*)
T12:String;(*'1-ф ток КЗ в начале'*)
T13:String;(*'1-ф ток КЗ в конце'*)
T14:String;(*'Порог теп.расцепителя'*)
T15:String;(*'Порог эл.маг.расцепителя'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВВ0';
NMO_BaseName:='ВВ';
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