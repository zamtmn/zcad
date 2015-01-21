unit aregDeviceDbBaseObject;
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
     pt:=SysUnit.ObjectTypeName2PTD('DeviceDbBaseObject');
     pt^.RegisterObject(TypeOf(DeviceDbBaseObject),@DeviceDbBaseObject.initnul);
     pt^.AddMetod('','initnul','',@DeviceDbBaseObject.initnul,m_constructor);
end;
end.
