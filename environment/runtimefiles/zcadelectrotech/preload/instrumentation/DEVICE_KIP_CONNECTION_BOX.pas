unit DEVICE_KIP_CONNECTION_BOX;
interface
uses system,devices;
usescopy objname;
usescopy objmaterial;
usescopy objconnect;
usescopy blocktype;
implementation
begin
   BTY_TreeCoord:='PLAN_KIPIA_Коробка соединительная';

   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]';

   NMO_Prefix:='';
   NMO_BaseName:='C';
   NMO_Suffix:='??';

   DB_link:='Коробка';

end.