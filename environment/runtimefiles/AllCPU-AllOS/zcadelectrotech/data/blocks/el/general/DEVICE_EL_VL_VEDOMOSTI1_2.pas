unit DEVICE_EL_VL_VEDOMOSTI1_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Sheet:String;(*'Лист'*)
VL_Name:String;(*'Наименование'*)
VL_Note:String;(*'Примечание'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Штамп';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ВЧ0';
NMO_BaseName:='ВЧ';
NMO_Suffix:='??';

VL_Sheet:='??';
VL_Name:='??';
VL_Note:='??';

end.