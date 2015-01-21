unit aregGDBDescriptor;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,UGDBDescriptor;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBDescriptor');
     pt^.RegisterObject(TypeOf(GDBDescriptor),@GDBDescriptor.initnul);
     pt^.AddMetod('','initnul','',@GDBDescriptor.initnul,m_constructor);
end;
end.
