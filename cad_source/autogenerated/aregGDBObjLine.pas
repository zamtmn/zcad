unit aregGDBObjLine;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,GDBLine;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObjLine');
     pt^.RegisterObject(TypeOf(GDBObjLine),@GDBObjLine.initnul);
     pt^.AddMetod('','initnul','',@GDBObjLine.initnul,m_constructor);
end;
end.
