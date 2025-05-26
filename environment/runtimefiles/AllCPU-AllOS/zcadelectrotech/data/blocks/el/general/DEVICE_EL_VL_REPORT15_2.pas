unit DEVICE_EL_VL_REPORT15_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_PanelF:String;(*'Щит'*)
VL_PanelK:String;(*'Нагрузка'*)
VL_Name:String;(*'Расшифровка'*)
VL_Phase:String;(*'Фаза'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВЭ0';
NMO_BaseName:='ВЭ';
NMO_Suffix:='??';

VL_PanelF:='??';
VL_PanelK:='??';
VL_Name:='??';
VL_Phase:='??';

end.