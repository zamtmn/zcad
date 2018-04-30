unit blocktype;
interface
uses system,devices;
var
   Device_Type:TDeviceType;(*'Тип устройства'*) 
   Device_Class:TDeviceClass;(*'Класс устройства'*)
   Device_Group:TDeviceGroup;(*'Группа устройства'*) 
   BTY_TreeCoord:GDBString;(*'Позиция в дереве'*)
   ENTID_Type:TENTID;(*'Object type'*)
implementation
begin
   BTY_TreeCoord:='';
   Device_Group:=TDG_ElDevice;
   ENTID_Type:='OBJT_Unknown';
end.
