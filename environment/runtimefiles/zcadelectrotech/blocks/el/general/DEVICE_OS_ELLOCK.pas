unit DEVICE_OS_ELLOCK;
interface
uses system,devices;
usescopy objname;
usescopy objmaterial;
usescopy objconnect;
usescopy blocktype;
var
   EL_Cab_AddLength:Double;(*'Добавлять к длине кабеля'*)
implementation
begin
   BTY_TreeCoord:='PLAN_OPS_Электрозамок';

   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]';

   NMO_Prefix:='';
   NMO_BaseName:='YAK';
   NMO_Suffix:='??';

   DB_link:='ELLOCK';

end.
