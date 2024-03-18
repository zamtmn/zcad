unit DEVICE_ELVELEC_SOCKET1_2P;

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

BTY_TreeCoord:='PLAN_VEL_Розетки_Розетка СП31 2Р';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_BaseName:='б/п';
NMO_Suffix:='(??)';
NMO_Template:='@@[NMO_BaseName]@@[NMO_Suffix] @@[Power] @@[LOCATION_height]';

GC_NameGroupTemplate:='@@[GC_HeadDevice].@@[GC_HDGroup]';

VSPECIFICATION_Position:='??';
VSPECIFICATION_Name:='Розетка СП31 2Р';
VSPECIFICATION_Brand:='';
VSPECIFICATION_Article:='';
VSPECIFICATION_Factoryname:='';
VSPECIFICATION_Unit:='шт.';
VSPECIFICATION_Count:=1;
VSPECIFICATION_Weight:='';
VSPECIFICATION_Note:='';
VSPECIFICATION_Grouping:='Электрооборудование';
VSPECIFICATION_Belong:='';


SerialConnection:=1;

end.