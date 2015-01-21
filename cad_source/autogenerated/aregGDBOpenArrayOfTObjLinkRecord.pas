unit aregGDBOpenArrayOfTObjLinkRecord;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
uses UObjectDescriptor,Varman,TypeDescriptors,UGDBOpenArrayOfTObjLinkRecord;
implementation
var
pt:PObjectDescriptor;
initialization
if assigned(SysUnit) then
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBOpenArrayOfTObjLinkRecord');
     pt^.RegisterObject(TypeOf(GDBOpenArrayOfTObjLinkRecord),@GDBOpenArrayOfTObjLinkRecord.initnul);
     pt^.AddMetod('','initnul','',@GDBOpenArrayOfTObjLinkRecord.initnul,m_constructor);
end;
end.
