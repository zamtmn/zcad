unit aregGDBObjDevice;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,GDBDevice;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObjDevice');
     pt^.RegisterObject(TypeOf(GDBObjDevice),@GDBObjDevice.initnul);
     pt^.AddMetod('','initnul','',@GDBObjDevice.initnul,m_constructor);
end;
end.
