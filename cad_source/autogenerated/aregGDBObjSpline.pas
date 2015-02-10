unit aregGDBObjSpline;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,gdbspline;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObjSpline');
     pt^.RegisterObject(TypeOf(GDBObjSpline),@GDBObjSpline.initnul);
     pt^.AddMetod('','initnul','',@GDBObjSpline.initnul,m_constructor);
end;
end.
