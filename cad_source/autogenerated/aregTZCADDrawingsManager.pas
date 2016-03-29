unit aregTZCADDrawingsManager;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,uzcdrawings;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('TZCADDrawingsManager');
     pt^.RegisterObject(TypeOf(TZCADDrawingsManager),@TZCADDrawingsManager.initnul);
     pt^.AddMetod('','initnul','',@TZCADDrawingsManager.initnul,m_constructor);
end;
end.
