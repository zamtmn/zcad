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
unit uzcExtdrConnector;
{$INCLUDE zengineconfig.inc}

interface
uses sysutils,uzedrawingdef,uzeentityextender,
     uzeentgenericsubentry,uzeentline,uzegeometry,
     uzeentdevice,TypeDescriptors,uzctnrVectorBytes,
     uzbtypes,uzeentsubordinated,uzeentity,uzeblockdef,
     usimplegenerics,uzeffdxfsupport,
     gzctnrVectorTypes,uzeBaseExtender,uzgldrawcontext,
     uzcsysvars,gzctnrVectorSimple,gzctnrVectorP,
     gzctnrVector;
const
  ConnectionExtenderName='extdrConnector';
type

  TNet=class;
  TBaseConnectExtender=class(TBaseEntityExtender)
    Net:TNet;
    pThisEntity:PGDBObjEntity;
    constructor Create(pEntity:Pointer);override;
    destructor Destroy;override;
  end;

  TConnectExtendersVector=GZVectorP<TBaseConnectExtender>;

  TNet=class
    Connections:TConnectExtendersVector;
    Setters:TConnectExtendersVector;
    Pins:TConnectExtendersVector;
    constructor Create;
    destructor Destroy;override;
    procedure AddConnection(Extdr:TBaseConnectExtender);
    procedure RemoveConnection(Extdr:TBaseConnectExtender);
    procedure AddSetter(Extdr:TBaseConnectExtender);
    procedure RemoveSetter(Extdr:TBaseConnectExtender);
    procedure AddPin(Extdr:TBaseConnectExtender);
    procedure RemovePin(Extdr:TBaseConnectExtender);

    function BiggerThat(Net:TNet):Boolean;
    function IsEmpty:Boolean;
    procedure ConsumeNet(Net:TNet);
    class procedure ConcatNets(Extdr1,Extdr2:TBaseConnectExtender);

    procedure AddToDWGPostProcs(pEntity:Pointer;const drawing:TDrawingDef);
  end;

  TConnectorExtender=class(TBaseConnectExtender)
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


function AddConnectorExtenderToEntity(PEnt:PGDBObjEntity):TConnectorExtender;

implementation

constructor TBaseConnectExtender.Create(pEntity:Pointer);
begin
  Net:=nil;
  pThisEntity:=pEntity;
end;
destructor TBaseConnectExtender.Destroy;
begin

end;

constructor TNet.Create;
begin
  Connections.init(10);
  Setters.init(2);
  Pins.init(10);
end;

destructor TNet.Destroy;
begin
  Connections.Clear;
  Connections.done;

  Setters.Clear;
  Setters.done;

  Pins.Clear;
  Pins.done;
end;

procedure TNet.AddConnection(Extdr:TBaseConnectExtender);
begin
  Connections.PushBackIfNotPresent(Extdr);
  Extdr.Net:=Self;
end;
procedure TNet.RemoveConnection(Extdr:TBaseConnectExtender);
begin
  Connections.RemoveDataFromArray(Extdr);
  Extdr.Net:=nil;
end;
procedure TNet.AddSetter(Extdr:TBaseConnectExtender);
begin
  Setters.PushBackIfNotPresent(Extdr);
  Extdr.Net:=Self;
end;
procedure TNet.RemoveSetter(Extdr:TBaseConnectExtender);
begin
  Setters.RemoveDataFromArray(Extdr);
  Extdr.Net:=nil;
end;
procedure TNet.AddPin(Extdr:TBaseConnectExtender);
var
  ir:itrec;
begin
  Pins.PushBackIfNotPresent(Extdr);
  Extdr.Net:=Self;
end;
procedure TNet.RemovePin(Extdr:TBaseConnectExtender);
begin
  Pins.RemoveDataFromArray(Extdr);
  Extdr.Net:=nil;
end;

function TNet.BiggerThat(Net:TNet):Boolean;
begin
  result:=    Connections.GetCount+    Setters.GetCount+    Pins.GetCount
         >Net.Connections.GetCount+Net.Setters.GetCount+Net.Pins.GetCount;
