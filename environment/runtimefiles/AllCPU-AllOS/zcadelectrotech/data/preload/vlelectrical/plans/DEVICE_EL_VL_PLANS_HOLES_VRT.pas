unit DEVICE_EL_VL_PLANS_HOLES_VRT;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;
usescopy objgroup;
usescopy addtocable;

var

VL_BottomFloor:Double;(*'Отметка пола'*)
VL_HeightFloor:Double;(*'Высота перекрытия'*)
VL_HeightGap:Double;(*'Зазор до перекрытия'*)
VL_HeightHoles:Double;(*'Высота отверстия'*)


implementation

begin

BTY_TreeCoord:='PLAN_EM_Эл.применик';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ОТ.0';
NMO_BaseName:='ОТ';
NMO_Suffix:='';

SerialConnection:=1;
GC_HeadDevice:='ЩО??';
GC_HDShortName:='??';
GC_HDGroup:=0;

VL_BottomFloor:=0;
VL_HeightFloor:=0;
VL_HeightGap:=0.2;
VL_HeightHoles:=0.2;

end.