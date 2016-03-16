unit aregGDBObjPolyline;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,uzeentpolyline;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObjPolyline');
     pt^.RegisterObject(TypeOf(GDBObjPolyline),@GDBObjPolyline.initnul);
     pt^.AddMetod('','initnul','',@GDBObjPolyline.initnul,m_constructor);
end;
end.
