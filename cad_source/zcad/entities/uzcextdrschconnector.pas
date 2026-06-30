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
unit uzcExtdrSCHConnector;
{$INCLUDE zengineconfig.inc}

interface
uses
  sysutils,uzedrawingdef,uzeExtdrAbstractEntityExtender,
  uzeExtdrBaseEntityExtender,
  uzeentgenericsubentry,uzeentline,
  uzeentdevice,uzctnrVectorBytesStream,
  uzeTypes,uzeentsubordinated,uzeentity,uzeblockdef,
  usimplegenerics,uzeffdxfsupport,
  gzctnrVectorTypes,uzeBaseExtender,uzgldrawcontext,
  uzcsysvars,gzctnrVectorSimple,gzctnrVectorP,UGDBOpenArrayOfPV,
  gzctnrVector;
const
  ConnectionExtenderName='extdrSCHConnector';
type

  TNet=class;
  TBaseSCHConnectExtender=class(TBaseEntityExtender)
    Net:TNet;
    constructor Create(pEntity:Pointer);override;
    destructor Destroy;override;
  end;

  TConnectExtendersVector=GZVectorP<TBaseSCHConnectExtender>;

  TNet=class
    Connections:TConnectExtendersVector;
    Setters:TConnectExtendersVector;
    Infos:TConnectExtendersVector;
    Pins:TConnectExtendersVector;
    constructor Create;
    destructor Destroy;override;
    procedure AddConnection(Extdr:TBaseSCHConnectExtender);
    procedure RemoveConnection(Extdr:TBaseSCHConnectExtender);
    procedure AddSetter(Extdr:TBaseSCHConnectExtender);
    procedure RemoveSetter(Extdr:TBaseSCHConnectExtender);
    procedure AddPin(Extdr:TBaseSCHConnectExtender);
    procedure RemovePin(Extdr:TBaseSCHConnectExtender);
    procedure AddInfo(Extdr:TBaseSCHConnectExtender);
    procedure RemoveInfo(Extdr:TBaseSCHConnectExtender);


    function BiggerThat(Net:TNet):Boolean;
    function IsEmpty:Boolean;
    procedure ConsumeNet(Net:TNet);
    class procedure ConcatNets(Extdr1,Extdr2:TBaseSCHConnectExtender);

    procedure AddToDWGPostProcs(pEntity:Pointer;const drawing:TDrawingDef);
  end;
  TConnectorType=(CTInfo,CTPin,CTSetter);
  TConnectorState=(CSNormal,CSSecondTry);//убрать
                                         //делал из расчета чтобы только один раз
                                         //передобавлять коннектор в список
                                         //на соединение, но работает без этого
  TSCHConnectorExtender=class(TBaseSCHConnectExtender)
    const
      DefaultConnectorRadius=0;
      DefaultConnectorType=CTPin;
    private
      FState:TConnectorState;
    public
      FConnectorRadius:Double;
      FConnectorType:TConnectorType;
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

    procedure SaveToDxfObjXData(var outStream:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFSaveContext);override;

    procedure AddToDWGPostProcs(pEntity:Pointer;const drawing:TDrawingDef);

  end;

function AddConnectorExtenderToEntity(PEnt:PGDBObjEntity):TSCHConnectorExtender;

implementation

uses
  uzcExtdrSCHConnection;

const
  CT2String:array[TConnectorType] of string=('CTInfo','CTPin','CTSetter');
  CT2UCString:array[TConnectorType] of string=('CTINFO','CTPIN','CTSETTER');

constructor TBaseSCHConnectExtender.Create(pEntity:Pointer);
begin
  inherited;
  Net:=nil;
  //pThisEntity:=pEntity;
end;
destructor TBaseSCHConnectExtender.Destroy;
begin

end;

constructor TNet.Create;
begin
  Connections.init(10);
  Setters.init(2);
  Infos.init(2);
  Pins.init(10);
end;

destructor TNet.Destroy;
begin
  Connections.Clear;
  Connections.done;

  Setters.Clear;
  Setters.done;

  Infos.Clear;
  Infos.done;

  Pins.Clear;
  Pins.done;
end;

procedure TNet.AddConnection(Extdr:TBaseSCHConnectExtender);
begin
  Connections.PushBackIfNotPresent(Extdr);
  Extdr.Net:=Self;
