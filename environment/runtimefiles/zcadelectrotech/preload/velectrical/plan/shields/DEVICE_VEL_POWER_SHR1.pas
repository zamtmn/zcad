unit DEVICE_VEL_POWER_SHR1;

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

implementation

begin

BTY_TreeCoord:='PLAN_VEL_Щиты_Щит распределительный';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_BaseName:='ЩР';
NMO_Suffix:='';
NMO_Template:='@@[NMO_BaseName]';

GC_NameGroupTemplate:='@@[GC_HeadDevice].@@[GC_HDGroup]';

VSPECIFICATION_Position:='';
VSPECIFICATION_Name:='Щит распределительный';
VSPECIFICATION_Brand:='';
VSPECIFICATION_Article:='';
VSPECIFICATION_Factoryname:='';
VSPECIFICATION_Unit:='шт.';
VSPECIFICATION_Count:=1;
VSPECIFICATION_Weight:='';
VSPECIFICATION_Note:='';
VSPECIFICATION_Grouping:='Щитки, шкафы, ящики, пульты';
VSPECIFICATION_Belong:='';


SerialConnection:=1;

end.