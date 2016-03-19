unit aregGDBTextStyleArray;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,uzestylestexts;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBTextStyleArray');
     pt^.RegisterObject(TypeOf(GDBTextStyleArray),@GDBTextStyleArray.initnul);
     pt^.AddMetod('','initnul','',@GDBTextStyleArray.initnul,m_constructor);
end;
end.
