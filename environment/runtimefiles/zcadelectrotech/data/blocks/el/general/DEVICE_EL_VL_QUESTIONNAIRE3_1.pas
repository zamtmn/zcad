unit DEVICE_EL_VL_QUESTIONNAIRE3_1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Un:String;(*'Ном.напряжение'*)
VL_In:String;(*'Ток сборных шин'*)
VL_BusbarL:String;(*'Сечение сборных шин'*)
VL_BusbarN:String;(*'Сечение нулевых шин'*)
VL_AVR:String;(*'Наличие АВР'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Опросник';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ОН.0';
NMO_BaseName:='ОН.';
NMO_Suffix:='??';

VL_Un:='400';
VL_In:='?';
VL_BusbarL:='?';
VL_BusbarN:='?';
VL_AVR:='?';

end.