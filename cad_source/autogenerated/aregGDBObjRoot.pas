unit aregGDBObjRoot;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,uzeroot;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObjRoot');
     pt^.RegisterObject(TypeOf(GDBObjRoot),@GDBObjRoot.initnul);
     pt^.AddMetod('','initnul','',@GDBObjRoot.initnul,m_constructor);
end;
end.
