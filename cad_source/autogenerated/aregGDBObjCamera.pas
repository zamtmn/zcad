unit aregGDBObjCamera;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,GDBCamera;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObjCamera');
     pt^.RegisterObject(TypeOf(GDBObjCamera),@GDBObjCamera.initnul);
     pt^.AddMetod('','initnul','',@GDBObjCamera.initnul,m_constructor);
end;
end.
