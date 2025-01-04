unit DEVICE_KIP_SENSOR;
interface
uses system,devices;
usescopy objname;
usescopy objmaterial;
usescopy objconnect;
usescopy blocktype;
implementation
begin
   BTY_TreeCoord:='PLAN_KIPIA_Датчик';

   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]';

   NMO_Prefix:='';
   NMO_BaseName:='ТС';
   NMO_Suffix:='??';

   DB_link:='Датчик';

end.
