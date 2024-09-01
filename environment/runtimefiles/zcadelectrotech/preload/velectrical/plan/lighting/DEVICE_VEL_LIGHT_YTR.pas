unit DEVICE_VEL_LIGHT_YTP;

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

implementation

begin

BTY_TreeCoord:='PLAN_VEL_Освещение_Ящик ЯТПР';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_BaseName:='EL1';
NMO_Suffix:='(??)';
NMO_Template:='@@[NMO_BaseName]@@[NMO_Suffix]';

GC_NameGroupTemplate:='@@[GC_HeadDevice].@@[GC_HDGroup]';

realnamedev:='Ящик ЯТПР-0,25/220/12';
Power:=0.25;
CosPHI:=0.92;
Voltage:=_AC_220V_50Hz;
Phase:=_A;

INFOPERSONALUSE_TextTemplate:=' ';

INFOTEXTPOINTER_Tp1Up.format:='@@[NMO_BaseName]@@[NMO_Suffix]';
INFOTEXTPOINTER_Tp1Bottom.format:=' ';
INFOTEXTPOINTER_Tp2Up.format:='@@[GC_HeadDevice].@@[GC_HDGroup]';
INFOTEXTPOINTER_Tp2Bottom.format:=' ';

VSPECIFICATION_Position:='';
VSPECIFICATION_Name:='Ящик с понижающим разделительным трансформатором';
VSPECIFICATION_Brand:='ЯТПР-0,25 220/12 IP54';
VSPECIFICATION_Article:='';
VSPECIFICATION_Factoryname:='ГК "Новые технологии" ';
VSPECIFICATION_Unit:='шт.';
VSPECIFICATION_Count:=1;
VSPECIFICATION_Weight:='';
VSPECIFICATION_Note:='';
VSPECIFICATION_Grouping:='Светильники, светоуказатели, световые табло';
VSPECIFICATION_Belong:='';


SerialConnection:=1;

end.