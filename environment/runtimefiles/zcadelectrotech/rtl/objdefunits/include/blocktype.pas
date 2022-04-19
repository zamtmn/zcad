unit blocktype;
interface
uses system,devices;
usescopy uentid;
var
   Device_Type:TDeviceType;(*'Тип устройства'*) 
   Device_Class:TDeviceClass;(*'Класс устройства'*)
   Device_Group:TDeviceGroup;(*'Группа устройства'*) 
   BTY_TreeCoord:String;(*'Позиция в дереве'*)
   ENTID_Type:TENTID;(*'Object type'*)
   ENTID_Representation:TEentityRepresentation;(*'Representation'*)
   ENTID_Function:TEentityFunction;(*'Function'*)
implementation
begin
   BTY_TreeCoord:='';
   Device_Group:=TDG_ElDevice;
   ENTID_Type:='OBJT_Unknown';
end.
