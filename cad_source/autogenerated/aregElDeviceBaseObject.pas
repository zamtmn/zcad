unit aregElDeviceBaseObject;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,uzcdevicebase;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('ElDeviceBaseObject');
     pt^.RegisterObject(TypeOf(ElDeviceBaseObject),@ElDeviceBaseObject.initnul);
     pt^.AddMetod('','initnul','',@ElDeviceBaseObject.initnul,m_constructor);
end;
end.
