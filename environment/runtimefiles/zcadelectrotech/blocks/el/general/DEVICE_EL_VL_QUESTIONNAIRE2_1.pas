unit DEVICE_EL_VL_QUESTIONNAIRE2_1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Ном. напряжение'*)
T2:String;(*'Ток сборных шин'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Опросник';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ОП0';
NMO_BaseName:='ОП';
NMO_Suffix:='??';

T1:='6/10';
T2:='630/1000';

end.