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
unit uzcExtdrSCHConnection;
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzedrawingdef,uzeExtdrAbstractEntityExtender,
  UGDBOpenArrayOfPV,uzeentgenericsubentry,uzeentline,uzegeometry,
  uzeentdevice,uzctnrVectorBytesStream,
  uzbBaseUtils,uzeTypes,uzeentsubordinated,uzeentity,uzeblockdef,
  usimplegenerics,uzeffdxfsupport,
  gzctnrVectorTypes,uzeBaseExtender,uzgldrawcontext,
  uzegeometrytypes,uzcsysvars,
  uzctnrVectorDouble,gzctnrVector,garrayutils,
  uzcExtdrSCHConnector,uzcEnitiesVariablesExtender,
  Math;

const
  ConnectionExtenderName='extdrSCHConnection';

type
  TKnot=record
    t,HalfWidth:double;
    {todo: тип наверно стоит убрать, он такойжк как в TNetTypeData всегда}
    &Type:TKnotType;
    constructor Create(const AT,AHW:double;const AType:TKnotType);
  end;
  PKnot=^TKnot;

  TKnots=GZVector<TKnot>;

  TKnotLess=class
    class function c(a,b:TKnot):boolean;
  end;

  TKnotsUtils=TOrderingArrayUtils<TKnots,TKnot,TKnotLess>;

  PTConnectPoint=^TConnectPoint;

  TConnectPoint=record
    t:double;
    Count:integer;
    constructor Create(AT:double);
  end;
  TConnectPoints=GZVector<TConnectPoint>;

  TIntersectPointsLess=class
    class function c(a,b:double):boolean;
  end;

  TIntersectPointsUtil=TOrderingArrayUtils<TZctnrVectorDouble,double,TIntersectPointsLess>;

  TSCHConnectionExtender=class(TBaseSCHConnectExtender)
  private
    FConnectedWith,FIntersectedWith:TZctnrVectorPGDBaseEntityNoDbl;
    FConnections:TConnectPoints;
    FKnots:TKnots;
  public
    FNetType:TNetTypeHandle;

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
    procedure onEntityAfterConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);override;
    procedure CopyExt2Ent(pSourceEntity,pDestEntity:pointer);override;
    procedure ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);override;
    procedure PostLoad(var context:TIODXFLoadContext);override;

    procedure onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);override;
    class function EntIOLoadNetExtender(_Name,_Value:string;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;

    procedure SaveToDxfObjXData(var outStream:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFSaveContext);override;

    procedure TryConnectToEnts(const p1,p2:TzePoint3d;var Objects:GDBObjOpenArrayOfPV;constref ANetData:TNetTypeData;const drawing:TDrawingDef;var DC:TDrawContext);
    procedure TryConnectToDeviceConnectors(const p1,p2:TzePoint3d;var Device:GDBObjDevice;const drawing:TDrawingDef;var DC:TDrawContext);
    function NeedStandardDraw(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext):boolean;override;

  protected
    procedure AddToDWGPostProcs(pEntity:Pointer;const drawing:TDrawingDef);
  end;


function AddSCHConnectionExtenderToEntity(PEnt:PGDBObjEntity):TSCHConnectionExtender;

implementation

const
  cNetConnectionSegsCount=6;


constructor TKnot.Create(const AT,AHW:double;const AType:TKnotType);
begin
  t:=AT;
  HalfWidth:=AHW;
  &Type:=AType;
end;

class function TKnotLess.c(a,b:TKnot):boolean;
begin
  Result:=a.t<b.t;
end;

class function TIntersectPointsLess.c(a,b:double):boolean;
begin
  Result:=a<b;
end;

function IsConnectPointEqual(const a,b:TConnectPoint):boolean;
begin
  Result:=SameValue(a.t,b.t,bigeps);
end;

constructor TConnectPoint.Create(AT:double);
begin
  t:=AT;
  Count:=1;
end;

function AddSCHConnectionExtenderToEntity(PEnt:PGDBObjEntity):TSCHConnectionExtender;
begin
  Result:=TSCHConnectionExtender.Create(PEnt);
  PEnt^.AddExtension(Result);
end;

procedure TSCHConnectionExtender.onEntitySupportOldVersions(pEntity:pointer;const drawing:TDrawingDef);
begin
end;

constructor TSCHConnectionExtender.Create;
begin
  inherited;
  FNetType:=TNetTypeHandles.GetInitialHandleValue;
  FConnectedWith.init(10);
  FIntersectedWith.init(10);
  //Intersects.init(2);
  FConnections.init(3);
  //Setters.init(2);
  //Pins.init(2);
  FKnots.init(10);
  Net:=nil;
end;

destructor TSCHConnectionExtender.Destroy;
begin
  inherited;
  FConnectedWith.Destroy;
  FIntersectedWith.Destroy;
  //Intersects.destroy;
  FConnections.Destroy;
  //Setters.destroy;
  //Pins.destroy;
  FKnots.Destroy;
end;

procedure TSCHConnectionExtender.Assign(Source:TBaseExtender);
begin
  FNetType:=TSCHConnectionExtender(Source).FNetType;
end;

procedure TSCHConnectionExtender.AddToDWGPostProcs(pEntity:Pointer;const drawing:TDrawingDef);
var
  p:PGDBObjLine;
  ir:itrec;
begin
  if Assigned(Net) then
    Net.AddToDWGPostProcs(pEntity,drawing);

  {p:=FConnectedWith.beginiterate(ir);
  if p<>nil then
  repeat
    if p<>nil then
      PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray.PushBackIfNotPresent(p);
      PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjCasheArray.PushBackIfNotPresent(p);
  p:=FConnectedWith.iterate(ir);
  until p=nil;
  FConnectedWith.Clear;}

  p:=FIntersectedWith.beginiterate(ir);
  if p<>nil then
    repeat
      if p<>nil then
        PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray.PushBackIfNotPresent(p);
      PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjCasheArray.PushBackIfNotPresent(p);
      p:=FIntersectedWith.iterate(ir);
    until p=nil;
  FIntersectedWith.Clear;
end;

procedure TSCHConnectionExtender.onRemoveFromArray(pEntity:Pointer;const drawing:TDrawingDef);
begin
  AddToDWGPostProcs(pEntity,drawing);
end;

procedure TSCHConnectionExtender.onEntityClone(pSourceEntity,pDestEntity:pointer);
begin
end;

procedure TSCHConnectionExtender.onEntityBuildVarGeometry(pEntity:pointer;const drawing:TDrawingDef);
begin
end;

procedure TSCHConnectionExtender.onBeforeEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  CNet:TNet;
begin
  if pThisEntity<>nil then begin
    if not PGDBObjEntity(pThisEntity)^.CheckState([ESConstructProxy,ESTemp]) then
      // if not (ESConstructProxy in pThisEntity^.State) then
      if IsObjectIt(TypeOf(pThisEntity^),typeof(GDBObjLine)) then begin
        if Assigned(Net) then begin
          CNet:=Net;
          Net.RemoveConnection(Self);
          CNet.AddToDWGPostProcs(pEntity,drawing);
          if CNet.IsEmpty then
            CNet.Destroy;
        end;

        AddToDWGPostProcs(pThisEntity,drawing);

        pThisEntity^.addtoconnect2(pThisEntity,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
      end;
  end;
end;

procedure TSCHConnectionExtender.onEntityAfterConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  ppin:TBaseSCHConnectExtender;
  setter:TBaseSCHConnectExtender;
  ir,eir:itrec;
  SVExtdr,PVExtdr:TVariablesExtender;
  //ConnectorExtender:TSCHConnectorExtender;
begin
  if Assigned(Net) then begin
    setter:=Net.Setters.beginiterate(ir);
    if setter<>nil then
      repeat
        SVExtdr:=setter.pThisEntity^.GetExtension<TVariablesExtender>;

        ppin:=Net.Pins.beginiterate(eir);
        if ppin<>nil then
          repeat
            PVExtdr:=ppin.pThisEntity^.GetExtension<TVariablesExtender>;
            PVExtdr.addConnected(SVExtdr);
            //PVExtdr.EntityUnit.ConnectedUses.PushBackIfNotPresent(@SVExtdr.EntityUnit);
            ppin:=Net.Pins.iterate(eir);
          until ppin=nil;

        ppin:=Net.Infos.beginiterate(eir);
        if ppin<>nil then
          repeat
            PVExtdr:=ppin.pThisEntity^.GetExtension<TVariablesExtender>;
            PVExtdr.addConnected(SVExtdr);
            ppin:=Net.Infos.iterate(eir);
          until ppin=nil;


        setter:=Net.Setters.iterate(ir);
      until setter=nil;
  end;
end;

procedure TSCHConnectionExtender.onEntityConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  Objects:GDBObjOpenArrayOfPV;
begin
  FConnectedWith.Clear;
  FIntersectedWith.Clear;
  //Intersects.Clear;
  FConnections.Clear;
  //Setters.Clear;
  //Pins.Clear;
  FKnots.Clear;
  if pThisEntity<>nil then begin
    if not PGDBObjEntity(pThisEntity)^.CheckState([ESConstructProxy,ESTemp]) then
      //if not (ESConstructProxy in pThisEntity^.State) then
      if IsObjectIt(TypeOf(pThisEntity^),typeof(GDBObjLine)) then begin
        objects.init(10);
        if PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.FindObjectsInVolume(PGDBObjLine(pThisEntity)^.vp.BoundingBox,Objects) then
          TryConnectToEnts(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,Objects,GetNETDataByType(FNetType)^,drawing,dc);
        {if PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.FindObjectsInPoint(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,Objects) then
          TryConnectToEnts(Objects,LBegin,drawing,dc);
        objects.Clear;
        if PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.FindObjectsInPoint(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,Objects) then
          TryConnectToEnts(Objects,LEnd,drawing,dc);}
        objects.Clear;
        objects.done;
      end;
  end;
  if FKnots.Count>1 then
    TKnotsUtils.Sort(FKnots,FKnots.Count);
end;

procedure TSCHConnectionExtender.onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
end;

procedure TSCHConnectionExtender.CopyExt2Ent(pSourceEntity,pDestEntity:pointer);
begin
end;

procedure TSCHConnectionExtender.ReorganizeEnts(OldEnts2NewEntsMap:TMapPointerToPointer);
begin
end;

procedure TSCHConnectionExtender.PostLoad(var context:TIODXFLoadContext);
begin
end;

class function TSCHConnectionExtender.getExtenderName:string;
begin
  Result:=ConnectionExtenderName;
end;

class function TSCHConnectionExtender.EntIOLoadNetExtender(_Name,_Value:string;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;
var
  NetExtender:TSCHConnectionExtender;
begin
  NetExtender:=PGDBObjEntity(PEnt)^.GetExtension<TSCHConnectionExtender>;
  if NetExtender=nil then begin
    NetExtender:=AddSCHConnectionExtenderToEntity(PEnt);
  end;
  if _Name='SCHNetType'then
    NetExtender.FNetType:=GetTypeByNETName(_Value);
  Result:=True;
end;

procedure TSCHConnectionExtender.SaveToDxfObjXData(var outStream:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFSaveContext);
begin
  dxfStringWithoutEncodeOut(outStream,1000,'SCHConnection=');
  dxfStringout(outStream,1000,'SCHNetType=',GetNETNameByType(FNetType));
end;

procedure drawArrow(l1,l2:TzePoint3d;pThisEntity:PGDBObjEntity;var DC:TDrawContext);
var
  onel:TzeVector3d;
  p1,p2:TzePoint3d;
  tp2,tp3:TzeVector3d;
  m,rotmatr:TzeTypedMatrix4d;
begin
  onel:=l2-l1;
  if onel.SqrLength>sqreps then begin
    onel.Normalize;
    tp2:=GetXfFromZ(onel);
    tp3:=VectorDot(tp2,onel);
    tp3.Normalize;//:=NormalizeVertex(tp3);
    tp2.Normalize;//:=NormalizeVertex(tp2);
    //rotmatr:=cOneMatrix;
    //PzePoint3d(@rotmatr.mtr[0])^:=onel;
    //PzePoint3d(@rotmatr.mtr[1])^:=tp2;
    //PzePoint3d(@rotmatr.mtr[2])^:=tp3;
    rotmatr:=CreateMatrixFromBasis(onel,tp2,tp3);
    //m:=cOneMatrix;
    //PzePoint3d(@m.mtr[3])^:=l2;
    m:=CreateTranslationMatrix(l2.asVector);
    m:=MatrixMultiply(rotmatr,m);
    p1:=VectorTransform3D(TzePoint3d.Make(-3*SysVar.DSGN.DSGN_HelpScale^,0.5*SysVar.DSGN.DSGN_HelpScale^,0),m);
    p2:=VectorTransform3D(TzePoint3d.Make(-3*SysVar.DSGN.DSGN_HelpScale^,-0.5*SysVar.DSGN.DSGN_HelpScale^,0),m);
    pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p1,l2);
    pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p2,l2);
  end;
end;

procedure drawCross(const p1:TzePoint3d;pThisEntity:PGDBObjEntity;var DC:TDrawContext);
begin
  pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p1-cV3d__1__1__0,p1+cV3d__1__1__0);
  pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p1-cV3d_m1__1__0,p1+cV3d_m1__1__0);
