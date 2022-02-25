unit DEVICE_EL_VL_SCHEMA5_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:Boolean;(*'Подвал'*)
T2:Boolean;(*'1 этаж'*)
T3:Boolean;(*'2 этаж'*)
T4:Boolean;(*'3 этаж'*)
T5:Boolean;(*'4 этаж'*)
T6:Boolean;(*'5 этаж'*)
T7:Boolean;(*'6 этаж'*)
T8:Boolean;(*'7 этаж'*)
T9:Boolean;(*'8 этаж'*)
T10:Boolean;(*'9 этаж'*)
T11:Boolean;(*'10 этаж'*)
T12:Boolean;(*'11 этаж'*)
T13:Boolean;(*'12 этаж'*)
T14:Boolean;(*'13 этаж'*)
T15:Boolean;(*'14 этаж'*)
T16:Boolean;(*'15 этаж'*)
T17:Boolean;(*'16 этаж'*)
T18:Boolean;(*'17 этаж'*)
T19:Boolean;(*'18 этаж'*)
T20:Boolean;(*'19 этаж'*)
T21:Boolean;(*'20 этаж'*)

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