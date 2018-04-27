unit DEVICE_OPS_DISTRIBUTION_BOX;
interface
uses system,devices;
usescopy objname;
usescopy objmaterial;
usescopy objconnect;
usescopy blocktype;
implementation
begin
   BTY_TreeCoord:='PLAN_OPS_Коробка распределительная';

   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]';

   NMO_Prefix:='';
   NMO_BaseName:='C';
   NMO_Suffix:='??';

   DB_link:='Коробка';

end.