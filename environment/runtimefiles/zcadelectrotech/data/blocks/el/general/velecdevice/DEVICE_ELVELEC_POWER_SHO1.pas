unit DEVICE_ELVELEC_POWER_SHO1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname_eo;
usescopy objgroup;
usescopy addtocable;
usescopy elreceivers;

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

NMO_Name:='';
NMO_BaseName:='ЩО';
NMO_Suffix:='';
NMO_Prefix:='';
NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]';

SerialConnection:=1;
GC_HeadDevice:='ЩО??';
GC_HDShortName:='??';
GC_HDGroup:=0;

VL_Type:='Р СП/1 ip20';
VL_Room:='.';
VL_Floor:='.';

nametemplatesxlsx:='<zlight>';
end.