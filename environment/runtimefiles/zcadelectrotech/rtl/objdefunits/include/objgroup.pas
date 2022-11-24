unit objgroup;
interface
uses system;
usescopy slcabagenmodul;
usescopy deverrors;
var
   GC_HeadDevice:String;(*'Головное устройство'*)
   GC_HeadDeviceTemplate:String;(*'Шаблон головного устройства'*)
   GC_HDShortName:String;(*'Короткое имя головного устройства'*)
   GC_HDShortNameTemplate:String;(*'Шаблон короткого имени головного устройства'*)
   GC_HDGroup:String;(*'Группа в головном устройстве'*)
   GC_HDGroupTemplate:String;(*'Шаблон группы'*)
   GC_velecSubGroupControlUnit:String;(*'Контрольный узел автопрокладки. ~, - и ! спецсимволы '*)
   GC_velecNumConnectDevice:Integer;(*'Номер подключения внутри девайса'*)

   SerialConnection:Integer;
   GC_NumberInGroup:Integer;(*'Номер устройства в группе'*)
   GC_InGroup_Metric:String;(*'Метрика нумерации в группе'*)
   GC_Metric:String;(*'Метрика нумерации'*)
implementation
begin
   SerialConnection:=1;
   GC_NumberInGroup:=0;
   GC_HeadDevice:='??';
   GC_HDShortName:='??';
   GC_Metric:='';
   GC_velecSubGroupControlUnit:='-';
   GC_velecNumConnectDevice:=0;
   GC_HDGroup:='0';
end.
