unit DEVICE_EL_VL_DATA1_4;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Units:String;(*'Ед.измерения'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Данные';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ДН0';
NMO_BaseName:='ДН';
NMO_Suffix:='??';

VL_Units:='??';

end.