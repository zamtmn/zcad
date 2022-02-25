unit DEVICE_EL_VL_DIAGRAM_TX1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

T1:String;(*'Пометки'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Таблица';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='Э0';
NMO_BaseName:='Э';
NMO_Suffix:='??';

T1:='Источник питания';

end.