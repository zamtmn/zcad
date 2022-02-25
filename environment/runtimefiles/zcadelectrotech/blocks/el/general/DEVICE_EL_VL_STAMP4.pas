unit DEVICE_EL_VL_STAMP4;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T16:String;(*'Гип'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Штамп';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ШТ0';
NMO_BaseName:='ШТ';
NMO_Suffix:='??';

T16:='??';

end.