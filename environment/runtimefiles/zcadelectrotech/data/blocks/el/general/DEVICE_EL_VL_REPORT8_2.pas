unit DEVICE_EL_VL_REPORT8_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Room:String;(*'Помещение'*)
VL_Light:String;(*'Освещенность'*)
VL_Lamp:String;(*'Светильник'*)
VL_Power:String;(*'Мощность'*)
VL_Quantity:String;(*'Количество'*)
VL_Height:String;(*'Высота'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВС0';
NMO_BaseName:='ВС';
NMO_Suffix:='??';

VL_Room:='??';
VL_Light:='??';
VL_Lamp:='??';
VL_Power:='??';
VL_Quantity:='??';
VL_Height:='??';

end.