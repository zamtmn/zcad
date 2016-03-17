unit aregGDBObjBlockInsert;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,uzeentblockinsert;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObjBlockInsert');
     pt^.RegisterObject(TypeOf(GDBObjBlockInsert),@GDBObjBlockInsert.initnul);
     pt^.AddMetod('','initnul','',@GDBObjBlockInsert.initnul,m_constructor);
end;
end.
