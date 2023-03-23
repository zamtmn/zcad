unit DEVICE_KIP_KNOPKA;
interface
uses system,devices;
usescopy objname;
usescopy objmaterial;
usescopy objconnect;
usescopy blocktype;
implementation
begin
   BTY_TreeCoord:='PLAN_KIPIA_Кнопка';

   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]';

   NMO_Prefix:='';
   NMO_BaseName:='SB';
   NMO_Suffix:='??';

   DB_link:='KIP_KNOPKA';

end.
