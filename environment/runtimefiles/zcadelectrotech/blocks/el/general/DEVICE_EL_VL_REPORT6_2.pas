unit DEVICE_EL_VL_REPORT6_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:GDBString;(*'Аппарат 1'*)
T2:GDBString;(*'Аппарат 2'*)
T3:GDBString;(*'Кабель 1 обозначение'*)
T4:GDBString;(*'Кабель 1 марка'*)
T5:GDBString;(*'Кабель 1 сечение'*)
T6:GDBString;(*'Кабель 1 длина'*)
T7:GDBString;(*'Труба 1 обозначение'*)
T8:GDBString;(*'Труба 1 длина'*)
T9:GDBString;(*'Кабель 2 обозначение'*)
T10:GDBString;(*'Кабель 2 марка'*)
T11:GDBString;(*'Кабель 2 сечение'*)
T12:GDBString;(*'Кабель 2 длина'*)
T13:GDBString;(*'Труба 2 обозначение'*)
T14:GDBString;(*'Труба 2 длина'*)
T15:GDBString;(*'Эл.применик обозначение'*)
T16:GDBString;(*'Эл.применик мощность кВт'*)
T17:GDBString;(*'Эл.применик ток, А'*)
T18:GDBString;(*'Эл.применик наименование'*)

T20:GDBString;(*'Схема шина'*)
T21:GDBString;(*'Схема аппарат 1'*)
T22:GDBString;(*'Схема кабель 1'*)
T23:GDBString;(*'Схема аппарат 2'*)
T24:GDBString;(*'Схема кабель 2'*)
T25:GDBString;(*'Схема кабель 3'*)
T26:GDBString;(*'Схема переход 1'*)
T27:GDBString;(*'Схема переход 2'*)
T28:GDBString;(*'Схема переход 3'*)
T29:GDBString;(*'Схема номер 1'*)
T30:GDBString;(*'Схема номер 2'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='РС0';
NMO_BaseName:='РС';
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

end.