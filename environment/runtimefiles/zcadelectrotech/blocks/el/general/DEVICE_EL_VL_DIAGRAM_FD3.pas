unit DEVICE_EL_VL_DIAGRAM_FD3;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T5:String;(*'P установленная'*)
T6:String;(*'P расчетная'*)
T7:String;(*'I фаза А'*)
T8:String;(*'I фаза В'*)
T9:String;(*'I фаза С'*)
T10:String;(*'Cos Ф'*)
T13:String;(*'P(А) установленная'*)
T14:String;(*'P(А) расчетная'*)
T15:String;(*'I(А) фаза А'*)
T16:String;(*'I(А) фаза В'*)
T17:String;(*'I(А) фаза С'*)
T18:String;(*'Cos Ф(А)'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Фидер';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ФД0';
NMO_BaseName:='ФД';
NMO_Suffix:='??';

T5:='??';
T6:='??';
T7:='??';
T8:='??';
T9:='??';
T10:='??';
T13:='??';
T14:='??';
T15:='??';
T16:='??';
T17:='??';
T18:='??';

end.