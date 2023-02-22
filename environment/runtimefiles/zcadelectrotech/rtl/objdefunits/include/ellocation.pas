unit ellocation;
interface
uses system;
var
   LOCATION_blocksection:string;(*'Блок секция'*)
   LOCATION_floor:string;(*'Этаж'*)
   LOCATION_floormark:double;(*'Этаж. Отметка пола'*)
   LOCATION_room:string;(*'Помещение'*)
implementation
begin
   LOCATION_blocksection:='-';
   LOCATION_floor:='-';
   LOCATION_floormark:=0.0;
   LOCATION_room:='-';
end.
