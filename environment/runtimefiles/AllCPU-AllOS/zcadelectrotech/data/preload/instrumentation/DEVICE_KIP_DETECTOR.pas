unit DEVICE_KIP_DETECTOR;
interface
uses system,devices;
usescopy objname;
usescopy objmaterial;
usescopy objconnect;
usescopy blocktype;
implementation
begin
   BTY_TreeCoord:='Схема_KIPIA_Детектор газа';

   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]';

   NMO_Prefix:='';
   NMO_BaseName:='C';
   NMO_Suffix:='??';

   DB_link:='KIP_SOU1';

end.
