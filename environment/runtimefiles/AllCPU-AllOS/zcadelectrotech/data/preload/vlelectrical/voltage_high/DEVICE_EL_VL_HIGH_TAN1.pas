unit DEVICE_EL_VL_HIGH_TAN1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Mark:String;(*'Обозначение'*)
VL_Type:String;(*'Марка'*)
VL_Data:String;(*'Параметры'*)
VL_Busbar:Integer;(*'Схема'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Аппаратура';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='В0';
NMO_BaseName:='В';
NMO_Suffix:='??';
NMO_Affix:='.13';

VL_Mark:='??';
VL_Type:='??';
VL_Data:='??';
VL_Busbar:=1;

end.