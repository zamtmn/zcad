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

unit uzeenrepresentation;
{$INCLUDE zengineconfig.inc}
interface
uses uzgldrawcontext,uzgldrawerabstract,uzglvectorobject,
     sysutils,
     uzegeometrytypes,uzegeometry,uzglgeometry,uzefont,uzeentitiesprop,UGDBPoint3DArray,
     uzeentsubordinated,
     uzegeomentitiestree,uzbtypes,
     gzctnrVectorTypes,uzgeomline3d,uzgeomproxy;
type
PTZEntityRepresentation=^TZEntityRepresentation;
TZEntityRepresentation= object(GDBaseObject)
                       {-}//private{//}
                       Graphix:ZGLGraphix;
                       Geometry:TGeomEntTreeNode;
                       {-}public{//}
                       constructor init();
                       destructor done;virtual;

                       function CalcTrueInFrustum(const frustum:ClipArray; FullCheck:boolean):TInBoundingVolume;
                       procedure DrawGeometry(var rc:TDrawContext;const aabb:TBoundingBox;const inFrustumState:TInBoundingVolume);virtual;
                       procedure Clear;virtual;
                       procedure Shrink;virtual;

                       function GetGraphix:PZGLGraphix;

                       {Команды которыми примитив рисует сам себя}
                       procedure DrawTextContent(drawer:TZGLAbstractDrawer;content:TDXFEntsInternalStringType;_pfont: PGDBfont;const DrawMatrix,objmatrix:DMatrix4D;const textprop_size:Double;var Outbound:OutBound4V);
                       procedure DrawLineWithLT(var Entity:GDBObjDrawable;var ObjMatrix:DMatrix4D; var rc:TDrawContext;const StartPointOCS,EndPointOCS:GDBVertex; const vp:GDBObjVisualProp;OnlyOne:Boolean=False);
                       procedure DrawLineByConstRefLinePropWithLT(var Entity:GDBObjDrawable;var ObjMatrix:DMatrix4D; var rc:TDrawContext;constref LP:GDBLineProp; const vp:GDBObjVisualProp;OnlyOne:Boolean=False);
                       procedure DrawLineWithoutLT(var rc:TDrawContext;const startpoint,endpoint:GDBVertex);
                       procedure DrawPolyLineWithLT(var rc:TDrawContext;const points:GDBPoint3dArray; const vp:GDBObjVisualProp; const closed,ltgen:Boolean);virtual;
                       procedure DrawPoint(var rc:TDrawContext;const point:GDBVertex; const vp:GDBObjVisualProp);
                       procedure StartSurface;
                       procedure EndSurface;
                       end;
implementation
function TZEntityRepresentation.GetGraphix:PZGLGraphix;
begin
  result:=@Graphix;
end;
constructor TZEntityRepresentation.init;
begin
  inherited;
  Graphix.init();
  Geometry.initnul;
end;
destructor TZEntityRepresentation.done;
begin
  Graphix.done;
  Geometry.done;
  inherited;
end;
function SqrCanSimplyDrawInWCS(const DC:TDrawContext;const ParamSize,TargetSize:Double):Boolean;
var
   templod:Double;
begin
     if dc.maxdetail then
                         exit(true);
  templod:=(ParamSize)/(dc.DrawingContext.zoom*dc.DrawingContext.zoom);
  if templod>TargetSize then
                            exit(true)
                        else
                            exit(false);
end;

procedure TZEntityRepresentation.DrawGeometry(var rc:TDrawContext;const aabb:TBoundingBox;const inFrustumState:TInBoundingVolume);
var
  v:gdbvertex;
  simplydraw:Boolean;
begin
  if rc.lod=LODCalculatedDetail then begin
    v:=uzegeometry.VertexSub(aabb.RTF,aabb.LBN);
    simplydraw:=not SqrCanSimplyDrawInWCS(rc,uzegeometry.SqrOneVertexlength(v),49);
  end else
    simplydraw:=rc.lod=LODLowDetail;
  Graphix.DrawGeometry(rc,inFrustumState,simplydraw);
end;
function TZEntityRepresentation.CalcTrueInFrustum(const frustum:ClipArray; FullCheck:boolean):TInBoundingVolume;
begin
  result:=Graphix.CalcTrueInFrustum(frustum,FullCheck);
end;
procedure TZEntityRepresentation.Clear;
begin
  Graphix.Clear;
  Geometry.ClearSub;
end;
procedure TZEntityRepresentation.Shrink;
begin
  Graphix.Shrink;
  Geometry.Shrink;
end;
procedure TZEntityRepresentation.DrawTextContent(drawer:TZGLAbstractDrawer;content:TDXFEntsInternalStringType;_pfont: PGDBfont;const DrawMatrix,objmatrix:DMatrix4D;const textprop_size:Double;var Outbound:OutBound4V);
begin
  Graphix.DrawTextContent(drawer,content,_pfont,DrawMatrix,objmatrix,textprop_size,Outbound);
end;
procedure TZEntityRepresentation.DrawLineWithLT(var Entity:GDBObjDrawable;var ObjMatrix:DMatrix4D;var rc:TDrawContext;const StartPointOCS,EndPointOCS:GDBVertex; const vp:GDBObjVisualProp;OnlyOne:Boolean=False);
var
  gl:TGeomLine3D;
  gp:TGeomProxy;
  dr:TLLDrawResult;
  StartPointWCS,EndPointWCS:GDBVertex;
begin
  StartPointWCS:=VectorTransform3D(StartPointOCS,ObjMatrix);
  EndPointWCS:=VectorTransform3D(EndPointOCS,ObjMatrix);
  dr:=Graphix.DrawLineWithLT(rc,StartPointWCS,EndPointWCS,vp);
  Geometry.Lock;
  if dr.Appearance<>TAMatching then
  begin
    gp.init(dr.LLPStart,dr.LLPEndi-1,dr.BB);
    Geometry.AddObjectToNodeTree(gp);
  end;
  gl.init(StartPointWCS,EndPointWCS,0);
  Geometry.AddObjectToNodeTree(gl);
  Geometry.UnLock;
end;
procedure TZEntityRepresentation.DrawLineByConstRefLinePropWithLT(var Entity:GDBObjDrawable;var ObjMatrix:DMatrix4D; var rc:TDrawContext;constref LP:GDBLineProp; const vp:GDBObjVisualProp;OnlyOne:Boolean=False);
var
  gpl:TGeomPLine3D;
  gp:TGeomProxy;
  dr:TLLDrawResult;
begin
  if ObjMatrix.IsIdentity then begin
    dr:=Graphix.DrawLineWithLT(rc,LP.lBegin,LP.lEnd,vp,OnlyOne);
    Geometry.Lock;
    if dr.Appearance<>TAMatching then
    begin
      gp.init(dr.LLPStart,dr.LLPEndi-1,dr.BB);
      Geometry.AddObjectToNodeTree(gp);
    end;
    gpl.init(LP,0);
    Geometry.AddObjectToNodeTree(gpl);
    Geometry.UnLock;
  end else
    DrawLineWithLT(Entity,ObjMatrix,rc,LP.lBegin,LP.lEnd,vp,OnlyOne);
end;

procedure TZEntityRepresentation.DrawLineWithoutLT(var rc:TDrawContext;const startpoint,endpoint:GDBVertex);
var
  gl:TGeomLine3D;
  gp:TGeomProxy;
  dr:TLLDrawResult;
begin
  Graphix.DrawLineWithoutLT(rc,startpoint,endpoint,dr);
  Geometry.Lock;
  if dr.Appearance<>TAMatching then
  begin
    gp.init(dr.LLPStart,dr.LLPEndi-1,dr.BB);
    Geometry.AddObjectToNodeTree(gp);
  end;
  gl.init(startpoint,endpoint,0);
  Geometry.AddObjectToNodeTree(gl);
  Geometry.UnLock;
end;
procedure TZEntityRepresentation.DrawPoint(var rc:TDrawContext;const point:GDBVertex; const vp:GDBObjVisualProp);
var
  //gl:TGeomLine3D;
  gp:TGeomProxy;
  dr:TLLDrawResult;
begin
  Graphix.DrawPointWithoutLT(rc,point,{vp}dr);
  Geometry.Lock;
  if dr.Appearance<>TAMatching then
  begin
    gp.init(dr.LLPStart,dr.LLPEndi-1,dr.BB);
    Geometry.AddObjectToNodeTree(gp);
  end;
  //gl.init(startpoint,endpoint,0);
  //Geometry.AddObjectToNodeTree(gl);
  Geometry.UnLock;
end;
procedure TZEntityRepresentation.DrawPolyLineWithLT(var rc:TDrawContext;const points:GDBPoint3dArray; const vp:GDBObjVisualProp; const closed,ltgen:Boolean);
var
  ptv,ptvprev,ptvfisrt: pgdbvertex;
  ir:itrec;
  gl:TGeomLine3D;
  segcounter:integer;
begin
  Graphix.DrawPolyLineWithLT(rc,points,vp,closed,ltgen);
  Geometry.Lock;
  Geometry.SetSize(Points.Count*sizeof(TGeomLine3D));
  ptv:=Points.beginiterate(ir);
  ptvfisrt:=ptv;
  segcounter:=0;
  if ptv<>nil then
  repeat
        ptvprev:=ptv;
        ptv:=Points.iterate(ir);
        if ptv<>nil then
        begin
          gl.init(ptv^,ptvprev^,segcounter);
          Geometry.AddObjectToNodeTree(gl);
          inc(segcounter);
        end;
  until ptv=nil;
  if closed then
  begin
    gl.init(ptvprev^,ptvfisrt^,segcounter);
    Geometry.AddObjectToNodeTree(gl);
  end;
  Geometry.UnLock;
end;
procedure TZEntityRepresentation.StartSurface;
begin
end;

procedure TZEntityRepresentation.EndSurface;
begin
end;

begin
end.

