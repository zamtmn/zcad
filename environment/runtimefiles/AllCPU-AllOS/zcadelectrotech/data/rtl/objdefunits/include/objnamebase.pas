unit objnamebase;
interface
uses system;

var
   NMO_Name:String;(*'Обозначение'*)
   NMO_BaseName:String;(*'Короткое Имя'*)
   NMO_Template:String;(*'Шаблон Обозначения'*) 
implementation
begin
   NMO_Name:='??';
   NMO_BaseName:='unnamed';
   NMO_Template:='@@[NMO_BaseName]';
end.
