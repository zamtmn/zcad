unit vinfopersonaluse;
interface
uses system;
type

(*varcategoryforoi INFOPERSONALUSE='Инфо личного пользования'*)

var
   INFOPERSONALUSE_Text:string;(*'Текст личного пользования'*)
   INFOPERSONALUSE_TextTemplate:string;(*'Шаблон для текста лич. польз.'*)  
implementation
begin
   INFOPERSONALUSE_Text:='';
   INFOPERSONALUSE_TextTemplate:='-';
end.