end;
procedure TNet.RemoveConnection(Extdr:TBaseSCHConnectExtender);
begin
  Connections.RemoveDataFromArray(Extdr);
  Extdr.Net:=nil;
end;
procedure TNet.AddSetter(Extdr:TBaseSCHConnectExtender);
begin
  Setters.PushBackIfNotPresent(Extdr);
  Extdr.Net:=Self;
end;
procedure TNet.RemoveSetter(Extdr:TBaseSCHConnectExtender);
begin
  Setters.RemoveDataFromArray(Extdr);
  Extdr.Net:=nil;
end;
procedure TNet.AddPin(Extdr:TBaseSCHConnectExtender);
begin
  Pins.PushBackIfNotPresent(Extdr);
  Extdr.Net:=Self;
end;
procedure TNet.RemovePin(Extdr:TBaseSCHConnectExtender);
begin
  Pins.RemoveDataFromArray(Extdr);
  Extdr.Net:=nil;
end;
procedure TNet.AddInfo(Extdr:TBaseSCHConnectExtender);
begin
  Infos.PushBackIfNotPresent(Extdr);
  Extdr.Net:=Self;
end;
procedure TNet.RemoveInfo(Extdr:TBaseSCHConnectExtender);
 begin
  Infos.RemoveDataFromArray(Extdr);
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
  Extdr:TBaseSCHConnectExtender;
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
  p:TBaseSCHConnectExtender;
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

class procedure TNet.ConcatNets(Extdr1,Extdr2:TBaseSCHConnectExtender);
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

function AddConnectorExtenderToEntity(PEnt:PGDBObjEntity):TSCHConnectorExtender;
begin
  result:=TSCHConnectorExtender.Create(PEnt);
  PEnt^.AddExtension(result);
end;
procedure TSCHConnectorExtender.onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);
begin
end;
constructor TSCHConnectorExtender.Create;
begin
  inherited Create(pEntity);
  FState:=CSNormal;
  FConnectorRadius:=DefaultConnectorRadius;
  FConnectorType:=DefaultConnectorType;
end;
destructor TSCHConnectorExtender.Destroy;
begin
end;
procedure TSCHConnectorExtender.Assign(Source:TBaseExtender);
begin
  FConnectorRadius:=TSCHConnectorExtender(Source).FConnectorRadius;
  FConnectorType:=TSCHConnectorExtender(Source).FConnectorType;
end;


procedure TSCHConnectorExtender.onRemoveFromArray(pEntity:Pointer;const drawing:TDrawingDef);
begin
  AddToDWGPostProcs(pEntity,drawing);
end;

procedure TSCHConnectorExtender.onEntityClone(pSourceEntity,pDestEntity:pointer);
var
  NetConnectorExtender:TSCHConnectorExtender;
begin
  NetConnectorExtender:=PGDBObjEntity(pDestEntity)^.EntExtensions.GetExtensionOf<TSCHConnectorExtender>;
  if NetConnectorExtender=nil then
    NetConnectorExtender:=AddConnectorExtenderToEntity(pDestEntity);
  NetConnectorExtender.Assign(PGDBObjEntity(pSourceEntity)^.EntExtensions.GetExtensionOf<TSCHConnectorExtender>);
end;
procedure TSCHConnectorExtender.onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);
begin
end;

procedure TSCHConnectorExtender.AddToDWGPostProcs(pEntity:Pointer;const drawing:TDrawingDef);
//var
//  p:PGDBObjLine;
//  ir:itrec;
begin
  if Assigned(Net) then
    Net.AddToDWGPostProcs(pEntity,drawing);
end;

