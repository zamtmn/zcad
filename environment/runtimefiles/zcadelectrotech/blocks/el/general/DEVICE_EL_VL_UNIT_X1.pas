unit DEVICE_EL_VL_UNIT_X1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Клемник'*)
T2:String;(*'Расшифровка'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Аппаратура';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='X0';
NMO_BaseName:='X';
NMO_Suffix:='??';
NMO_Affix:='';

T1:='';

end.