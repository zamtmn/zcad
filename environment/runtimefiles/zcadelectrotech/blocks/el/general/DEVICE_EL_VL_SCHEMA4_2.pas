unit DEVICE_EL_VL_SCHEMA4_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Floor1:Boolean;(*'Подвал'*)
VL_Floor2:Boolean;(*'1 этаж'*)
VL_Floor3:Boolean;(*'2 этаж'*)
VL_Floor4:Boolean;(*'3 этаж'*)
VL_Floor5:Boolean;(*'4 этаж'*)
VL_Floor6:Boolean;(*'5 этаж'*)
VL_Floor7:Boolean;(*'6 этаж'*)
VL_Floor8:Boolean;(*'7 этаж'*)
VL_Floor9:Boolean;(*'8 этаж'*)

VL_Shield:Integer;(*'Щит'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ЭТ0';
NMO_BaseName:='ЭТ';
NMO_Suffix:='??';

VL_Floor1:=True;
VL_Floor2:=False;
VL_Floor3:=False;
VL_Floor4:=False;
VL_Floor5:=False;
VL_Floor6:=False;
VL_Floor7:=False;
VL_Floor8:=False;
VL_Floor9:=False;

VL_Shield:=1;

end.