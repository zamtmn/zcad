unit DEVICE_EL_VL_SCHEMA5_2;

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
T10:GDBBoolean;(*'9 этаж'*)
T11:GDBBoolean;(*'10 этаж'*)
T12:GDBBoolean;(*'11 этаж'*)
T13:GDBBoolean;(*'12 этаж'*)
T14:GDBBoolean;(*'13 этаж'*)
T15:GDBBoolean;(*'14 этаж'*)
T16:GDBBoolean;(*'15 этаж'*)
T17:GDBBoolean;(*'16 этаж'*)
T18:GDBBoolean;(*'17 этаж'*)
T19:GDBBoolean;(*'18 этаж'*)
T20:GDBBoolean;(*'19 этаж'*)
T21:GDBBoolean;(*'20 этаж'*)

T31:Integer;(*'Щит'*)

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
T10:=False;
T11:=False;
T12:=False;
T13:=False;
T14:=False;
T15:=False;
T16:=False;
T17:=False;
T18:=False;
T19:=False;
T20:=False;
T21:=False;

T31:=1;

end.