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
     uzegeometrytypes,uzcsysvars;
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
    class function getExtenderName:string;override;
    constructor Create(pEntity:Pointer);override;
    destructor Destroy;override;

    procedure Assign(Source:TBaseExtender);override;

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
procedure TNetExtender.onEntityConnect(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
var
  Objects:GDBObjOpenArrayOfPV;
begin
  if pThisEntity<>nil then begin
    if not (ESConstructProxy in pThisEntity^.State) then
      if pThisEntity^.GetObjType=GDBLineID then begin
        //pThisEntity^.Representation.DrawLineWithLT(DC,PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin+_XY_zVertex,PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin-_XY_zVertex,pThisEntity.vp);
        //pThisEntity^.Representation.DrawLineWithLT(DC,PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin+_MinusXY_zVertex,PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin-_MinusXY_zVertex,pThisEntity.vp);
        //pThisEntity^.Representation.DrawLineWithLT(DC,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd+x_Y_zVertex,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd-x_Y_zVertex,pThisEntity.vp);
        //pThisEntity^.Representation.DrawLineWithLT(DC,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd+_X_yzVertex,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd-_X_yzVertex,pThisEntity.vp);
        objects.init(10);
        if PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.FindObjectsInPoint(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,Objects) then
          TryConnectToEnts(Objects,LBegin,drawing,dc);
        objects.Clear;
        if PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.FindObjectsInPoint(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,Objects) then
          TryConnectToEnts(Objects,LEnd,drawing,dc);
        objects.Clear;
        objects.done;
      end;
  end;
end;
procedure TNetExtender.onAfterEntityFormat(pEntity:Pointer;const drawing:TDrawingDef;var DC:TDrawContext);
begin
  if pThisEntity<>nil then begin
    if not (ESConstructProxy in pThisEntity^.State) then
      if pThisEntity^.GetObjType=GDBLineID then begin
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

procedure TNetExtender.TryConnectToEnts(var Objects:GDBObjOpenArrayOfPV;Position:TLineEnd;const drawing:TDrawingDef;var DC:TDrawContext);
var
  p:PGDBObjLine;
  ir:itrec;
  NetExtender:TNetExtender;
begin
  p:=Objects.beginiterate(ir);
  if p<>nil then
  repeat
    if (pointer(p)<>pThisEntity)and(p^.GetObjType=GDBLineID) then begin
      NetExtender:=p^.GetExtension<TNetExtender>;
      if NetExtender<>nil then begin
        case Position of
          LBegin:begin
            if uzegeometry.IsPointEqual(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,p^.CoordInWCS.lBegin) then begin
              drawArrow(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,pThisEntity,DC);
              p^.addtoconnect2(p,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
              //pThisEntity^.Representation.DrawLineWithLT(DC,PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin+_XY_zVertex,PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin-_XY_zVertex,pThisEntity.vp);
              //pThisEntity^.Representation.DrawLineWithLT(DC,PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin+_MinusXY_zVertex,PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin-_MinusXY_zVertex,pThisEntity.vp);
            end;
            if uzegeometry.IsPointEqual(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,p^.CoordInWCS.lEnd) then begin
              drawArrow(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,pThisEntity,DC);
              p^.addtoconnect2(p,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
              //pThisEntity^.Representation.DrawLineWithLT(DC,PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin+_XY_zVertex,PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin-_XY_zVertex,pThisEntity.vp);
              //pThisEntity^.Representation.DrawLineWithLT(DC,PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin+_MinusXY_zVertex,PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin-_MinusXY_zVertex,pThisEntity.vp);
            end;
          end;
          LEnd:begin
            if uzegeometry.IsPointEqual(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,p^.CoordInWCS.lBegin) then begin
              drawArrow(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,pThisEntity,DC);
              p^.addtoconnect2(p,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
              //pThisEntity^.Representation.DrawLineWithLT(DC,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd+x_Y_zVertex,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd-x_Y_zVertex,pThisEntity.vp);
              //pThisEntity^.Representation.DrawLineWithLT(DC,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd+_X_yzVertex,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd-_X_yzVertex,pThisEntity.vp);
            end;
            if uzegeometry.IsPointEqual(PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,p^.CoordInWCS.lEnd) then begin
              drawArrow(PGDBObjLine(pThisEntity)^.CoordInWCS.lBegin,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd,pThisEntity,DC);
              p^.addtoconnect2(p,PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.ObjToConnectedArray);
              //pThisEntity^.Representation.DrawLineWithLT(DC,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd+x_Y_zVertex,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd-x_Y_zVertex,pThisEntity.vp);
              //pThisEntity^.Representation.DrawLineWithLT(DC,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd+_X_yzVertex,PGDBObjLine(pThisEntity)^.CoordInWCS.lEnd-_X_yzVertex,pThisEntity.vp);
            end;
          end;
        end;
      end;
    end;
  p:=Objects.iterate(ir);
  until p=nil;
end;

initialization
  //extdrAdd(extdrNet)
  EntityExtenders.RegisterKey(uppercase(NetExtenderName),TNetExtender);
  GDBObjEntity.GetDXFIOFeatures.RegisterNamedLoadFeature('NETEXTENDER',TNetExtender.EntIOLoadNetExtender);
finalization
end.

