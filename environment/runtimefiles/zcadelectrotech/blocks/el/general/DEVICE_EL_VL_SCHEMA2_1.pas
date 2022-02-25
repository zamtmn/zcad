
unit DEVICE_EL_VL_SCHEMA2_1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Обозначение 1'*)
T2:String;(*'Марка 1'*)
T3:String;(*'Параметры 1'*)
T4:String;(*'Обозначение 2'*)
T5:String;(*'Марка 2'*)
T6:String;(*'Параметры 2'*)
T7:String;(*'Обозначение 3'*)
T8:String;(*'Марка 3'*)
T9:String;(*'Параметры 3'*)
T10:String;(*'Кабель 1.1'*)
T11:String;(*'Кабель 1.2'*)
T12:String;(*'Кабель 2.1'*)
T13:String;(*'Кабель 2.2'*)
T14:String;(*'Номер группы'*)
T15:String;(*'Расчетная мощность'*)
T16:String;(*'Расчетный ток'*)
T17:String;(*'Наименование'*)
T18:String;(*'Расчетная мощность'*)
T19:String;(*'Расчетный ток'*)
T20:String;(*'Косинус нагрузки'*)

T21:Boolean;(*'Шина 1'*)
T22:Boolean;(*'Шина 2'*)
T23:Boolean;(*'Аппарат 1'*)
T24:Boolean;(*'Аппарат 2'*)
T25:Boolean;(*'Переход 1'*)
T26:Boolean;(*'Переход 2'*)
T27:Boolean;(*'Кабель 1'*)
T28:Boolean;(*'Кабель 2'*)

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