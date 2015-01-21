unit aregGDBObjMText;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,GDBMText;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObjMText');
     pt^.RegisterObject(TypeOf(GDBObjMText),@GDBObjMText.initnul);
     pt^.AddMetod('','initnul','',@GDBObjMText.initnul,m_constructor);
end;
end.
