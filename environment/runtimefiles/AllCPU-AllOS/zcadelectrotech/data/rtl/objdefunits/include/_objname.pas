unit _ObjName;
interface
uses system;
var
  NMO_Name:TCalculatedString;(*'Обозначение'*)
implementation
begin
   NMO_Name.format:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]@@[NMO_Affix]';
end.
