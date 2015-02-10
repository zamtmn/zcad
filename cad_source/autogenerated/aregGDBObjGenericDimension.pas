unit aregGDBObjGenericDimension;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,gdbgenericdimension;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObjGenericDimension');
     pt^.RegisterObject(TypeOf(GDBObjGenericDimension),@GDBObjGenericDimension.initnul);
     pt^.AddMetod('','initnul','',@GDBObjGenericDimension.initnul,m_constructor);
end;
end.
