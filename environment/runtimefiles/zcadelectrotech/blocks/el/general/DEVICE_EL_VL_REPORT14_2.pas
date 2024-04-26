unit DEVICE_EL_VL_REPORT14_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Point:String;(*'Наименование точки'*)
VL_PositionX:String;(*'Координата X'*)
VL_PositionY:String;(*'Координата Y'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВГ0';
NMO_BaseName:='ВГ';
NMO_Suffix:='??';

VL_Point:='??';
VL_PositionX:='??';
VL_PositionY:='??';

end.