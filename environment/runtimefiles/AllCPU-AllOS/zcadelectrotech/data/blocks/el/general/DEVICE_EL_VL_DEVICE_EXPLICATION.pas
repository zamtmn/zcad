unit DEVICE_EL_VL_DEVICE_EXPLICATION;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;
usescopy objgroup;
usescopy addtocable;

var

VL_Room:String;(*'Помещение'*)
VL_Floor:String;(*'Этаж'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Эл.применик';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ЭК.0';
NMO_BaseName:='ЭК.';
NMO_Suffix:='';

SerialConnection:=1;
GC_HeadDevice:='ЩО??';
GC_HDShortName:='??';
GC_HDGroup:=0;

VL_Room:='1';
VL_Floor:='0';

end.