unit aregGDBPoint3dArray;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,UGDBPoint3DArray;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBPoint3dArray');
     pt^.RegisterObject(TypeOf(GDBPoint3dArray),@GDBPoint3dArray.initnul);
     pt^.AddMetod('','initnul','',@GDBPoint3dArray.initnul,m_constructor);
end;
end.
