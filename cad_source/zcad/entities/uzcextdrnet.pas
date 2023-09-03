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
     gzctnrVectorTypes,uzeBaseExtender,uzeconsts,uzgldrawcontext,
     uzegeometrytypes,uzcsysvars,uzctnrVectorDouble;
const
  NetExtenderName='extdrNet';
type
TLineEnd=(LBegin,LEnd);
TNet=class
    Entities:GDBObjOpenArrayOfPV;
    constructor Create;
    destructor Destroy;override;
end;

TNetExtender=class(TBaseEntityExtender)
    pThisEntity:PGDBObjEntity;
    Connected:GDBObjOpenArrayOfPV;
    Intersects:TZctnrVectorDouble;
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


    class function EntIOLoadNetExtender(_Name,_Value:String;ptu:PExtensionData;const drawing:TDrawingDef;PEnt:pointer):boolean;

    procedure SaveToDxfObjXData(var outhandle:TZctnrVectorBytes;PEnt:Pointer;var IODXFContext:TIODXFContext);override;

    procedure TryConnectToEnts(var Objects:GDBObjOpenArrayOfPV;Position:TLineEnd;const drawing:TDrawingDef;var DC:TDrawContext);
    procedure TryConnectToEnts2(const p1,p2:GDBVertex;var Objects:GDBObjOpenArrayOfPV;const drawing:TDrawingDef;var DC:TDrawContext);
    function NeedStandardDraw(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext):Boolean;override;

    protected
      procedure AddToDWGPostProcs(pEntity:Pointer;const drawing:TDrawingDef);
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
  Connected.init(10);
  Intersects.init(2);
end;
destructor TNetExtender.Destroy;
begin
  Connected.destroy;
  Intersects.destroy;
end;
procedure TNetExtender.Assign(Source:TBaseExtender);
begin
end;

procedure TNetExtender.AddToDWGPostProcs(pEntity:Pointer;const drawing:TDrawingDef);
var
  p:PGDBObjLine;
  ir:itrec;
begin
  p:=Connected.beginiterate(ir);
  if p<>nil then
  repeat
    if p<>nil then
      PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray.PushBackIfNotPresent(p);
      PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjCasheArray.PushBackIfNotPresent(p);
  p:=Connected.iterate(ir);
  until p=nil;
  Connected.Clear;
end;

procedure TNetExtender.onRemoveFromArray(pEntity:Pointer;const drawing:TDrawingDef);
begin
  AddToDWGPostProcs(pEntity,drawing);
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
procedure TNetExtender.onEntityConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  Objects:GDBObjOpenArrayOfPV;
begin
  Connected.Clear;
  Intersects.Clear;
  if pThisEntity<>nil then begin
    if not (ESConstructProxy in pThisEntity^.State) then
      if IsIt(TypeOf(pThisEntity^),typeof(GDBObjLine)) then begin
        objects.init(10);
        if PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.FindObjectsInVolume(PGDBObjLine(pThisEntity)^.vp.BoundingBox,Objects)then
          TryConnectToEnts2(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,Objects,drawing,dc);
        {if PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.FindObjectsInPoint(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,Objects) then
          TryConnectToEnts(Objects,LBegin,drawing,dc);
        objects.Clear;
        if PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.FindObjectsInPoint(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,Objects) then
          TryConnectToEnts(Objects,LEnd,drawing,dc);}
        objects.Clear;
        objects.done;
      end;
  end;
