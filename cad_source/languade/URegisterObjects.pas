{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit URegisterObjects;
{$INCLUDE def.inc}
interface
uses {URecordDescriptor,}UObjectDescriptor,TypeDescriptors;
procedure startup;
implementation
uses GDBDevice,GDBBlockDef,varman,UGDBDescriptor,UGDBLayerArray,UGDBTextStyleArray,
     UGDBOpenArrayOfTObjLinkRecord,UGDBObjBlockdefArray,UGDBVisibleOpenArray,
     GDBRoot,{gdbEntity,}GDBBlockInsert,GDBCircle,GDBArc,
     GDBPoint,GDBText,GDBMText,GDBLine,GDBPolyLine,GDBLWPolyLine,GDBNet,
     UGDBPoint3DArray,UGDBLineWidthArray,UGDBPolyLine2DArray,gdbase,GDBCamera,log,RegCnownTypes;
procedure startup;
     var potd:PObjectDescriptor;
begin
     potd:=PObjectDescriptor(SysUnit^.TypeName2PTD('GDBBaseCamera'));
     potd^.RegisterObject(typeof(GDBBaseCamera),@GDBBaseCamera.initnul);
     potd^.AddMetod('','initnul','',@GDBBaseCamera.initnul,m_constructor);

     potd:=PObjectDescriptor(SysUnit^.TypeName2PTD('GDBObjCamera'));
     potd^.RegisterObject(typeof(GDBObjCamera),@GDBObjCamera.initnul);
     potd^.AddMetod('','initnul','',@GDBObjCamera.initnul,m_constructor);

     potd:=PObjectDescriptor(SysUnit^.TypeName2PTD('GDBDescriptor'));
     potd^.RegisterObject(typeof(GDBDescriptor),@GDBDescriptor.initnul);
     //potd^.AddMetod('initnul',@GDBDescriptor.initnul,m_constructor);
     //potd^.AddMetod('format',@GDBDescriptor.format,m_procedure);

     potd:=PObjectDescriptor(SysUnit^.TypeName2PTD('GDBLayerArray'));
     potd^.RegisterObject(typeof(GDBLayerArray),@GDBLayerArray.initnul);
     //potd^.AddMetod('initnul',@GDBLayerArray.initnul,m_constructor);
     //potd^.AddMetod('format',@GDBLayerArray.format,m_procedure);

     potd:=PObjectDescriptor(SysUnit.TypeName2PTD('GDBTextStyleArray'));
     potd^.RegisterObject(typeof(GDBTextStyleArray),@GDBTextStyleArray.initnul);
     //potd^.AddMetod('initnul',@GDBLayerArray.initnul,m_constructor);
     //potd^.AddMetod('format',@GDBLayerArray.format,m_procedure);


     potd:=PObjectDescriptor(SysUnit.TypeName2PTD('GDBOpenArrayOfTObjLinkRecord'));
     potd^.RegisterObject(typeof(GDBOpenArrayOfTObjLinkRecord),@GDBOpenArrayOfTObjLinkRecord.initnul);
     //PObjectDescriptor(Types.TypeName2PTD('GDBOpenArrayOfTObjLinkRecord'))^.RegisterVMT(typeof(GDBOpenArrayOfTObjLinkRecord));
     //PObjectDescriptor(Types.TypeName2PTD('GDBOpenArrayOfTObjLinkRecord'))^.RegisterDefaultConstructor(@GDBOpenArrayOfTObjLinkRecord.initnul);

     potd:=PObjectDescriptor(SysUnit.TypeName2PTD('GDBObjBlockdefArray'));
     potd^.RegisterObject(typeof(GDBObjBlockdefArray),@GDBObjBlockdefArray.initnul);
     //PObjectDescriptor(Types.TypeName2PTD('GDBObjBlockdefArray'))^.RegisterVMT(typeof(GDBObjBlockdefArray));
     //PObjectDescriptor(Types.TypeName2PTD('GDBObjBlockdefArray'))^.RegisterDefaultConstructor(@GDBObjBlockdefArray.initnul);

     potd:=PObjectDescriptor(SysUnit.TypeName2PTD('GDBObjRoot'));
     potd^.RegisterObject(typeof(GDBObjRoot),@GDBObjRoot.initnul);
     //PObjectDescriptor(Types.TypeName2PTD('GDBObjRoot'))^.RegisterVMT(typeof(GDBObjRoot));
     //PObjectDescriptor(Types.TypeName2PTD('GDBObjRoot'))^.RegisterDefaultConstructor(@GDBObjRoot.initnul);

     potd:=PObjectDescriptor(SysUnit.TypeName2PTD('GDBObjLine'));
     potd^.RegisterObject(typeof(GDBObjLine),@GDBObjLine.initnul);
     //PObjectDescriptor(Types.TypeName2PTD('GDBObjLine'))^.RegisterVMT(typeof(GDBObjLine));
     //PObjectDescriptor(Types.TypeName2PTD('GDBObjLine'))^.RegisterDefaultConstructor(@GDBObjLine.initnul);

     potd:=PObjectDescriptor(SysUnit.TypeName2PTD('GDBObjCircle'));
     potd^.RegisterObject(typeof(GDBObjCircle),@GDBObjCircle.initnul);
     //PObjectDescriptor(Types.TypeName2PTD('GDBObjCircle'))^.RegisterVMT(typeof(GDBObjCircle));
     //PObjectDescriptor(Types.TypeName2PTD('GDBObjCircle'))^.RegisterDefaultConstructor(@GDBObjCircle.initnul);

     potd:=PObjectDescriptor(SysUnit.TypeName2PTD('GDBObjArc'));
     potd^.RegisterObject(typeof(GDBObjArc),@GDBObjArc.initnul);

     potd:=PObjectDescriptor(SysUnit.TypeName2PTD('GDBObjPoint'));
     potd^.RegisterObject(typeof(GDBObjPoint),@GDBObjPoint.initnul);

     potd:=PObjectDescriptor(SysUnit.TypeName2PTD('GDBObjNet'));
     potd^.RegisterObject(typeof(GDBObjNet),@GDBObjNet.initnul);

     potd:=PObjectDescriptor(SysUnit.TypeName2PTD('GDBObjPolyline'));
     potd^.RegisterObject(typeof(GDBObjPolyline),@GDBObjPolyline.initnul);

     potd:=PObjectDescriptor(SysUnit.TypeName2PTD('GDBPoint3dArray'));
     potd^.RegisterObject(typeof(GDBPoint3dArray),@GDBPoint3dArray.initnul);

     potd:=PObjectDescriptor(SysUnit.TypeName2PTD('GDBObjLWPolyline'));
     potd^.RegisterObject(typeof(GDBObjLWPolyline),@GDBObjLWPolyline.initnul);

     potd:=PObjectDescriptor(SysUnit.TypeName2PTD('GDBLineWidthArray'));
     potd^.RegisterObject(typeof(GDBLineWidthArray),@GDBLineWidthArray.initnul);

     potd:=PObjectDescriptor(SysUnit.TypeName2PTD('GDBPolyline2DArray'));
     potd^.RegisterObject(typeof(GDBPolyline2DArray),@GDBPolyline2DArray.initnul);

     potd:=PObjectDescriptor(SysUnit.TypeName2PTD('GDBObjBlockInsert'));
     potd^.RegisterObject(typeof(GDBObjBlockInsert),@GDBObjBlockInsert.initnul);

     potd:=PObjectDescriptor(SysUnit.TypeName2PTD('GDBObjDevice'));
     potd^.RegisterObject(typeof(GDBObjDevice),@GDBObjDevice.initnul);

     potd:=PObjectDescriptor(SysUnit.TypeName2PTD('GDBObjText'));
     potd^.RegisterObject(typeof(GDBObjText),@GDBObjText.initnul);
     //PObjectDescriptor(Types.TypeName2PTD('GDBObjText'))^.RegisterVMT(typeof(GDBObjText));
     //PObjectDescriptor(Types.TypeName2PTD('GDBObjText'))^.RegisterDefaultConstructor(@GDBObjText.initnul);

     potd:=PObjectDescriptor(SysUnit.TypeName2PTD('GDBObjMText'));
     potd^.RegisterObject(typeof(GDBObjMText),@GDBObjMText.initnul);

     potd:=PObjectDescriptor(SysUnit.TypeName2PTD('GDBObjBlockdef'));
     potd^.RegisterObject(typeof(GDBObjBlockdef),@GDBObjBlockdef.initnul);

     //PObjectDescriptor(Types.TypeName2PTD('GDBObjBlockdef'))^.RegisterVMT(typeof(GDBObjBlockdef));
     //PObjectDescriptor(Types.TypeName2PTD('GDBObjBlockdef'))^.RegisterDefaultConstructor(@GDBObjBlockdef.initnul);

     potd:=PObjectDescriptor(SysUnit.TypeName2PTD('GDBObjBlockdefArray'));
     potd^.RegisterObject(typeof(GDBObjBlockdefArray),@GDBObjBlockdefArray.initnul);
     //PObjectDescriptor(Types.TypeName2PTD('GDBObjBlockdefArray'))^.RegisterVMT(typeof(GDBObjBlockdefArray));
     //PObjectDescriptor(Types.TypeName2PTD('GDBObjBlockdefArray'))^.RegisterDefaultConstructor(@GDBObjBlockdefArray.initnul);

     potd:=PObjectDescriptor(SysUnit.TypeName2PTD('GDBObjEntityOpenArray'));
     potd^.RegisterObject(typeof(GDBObjEntityOpenArray),@GDBObjEntityOpenArray.initnul);
     //PObjectDescriptor(Types.TypeName2PTD('GDBObjEntityOpenArray'))^.RegisterVMT(typeof(GDBObjEntityOpenArray));
     //PObjectDescriptor(Types.TypeName2PTD('GDBObjEntityOpenArray'))^.RegisterDefaultConstructor(@GDBObjEntityOpenArray.initnul);

end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('URegistrObjects.initialization');{$ENDIF}
  RegCnownTypes.RegTypes;
  startup;
end.
