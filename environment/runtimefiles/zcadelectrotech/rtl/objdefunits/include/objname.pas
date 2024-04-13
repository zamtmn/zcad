unit objname;
interface
uses system;

var
   NMO_Name:String;(*'Обозначение'*)
   NMO_BaseName:String;(*'Короткое Имя'*)
   NMO_Prefix:String;(*'Префикс'*)
   NMO_Suffix:String;(*'Суффикс'*)
   NMO_Affix:String;(*'Аффикс'*)
   NMO_Template:String;(*'Шаблон Обозначения'*) 
implementation
begin
   NMO_Name:='??';
   NMO_Prefix:='';
   NMO_Suffix:='';
   NMO_Affix:='';
   NMO_BaseName:='unnamed';
   NMO_Template:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]@@[NMO_Affix]';
end.
