unit DEVICE_EL_VL_SCHEMA5_2;

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
VL_Floor10:Boolean;(*'9 этаж'*)
VL_Floor11:Boolean;(*'10 этаж'*)
VL_Floor12:Boolean;(*'11 этаж'*)
VL_Floor13:Boolean;(*'12 этаж'*)
VL_Floor14:Boolean;(*'13 этаж'*)
VL_Floor15:Boolean;(*'14 этаж'*)
VL_Floor16:Boolean;(*'15 этаж'*)
VL_Floor17:Boolean;(*'16 этаж'*)
VL_Floor18:Boolean;(*'17 этаж'*)
VL_Floor19:Boolean;(*'18 этаж'*)
VL_Floor20:Boolean;(*'19 этаж'*)
VL_Floor21:Boolean;(*'20 этаж'*)
VL_Floor22:Boolean;(*'21 этаж'*)
VL_Floor23:Boolean;(*'22 этаж'*)
VL_Floor24:Boolean;(*'23 этаж'*)
VL_Floor25:Boolean;(*'24 этаж'*)
VL_Floor26:Boolean;(*'25 этаж'*)
VL_Floor27:Boolean;(*'26 этаж'*)
VL_Floor28:Boolean;(*'27 этаж'*)
VL_Floor29:Boolean;(*'28 этаж'*)
VL_Floor30:Boolean;(*'29 этаж'*)
VL_Floor31:Boolean;(*'30 этаж'*)
VL_Floor32:Boolean;(*'31 этаж'*)
VL_Floor33:Boolean;(*'32 этаж'*)
VL_Floor34:Boolean;(*'33 этаж'*)
VL_Floor35:Boolean;(*'34 этаж'*)
VL_Floor36:Boolean;(*'35 этаж'*)
VL_Floor37:Boolean;(*'36 этаж'*)

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
VL_Floor10:=False;
VL_Floor11:=False;
VL_Floor12:=False;
VL_Floor13:=False;
VL_Floor14:=False;
VL_Floor15:=False;
VL_Floor16:=False;
VL_Floor17:=False;
VL_Floor18:=False;
VL_Floor19:=False;
VL_Floor20:=False;
VL_Floor21:=False;
VL_Floor22:=False;
VL_Floor23:=False;
VL_Floor24:=False;
VL_Floor25:=False;
VL_Floor26:=False;
VL_Floor27:=False;
VL_Floor28:=False;
VL_Floor29:=False;
VL_Floor30:=False;
VL_Floor31:=False;
VL_Floor32:=False;
VL_Floor33:=False;
VL_Floor34:=False;
VL_Floor35:=False;
VL_Floor36:=False;
VL_Floor37:=False;

VL_Shield:=1;

end.