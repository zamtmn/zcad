unit aregGDBObjCircle;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,GDBCircle;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObjCircle');
     pt^.RegisterObject(TypeOf(GDBObjCircle),@GDBObjCircle.initnul);
     pt^.AddMetod('','initnul','',@GDBObjCircle.initnul,m_constructor);
end;
end.
