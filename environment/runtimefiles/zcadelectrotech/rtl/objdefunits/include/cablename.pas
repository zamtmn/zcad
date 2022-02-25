unit cablename;
interface
uses system;
var
   NMO_Name:String;(*'Обозначение'*)
   NMO_BaseName:String;(*'Короткое Имя'*)
   NMO_Prefix:String;(*'Префикс'*)
   NMO_PrefixTemplate:String;(*'Шаблон префикса'*)
   NMO_Suffix:String;(*'Суффикс'*)
   NMO_SuffixTemplate:String;(*'Шаблон суффикса'*)
   NMO_Template:String;(*'Шаблон Обозначения'*) 
implementation
begin
   NMO_Name:='??';
   NMO_Prefix:='';
   NMO_Suffix:='';
   NMO_BaseName:='Н';
   NMO_Template:='@@[GC_HDShortName]@@[GC_HDGroup]';
end.
