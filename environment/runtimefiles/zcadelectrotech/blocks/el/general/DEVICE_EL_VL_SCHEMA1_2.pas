
unit DEVICE_EL_VL_SCHEMA1_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:GDBString;(*'Обозначение 1'*)
T2:GDBString;(*'Марка 1'*)
T3:GDBString;(*'Параметры 1'*)
T4:GDBString;(*'Обозначение 2'*)
T5:GDBString;(*'Марка 2'*)
T6:GDBString;(*'Параметры 2'*)
T7:GDBString;(*'Обозначение 3'*)
T8:GDBString;(*'Марка 3'*)
T9:GDBString;(*'Параметры 3'*)
T10:GDBString;(*'Кабель 1.1'*)
T11:GDBString;(*'Кабель 1.2'*)
T12:GDBString;(*'Кабель 2.1'*)
T13:GDBString;(*'Кабель 2.2'*)
T14:GDBString;(*'Номер группы'*)
T15:GDBString;(*'Расчетная мощность'*)
T16:GDBString;(*'Расчетный ток'*)
T17:GDBString;(*'Наименование'*)
T18:GDBString;(*'Расчетная мощность'*)
T19:GDBString;(*'Расчетный ток'*)
T20:GDBString;(*'Косинус нагрузки'*)

T21:GDBBoolean;(*'Шина 1'*)
T22:GDBBoolean;(*'Шина 2'*)
T23:GDBBoolean;(*'Аппарат 1'*)
T24:GDBBoolean;(*'Аппарат 2'*)
T25:GDBBoolean;(*'Переход 1'*)
T26:GDBBoolean;(*'Переход 2'*)
T27:GDBBoolean;(*'Кабель 1'*)
T28:GDBBoolean;(*'Кабель 2'*)

T31:Integer;(*'Аппарат 1'*)
T32:Integer;(*'Аппарат 2'*)
T33:Integer;(*'Аппарат 3'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='РЛ0';
NMO_BaseName:='РЛ';
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
T16:='??';
T17:='??';
T18:='??';
T19:='??';
T20:='??';

T21:=True;
T22:=False;
T23:=True;
T24:=False;
T25:=False;
T26:=False;
T27:=False;
T28:=False;

T31:=1;
T32:=0;
T33:=0;

end.