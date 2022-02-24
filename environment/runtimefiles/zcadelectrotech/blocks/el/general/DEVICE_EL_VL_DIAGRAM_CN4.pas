unit DEVICE_EL_VL_DIAGRAM_CN4;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T11:Integer;(*'123'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Шина';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='CN0';
NMO_BaseName:='CN';
NMO_Suffix:='??';
NMO_Affix:='';

T11:=3;

end.