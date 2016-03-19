unit aregGDBLayerArray;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,uzestyleslayers;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBLayerArray');
     pt^.RegisterObject(TypeOf(GDBLayerArray),@GDBLayerArray.initnul);
     pt^.AddMetod('','initnul','',@GDBLayerArray.initnul,m_constructor);
end;
end.
