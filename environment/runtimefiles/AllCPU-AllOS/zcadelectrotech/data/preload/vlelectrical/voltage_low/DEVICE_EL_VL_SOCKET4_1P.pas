unit DEVICE_EL_VL_SOCKET4_1P;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;
usescopy objgroup;
usescopy addtocable;

var

VL_Type:String;(*'Розетка'*)
VL_Room:String;(*'Помещение'*)
VL_Floor:String;(*'Этаж'*)
VL_Group:String;(*'Группа'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Розетка';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='Гр0';
NMO_BaseName:='';
NMO_Suffix:='';

SerialConnection:=1;
GC_HeadDevice:='ЩО??';
GC_HDShortName:='??';
GC_HDGroup:=0;

VL_Type:='Р СП/1 ip20';
VL_Room:='.';
VL_Floor:='0';

end.