unit DEVICE_EL_VL_SCHEMA4_2;

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

T31:=1;

end.