unit DEVICE_EL_VL_DIAGRAM_FD4_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_PyP:String;(*'P установленная'*)
VL_PpP:String;(*'P расчетная'*)
VL_IaP:String;(*'I расчетный'*)
VL_CosP:String;(*'Cos Ф'*)
VL_PyA:String;(*'P(A) установленная'*)
VL_PpA:String;(*'P(A) расчетная'*)
VL_IaA:String;(*'I(A) расчетный'*)
VL_CosA:String;(*'Cos(A) Ф'*)
VL_PyLZ:String;(*'P(Л/З) установленная'*)
VL_PpLZ:String;(*'P(Л/З) расчетная'*)
VL_IaLZ:String;(*'I(Л/З) расчетный'*)
VL_CosLZ:String;(*'Cos(Л/З) Ф'*)

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
VL_CosP:='??';
VL_PyA:='??';
VL_PpA:='??';
VL_IaA:='??';
VL_CosA:='??';
VL_PyLZ:='??';
VL_PpLZ:='??';
VL_IaLZ:='??';
VL_CosLZ:='??';

end.