unit aregCableDeviceBaseObject;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,DeviceBase;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('CableDeviceBaseObject');
     pt^.RegisterObject(TypeOf(CableDeviceBaseObject),@CableDeviceBaseObject.initnul);
     pt^.AddMetod('','initnul','',@CableDeviceBaseObject.initnul,m_constructor);
end;
end.
