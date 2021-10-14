unit objgroup;
interface
uses system;
usescopy slcabagenmodul;
var
   GC_HeadDevice:GDBString;(*'Головное устройство'*)
   GC_HeadDeviceTemplate:GDBString;(*'Шаблон головного устройства'*)
   GC_HDShortName:GDBString;(*'Короткое имя головного устройства'*)
   GC_HDShortNameTemplate:GDBString;(*'Шаблон короткого имени головного устройства'*)
   GC_HDGroup:GDBString;(*'Группа в головном устройстве'*)
   GC_HDGroupTemplate:GDBString;(*'Шаблон группы'*)

   SerialConnection:GDBInteger;
   GC_NumberInGroup:GDBInteger;(*'Номер устройства в группе'*)
   GC_InGroup_Metric:GDBString;(*'Метрика нумерации в группе'*)
   GC_Metric:GDBString;(*'Метрика нумерации'*)
implementation
begin
   SerialConnection:=1;
   GC_NumberInGroup:=0;
   GC_HeadDevice:='??';
   GC_HDShortName:='??';
   GC_Metric:='';
   GC_HDGroup:='0';
end.
