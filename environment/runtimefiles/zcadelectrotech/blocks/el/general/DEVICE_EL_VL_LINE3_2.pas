unit DEVICE_EL_VL_LINE3_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;
usescopy objgroup;
usescopy addtocable;

var

VL_Type:String;(*'Опора'*)
VL_Room:String;(*'Помещение'*)
VL_Floor:String;(*'Этаж'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_светильник';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ОП0';
NMO_BaseName:='ОП';
NMO_Suffix:='??';

SerialConnection:=1;
GC_HeadDevice:='ЩНО??';
GC_HDShortName:='??';
GC_HDGroup:=0;

VL_Room:='.';
VL_Floor:='0';

end.