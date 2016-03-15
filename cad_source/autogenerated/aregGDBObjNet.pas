unit aregGDBObjNet;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,uzcentnet;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObjNet');
     pt^.RegisterObject(TypeOf(GDBObjNet),@GDBObjNet.initnul);
     pt^.AddMetod('','initnul','',@GDBObjNet.initnul,m_constructor);
end;
end.
