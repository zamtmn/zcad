unit DEVICE_EL_VL_UNIT_QF4;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Обозначение'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Аппаратура';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='QF0';
NMO_BaseName:='QF';
NMO_Suffix:='??';
NMO_Affix:='';

T1:='';

end.