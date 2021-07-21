unit DEVICE_EL_VL_DIAGRAM_QF1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:GDBString;(*'Обозначение'*)
T2:GDBString;(*'Марка'*)
T3:GDBString;(*'Параметры'*)
T4:GDBString;(*'Эл.терм.уставка'*)
T5:GDBString;(*'Эл.маг.уставка'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Аппаратура';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='A0';
NMO_BaseName:='A1.';
NMO_Suffix:='??';

T1:='??';
T2:='??';
T3:='??';
T4:='';
T5:='';

end.