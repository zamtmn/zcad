unit aregGDBObjEntityOpenArray;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,UGDBVisibleOpenArray;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObjEntityOpenArray');
     pt^.RegisterObject(TypeOf(GDBObjEntityOpenArray),@GDBObjEntityOpenArray.initnul);
     pt^.AddMetod('','initnul','',@GDBObjEntityOpenArray.initnul,m_constructor);
end;
end.