end;

procedure drawCircle(const p0:TzePoint3d;r:double;pThisEntity:PGDBObjEntity;var DC:TDrawContext);
var
  v:TzeVector3d;
  p,mp:array[boolean]of TzePoint3d;
  i:integer;
begin
  if r>bigeps then begin
    p[false]:=p0+cV3d__1__0__0*r;
    mp[false]:=p[false];
    v.Z:=0;
    for i:=1 to cNetConnectionSegsCount-1 do begin
      SinCos(i*pi/cNetConnectionSegsCount,v.y,v.x);
      if odd(i) then begin
        p[true]:=p0+v*r;
      end else begin
        p[false]:=p0+v*r;
       end;
      pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p[false],p[true]);

      v.y:=-v.y;
      if odd(i) then begin
        mp[true]:=p0+v*r;
      end else begin
        mp[false]:=p0+v*r;
      end;
      pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,mp[false],mp[true]);

    end;
    if odd(cNetConnectionSegsCount) then begin
      p[true]:=p0+cV3d_m1__0__0*r;
      pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,mp[false],p[true]);
    end else begin
      p[false]:=p0+cV3d_m1__0__0*r;
      pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p[false],mp[true]);
    end;
    pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p[false],p[true]);
  end;
end;

procedure drawFilledCircle(const p0:TzePoint3d;r:double;pThisEntity:PGDBObjEntity;var DC:TDrawContext);
var
  v:TzeVector3d;
  p,mp:array[boolean]of TzePoint3d;
  i:integer;
