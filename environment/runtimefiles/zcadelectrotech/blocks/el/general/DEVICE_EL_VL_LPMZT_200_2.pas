unit DEVICE_EL_VL_LPMZT_200_2;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:Integer;(*'Длина'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Ведомость';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='ЛТ0';
NMO_BaseName:='ЛТ';
NMO_Suffix:='??';

T1:=1;

end.