unit aregDbBaseObject;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,uzcdevicebaseabstract;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('DbBaseObject');
     pt^.RegisterObject(TypeOf(DbBaseObject),@DbBaseObject.initnul);
     pt^.AddMetod('','initnul','',@DbBaseObject.initnul,m_constructor);
end;
end.
