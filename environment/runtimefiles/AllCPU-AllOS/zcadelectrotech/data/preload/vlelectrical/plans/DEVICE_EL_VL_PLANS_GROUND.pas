unit DEVICE_EL_VL_PLANS_GROUND;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;
usescopy objgroup;
usescopy addtocable;

var

VL_InstallMark:Double;(*'Отметка установки'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Эл.применик';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ЗМ.0';
NMO_BaseName:='ЗМ';
NMO_Suffix:='';

SerialConnection:=1;
GC_HeadDevice:='ЩО??';
GC_HDShortName:='??';
GC_HDGroup:=0;

VL_InstallMark:=0;


end.