unit DEVICE_EL_VL_UNIT_X1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Klemnik:String;(*'Клемник'*)
VL_Mark:String;(*'Расшифровка'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Аппаратура';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='X0';
NMO_BaseName:='X';
NMO_Suffix:='??';
NMO_Affix:='';

VL_Klemnik:='';
VL_Mark:='';

end.