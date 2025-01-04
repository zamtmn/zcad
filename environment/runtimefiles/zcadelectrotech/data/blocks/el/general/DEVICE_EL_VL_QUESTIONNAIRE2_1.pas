unit DEVICE_EL_VL_QUESTIONNAIRE2_1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Un:String;(*'Ном. напряжение'*)
VL_In:String;(*'Ток сборных шин'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Опросник';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ОВ.0';
NMO_BaseName:='ОВ.';
NMO_Suffix:='??';

VL_Un:='?';
VL_In:='?';

end.