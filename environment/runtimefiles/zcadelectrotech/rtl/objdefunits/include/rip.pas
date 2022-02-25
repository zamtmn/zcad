unit rip;
interface
uses system,devices;
usescopy objname;
usescopy objmaterial;
usescopy blocktype;
var
   EL_Cab_AddLength:Double;(*'Добавлять к длине кабеля'*)
implementation
begin
   BTY_TreeCoord:='PLAN_OPS_Блок питания 1';

   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]';

   EL_Cab_AddLength:=0.1;

   NMO_Prefix:='';
   NMO_BaseName:='GB';
   NMO_Suffix:='??';

   DB_link:='RIP';

end.