begin
  if r>bigeps then begin
    p[false]:=p0+cV3d__1__0__0*r;
    mp[false]:=p[false];
    v.Z:=0;
    pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p0,p[false]);
    for i:=1 to cNetConnectionSegsCount-1 do begin
      SinCos(i*pi/cNetConnectionSegsCount,v.y,v.x);
      if odd(i) then begin
        p[true]:=p0+v*r;
        pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p0,p[true]);
      end else begin
        p[false]:=p0+v*r;
        pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p0,p[false]);
      end;
      pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p[false],p[true]);

      v.y:=-v.y;
      if odd(i) then begin
        mp[true]:=p0+v*r;
        pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p0,mp[true]);
      end else begin
        mp[false]:=p0+v*r;
        pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p0,mp[false]);
      end;
      pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,mp[false],mp[true]);

    end;
    if odd(cNetConnectionSegsCount) then begin
      p[true]:=p0+cV3d_m1__0__0*r;
      pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p0,p[true]);
      pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,mp[false],p[true]);
    end else begin
      p[false]:=p0+cV3d_m1__0__0*r;
      pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p0,p[false]);
      pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p[false],mp[true]);
    end;
    pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p[false],p[true]);
  end;
end;

procedure drawIntersectArc(l1,l2:TzePoint3d;pThisEntity:PGDBObjEntity;var DC:TDrawContext);
var
  v:TzeVector3d;
  p1,p2:TzePoint3d;
  onel,tp2,tp3:TzeVector3d;
  m,rotmatr:TzeTypedMatrix4d;
  l{,x,y,z}:double;
  sine,cosine:double;
  chg:boolean;
