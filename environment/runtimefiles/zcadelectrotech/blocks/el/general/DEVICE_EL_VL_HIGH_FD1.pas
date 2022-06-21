unit DEVICE_EL_VL_HIGH_FD1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Обозначение'*)
T2:String;(*'Камера'*)
T3:String;(*'Номер'*)
T4:String;(*'P активная'*)
T5:String;(*'I расчетный'*)
T6:String;(*'Cos Ф'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Фидер';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ФВ0';
NMO_BaseName:='ФВ';
NMO_Suffix:='??';

T1:='??';
T2:='??';
T3:='??';
T4:='??';
T5:='??';
T6:='??';

end.