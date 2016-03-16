unit aregGDBObjArc;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,uzeentarc;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObjArc');
     pt^.RegisterObject(TypeOf(GDBObjArc),@GDBObjArc.initnul);
     pt^.AddMetod('','initnul','',@GDBObjArc.initnul,m_constructor);
end;
end.
