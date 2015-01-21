unit aregGDBObjLWPolyline;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,GDBLWPolyLine;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObjLWPolyline');
     pt^.RegisterObject(TypeOf(GDBObjLWPolyline),@GDBObjLWPolyline.initnul);
     pt^.AddMetod('','initnul','',@GDBObjLWPolyline.initnul,m_constructor);
end;
end.
