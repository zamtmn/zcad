unit DEVICE_EL_VL_DEVICE_MOTOR;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;
usescopy objgroup;
usescopy addtocable;

var

VL_Type:String;(*'Эл.двигатель'*)
VL_Room:String;(*'Помещение'*)
VL_Floor:String;(*'Этаж'*)
VL_Group:String;(*'Группа'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Эл.применик';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='М0';
NMO_BaseName:='М';
NMO_Suffix:='';

SerialConnection:=1;
GC_HeadDevice:='ЩО??';
GC_HDShortName:='??';
GC_HDGroup:=0;

VL_Type:='ЭМ/1';
VL_Room:='.';
VL_Floor:='0';

end.