unit aregGDBBaseCamera;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,gdbase;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBBaseCamera');
     pt^.RegisterObject(TypeOf(GDBBaseCamera),@GDBBaseCamera.initnul);
     pt^.AddMetod('','initnul','',@GDBBaseCamera.initnul,m_constructor);
end;
end.
