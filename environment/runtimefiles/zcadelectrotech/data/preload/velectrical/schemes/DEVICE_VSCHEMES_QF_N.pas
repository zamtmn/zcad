unit DEVICE_VSCHEMES_QF_N;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;
usescopy vspecification;

var

VSCHEMAUGOtext:String;(*'Обозначение'*)

implementation

begin
BTY_TreeCoord:='PLAN_VEL_Схемы_АВ+N';

VSCHEMAUGOtext:='??\P??\P??';
VSPECIFICATION_Position:='QF';
VSPECIFICATION_Name:='Автоматический выключатель, 4P';
VSPECIFICATION_Brand:='';
VSPECIFICATION_Article:='';
VSPECIFICATION_Factoryname:='';
VSPECIFICATION_Unit:='шт.';
VSPECIFICATION_Count:=1;
VSPECIFICATION_Weight:='';
VSPECIFICATION_Note:='';
VSPECIFICATION_Grouping:='??';
VSPECIFICATION_Belong:='';
end.