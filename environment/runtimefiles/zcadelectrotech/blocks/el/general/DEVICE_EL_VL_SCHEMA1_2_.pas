unit DEVICE_EL_VL_SCHEMA1_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Аппарат 1'*)
T2:String;(*'Аппарат 2'*)
T3:String;(*'Кабель 1 обозначение'*)
T4:String;(*'Кабель 1 марка'*)
T5:String;(*'Кабель 1 сечение'*)
T6:String;(*'Кабель 1 длина'*)
T7:String;(*'Труба 1 обозначение'*)
T8:String;(*'Труба 1 длина'*)
T9:String;(*'Кабель 2 обозначение'*)
T10:String;(*'Кабель 2 марка'*)
T11:String;(*'Кабель 2 сечение'*)
T12:String;(*'Кабель 2 длина'*)
T13:String;(*'Труба 2 обозначение'*)
T14:String;(*'Труба 2 длина'*)
T15:String;(*'Эл.применик обозначение'*)
T16:String;(*'Эл.применик мощность кВт'*)
T17:String;(*'Эл.применик ток, А'*)
T18:String;(*'Эл.применик наименование'*)

T20:Boolean;(*'Схема шина 1'*)
T21:Boolean;(*'Схема аппарат 1'*)
T22:Boolean;(*'Схема кабель 1'*)
T23:Boolean;(*'Схема аппарат 2'*)
T24:Boolean;(*'Схема кабель 2'*)
T25:Boolean;(*'Схема кабель 3'*)
T26:Boolean;(*'Схема переход 1'*)
T27:Boolean;(*'Схема переход 2'*)
T28:Boolean;(*'Схема переход 3'*)
T29:String;(*'Схема номер 1'*)
T30:String;(*'Схема номер 2'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='РС0';
NMO_BaseName:='РС';
NMO_Suffix:='??';

end.