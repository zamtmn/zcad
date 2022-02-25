unit DEVICE_EL_VL_CONNECTOR1_2P_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname_eo;
usescopy objgroup;
usescopy addtocable;

var

T1:String;(*'Группа'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Розетка';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='Гр0';
NMO_BaseName:='Гр';
NMO_Suffix:='??';

SerialConnection:=1;
GC_HeadDevice:='ЩО??';
GC_HDShortName:='??';
GC_HDGroup:=0;

end.