end;
procedure TNetExtender.onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
  if pThisEntity<>nil then begin
    if not (ESConstructProxy in pThisEntity^.State) then
      if IsIt(TypeOf(pThisEntity^),typeof(GDBObjLine)) then begin

        AddToDWGPostProcs(pThisEntity,drawing);

        pThisEntity^.addtoconnect2(pThisEntity,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
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

procedure drawArrow(l1,l2:GDBVertex;pThisEntity:PGDBObjEntity;var DC:TDrawContext);
var
  onel,p1,p2:GDBVertex;
  tp2,tp3:GDBVertex;
  m,rotmatr:DMatrix4D;
begin

  onel:=l2-l1;
  if SysVar.DWG.DWG_HelpGeometryDraw^ then
    if onel.SqrLength>sqreps then begin
      onel:=onel.NormalizeVertex;
      tp2:=GetXfFromZ(onel);
      tp3:=CrossVertex(tp2,onel);
      tp3:=NormalizeVertex(tp3);
      tp2:=NormalizeVertex(tp2);
      rotmatr:=onematrix;
      PGDBVertex(@rotmatr[0])^:=onel;
      PGDBVertex(@rotmatr[1])^:=tp2;
      PGDBVertex(@rotmatr[2])^:=tp3;
      m:=onematrix;
      PGDBVertex(@m[3])^:=l2;
      m:=MatrixMultiply(rotmatr,m);
      p1:=VectorTransform3D(uzegeometry.CreateVertex(-3*SysVar.DSGN.DSGN_HelpScale^,0.5*SysVar.DSGN.DSGN_HelpScale^,0),m);
      p2:=VectorTransform3D(uzegeometry.CreateVertex(-3*SysVar.DSGN.DSGN_HelpScale^,-0.5*SysVar.DSGN.DSGN_HelpScale^,0),m);
      pThisEntity^.Representation.DrawLineWithLT(DC,p1,l2,pThisEntity.vp);
      pThisEntity^.Representation.DrawLineWithLT(DC,p2,l2,pThisEntity.vp);
    end;
end;
procedure drawCross(p1:GDBVertex;pThisEntity:PGDBObjEntity;var DC:TDrawContext);
begin
  if SysVar.DWG.DWG_HelpGeometryDraw^ then begin
    pThisEntity^.Representation.DrawLineWithLT(DC,p1-_XY_zVertex,p1+_XY_zVertex,pThisEntity.vp);
    pThisEntity^.Representation.DrawLineWithLT(DC,p1-_MinusXY_zVertex,p1+_MinusXY_zVertex,pThisEntity.vp);
  end;
end;


procedure TNetExtender.TryConnectToEnts(var Objects:GDBObjOpenArrayOfPV;Position:TLineEnd;const drawing:TDrawingDef;var DC:TDrawContext);
var
  p:PGDBObjLine;
  ir:itrec;
  NetExtender:TNetExtender;
begin
  p:=Objects.beginiterate(ir);
  if p<>nil then
  repeat
    if (pointer(p)<>pThisEntity)and(IsIt(TypeOf(p^),typeof(GDBObjLine))) then begin
      NetExtender:=p^.GetExtension<TNetExtender>;
      if NetExtender<>nil then begin
        case Position of
          LBegin:begin
            if uzegeometry.IsPointEqual(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,p^.CoordInWCS.lBegin) then begin
              drawArrow(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,pThisEntity,DC);
              p^.addtoconnect2(p,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
              Connected.PushBackIfNotPresent(p);
            end;
            if uzegeometry.IsPointEqual(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,p^.CoordInWCS.lEnd) then begin
              drawArrow(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,pThisEntity,DC);
              p^.addtoconnect2(p,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
              Connected.PushBackIfNotPresent(p);
            end;
          end;
          LEnd:begin
            if uzegeometry.IsPointEqual(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,p^.CoordInWCS.lBegin) then begin
              drawArrow(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,pThisEntity,DC);
              p^.addtoconnect2(p,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
              Connected.PushBackIfNotPresent(p);
            end;
            if uzegeometry.IsPointEqual(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,p^.CoordInWCS.lEnd) then begin
              drawArrow(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,pThisEntity,DC);
              p^.addtoconnect2(p,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
              Connected.PushBackIfNotPresent(p);
            end;
          end;
        end;
      end;
    end;
  p:=Objects.iterate(ir);
  until p=nil;
end;

procedure TNetExtender.TryConnectToEnts2(const p1,p2:GDBVertex;var Objects:GDBObjOpenArrayOfPV;const drawing:TDrawingDef;var DC:TDrawContext);
var
  p:PGDBObjLine;
  ir:itrec;
  NetExtender:TNetExtender;
  ip:Intercept3DProp;
begin
  p:=Objects.beginiterate(ir);
  if p<>nil then
  repeat
    if (pointer(p)<>pThisEntity)and(IsIt(TypeOf(p^),typeof(GDBObjLine))) then begin
      NetExtender:=p^.GetExtension<TNetExtender>;
      if NetExtender<>nil then begin
        ip:=uzegeometry.intercept3d(p1,p2,p^.CoordInWCS.lBegin,p^.CoordInWCS.lEnd);
        if ip.isintercept then begin
          if uzegeometry.IsDoubleEqual(ip.t1,0,bigeps)then begin
            drawArrow(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,pThisEntity,DC);
            p^.addtoconnect2(p,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
            Connected.PushBackIfNotPresent(p);
          end else if uzegeometry.IsDoubleEqual(ip.t1,1,bigeps)then begin
            drawArrow(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,pThisEntity,DC);
            p^.addtoconnect2(p,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
            Connected.PushBackIfNotPresent(p);
          end else if (uzegeometry.IsDoubleEqual(ip.t2,0,bigeps))or(uzegeometry.IsDoubleEqual(ip.t2,1,bigeps))then begin
            drawCross(ip.interceptcoord,pThisEntity,DC);
            p^.addtoconnect2(p,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
            Connected.PushBackIfNotPresent(p);
          end else
            Intersects.PushBackData(ip.t1);
        end;
      end;
    end;
  p:=Objects.iterate(ir);
  until p=nil;
end;

function TNetExtender.NeedStandardDraw(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext):Boolean;
begin
  if Intersects.Count>0 then begin
    result:=false;
  end else
    result:=true;
end;

initialization
  //extdrAdd(extdrNet)
  EntityExtenders.RegisterKey(uppercase(NetExtenderName),TNetExtender);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('NETEXTENDER',TNetExtender.EntIOLoadNetExtender);
finalization
end.

