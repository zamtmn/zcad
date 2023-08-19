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
     UGDBOpenArrayOfPV,uzeentgenericsubentry,uzeentline,uzegeometry,
     uzeentdevice,TypeDescriptors,uzctnrVectorBytes,
     uzbtypes,uzeentsubordinated,uzeentity,uzeblockdef,
     varmandef,Varman,UUnitManager,URecordDescriptor,UBaseTypeDescriptor,
     uzeentitiestree,usimplegenerics,uzeffdxfsupport,uzbpaths,uzcTranslations,
     gzctnrVectorTypes,uzeBaseExtender,uzeconsts,uzgldrawcontext;
const
  NetExtenderName='extdrNet';
type
TNet=class
    Entities:GDBObjOpenArrayOfPV;
    constructor Create;
    destructor Destroy;override;
end;

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


    class function EntIOLoadNetExtender(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;

    procedure SaveToDxfObjXData(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);override;

    procedure TryConnectToEnts(var Objects:GDBObjOpenArrayOfPV);
  end;


function AddNetExtenderToEntity(PEnt:PGDBObjEntity):TNetExtender;

implementation

constructor TNet.Create;
begin
  Entities.init(10);
end;

destructor TNet.Destroy;
begin
  Entities.done;
end;

function AddNetExtenderToEntity(PEnt:PGDBObjEntity):TNetExtender;
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
var
  Objects:GDBObjOpenArrayOfPV;
begin
  if pThisEntity<>nil then begin
    if not (ESConstructProxy in pThisEntity^.State) then
      if pThisEntity^.GetObjType=GDBLineID then begin
        objects.init(10);
        if PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.FindObjectsInPoint(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,Objects) then
          TryConnectToEnts(Objects);
        if PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.FindObjectsInPoint(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,Objects) then
          TryConnectToEnts(Objects);
      end;
  end;
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

class function TNetExtender.EntIOLoadNetExtender(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  NetExtender:TNetExtender;
begin
  NetExtender:=PGDBObjEntity(PEnt)^.GetExtension<TNetExtender>;
  if NetExtender=nil then begin
    NetExtender:=AddNetExtenderToEntity(PEnt);
  end;
  result:=true;
end;

procedure TNetExtender.SaveToDxfObjXData(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);
begin
   dxfStringout(outhandle,1000,'NETEXTENDER=');
end;

procedure TNetExtender.TryConnectToEnts(var Objects:GDBObjOpenArrayOfPV);
var
  p:PGDBObjLine;
  ir:itrec;
  NetExtender:TNetExtender;
begin
  p:=Objects.beginiterate(ir);
  if p<>nil then
  repeat
    {if (p<>pThisEntity)and(p^.GetObjType=GDBLineID) then begin
      NetExtender:=p^.GetExtension<TNetExtender>;
      if NetExtender<>nil then begin
        uzegeometry.
      end;
    end;}
  p:=Objects.iterate(ir);
  until p=nil;
end;

initialization
  //extdrAdd(extdrNet)
  EntityExtenders.RegisterKey(uppercase(NetExtenderName),TNetExtender);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('NETEXTENDER',TNetExtender.EntIOLoadNetExtender);
finalization
end.

