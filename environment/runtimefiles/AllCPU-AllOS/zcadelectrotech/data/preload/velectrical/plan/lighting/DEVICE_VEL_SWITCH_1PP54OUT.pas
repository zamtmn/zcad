unit DEVICE_VEL_SWITCH_1PP54OUT;

interface

uses system,devices;
usescopy blocktype;
usescopy objname_eo;
usescopy objgroup;
usescopy addtocable;
usescopy elreceivers;
usescopy vlocation;
usescopy vtextpointer;
usescopy vspecification;
usescopy vinfopersonaluse;
var
VELLightNumControl:String;(*'Номер управления светильником'*)
implementation

begin

BTY_TreeCoord:='PLAN_VEL_Освещение_Выключатель накладной проходной ОП54 1Р';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_BaseName:='Вкл';
NMO_Suffix:='(??)';
NMO_Template:='@@[NMO_BaseName]@@[NMO_Suffix]';

VELLightNumControl:='';

GC_NameGroupTemplate:='@@[GC_HeadDevice].@@[GC_HDGroup]';

realnamedev:='Выключатель';
Power:=0.0;
CosPHI:=0.92;
Voltage:=_AC_220V_50Hz;
Phase:=_A;

INFOPERSONALUSE_TextTemplate:='@@[GC_HeadDevice].@@[GC_HDGroup]';

INFOTEXTPOINTER_Tp1Up.format:=' ';
INFOTEXTPOINTER_Tp1Bottom.format:=' ';
INFOTEXTPOINTER_Tp2Up.format:=' ';
INFOTEXTPOINTER_Tp2Bottom.format:=' ';

ANALYSISEM_exporttoxlsx:=false;

VSPECIFICATION_Position:='';
VSPECIFICATION_Name:='Выключатель накладной проходной ОП54 1Р';
VSPECIFICATION_Brand:='';
VSPECIFICATION_Article:='';
VSPECIFICATION_Factoryname:='';
VSPECIFICATION_Unit:='шт.';
VSPECIFICATION_Count:=1;
VSPECIFICATION_Weight:='';
VSPECIFICATION_Note:='';
VSPECIFICATION_Grouping:='Светильники, светоуказатели, световые табло';
VSPECIFICATION_Belong:='';


SerialConnection:=1;

end.