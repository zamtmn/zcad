unit DEVICE_ELVELEC_DIAGRAM_INOUTGROUP;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T11:Integer;(*'123'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Кабель';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='Н0';
NMO_BaseName:='Н';
NMO_Suffix:='??';
NMO_Affix:='';

T11:=3;

end.