unit objname;
interface
uses system,slcabagenmodul;
var
   NMO_Name:GDBString;(*'Обозначение'*)
   NMO_BaseName:GDBString;(*'Короткое Имя'*)
   NMO_Prefix:GDBString;(*'Префикс'*)
   NMO_Suffix:GDBString;(*'Суффикс'*)
   NMO_Affix:GDBString;(*'Аффикс'*)
   NMO_Template:GDBString;(*'Шаблон Обозначения'*) 
implementation
begin
   NMO_Name:='??';
   NMO_Prefix:='';
   NMO_Suffix:='';
   NMO_Affix:='';
   NMO_BaseName:='unnamed';
   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]@@[NMO_Affix]';
end.
