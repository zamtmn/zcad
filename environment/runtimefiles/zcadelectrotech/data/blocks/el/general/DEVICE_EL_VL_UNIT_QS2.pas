unit DEVICE_EL_VL_UNIT_QS2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Mark:String;(*'Обозначение'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Аппаратура';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='QS0';
NMO_BaseName:='QS';
NMO_Suffix:='??';
NMO_Affix:='';

VL_Mark:='';

end.