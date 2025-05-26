unit DEVICE_EL_VL_DIAGRAM_SH1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Mark:String;(*'Обозначение'*)
VL_Type:String;(*'Марка'*)
VL_Data:String;(*'Параметры'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Аппаратура';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='А0';
NMO_BaseName:='А';
NMO_Suffix:='??';
NMO_Affix:='.11';

VL_Mark:='??';
VL_Type:='??';
VL_Data:='??';

end.