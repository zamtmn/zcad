unit DEVICE_EL_VL_DIAGRAM_TM1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Тип'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Трансформатор';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ТМ0';
NMO_BaseName:='ТМ';
NMO_Suffix:='??';

T1:='??';

end.