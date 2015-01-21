unit aregGDBLineWidthArray;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,UGDBLineWidthArray;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBLineWidthArray');
     pt^.RegisterObject(TypeOf(GDBLineWidthArray),@GDBLineWidthArray.initnul);
     pt^.AddMetod('','initnul','',@GDBLineWidthArray.initnul,m_constructor);
end;
end.
