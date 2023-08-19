unit DEVICE_EL_VL_DIAGRAM_QF3;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Обозначение'*)
T2:String;(*'Марка'*)
T3:String;(*'Параметры'*)
T4:String;(*'Терм.уставка'*)
T5:String;(*'Эл.маг.уставка'*)

T11:Integer;(*'123'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Аппаратура';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='А0';
NMO_BaseName:='А';
NMO_Suffix:='??';
NMO_Affix:='.1';

T1:='??';
T2:='??';
T3:='??';
T4:='??';
T5:='??';

T11:=3;

end.