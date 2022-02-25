unit DEVICE_OS_READER;
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
   BTY_TreeCoord:='PLAN_OPS_Считыватель без клавиатуры';

   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]';

   NMO_Prefix:='';
   NMO_BaseName:='СЧ';
   NMO_Suffix:='??';

   DB_link:='READER';

end.
