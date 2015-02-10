unit aregGDBObj3DFace;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,GDB3DFace;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObj3DFace');
     pt^.RegisterObject(TypeOf(GDBObj3DFace),@GDBObj3DFace.initnul);
     pt^.AddMetod('','initnul','',@GDBObj3DFace.initnul,m_constructor);
end;
end.
