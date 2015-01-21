unit aregGDBObjBlockdefArray;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,UGDBObjBlockdefArray;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObjBlockdefArray');
     pt^.RegisterObject(TypeOf(GDBObjBlockdefArray),@GDBObjBlockdefArray.initnul);
     pt^.AddMetod('','initnul','',@GDBObjBlockdefArray.initnul,m_constructor);
end;
end.
