unit DEVICE_EL_VL_LINE3_5;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;
usescopy objgroup;
usescopy addtocable;

var

VL_Code:String;(*'Код'*)
VL_Type:String;(*'Светильник'*)
VL_Room:String;(*'Помещение'*)
VL_Floor:String;(*'Этаж'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_светильник';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='СВ0';
NMO_BaseName:='СВ';
NMO_Suffix:='??';

SerialConnection:=1;
GC_HeadDevice:='ЩНО??';
GC_HDShortName:='??';
GC_HDGroup:=0;

VL_Room:='.';
VL_Floor:='0';

end.