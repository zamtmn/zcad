unit aregGDBObjSolid;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,uzeentsolid;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObjSolid');
     pt^.RegisterObject(TypeOf(GDBObjSolid),@GDBObjSolid.initnul);
     pt^.AddMetod('','initnul','',@GDBObjSolid.initnul,m_constructor);
end;
end.
