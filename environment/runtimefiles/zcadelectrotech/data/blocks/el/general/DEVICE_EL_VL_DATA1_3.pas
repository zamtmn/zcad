unit DEVICE_EL_VL_DATA1_3;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Data:String;(*'Значение'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Данные';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ДН0';
NMO_BaseName:='ДН';
NMO_Suffix:='??';

VL_Data:='??';

end.