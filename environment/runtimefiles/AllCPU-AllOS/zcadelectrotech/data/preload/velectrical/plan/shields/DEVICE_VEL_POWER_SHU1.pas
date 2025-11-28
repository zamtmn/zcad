unit DEVICE_VEL_POWER_SHU1;

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

BTY_TreeCoord:='PLAN_VEL_Щиты_Щит управления (вид1)';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_BaseName:='ЩУ';
NMO_Suffix:='';
NMO_Template:='@@[NMO_BaseName]';

nametemplatesxlsx:='<zlight>';
ANALYSISEM_icanbeheadunit:=true;

realnamedev:='Щит управления (вид1)';
Power:=0.0;
CosPHI:=0.8;
Voltage:=_AC_380V_50Hz;
Phase:=_ABC;

GC_NameGroupTemplate:='@@[GC_HeadDevice].@@[GC_HDGroup]';

INFOTEXTPOINTER_Tp1Up.format:='@@[NMO_BaseName]@@[NMO_Suffix]';
INFOTEXTPOINTER_Tp1Bottom.format:=' ';
INFOTEXTPOINTER_Tp2Up.format:=' ';
INFOTEXTPOINTER_Tp2Bottom.format:=' ';

VSPECIFICATION_Position:='';
VSPECIFICATION_Name:='Щит управления (вид1)';
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