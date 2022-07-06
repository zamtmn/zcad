unit DEVICE_EL_VL_LIGHT4_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname_eo;
usescopy objgroup;
usescopy _addtocable;

var

VL_Code:String;(*'Код'*)
VL_Type:String;(*'Светильник'*)
VL_Room:String;(*'Помещение'*)
VL_Group:String;(*'Группа'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Светильник';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='Гр0';
NMO_BaseName:='Гр';
NMO_Suffix:='??';

SerialConnection:=1;
GC_HeadDevice:='ЩАО??';
GC_HDShortName:='??';
GC_HDGroup:=0;

VL_Code:='А';
VL_Room:='.';

end.