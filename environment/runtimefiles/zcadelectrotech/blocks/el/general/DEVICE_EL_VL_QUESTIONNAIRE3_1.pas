unit DEVICE_EL_VL_QUESTIONNAIRE3_1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Ном.напряжение'*)
T2:String;(*'Ток сборных шин'*)
T3:String;(*'Сечение сборных шин'*)
T4:String;(*'Сечение нулевых шин'*)
T5:String;(*'Наличие АВР'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Опросник';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ОН.0';
NMO_BaseName:='ОН.';
NMO_Suffix:='??';

T1:='400';
T2:='?';
T3:='?';
T4:='?';
T5:='?';

end.