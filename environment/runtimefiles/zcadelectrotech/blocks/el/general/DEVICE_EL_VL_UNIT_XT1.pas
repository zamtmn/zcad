unit DEVICE_EL_VL_UNIT_XT1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Сноска'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Аппаратура';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='XT0';
NMO_BaseName:='';
NMO_Suffix:='';
NMO_Affix:='';

T1:='';

end.