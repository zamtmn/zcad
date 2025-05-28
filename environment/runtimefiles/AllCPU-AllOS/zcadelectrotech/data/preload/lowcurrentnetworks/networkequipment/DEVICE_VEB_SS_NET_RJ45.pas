unit DEVICE_VEB_SS_NET_RJ45;

interface

uses system,devices;
usescopy blocktype;
usescopy objname_eo;
usescopy objgroup;
usescopy addtocable;
usescopy vnetsystem;
usescopy vlocation;
usescopy vtextpointer;
usescopy vspecification;
usescopy vinfopersonaluse;

implementation

begin

BTY_TreeCoord:='PLAN_VEB_LAN_NET_RJ45';

NMO_BaseName:='K';
NMO_Suffix:='(??)';
NMO_Template:='@@[NMO_BaseName]@@[NMO_Suffix]';

GC_NameGroupTemplate:='@@[GC_HeadDevice].@@[GC_HDGroup]';

INFOPERSONALUSE_TextTemplate:='';

INFOTEXTPOINTER_Tp1Up.format:='@@[NMO_BaseName]@@[NMO_Suffix]';
INFOTEXTPOINTER_Tp1Bottom.format:=' ';
INFOTEXTPOINTER_Tp2Up.format:='@@[GC_HeadDevice].@@[GC_HDGroup]';
INFOTEXTPOINTER_Tp2Bottom.format:=' ';

VSPECIFICATION_Position:='';
VSPECIFICATION_Name:='Компьютерная розетка RJ45';
VSPECIFICATION_Brand:='';
VSPECIFICATION_Article:='';
VSPECIFICATION_Factoryname:='';
VSPECIFICATION_Unit:='шт.';
VSPECIFICATION_Count:=1;
VSPECIFICATION_Weight:='';
VSPECIFICATION_Note:='';
VSPECIFICATION_Grouping:='Сетевое оборудование';
VSPECIFICATION_Belong:='';

SerialConnection:=1;

end.