end;
function TNet.IsEmpty:Boolean;
begin
  result:=(Connections.GetCount=0)and(Setters.GetCount=0)and(Pins.GetCount=0);
end;

procedure TNet.ConsumeNet(Net:TNet);
var
  Extdr:TBaseConnectExtender;
  ir:itrec;
begin
  Extdr:=Net.Connections.beginiterate(ir);
  if Extdr<>nil then
  repeat
    //Net.RemoveConnection(Extdr);
    AddConnection(Extdr);
  Extdr:=Net.Connections.iterate(ir);
  until Extdr=nil;
  Net.Connections.Clear;

  Extdr:=Net.Setters.beginiterate(ir);
  if Extdr<>nil then
  repeat
    //Net.RemoveSetter(Extdr);
    AddSetter(Extdr);
  Extdr:=Net.Setters.iterate(ir);
  until Extdr=nil;
  Net.Setters.Clear;

  Extdr:=Net.Pins.beginiterate(ir);
  if Extdr<>nil then
  repeat
    //Net.RemovePin(Extdr);
    AddPin(Extdr);
  Extdr:=Net.Pins.iterate(ir);
  until Extdr=nil;
  Net.Pins.Clear;
end;

procedure TNet.AddToDWGPostProcs(pEntity:Pointer;const drawing:TDrawingDef);
var
  p:TBaseConnectExtender;
  ir:itrec;
begin
  p:=Connections.beginiterate(ir);
  if p<>nil then
  repeat
    PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray.PushBackIfNotPresent(p.pThisEntity);
    PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjCasheArray.PushBackIfNotPresent(p.pThisEntity);

  p:=Connections.iterate(ir);
  until p=nil;

  p:=Setters.beginiterate(ir);
  if p<>nil then
  repeat
    PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray.PushBackIfNotPresent(p.pThisEntity);
    PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjCasheArray.PushBackIfNotPresent(p.pThisEntity);

  p:=Setters.iterate(ir);
  until p=nil;

  p:=Pins.beginiterate(ir);
  if p<>nil then
  repeat
    PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray.PushBackIfNotPresent(p.pThisEntity);
    PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjCasheArray.PushBackIfNotPresent(p.pThisEntity);

  p:=Pins.iterate(ir);
  until p=nil;
end;

class procedure TNet.ConcatNets(Extdr1,Extdr2:TBaseConnectExtender);
var
  NewNet:TNet;
begin
  if (Extdr1.Net=nil)and(Extdr2.Net=nil)then begin
    NewNet:=TNet.Create;
    NewNet.AddConnection(Extdr1);
    NewNet.AddConnection(Extdr2);
  end else if Extdr1.Net=Extdr2.Net then begin
    //уже склеены, ничего не делаем
  end else if (Extdr1.Net<>nil)and(Extdr2.Net<>nil)then begin
    if Extdr1.Net.BiggerThat(Extdr2.Net) then begin
      NewNet:=Extdr2.Net;
      Extdr1.Net.ConsumeNet(Extdr2.Net);
    end else begin
      NewNet:=Extdr1.Net;
      Extdr2.Net.ConsumeNet(Extdr1.Net);
    end;
    NewNet.Destroy;
  end else if Extdr1.Net<>nil then begin
    Extdr1.Net.AddConnection(Extdr2)
  end else begin
    Extdr2.Net.AddConnection(Extdr1)
  end;
end;

function AddConnectorExtenderToEntity(PEnt:PGDBObjEntity):TConnectorExtender;
begin
  result:=TConnectorExtender.Create(PEnt);
  PEnt^.AddExtension(result);
end;
procedure TConnectorExtender.onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);
begin
end;
constructor TConnectorExtender.Create;
begin
  inherited Create(pEntity);
  FConnectorRadius:=0;
  FSetter:=False;
end;
destructor TConnectorExtender.Destroy;
begin
end;
procedure TConnectorExtender.Assign(Source:TBaseExtender);
begin
  FConnectorRadius:=TConnectorExtender(Source).FConnectorRadius;
  FSetter:=TConnectorExtender(Source).FSetter;
