unit DEVICE_VEL_SOCKET_RODENTPROTECT;

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

BTY_TreeCoord:='PLAN_VEL_Барьер Грызун';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_BaseName:='C';
NMO_Suffix:='';
NMO_Template:='@@[NMO_BaseName]@@[NMO_Suffix]';

GC_NameGroupTemplate:='@@[GC_HeadDevice].@@[GC_HDGroup]';

realnamedev:='Барьер Грызун';
Power:=0.0;
CosPHI:=1.0;
Voltage:=_AC_220V_50Hz;
Phase:=_A;

INFOPERSONALUSE_TextTemplate:='';

INFOTEXTPOINTER_Tp1Up.format:='';
INFOTEXTPOINTER_Tp1Bottom.format:='';
INFOTEXTPOINTER_Tp2Up.format:='';
INFOTEXTPOINTER_Tp2Bottom.format:='';

VSPECIFICATION_Position:='??';
VSPECIFICATION_Name:='Барьер Грызун';
VSPECIFICATION_Brand:='';
VSPECIFICATION_Article:='';
VSPECIFICATION_Factoryname:='';
VSPECIFICATION_Unit:='шт.';
VSPECIFICATION_Count:=1;
VSPECIFICATION_Weight:='';
VSPECIFICATION_Note:='';
VSPECIFICATION_Grouping:='Электроустановочные изделия низковольтные';
VSPECIFICATION_Belong:='';

SerialConnection:=1;

end.