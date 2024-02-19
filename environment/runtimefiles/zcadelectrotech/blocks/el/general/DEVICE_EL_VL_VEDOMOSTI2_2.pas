unit DEVICE_EL_VL_VEDOMOSTI2_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T3:String;(*'Обозначение'*)
T5:String;(*'Наименование'*)
T6:String;(*'Примечание'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='СД0';
NMO_BaseName:='СД';
NMO_Suffix:='??';

T3:='??';
T5:='??';
T6:='';

end.