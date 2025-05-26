unit DEVICE_VEL_POWER_BU;

interface

uses system,devices;
usescopy blocktype;
usescopy objname_eo;
usescopy objgroup;
usescopy addtocable;
usescopy elreceivers;
usescopy vlocation;
usescopy vtextpointer;
usescopy vinfopersonaluse;

implementation

begin

BTY_TreeCoord:='PLAN_VEL_Электроприемники_Блок управления';
Device_Type:=TDT_SilaPotr;
Device_Class:=TDC_Shell;

NMO_BaseName:='Дв';
NMO_Suffix:='(??)';
NMO_Template:='@@[NMO_BaseName]@@[NMO_Suffix]';

GC_NameGroupTemplate:='@@[GC_HeadDevice].@@[GC_HDGroup]';

realnamedev:='Блок управления';
Power:=1;
CosPHI:=0.8;
Voltage:=_AC_380V_50Hz;
Phase:=_ABC;

INFOPERSONALUSE_TextTemplate:='';

INFOTEXTPOINTER_Tp1Up.format:='@@[NMO_BaseName]@@[NMO_Suffix]';
INFOTEXTPOINTER_Tp1Bottom.format:='@@[Power]';
INFOTEXTPOINTER_Tp2Up.format:='@@[GC_HeadDevice].@@[GC_HDGroup]';
INFOTEXTPOINTER_Tp2Bottom.format:=' ';

SerialConnection:=1;

end.