end;


procedure TConnectorExtender.onRemoveFromArray(pEntity:Pointer;const drawing:TDrawingDef);
begin
  AddToDWGPostProcs(pEntity,drawing);
end;

procedure TConnectorExtender.onEntityClone(pSourceEntity,pDestEntity:pointer);
var
  NetConnectorExtender:TConnectorExtender;
begin
  NetConnectorExtender:=PGDBObjEntity(pDestEntity)^.EntExtensions.GetExtension<TConnectorExtender>;
  if NetConnectorExtender=nil then
    NetConnectorExtender:=AddConnectorExtenderToEntity(pDestEntity);
  NetConnectorExtender.Assign(PGDBObjEntity(pSourceEntity)^.EntExtensions.GetExtension<TConnectorExtender>);
end;
procedure TConnectorExtender.onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);
begin
end;

procedure TConnectorExtender.AddToDWGPostProcs(pEntity:Pointer;const drawing:TDrawingDef);
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

procedure TConnectorExtender.onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  CNet:TNet;
begin
  if (pEntity<>nil)and(dc.Options*[DCODrawable]<>[]) then begin
    if not PGDBObjEntity(pEntity)^.CheckState([ESConstructProxy,ESTemp]) then begin
      if Assigned(net) then begin
        CNet:=Net;
        if FSetter then
          Net.RemoveSetter(Self)
        else
          Net.RemovePin(Self);
        CNet.AddToDWGPostProcs(pEntity,drawing);
        if CNet.IsEmpty then
          CNet.Destroy;
      end;

      AddToDWGPostProcs(pEntity,drawing);

      PGDBObjEntity(pEntity)^.addtoconnect2(pEntity,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
    end;
  end;
end;

procedure TConnectorExtender.onEntityConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;
procedure TConnectorExtender.onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;

procedure TConnectorExtender.CopyExt2Ent(pSourceEntity,pDestEntity:pointer);
begin
  onEntityClone(pSourceEntity,pDestEntity);
end;
procedure TConnectorExtender.ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);
begin
end;

procedure TConnectorExtender.PostLoad(var context:TIODXFLoadContext);
begin
end;

class function TConnectorExtender.getExtenderName:string;
begin
  result:=ConnectionExtenderName;
end;

class function TConnectorExtender.EntIOLoadNetConnectorRadius(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  NetConnectorExtender:TConnectorExtender;
begin
  NetConnectorExtender:=PGDBObjEntity(PEnt)^.GetExtension<TConnectorExtender>;
  if NetConnectorExtender=nil then begin
    NetConnectorExtender:=AddConnectorExtenderToEntity(PEnt);
  end;
  NetConnectorExtender.FConnectorRadius:=StrToFloat(_Value);
  result:=true;
end;

class function TConnectorExtender.EntIOLoadNetConnectorSetter(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  NetConnectorExtender:TConnectorExtender;
begin
  NetConnectorExtender:=PGDBObjEntity(PEnt)^.GetExtension<TConnectorExtender>;
  if NetConnectorExtender=nil then begin
    NetConnectorExtender:=AddConnectorExtenderToEntity(PEnt);
  end;
  NetConnectorExtender.FSetter:=True;
  result:=true;
end;


procedure TConnectorExtender.SaveToDxfObjXData(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);
begin
   dxfStringout(outhandle,1000,'CONNECTORRADIUS=',FloatToStr(FConnectorRadius));
   if FSetter then
     dxfStringout(outhandle,1000,'NCESetter=TRUE');
end;

initialization
  //extdrAdd(extdrNetConnector)
  EntityExtenders.RegisterKey(uppercase(ConnectionExtenderName),TConnectorExtender);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('CONNECTORRADIUS',TConnectorExtender.EntIOLoadNetConnectorRadius);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('CONNECTORSETTER',TConnectorExtender.EntIOLoadNetConnectorSetter);
finalization
end.

