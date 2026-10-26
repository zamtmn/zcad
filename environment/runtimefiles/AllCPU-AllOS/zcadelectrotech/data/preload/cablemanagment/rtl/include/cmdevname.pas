unit CMDevName;
interface
uses system;
usescopy _ObjName;
usescopy _ObjNameParts;
implementation
begin
   NMO_Prefix:='';
   NMO_Suffix:='';
   NMO_Affix:='';
   NMO_BaseName:='??';
   NMO_Name.value:='??';
   NMO_Name.format:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]@@[NMO_Affix]';
end.
