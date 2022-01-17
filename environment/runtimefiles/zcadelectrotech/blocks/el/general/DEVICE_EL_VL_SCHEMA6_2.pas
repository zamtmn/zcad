unit DEVICE_EL_VL_SCHEMA6_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:GDBBoolean;(*'Подвал'*)
T2:GDBBoolean;(*'1 этаж'*)
T3:GDBBoolean;(*'2 этаж'*)
T4:GDBBoolean;(*'3 этаж'*)
T5:GDBBoolean;(*'4 этаж'*)
T6:GDBBoolean;(*'5 этаж'*)
T7:GDBBoolean;(*'6 этаж'*)
T8:GDBBoolean;(*'7 этаж'*)
T9:GDBBoolean;(*'8 этаж'*)

T31:GDBInteger;(*'Щит'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ЭТ0';
NMO_BaseName:='ЭТ';
NMO_Suffix:='??';

T1:=True;
T2:=False;
T3:=False;
T4:=False;
T5:=False;
T6:=False;
T7:=False;
T8:=False;
T9:=False;

T31:=1;

end.