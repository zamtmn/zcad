unit DEVICE_EL_VL_DIAGRAM_H7;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Phase:Integer;(*'123'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Кабель';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='Н0';
NMO_BaseName:='Н';
NMO_Suffix:='??';
NMO_Affix:='';

VL_Phase:=3;

end.