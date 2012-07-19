unit RegCnownTypes;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
procedure RegTypes;
implementation
uses URecordDescriptor,UObjectDescriptor,Varman,gdbase {$INCLUDE RFN.pas};
procedure RegTypes;
var
pt:PObjectDescriptor;
begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBObjCamera');
     pt^.RegisterVMT(TypeOf(GDBObjCamera));
     pt:=SysUnit.ObjectTypeName2PTD('DbBaseObject');
     pt^.RegisterVMT(TypeOf(DbBaseObject));
     pt:=SysUnit.ObjectTypeName2PTD('ElDeviceBaseObject');
     pt^.RegisterVMT(TypeOf(ElDeviceBaseObject));
     pt:=SysUnit.ObjectTypeName2PTD('CableDeviceBaseObject');
     pt^.RegisterVMT(TypeOf(CableDeviceBaseObject));
     pt:=SysUnit.ObjectTypeName2PTD('DbBaseObject');
     pt^.RegisterVMT(TypeOf(DbBaseObject));
     pt:=SysUnit.ObjectTypeName2PTD('ElDeviceBaseObject');
     pt^.RegisterVMT(TypeOf(ElDeviceBaseObject));
     pt:=SysUnit.ObjectTypeName2PTD('CableDeviceBaseObject');
     pt^.RegisterVMT(TypeOf(CableDeviceBaseObject));
end;
end.
