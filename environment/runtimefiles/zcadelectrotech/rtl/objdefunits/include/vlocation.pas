unit vlocation;
interface
uses system;
type

(*varcategoryforoi LOCATION='Место установки'*)

var
   LOCATION_blocksection:string;(*'Блок секция'*)
   LOCATION_floor:string;(*'Этаж'*)
   LOCATION_floormark:double;(*'Отметка этажа'*)
   LOCATION_room:string;(*'Помещение'*)
   LOCATION_height:string;(*'Высота установки от пола'*)
   
implementation
begin
   LOCATION_blocksection:='-';
   LOCATION_floor:='-';
   LOCATION_floormark:=0.0;
   LOCATION_room:='-';
   LOCATION_height:='h-0';
end.
