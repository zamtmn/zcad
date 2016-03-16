unit aregGDBObjPoint;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,uzeentpoint;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObjPoint');
     pt^.RegisterObject(TypeOf(GDBObjPoint),@GDBObjPoint.initnul);
     pt^.AddMetod('','initnul','',@GDBObjPoint.initnul,m_constructor);
end;
end.
