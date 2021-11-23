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
unit uzcExtdrLayerControl;

interface

uses sysutils,UGDBObjBlockdefArray,uzedrawingdef,uzeentityextender,
     uzeentdevice,TypeDescriptors,uzetextpreprocessor,UGDBOpenArrayOfByte,
     uzbtypesbase,uzbtypes,uzeentsubordinated,uzeentity,uzeenttext,uzeblockdef,
     varmandef,Varman,UUnitManager,URecordDescriptor,UBaseTypeDescriptor,uzbmemman,
     uzeentitiestree,usimplegenerics,uzeffdxfsupport,uzcvariablesutils,
     uzeBaseExtender,uzgldrawcontext;
const
  LayerControlExtenderName='extdrLayerControl';
type
TLayerControlExtender=class(TBaseEntityExtender)
    GoodLayer,BadLayer:GDBString;
    VariableName:GDBString;
    Inverse:GDBBoolean;
    class function getExtenderName:string;override;
    constructor Create(pEntity:Pointer);override;
    procedure Assign(Source:TBaseExtender);override;
    procedure onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;
    procedure onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;
    procedure SaveToDxf(var outhandle:GDBOpenArrayOfByte;PEnt:Pointer;var IODXFContext:TIODXFContext);override;
    procedure PostLoad(var context:TIODXFLoadContext);override;
    class function EntIOLoadGoodLayer(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
    class function EntIOLoadBadLayer(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
    class function EntIOLoadVariableName(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
    class function EntIOLoadInverse(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;

    procedure onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);override;
  end;

implementation
procedure TLayerControlExtender.Assign(Source:TBaseExtender);
begin
  GoodLayer:=TLayerControlExtender(Source).GoodLayer;
  BadLayer:=TLayerControlExtender(Source).BadLayer;
  VariableName:=TLayerControlExtender(Source).VariableName;
  Inverse:=TLayerControlExtender(Source).Inverse;
end;

constructor TLayerControlExtender.Create(pEntity:Pointer);
begin
  GoodLayer:='EL_DEVICE_NAME';
  BadLayer:='SYS_METRIC';
  VariableName:='Test';
  Inverse:=False;
end;

procedure TLayerControlExtender.onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;
procedure TLayerControlExtender.onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  pvd:pvardesk;
  pl:pointer;
begin
  pvd:=FindVariableInEnt(pEntity,VariableName);
  if pvd<>nil then
    if pvd^.data.Instance<>nil then
      if pvd^.data.PTD^.GetFactTypedef=@FundamentalBooleanDescriptorOdj then begin
        if pboolean(pvd^.data.Instance)^ xor Inverse then
          pl:=drawing.GetLayerTable^.getAddres(GoodLayer)
        else
          pl:=drawing.GetLayerTable^.getAddres(BadLayer);
        if pl<>nil then
          PGDBObjEntity(pEntity)^.vp.Layer:=pl;
      end;
end;

class function TLayerControlExtender.getExtenderName:string;
begin
  result:=LayerControlExtenderName;
end;

procedure TLayerControlExtender.SaveToDxf(var outhandle:GDBOpenArrayOfByte;PEnt:Pointer;var IODXFContext:TIODXFContext);
begin
  dxfGDBStringout(outhandle,1000,'LCGoodLayer='+GoodLayer);
  dxfGDBStringout(outhandle,1000,'LCBadLayer='+BadLayer);
  dxfGDBStringout(outhandle,1000,'LCVariableName='+VariableName);
  if Inverse then
    dxfGDBStringout(outhandle,1000,'LCInverse');
end;

procedure TLayerControlExtender.PostLoad(var context:TIODXFLoadContext);
begin
end;


function AddLayerControlExtenderToEntity(PEnt:PGDBObjEntity):TLayerControlExtender;
begin
  result:=TLayerControlExtender.Create(PEnt);
  PEnt^.AddExtension(result);
end;


class function TLayerControlExtender.EntIOLoadGoodLayer(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  LCExtdr:TLayerControlExtender;
begin
  LCExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TLayerControlExtender>;
  if LCExtdr=nil then
    LCExtdr:=AddLayerControlExtenderToEntity(PEnt);
  LCExtdr.GoodLayer:=_Value;
  result:=true;
end;

class function TLayerControlExtender.EntIOLoadBadLayer(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  LCExtdr:TLayerControlExtender;
begin
  LCExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TLayerControlExtender>;
  if LCExtdr=nil then
    LCExtdr:=AddLayerControlExtenderToEntity(PEnt);
  LCExtdr.BadLayer:=_Value;
  result:=true;
end;

class function TLayerControlExtender.EntIOLoadVariableName(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  LCExtdr:TLayerControlExtender;
begin
  LCExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TLayerControlExtender>;
  if LCExtdr=nil then
    LCExtdr:=AddLayerControlExtenderToEntity(PEnt);
  LCExtdr.VariableName:=_Value;
  result:=true;
end;

class function TLayerControlExtender.EntIOLoadInverse(_Name,_Value:GDBString;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  LCExtdr:TLayerControlExtender;
begin
  LCExtdr:=PGDBObjEntity(PEnt)^.GetExtension<TLayerControlExtender>;
  if LCExtdr=nil then
    LCExtdr:=AddLayerControlExtenderToEntity(PEnt);
  LCExtdr.Inverse:=True;
  result:=true;
end;


procedure TLayerControlExtender.onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);
begin
end;

initialization
  EntityExtenders.RegisterKey(uppercase(LayerControlExtenderName),TLayerControlExtender);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('LCGoodLayer',TLayerControlExtender.EntIOLoadGoodLayer);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('LCBadLayer',TLayerControlExtender.EntIOLoadBadLayer);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('LCVariableName',TLayerControlExtender.EntIOLoadVariableName);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('LCInverse',TLayerControlExtender.EntIOLoadInverse);
finalization
end.
