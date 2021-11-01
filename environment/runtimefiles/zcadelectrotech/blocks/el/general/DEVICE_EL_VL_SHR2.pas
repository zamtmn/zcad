unit DEVICE_EL_VL_SHR2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;
usescopy objgroup;
usescopy addtocable;

implementation

begin

BTY_TreeCoord:='PLAN_EM_Щит';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ЩР0';
NMO_BaseName:='ЩР';
NMO_Suffix:='??';

SerialConnection:=1;
GC_HeadDevice:='ЩР??';
GC_HDShortName:='??';
GC_HDGroup:=0;

end.