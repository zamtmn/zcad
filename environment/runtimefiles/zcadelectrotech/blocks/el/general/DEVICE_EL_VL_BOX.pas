unit DEVICE_EL_VL_BOX;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;
usescopy objgroup;

implementation

begin

BTY_TreeCoord:='PLAN_EM_Коробка';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='Гр0';
NMO_BaseName:='Гр';
NMO_Suffix:='??';

SerialConnection:=1;
GC_HeadDevice:='ШО??';
GC_HDShortName:='??';
GC_HDGroup:=0;

end.