unit DEVICE_EL_VL_DIAGRAM_FD3_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_PyP:String;(*'P установленная'*)
VL_PpP:String;(*'P расчетная'*)
VL_IaP:String;(*'I фаза А'*)
VL_IbP:String;(*'I фаза В'*)
VL_IcP:String;(*'I фаза С'*)
VL_CosP:String;(*'Cos Ф'*)
VL_PyA:String;(*'P(A) установленная'*)
VL_PpA:String;(*'P(A) расчетная'*)
VL_IaA:String;(*'I(A) фаза А'*)
VL_IbA:String;(*'I(A) фаза В'*)
VL_IcA:String;(*'I(A) фаза С'*)
VL_CosA:String;(*'Cos(A) Ф'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Фидер';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ФД0';
NMO_BaseName:='ФД';
NMO_Suffix:='??';

VL_PyP:='??';
VL_PpP:='??';
VL_IaP:='??';
VL_IbP:='??';
VL_IcP:='??';
VL_CosP:='??';
VL_PyA:='??';
VL_PpA:='??';
VL_IaA:='??';
VL_IbA:='??';
VL_IcA:='??';
VL_CosA:='??';

end.