procedure TSCHConnectorExtender.onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  CNet:TNet;
begin
  if (pEntity<>nil)and(dc.Options*[DCODrawable]<>[]) then begin
    if not PGDBObjEntity(pEntity)^.CheckState([ESConstructProxy,ESTemp]) then begin
      if Assigned(net) then begin
        CNet:=Net;
        case FConnectorType of
          CTInfo:Net.RemoveInfo(Self);
          CTPin:Net.RemovePin(Self);
          CTSetter:Net.RemoveSetter(Self);
        end;
        CNet.AddToDWGPostProcs(pEntity,drawing);
        if CNet.IsEmpty then
          CNet.Destroy;
      end;

      AddToDWGPostProcs(pEntity,drawing);

      PGDBObjEntity(pEntity)^.addtoconnect2(pEntity,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
    end;
  end;
end;

procedure TSCHConnectorExtender.onEntityConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  Objects:GDBObjOpenArrayOfPV;
  p:PGDBObjEntity;
  ir:itrec;
  ConnectionExtender:TSCHConnectionExtender;
begin
  if FState=CSNormal then begin
    if pThisEntity<>nil then begin
      if not PGDBObjEntity(pThisEntity)^.CheckState([ESConstructProxy,ESTemp]) then begin
        objects.init(10);
        if PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.FindObjectsInVolume(PGDBObjEntity(pThisEntity)^.vp.BoundingBox,Objects)then begin
          p:=Objects.beginiterate(ir);
          if p<>nil then repeat
            if p<>pThisEntity then begin
              ConnectionExtender:=p^.GetExtension<TSCHConnectionExtender>;
              if ConnectionExtender<>nil then begin
                FState:=CSSecondTry;
                p^.addtoconnect2(p,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
                p^.addtoconnect2(p,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjCasheArray);
              end;
            end;
            p:=Objects.iterate(ir);
          until p=nil;
        end;
        objects.Clear;
        objects.done;
        if FState=CSSecondTry then begin
          FState:=CSNormal;
          //PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray.PushBackData(self.pThisEntity);
        end;
      end;
    end
  end else
    FState:=CSNormal;
end;
procedure TSCHConnectorExtender.onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;

procedure TSCHConnectorExtender.CopyExt2Ent(pSourceEntity,pDestEntity:pointer);
begin
  onEntityClone(pSourceEntity,pDestEntity);
end;
procedure TSCHConnectorExtender.ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);
begin
end;

procedure TSCHConnectorExtender.PostLoad(var context:TIODXFLoadContext);
begin
end;

class function TSCHConnectorExtender.getExtenderName:string;
begin
  result:=ConnectionExtenderName;
end;

class function TSCHConnectorExtender.EntIOLoadNetConnectorRadius(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  NetConnectorExtender:TSCHConnectorExtender;
begin
  NetConnectorExtender:=PGDBObjEntity(PEnt)^.GetExtension<TSCHConnectorExtender>;
  if NetConnectorExtender=nil then begin
    NetConnectorExtender:=AddConnectorExtenderToEntity(PEnt);
  end;
  NetConnectorExtender.FConnectorRadius:=StrToFloat(_Value);
  result:=true;
end;

function ConnectorType2String(ConnectorType:TConnectorType):string;
begin
  result:=CT2String[ConnectorType];
end;

function String2ConnectorType(ACTString:String):TConnectorType;
var
  i:TConnectorType;
begin
  for i in TConnectorType do
    if (ACTString=CT2String[i])or(ACTString=CT2UCString[i]) then
      exit(i);
  raise Exception.CreateFmt('Wrong ConnectorType name : ''%s''', [ACTString]);
end;


class function TSCHConnectorExtender.EntIOLoadNetConnectorSetter(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  NetConnectorExtender:TSCHConnectorExtender;
begin
  NetConnectorExtender:=PGDBObjEntity(PEnt)^.GetExtension<TSCHConnectorExtender>;
  if NetConnectorExtender=nil then begin
    NetConnectorExtender:=AddConnectorExtenderToEntity(PEnt);
  end;
  NetConnectorExtender.FConnectorType:=String2ConnectorType(_Value);
  result:=true;
end;


procedure TSCHConnectorExtender.SaveToDxfObjXData(var outStream:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFSaveContext);
begin
  dxfStringout(outStream,1000,'SCHConnectorRadius=',FloatToStr(FConnectorRadius));
  if FConnectorType<>DefaultConnectorType then
    case FConnectorType of
      CTInfo:dxfStringWithoutEncodeOut(outStream,1000,'SCHConnectorType=CTInfo');
      CTPin:dxfStringWithoutEncodeOut(outStream,1000,'SCHConnectorType=CTPin');
      CTSetter:dxfStringWithoutEncodeOut(outStream,1000,'SCHConnectorType=CTSetter');
  end;
end;

initialization
  //extdrAdd(extdrSCHConnector)
  EntityExtenders.RegisterKey(uppercase(ConnectionExtenderName),TSCHConnectorExtender);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('SCHConnectorRadius',TSCHConnectorExtender.EntIOLoadNetConnectorRadius);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('SCHConnectorType',TSCHConnectorExtender.EntIOLoadNetConnectorSetter);
finalization
end.
