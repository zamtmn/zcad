unit DEVICE_CM_2WAY;
interface
uses system;
usescopy CMDevName;
usescopy _ObjID;
usescopy objmaterial;
implementation
begin
  NMO_Prefix:='';
  NMO_Suffix:='';
  NMO_Affix:='';
  NMO_BaseName:='??';
  NMO_Name.value:='??';
  NMO_Name.format:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]@@[NMO_Affix]';

  ENTID_Function:='Mechanics~Cable_management_system~Cable_trays~Fittings';
  ENTID_Representation:='GraphSymbol~onPlan';

  DB_link:='??';
  DB_MatName:='??';
end.