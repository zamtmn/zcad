unit DEVICE_EL_VL_REPORT4_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Number:String;(*'Позиция'*)
VL_Name:String;(*'Наименование'*)
VL_Quantity:String;(*'Количество'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВУ0';
NMO_BaseName:='ВУ';
NMO_Suffix:='??';

VL_Number:='??';
VL_Name:='??';
VL_Quantity:='??';

end.