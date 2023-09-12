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
unit uzcExtdrNetConnector;
{$INCLUDE zengineconfig.inc}

interface
uses sysutils,uzedrawingdef,uzeentityextender,
     UGDBOpenArrayOfPV,uzeentgenericsubentry,uzeentline,uzegeometry,
     uzeentdevice,TypeDescriptors,uzctnrVectorBytes,
     uzbtypes,uzeentsubordinated,uzeentity,uzeblockdef,
     //varmandef,Varman,UUnitManager,URecordDescriptor,UBaseTypeDescriptor,
     usimplegenerics,uzeffdxfsupport,//uzbpaths,uzcTranslations,
     gzctnrVectorTypes,uzeBaseExtender,uzgldrawcontext,
     uzegeometrytypes,uzcsysvars,
     uzctnrVectorDouble,gzctnrVector,garrayutils;
const
  NetConnectorExtenderName='extdrNetConnector';
type

  TNetConnectorExtender=class(TBaseEntityExtender)
    public
      FConnectorRadius:Double;
      FSetter:Boolean;
    class function getExtenderName:string;override;
    constructor Create(pEntity:Pointer);override;
    destructor Destroy;override;

    procedure Assign(Source:TBaseExtender);override;

    procedure onRemoveFromArray(pEntity:Pointer;const drawing:TDrawingDef);override;
    procedure onEntityClone(pSourceEntity,pDestEntity:pointer);override;
    procedure onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);override;
    procedure onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;
    procedure onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;
    procedure onEntityConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;
    procedure CopyExt2Ent(pSourceEntity,pDestEntity:pointer);override;
    procedure ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);override;
    procedure PostLoad(var context:TIODXFLoadContext);override;

    procedure onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);override;


    class function EntIOLoadNetConnectorRadius(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
    class function EntIOLoadNetConnectorSetter(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;

    procedure SaveToDxfObjXData(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);override;

    procedure AddToDWGPostProcs(pEntity:Pointer;const drawing:TDrawingDef);

  end;


function AddNetConnectorExtenderToEntity(PEnt:PGDBObjEntity):TNetConnectorExtender;

implementation

function AddNetConnectorExtenderToEntity(PEnt:PGDBObjEntity):TNetConnectorExtender;
begin
  result:=TNetConnectorExtender.Create(PEnt);
  PEnt^.AddExtension(result);
end;
procedure TNetConnectorExtender.onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);
begin
end;
constructor TNetConnectorExtender.Create;
begin
  FConnectorRadius:=0;
  FSetter:=False;
end;
destructor TNetConnectorExtender.Destroy;
begin
end;
procedure TNetConnectorExtender.Assign(Source:TBaseExtender);
begin
  FConnectorRadius:=TNetConnectorExtender(Source).FConnectorRadius;
  FSetter:=TNetConnectorExtender(Source).FSetter;
end;


procedure TNetConnectorExtender.onRemoveFromArray(pEntity:Pointer;const drawing:TDrawingDef);
begin
end;
procedure TNetConnectorExtender.onEntityClone(pSourceEntity,pDestEntity:pointer);
var
  NetConnectorExtender:TNetConnectorExtender;
begin
  NetConnectorExtender:=PGDBObjEntity(pDestEntity)^.EntExtensions.GetExtension<TNetConnectorExtender>;
  if NetConnectorExtender=nil then
    NetConnectorExtender:=AddNetConnectorExtenderToEntity(pDestEntity);
  NetConnectorExtender.Assign(PGDBObjEntity(pSourceEntity)^.EntExtensions.GetExtension<TNetConnectorExtender>);
end;
procedure TNetConnectorExtender.onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);
begin
end;

procedure TNetConnectorExtender.AddToDWGPostProcs(pEntity:Pointer;const drawing:TDrawingDef);
var
  p:PGDBObjLine;
  ir:itrec;
begin
  {p:=ConnectedWith.beginiterate(ir);
  if p<>nil then
  repeat
    if p<>nil then
      PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray.PushBackIfNotPresent(p);
      PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjCasheArray.PushBackIfNotPresent(p);
  p:=ConnectedWith.iterate(ir);
  until p=nil;
  ConnectedWith.Clear;

  p:=IntersectedWith.beginiterate(ir);
  if p<>nil then
  repeat
    if p<>nil then
      PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray.PushBackIfNotPresent(p);
      PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjCasheArray.PushBackIfNotPresent(p);
  p:=IntersectedWith.iterate(ir);
  until p=nil;
  IntersectedWith.Clear;}
end;

procedure TNetConnectorExtender.onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
//var
 // CNet:TNet;
begin
  if {pThisEntity}pEntity<>nil then begin
    if not (ESConstructProxy in PGDBObjEntity(pEntity)^.State) then
      if IsIt(TypeOf(PGDBObjEntity(pEntity)^),typeof(GDBObjLine)) then begin
        //if Assigned(Net) then begin
        //  CNet:=Net;
        //  Net.RemoveMi(Self);
        //  if CNet.Entities.Count=0 then
        //    CNet.Destroy;
        //end;

        AddToDWGPostProcs(pEntity,drawing);

        PGDBObjEntity(pEntity)^.addtoconnect2(pEntity,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
      end;
  end;
end;
procedure TNetConnectorExtender.onEntityConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;
procedure TNetConnectorExtender.onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;

procedure TNetConnectorExtender.CopyExt2Ent(pSourceEntity,pDestEntity:pointer);
begin
  onEntityClone(pSourceEntity,pDestEntity);
end;
procedure TNetConnectorExtender.ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);
begin
end;

procedure TNetConnectorExtender.PostLoad(var context:TIODXFLoadContext);
begin
end;

class function TNetConnectorExtender.getExtenderName:string;
begin
  result:=NetConnectorExtenderName;
end;

class function TNetConnectorExtender.EntIOLoadNetConnectorRadius(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  NetConnectorExtender:TNetConnectorExtender;
begin
  NetConnectorExtender:=PGDBObjEntity(PEnt)^.GetExtension<TNetConnectorExtender>;
  if NetConnectorExtender=nil then begin
    NetConnectorExtender:=AddNetConnectorExtenderToEntity(PEnt);
  end;
  NetConnectorExtender.FConnectorRadius:=StrToFloat(_Value);
  result:=true;
end;

class function TNetConnectorExtender.EntIOLoadNetConnectorSetter(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  NetConnectorExtender:TNetConnectorExtender;
begin
  NetConnectorExtender:=PGDBObjEntity(PEnt)^.GetExtension<TNetConnectorExtender>;
  if NetConnectorExtender=nil then begin
    NetConnectorExtender:=AddNetConnectorExtenderToEntity(PEnt);
  end;
  NetConnectorExtender.FSetter:=True;
  result:=true;
end;


procedure TNetConnectorExtender.SaveToDxfObjXData(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);
begin
   dxfStringout(outhandle,1000,'NCEConnectorRadius=',FloatToStr(FConnectorRadius));
   if FSetter then
     dxfStringout(outhandle,1000,'NCESetter=TRUE');
end;

initialization
  //extdrAdd(extdrNetConnector)
  EntityExtenders.RegisterKey(uppercase(NetConnectorExtenderName),TNetConnectorExtender);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('NCEConnectorRadius',TNetConnectorExtender.EntIOLoadNetConnectorRadius);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('NCESetter',TNetConnectorExtender.EntIOLoadNetConnectorSetter);
finalization
end.

