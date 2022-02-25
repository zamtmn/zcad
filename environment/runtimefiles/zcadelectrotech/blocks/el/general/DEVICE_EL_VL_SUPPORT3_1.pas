unit DEVICE_EL_VL_SUPPORT3_1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;
usescopy objgroup;
usescopy addtocable;

var

T1:String;(*'Питающая фаза'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_светильник';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ОП0';
NMO_BaseName:='ОП';
NMO_Suffix:='??';

SerialConnection:=1;
GC_HeadDevice:='ЩНО??';
GC_HDShortName:='??';
GC_HDGroup:=0;

end.