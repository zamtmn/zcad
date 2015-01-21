unit RegCnownTypes;
{$INCLUDE def.inc}
{Этот модуль создан автоматически. НЕ РЕДАКТИРОВАТЬ}
interface
procedure RegTypes;
implementation
uses URecordDescriptor,UObjectDescriptor,Varman,gdbase,TypeDescriptors {$INCLUDE RFN.pas};
procedure RegTypes;
var
pt:PObjectDescriptor;
begin
if assigned(SysUnit) then begin
     pt:=SysUnit.ObjectTypeName2PTD('GDBBaseCamera');
     pt^.RegisterObject(TypeOf(GDBBaseCamera),@GDBBaseCamera.initnul);
     pt^.AddMetod('','initnul','',@GDBBaseCamera.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBObjEntityOpenArray');
     pt^.RegisterObject(TypeOf(GDBObjEntityOpenArray),@GDBObjEntityOpenArray.initnul);
     pt^.AddMetod('','initnul','',@GDBObjEntityOpenArray.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBPoint3dArray');
     pt^.RegisterObject(TypeOf(GDBPoint3dArray),@GDBPoint3dArray.initnul);
     pt^.AddMetod('','initnul','',@GDBPoint3dArray.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBPolyline2DArray');
     pt^.RegisterObject(TypeOf(GDBPolyline2DArray),@GDBPolyline2DArray.initnul);
     pt^.AddMetod('','initnul','',@GDBPolyline2DArray.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBLineWidthArray');
     pt^.RegisterObject(TypeOf(GDBLineWidthArray),@GDBLineWidthArray.initnul);
     pt^.AddMetod('','initnul','',@GDBLineWidthArray.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBTextStyleArray');
     pt^.RegisterObject(TypeOf(GDBTextStyleArray),@GDBTextStyleArray.initnul);
     pt^.AddMetod('','initnul','',@GDBTextStyleArray.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBLayerArray');
     pt^.RegisterObject(TypeOf(GDBLayerArray),@GDBLayerArray.initnul);
     pt^.AddMetod('','initnul','',@GDBLayerArray.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBObjCircle');
     pt^.RegisterObject(TypeOf(GDBObjCircle),@GDBObjCircle.initnul);
     pt^.AddMetod('','initnul','',@GDBObjCircle.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBObjArc');
     pt^.RegisterObject(TypeOf(GDBObjArc),@GDBObjArc.initnul);
     pt^.AddMetod('','initnul','',@GDBObjArc.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBObjBlockdef');
     pt^.RegisterObject(TypeOf(GDBObjBlockdef),@GDBObjBlockdef.initnul);
     pt^.AddMetod('','initnul','',@GDBObjBlockdef.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBObjBlockdefArray');
     pt^.RegisterObject(TypeOf(GDBObjBlockdefArray),@GDBObjBlockdefArray.initnul);
     pt^.AddMetod('','initnul','',@GDBObjBlockdefArray.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBObjBlockInsert');
     pt^.RegisterObject(TypeOf(GDBObjBlockInsert),@GDBObjBlockInsert.initnul);
     pt^.AddMetod('','initnul','',@GDBObjBlockInsert.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBObjDevice');
     pt^.RegisterObject(TypeOf(GDBObjDevice),@GDBObjDevice.initnul);
     pt^.AddMetod('','initnul','',@GDBObjDevice.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBObjNet');
     pt^.RegisterObject(TypeOf(GDBObjNet),@GDBObjNet.initnul);
     pt^.AddMetod('','initnul','',@GDBObjNet.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBObjLine');
     pt^.RegisterObject(TypeOf(GDBObjLine),@GDBObjLine.initnul);
     pt^.AddMetod('','initnul','',@GDBObjLine.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBObjLWPolyline');
     pt^.RegisterObject(TypeOf(GDBObjLWPolyline),@GDBObjLWPolyline.initnul);
     pt^.AddMetod('','initnul','',@GDBObjLWPolyline.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBObjText');
     pt^.RegisterObject(TypeOf(GDBObjText),@GDBObjText.initnul);
     pt^.AddMetod('','initnul','',@GDBObjText.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBObjMText');
     pt^.RegisterObject(TypeOf(GDBObjMText),@GDBObjMText.initnul);
     pt^.AddMetod('','initnul','',@GDBObjMText.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBObjPoint');
     pt^.RegisterObject(TypeOf(GDBObjPoint),@GDBObjPoint.initnul);
     pt^.AddMetod('','initnul','',@GDBObjPoint.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBObjPolyline');
     pt^.RegisterObject(TypeOf(GDBObjPolyline),@GDBObjPolyline.initnul);
     pt^.AddMetod('','initnul','',@GDBObjPolyline.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBObjRoot');
     pt^.RegisterObject(TypeOf(GDBObjRoot),@GDBObjRoot.initnul);
     pt^.AddMetod('','initnul','',@GDBObjRoot.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBObjCamera');
     pt^.RegisterObject(TypeOf(GDBObjCamera),@GDBObjCamera.initnul);
     pt^.AddMetod('','initnul','',@GDBObjCamera.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBOpenArrayOfTObjLinkRecord');
     pt^.RegisterObject(TypeOf(GDBOpenArrayOfTObjLinkRecord),@GDBOpenArrayOfTObjLinkRecord.initnul);
     pt^.AddMetod('','initnul','',@GDBOpenArrayOfTObjLinkRecord.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('DbBaseObject');
     pt^.RegisterObject(TypeOf(DbBaseObject),@DbBaseObject.initnul);
     pt^.AddMetod('','initnul','',@DbBaseObject.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('ElDeviceBaseObject');
     pt^.RegisterObject(TypeOf(ElDeviceBaseObject),@ElDeviceBaseObject.initnul);
     pt^.AddMetod('','initnul','',@ElDeviceBaseObject.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('CableDeviceBaseObject');
     pt^.RegisterObject(TypeOf(CableDeviceBaseObject),@CableDeviceBaseObject.initnul);
     pt^.AddMetod('','initnul','',@CableDeviceBaseObject.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('DbBaseObject');
     pt^.RegisterObject(TypeOf(DbBaseObject),@DbBaseObject.initnul);
     pt^.AddMetod('','initnul','',@DbBaseObject.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('ElDeviceBaseObject');
     pt^.RegisterObject(TypeOf(ElDeviceBaseObject),@ElDeviceBaseObject.initnul);
     pt^.AddMetod('','initnul','',@ElDeviceBaseObject.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('CableDeviceBaseObject');
     pt^.RegisterObject(TypeOf(CableDeviceBaseObject),@CableDeviceBaseObject.initnul);
     pt^.AddMetod('','initnul','',@CableDeviceBaseObject.initnul,m_constructor);

     pt:=SysUnit.ObjectTypeName2PTD('GDBDescriptor');
     pt^.RegisterObject(TypeOf(GDBDescriptor),@GDBDescriptor.initnul);
     pt^.AddMetod('','initnul','',@GDBDescriptor.initnul,m_constructor);

end;
end;
end.
