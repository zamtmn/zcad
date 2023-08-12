{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
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
unit uzcExtdrNet;
{$INCLUDE zengineconfig.inc}

interface
uses sysutils,UGDBObjBlockdefArray,uzedrawingdef,uzeentityextender,
     uzeentdevice,TypeDescriptors,uzctnrVectorBytes,
     uzbtypes,uzeentsubordinated,uzeentity,uzeblockdef,
     varmandef,Varman,UUnitManager,URecordDescriptor,UBaseTypeDescriptor,
     uzeentitiestree,usimplegenerics,uzeffdxfsupport,uzbpaths,uzcTranslations,
     gzctnrVectorTypes,uzeBaseExtender,uzeconsts,uzgldrawcontext;
const
  NetExtenderName='extdrNet';
type
TNetExtender=class(TBaseEntityExtender)
    pThisEntity:PGDBObjEntity;
    class function getExtenderName:string;override;
    constructor Create(pEntity:Pointer);override;
    destructor Destroy;override;

    procedure Assign(Source:TBaseExtender);override;

    procedure onEntityClone(pSourceEntity,pDestEntity:pointer);override;
    procedure onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);override;
    procedure onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;
    procedure onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;
    procedure CopyExt2Ent(pSourceEntity,pDestEntity:pointer);override;
    procedure ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);override;
    procedure PostLoad(var context:TIODXFLoadContext);override;

    procedure onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);override;


    class function EntIOLoadIncludingVolumeExtender(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;

    procedure SaveToDxfObjXData(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);override;
  end;


function AddVolumeExtenderToEntity(PEnt:PGDBObjEntity):TNetExtender;
implementation

function AddVolumeExtenderToEntity(PEnt:PGDBObjEntity):TNetExtender;
begin
     result:=TNetExtender.Create(PEnt);
     PEnt^.AddExtension(result);
end;
procedure TNetExtender.onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);
begin
end;
constructor TNetExtender.Create;
begin
  pThisEntity:=pEntity;
end;
destructor TNetExtender.Destroy;
begin
end;
procedure TNetExtender.Assign(Source:TBaseExtender);
begin
end;

procedure TNetExtender.onEntityClone(pSourceEntity,pDestEntity:pointer);
begin
end;
procedure TNetExtender.onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);
begin
end;
procedure TNetExtender.onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;
procedure TNetExtender.onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;
procedure TNetExtender.CopyExt2Ent(pSourceEntity,pDestEntity:pointer);
begin
end;
procedure TNetExtender.ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);
begin
end;

procedure TNetExtender.PostLoad(var context:TIODXFLoadContext);
begin
end;

class function TNetExtender.getExtenderName:string;
begin
  result:=NetExtenderName;
end;

class function TNetExtender.EntIOLoadIncludingVolumeExtender(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  VolumeExtender:TNetExtender;
begin
  VolumeExtender:=PGDBObjEntity(PEnt)^.GetExtension<TNetExtender>;
  if VolumeExtender=nil then begin
    VolumeExtender:=AddVolumeExtenderToEntity(PEnt);
  end;
  result:=true;
end;

procedure TNetExtender.SaveToDxfObjXData(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);
begin
   dxfStringout(outhandle,1000,'NETEXTENDER=');
end;


initialization
  //extdrAdd(extdrIncludingVolume)
  EntityExtenders.RegisterKey(uppercase(NetExtenderName),TNetExtender);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('NETVOLUMEEXTENDER',TNetExtender.EntIOLoadIncludingVolumeExtender);
finalization
end.

