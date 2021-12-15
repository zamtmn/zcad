
unit DEVICE_EL_VL_SCHEMA2_1;

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
T10:GDBString;(*'Кабель 1'*)
T11:GDBString;(*'Кабель 2'*)
T12:GDBString;(*'Номер группы'*)
T13:GDBString;(*'Расчетная мощность'*)
T14:GDBString;(*'Расчетный ток'*)
T15:GDBString;(*'Наименование'*)
T16:GDBString;(*'Источник питания'*)
T17:GDBString;(*'Расчетная мощность'*)
T18:GDBString;(*'Расчетный ток'*)
T19:GDBString;(*'Косинус нагрузки'*)

T21:GDBBoolean;(*'Шина 1'*)
T22:GDBBoolean;(*'Шина 2'*)
T23:GDBBoolean;(*'Аппарат 1'*)
T24:GDBBoolean;(*'Аппарат 2'*)
T25:GDBBoolean;(*'Переход 1'*)
T26:GDBBoolean;(*'Переход 2'*)
T27:GDBBoolean;(*'Кабель 1'*)

T31:GDBInteger;(*'Аппарат 1'*)
T32:GDBInteger;(*'Аппарат 2'*)
T33:GDBInteger;(*'Аппарат 3'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='РЛ0';
NMO_BaseName:='РЛ';
NMO_Suffix:='??';

end.