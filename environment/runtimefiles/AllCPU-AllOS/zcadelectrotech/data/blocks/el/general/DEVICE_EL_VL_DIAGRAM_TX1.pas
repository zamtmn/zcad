unit DEVICE_EL_VL_DIAGRAM_TX1;

interface

uses system,devices;
usescopy blocktype;
usescopy objname;

var

VL_Mark:String;(*'Пометки'*)

implementation

begin

BTY_TreeCoord:='PLAN_EM_Таблица';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_Name:='Э0';
NMO_BaseName:='Э';
NMO_Suffix:='??';

VL_Mark:='Источник питания';

end.