begin
  v:=l2-l1;
  chg:=False;
  if abs(v.x)<bigeps then begin
    if v.y<0 then
      chg:=True;
  end else begin
    if v.x<bigeps then
      chg:=True;
  end;
  if chg then begin
    v:=-v;
    p1:=l2;
    l2:=L1+v;
    l1:=p1+v;
  end;
  l:=v.Length;
  if l>bigeps then begin
    onel:=v;
    tp2:=GetXfFromZ(onel);
    tp3:=VectorDot(tp2,onel);
    tp3.Normalize;//:=NormalizeVertex(tp3);
    tp2.Normalize;//:=NormalizeVertex(tp2);
    //rotmatr:=cOneMatrix;
    //PzePoint3d(@rotmatr.mtr[0])^:=onel;
    //PzePoint3d(@rotmatr.mtr[1])^:=tp2*l;
    //PzePoint3d(@rotmatr.mtr[2])^:=tp3*l;
    rotmatr:=CreateMatrixFromBasis(onel,tp2*l,tp3*l);
    m:=cOneMatrix;
    m.mtr.v[3].Slice:=l1.asVector;
    m:=MatrixMultiply(rotmatr,m);

    p1:=VectorTransform3D(TzePoint3d.Make(-1,0,0),m);
    SinCos(5*pi/6,sine,cosine);
    p2:=VectorTransform3D(TzePoint3d.Make(cosine,sine,0),m);
    pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p1,p2);
    SinCos(4*pi/6,sine,cosine);
    p1:=VectorTransform3D(TzePoint3d.Make(cosine,sine,0),m);
    pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p2,p1);
    SinCos(3*pi/6,sine,cosine);
    p2:=VectorTransform3D(TzePoint3d.Make(cosine,sine,0),m);
    pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p1,p2);

    SinCos(2*pi/6,sine,cosine);
    p1:=VectorTransform3D(TzePoint3d.Make(cosine,sine,0),m);
    pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p2,p1);
    SinCos(1*pi/6,sine,cosine);
    p2:=VectorTransform3D(TzePoint3d.Make(cosine,sine,0),m);
    pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p1,p2);

    pThisEntity^.Representation.CreateWCSLineWithoutLT(DC,pThisEntity^,p2,l2);
  end;
