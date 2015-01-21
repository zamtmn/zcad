unit aregGDBObjText;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,GDBtext;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObjText');
     pt^.RegisterObject(TypeOf(GDBObjText),@GDBObjText.initnul);
     pt^.AddMetod('','initnul','',@GDBObjText.initnul,m_constructor);
end;
end.
