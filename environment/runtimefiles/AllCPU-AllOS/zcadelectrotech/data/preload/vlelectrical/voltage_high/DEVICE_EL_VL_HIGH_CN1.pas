unit DEVICE_EL_VL_HIGH_CN1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Busbar:Integer;(*'Схема'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Шина';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='CN0';
NMO_BaseName:='CN';
NMO_Suffix:='??';
NMO_Affix:='';

VL_Busbar:=1;

end.