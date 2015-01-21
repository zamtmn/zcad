unit aregGDBPolyline2DArray;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,UGDBPolyLine2DArray;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBPolyline2DArray');
     pt^.RegisterObject(TypeOf(GDBPolyline2DArray),@GDBPolyline2DArray.initnul);
     pt^.AddMetod('','initnul','',@GDBPolyline2DArray.initnul,m_constructor);
end;
end.
