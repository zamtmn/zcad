unit DEVICE_EL_VL_TRANSFORM1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;
usescopy objgroup;
usescopy _addtocable;

implementation

begin

BTY_TreeCoord:='PLAN_EM_Двигатель';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ТП0';
NMO_BaseName:='ТП';
NMO_Suffix:='??';

SerialConnection:=1;
GC_HeadDevice:='ШР??';
GC_HDShortName:='??';
GC_HDGroup:=0;

end.