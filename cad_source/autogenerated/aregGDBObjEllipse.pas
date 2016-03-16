unit aregGDBObjEllipse;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,uzeentellipse;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObjEllipse');
     pt^.RegisterObject(TypeOf(GDBObjEllipse),@GDBObjEllipse.initnul);
     pt^.AddMetod('','initnul','',@GDBObjEllipse.initnul,m_constructor);
end;
end.
