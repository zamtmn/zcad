unit aregGDBObjBlockdef;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,uzeblockdef;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObjBlockdef');
     pt^.RegisterObject(TypeOf(GDBObjBlockdef),@GDBObjBlockdef.initnul);
     pt^.AddMetod('','initnul','',@GDBObjBlockdef.initnul,m_constructor);
end;
end.
