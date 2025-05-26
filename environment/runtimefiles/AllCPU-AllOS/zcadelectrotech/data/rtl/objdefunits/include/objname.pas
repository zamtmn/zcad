unit objname;
interface
uses system;
usescopy objnamebase;

var
   NMO_Prefix:String;(*'Префикс'*)
   NMO_Suffix:String;(*'Суффикс'*)
   NMO_Affix:String;(*'Аффикс'*)
implementation
begin
   NMO_Name:='??';
   NMO_Prefix:='';
   NMO_Suffix:='';
   NMO_Affix:='';
   NMO_BaseName:='unnamed';
   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]@@[NMO_Affix]';
end.