end;

procedure TSCHConnectionExtender.TryConnectToEnts(const p1,p2:TzePoint3d;var Objects:GDBObjOpenArrayOfPV;constref ANetData:TNetTypeData;const drawing:TDrawingDef;var DC:TDrawContext);
var
  p:PGDBObjLine;
  ir:itrec;
  NetExtender:TSCHConnectionExtender;
  ConnectorExtender:TSCHConnectorExtender;
  ip:Intercept3DProp;
  PTI:Pointer;
  dist:TDistWitht;
  knot:TKnot;

  procedure addToConnections(t:double);
  var
    ci:integer;
    cp:TConnectPoint;
    pcp:PTConnectPoint;
    //aknot:TKnot;
  begin
    cp:=TConnectPoint.Create(t);
    ci:=FConnections.IsDataExistWithCompareProc(cp,IsConnectPointEqual);
    if ci=-1 then
      FConnections.PushBackData(cp)
    else begin
      pcp:=FConnections.getDataMutable(ci);
      Inc(pcp^.Count);
      {if pcp^.count=3 then begin
        aknot.Create(dist.t,abs(ConnectorExtender.FConnectorRadius)/2,KTNormal);
        FKnots.PushBackData(aknot);
      end;}
    end;
  end;

begin
  p:=Objects.beginiterate(ir);
  if p<>nil then
    repeat
      if pointer(p)<>pThisEntity then begin
        PTI:=TypeOf(p^);
        if IsObjectIt(PTI,typeof(GDBObjLine)) then begin
          NetExtender:=p^.GetExtension<TSCHConnectionExtender>;
          if NetExtender<>nil then begin
            if NetExtender.FNetType=FNetType then begin
            ip:=uzegeometry.intercept3d(p1,p2,p^.CoordInWCS.lBegin,p^.CoordInWCS.lEnd);
              if ip.isintercept then begin
                if SameValue(ip.t1,0,bigeps) then begin
                  addToConnections(0);
                  //drawArrow(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,pThisEntity,DC);
                  p^.addtoconnect2(p,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
                  p^.addtoconnect2(p,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjCasheArray);
                  FConnectedWith.PushBackIfNotPresent(p);
                  TNet.ConcatNets(self,NetExtender);
                end else if SameValue(ip.t1,1,bigeps) then begin
                  addToConnections(1);
                  //drawArrow(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,pThisEntity,DC);
                  p^.addtoconnect2(p,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
                  p^.addtoconnect2(p,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjCasheArray);
                  FConnectedWith.PushBackIfNotPresent(p);
                  TNet.ConcatNets(self,NetExtender);
                end else if (SameValue(ip.t2,0,bigeps))or({IsDoubleEqual}SameValue(ip.t2,1,bigeps)) then begin
                  addToConnections(ip.t1);
                  //drawCross(ip.interceptcoord,pThisEntity,DC);
                  p^.addtoconnect2(p,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
                  p^.addtoconnect2(p,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjCasheArray);
                  FConnectedWith.PushBackIfNotPresent(p);
                  TNet.ConcatNets(self,NetExtender);
                end else begin
                  if p1.SqrLengthTo(p2)>p^.CoordInWCS.lBegin.SqrLengthTo(p^.CoordInWCS.lEnd) then
                    FKnots.PushBackData(TKnot.Create(ip.t1,ANetData.IntersectRadius,{KTArc}ANetData.IntersectType));
                  FIntersectedWith.PushBackIfNotPresent(p);
                  p^.addtoconnect2(p,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
                  p^.addtoconnect2(p,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjCasheArray);
                end;
              end;
            end;
          end;
        end else if IsObjectIt(PTI,typeof(GDBObjDevice)) then begin
          ConnectorExtender:=p^.GetExtension<TSCHConnectorExtender>;
          if ConnectorExtender=nil then
            TryConnectToDeviceConnectors(p1,p2,PGDBObjDevice(p)^,drawing,DC)
          else if ConnectorExtender.FNetType=FNetType then begin
            dist:=distance2ray(PGDBObjDevice(p).P_insert_in_WCS,p1,p2);
            if (abs(dist.d)<bigeps)and((dist.t>-bigeps)and((dist.t<1+bigeps))) then begin
              knot.Create(dist.t,abs(ConnectorExtender.FConnectorRadius){/2},KTNormal);
              if ConnectorExtender.FConnectorRadius<>0 then
                knot.&Type:=KTEmpty;
              FKnots.PushBackData(knot);
              if not Assigned(Net) then begin
                Net:=TNet.Create;
                Net.AddConnection(Self);
              end;
              case ConnectorExtender.FConnectorType of
                CTInfo:begin
                  Net.AddInfo(ConnectorExtender);
                  PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray.PushBackIfNotPresent(p);
                  PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjCasheArray.PushBackIfNotPresent(p);
                end;
                CTPin:begin
                  Net.AddPin(ConnectorExtender);
                  PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray.PushBackIfNotPresent(p);
                  PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjCasheArray.PushBackIfNotPresent(p);
                end;
                CTSetter:Net.AddSetter(ConnectorExtender);
              end;
            end;
          end;
        end;
      end;
      p:=Objects.iterate(ir);
    until p=nil;
end;

procedure TSCHConnectionExtender.TryConnectToDeviceConnectors(const p1,p2:TzePoint3d;var Device:GDBObjDevice;const drawing:TDrawingDef;var DC:TDrawContext);
var
  p:PGDBObjDevice;
  ir:itrec;
  ConnectorExtender:TSCHConnectorExtender;
  knot:TKnot;
  t:double;
  isConnected:boolean;
begin
  p:=Device.VarObjArray.beginiterate(ir);
  if p<>nil then
    repeat

      if IsObjectIt(TypeOf(p^),typeof(GDBObjDevice)) then begin
        ConnectorExtender:=p^.GetExtension<TSCHConnectorExtender>;
        if ConnectorExtender=nil then
          TryConnectToDeviceConnectors(p1,p2,PGDBObjDevice(p)^,drawing,DC)
        else if ConnectorExtender.FNetType=FNetType then begin
          isConnected:=True;
          if p1.IsEqual(p^.P_insert_in_WCS) then
            t:=0
          else if p2.IsEqual(p^.P_insert_in_WCS) then
            t:=1
          else
            isConnected:=False;
          if isConnected then begin
            knot.Create(t,abs(ConnectorExtender.FConnectorRadius){/2},KTNormal);
            if ConnectorExtender.FConnectorRadius<>0 then
              knot.&Type:=KTEmpty;
            FKnots.PushBackData(knot);
            if not Assigned(Net) then begin
              Net:=TNet.Create;
              Net.AddConnection(Self);
            end;
            case ConnectorExtender.FConnectorType of
              CTInfo:begin
                Net.AddInfo(ConnectorExtender);
                PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray.PushBackIfNotPresent(p);
                PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjCasheArray.PushBackIfNotPresent(p);
              end;
              CTPin:begin
                Net.AddPin(ConnectorExtender);
                PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray.PushBackIfNotPresent(p);
                PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjCasheArray.PushBackIfNotPresent(p);
              end;
              CTSetter:Net.AddSetter(ConnectorExtender);
            end;

          end;
        end;
      end;
      p:=Device.VarObjArray.iterate(ir);
    until p=nil;
end;

function TSCHConnectionExtender.NeedStandardDraw(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext):boolean;
var
  i:integer;
  pc:TConnectPoints.PT;
  pnd:TNetTypeHandles.PGLincedData;
  linelen,l:double;
  knot:TKnot;
  oldP,P:TzePoint3d;
begin
  pThisEntity^.Representation.geometry.lock;
  try
    pnd:=GetNETDataByType(FNetType);
    Result:=True;
    for i:=0 to FConnections.Count-1 do begin
      pc:=FConnections.getDataMutable(i);
      if SysVar.DISP.DISP_SystmGeometryDraw^ then begin
        if pc^.t=0 then
          drawArrow(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,pThisEntity,DC)
        else if pc^.t=1 then
          drawArrow(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,pThisEntity,DC)
        else
          drawCross(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin.LerpTo(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,pc^.t),pThisEntity,DC);
      end;
      if (pc^.Count>1)or((pc^.t>bigeps)and(pc^.t<(1-bigeps))) then begin
        case pnd^.TConnectType of
          KTFilledCircle:drawFilledCircle(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin.LerpTo(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,pc^.t),pnd^.ConnectRadius,pThisEntity,DC);
          KTCircle:drawCircle(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin.LerpTo(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,pc^.t),pnd^.ConnectRadius,pThisEntity,DC);
        end;
      end else begin
        case pnd^.LConnectType of
          KTFilledCircle:drawFilledCircle(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin.LerpTo(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,pc^.t),pnd^.ConnectRadius,pThisEntity,DC);
          KTCircle:drawCircle(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin.LerpTo(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,pc^.t),pnd^.ConnectRadius,pThisEntity,DC);
        end;
      end;
    end;
    oldP:=PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin;
    if FKnots.Count>0 then begin
      linelen:=PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin.LengthTo(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd);
      for i:=0 to FKnots.Count-1 do begin
        knot:=FKnots.getData(i);
        l:=knot.HalfWidth/linelen;
        case knot.&Type of
          KTArc:begin
            P:=PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin.LerpTo(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,knot.t-l);
            pThisEntity^.Representation.CreateLine(DC,pThisEntity^,pThisEntity.vp,cOneMatrix,oldP,P);
            oldP:=PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin.LerpTo(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,knot.t+l);
            P:=PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin.LerpTo(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,knot.t);
            drawIntersectArc(P,oldP,pThisEntity,DC);
          end;
          KTEmpty:begin
            if knot.t>bigeps then begin
              P:=PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin.LerpTo(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,knot.t-l);
              pThisEntity^.Representation.CreateLine(DC,pThisEntity^,pThisEntity.vp,cOneMatrix,oldP,P);
            end;
            oldP:=PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin.LerpTo(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,knot.t+l);
          end;
          KTNormal:begin
            if knot.t>bigeps then begin
              P:=PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin.LerpTo(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,knot.t);
              pThisEntity^.Representation.CreateLine(DC,pThisEntity^,pThisEntity.vp,cOneMatrix,oldP,P);
            end else
              P:=PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin.LerpTo(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,knot.t);
            oldP:=p;
          end;
          //это пока не реализовано, или хз
          //KTCircle:
          //KTFilledCircle:
        end;
      end;
      if not SameValue(knot.t,1,bigeps) then
        pThisEntity^.Representation.CreateLine(DC,pThisEntity^,pThisEntity.vp,cOneMatrix,oldP,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd);
      Result:=False;
    end;
  finally
    pThisEntity^.Representation.geometry.UnLock;
  end;
end;

initialization
  //extdrAdd(extdrSCHConnection)
  EntityExtenders.RegisterKey(uppercase(ConnectionExtenderName),TSCHConnectionExtender);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('SCHConnection',TSCHConnectionExtender.EntIOLoadNetExtender);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('SCHNetType',TSCHConnectionExtender.EntIOLoadNetExtender);

finalization
end.
