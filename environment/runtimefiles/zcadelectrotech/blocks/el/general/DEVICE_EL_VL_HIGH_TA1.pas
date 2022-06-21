unit DEVICE_EL_VL_HIGH_TA1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Обозначение'*)
T2:String;(*'Марка'*)
T3:String;(*'Параметры'*)

T11:Integer;(*'Полюсов'*)
T12:Integer;(*'Обмоток'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Аппаратура';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='В0';
NMO_BaseName:='В';
NMO_Suffix:='??';
NMO_Affix:='.11';

T1:='??';
T2:='??';
T3:='??';

T11:=1;
T12:=1;

end.