unit DEVICE_OS_KNOPKA;
interface
uses system,devices;
usescopy objname;
usescopy objmaterial;
usescopy objconnect;
usescopy blocktype;
var
  NMO_Type:GDBString;
implementation
begin
   BTY_TreeCoord:='PLAN_KIPIA_Схема автоматизации';

   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]';

   NMO_Type:='-?-';
   NMO_Prefix:='';
   NMO_BaseName:='B';
   NMO_Suffix:='??';

   DB_link:='Датчик';

end.
