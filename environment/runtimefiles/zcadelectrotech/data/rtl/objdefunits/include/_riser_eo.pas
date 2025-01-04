unit _riser;
interface
uses system;
usescopy objname;
usescopy _addtocable;
var
   Text:String;(*'Текст'*)
   Elevation:Double;(*'Отметка'*)
   RiserName:TCalculatedString;(*'Имя стояка'*)
implementation
begin
   Text:='??';
   Elevation:=0;
   RiserName:='';
   RiserName.value:='';
   RiserName.format:='@@[NMO_Prefix]@@[NMO_BaseName]@@[NMO_Suffix]@@[NMO_Affix]';
end.