unit vtextpointer;
interface
uses system;
type

(*varcategoryforoi INFOTEXTPOINTER='Текстовые выноски'*)

var
   INFOTEXTPOINTER_Tp1Up:TCalculatedString;(*'1-верхняя полка'*)
   INFOTEXTPOINTER_Tp1Bottom:TCalculatedString;(*'1-нижняя полка'*)  
   INFOTEXTPOINTER_Tp2Up:TCalculatedString;(*'2-верхняя полка'*)
   INFOTEXTPOINTER_Tp2Bottom:TCalculatedString;(*'2-нижняя полка'*)     
implementation
begin
   INFOTEXTPOINTER_Tp1Up.value:='';
   INFOTEXTPOINTER_Tp1Up.format:='';   
   INFOTEXTPOINTER_Tp1Bottom.value:='';
   INFOTEXTPOINTER_Tp1Bottom.format:='';   
   INFOTEXTPOINTER_Tp2Up.value:='';
   INFOTEXTPOINTER_Tp2Up.format:='';   
   INFOTEXTPOINTER_Tp2Bottom.value:='';
   INFOTEXTPOINTER_Tp2Bottom.format:='';        
end.
