unit DEVICE_VEL_LIGHT_R3;

interface

uses system,devices;
usescopy blocktype;
usescopy objname_eo;
usescopy objgroup;
usescopy addtocable;
usescopy elreceivers;
usescopy vlocation;
usescopy vspecification;
usescopy vinfopersonaluse;
var

VELLightType:String;(*'Тип светильника (авар/рем/деж)'*)
VELLightNumControl:String;(*'Номер управления светильником'*)

implementation

begin

BTY_TreeCoord:='PLAN_VEL_Освещение_Светильник R3';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_BaseName:='EL1';
NMO_Suffix:='(??)';
NMO_Template:='@@[NMO_BaseName]@@[NMO_Suffix]';

VELLightType:='';
VELLightNumControl:='';

GC_NameGroupTemplate:='@@[GC_HeadDevice].@@[GC_HDGroup]';

realnamedev:='Светильник';
Power:=0.03;
CosPHI:=0.92;
Voltage:=_AC_220V_50Hz;
Phase:=_A;

INFOPERSONALUSE_TextTemplate:='';


VSPECIFICATION_Position:='';
VSPECIFICATION_Name:='Светильник R3';
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