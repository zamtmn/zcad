unit DEVICE_EL_VL_UNIT_CH1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:GDBString;(*'Сноска'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Аппаратура';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='СХ0';
NMO_BaseName:='СХ';
NMO_Suffix:='??';
NMO_Affix:='.CH';

T1:='??';

end.