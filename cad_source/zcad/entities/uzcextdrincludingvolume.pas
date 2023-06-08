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
unit uzcExtdrIncludingVolume;
{$INCLUDE zengineconfig.inc}

interface
uses sysutils,UGDBObjBlockdefArray,uzedrawingdef,uzeentityextender,
     uzeentdevice,TypeDescriptors,uzctnrVectorBytes,
     uzbtypes,uzeentsubordinated,uzeentity,uzeblockdef,
     varmandef,Varman,UUnitManager,URecordDescriptor,UBaseTypeDescriptor,
     uzeentitiestree,usimplegenerics,uzeffdxfsupport,uzbpaths,uzcTranslations,
     gzctnrVectorTypes,uzeBaseExtender,uzeconsts,uzgldrawcontext;
const
  IncludingVolumeExtenderName='extdrIncludingVolume';
type
TIncludingVolumeExtender=class(TBaseEntityExtender)
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


function AddVolumeExtenderToEntity(PEnt:PGDBObjEntity):TIncludingVolumeExtender;
implementation

function AddVolumeExtenderToEntity(PEnt:PGDBObjEntity):TIncludingVolumeExtender;
begin
     result:=TIncludingVolumeExtender.Create(PEnt);
     PEnt^.AddExtension(result);
end;
procedure TIncludingVolumeExtender.onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);
begin
end;
constructor TIncludingVolumeExtender.Create;
begin
  pThisEntity:=pEntity;
end;
destructor TIncludingVolumeExtender.Destroy;
begin
end;
procedure TIncludingVolumeExtender.Assign(Source:TBaseExtender);
begin
end;

procedure TIncludingVolumeExtender.onEntityClone(pSourceEntity,pDestEntity:pointer);
begin
end;
procedure TIncludingVolumeExtender.onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);
begin
end;
procedure TIncludingVolumeExtender.onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;
procedure TIncludingVolumeExtender.onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;
procedure TIncludingVolumeExtender.CopyExt2Ent(pSourceEntity,pDestEntity:pointer);
begin
end;
procedure TIncludingVolumeExtender.ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);
begin
end;

procedure TIncludingVolumeExtender.PostLoad(var context:TIODXFLoadContext);
begin
end;

class function TIncludingVolumeExtender.getExtenderName:string;
begin
  result:=IncludingVolumeExtenderName;
end;

class function TIncludingVolumeExtender.EntIOLoadIncludingVolumeExtender(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  VolumeExtender:TIncludingVolumeExtender;
begin
  VolumeExtender:=PGDBObjEntity(PEnt)^.GetExtension<TIncludingVolumeExtender>;
  if VolumeExtender=nil then begin
    VolumeExtender:=AddVolumeExtenderToEntity(PEnt);
  end;
  result:=true;
end;

procedure TIncludingVolumeExtender.SaveToDxfObjXData(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);
begin
   dxfStringout(outhandle,1000,'INCLUDINGVOLUMEEXTENDER=');
end;


initialization
  //extdrAdd(extdrIncludingVolume)
  EntityExtenders.RegisterKey(uppercase(IncludingVolumeExtenderName),TIncludingVolumeExtender);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('INCLUDINGVOLUMEEXTENDER',TIncludingVolumeExtender.EntIOLoadIncludingVolumeExtender);
finalization
end.

