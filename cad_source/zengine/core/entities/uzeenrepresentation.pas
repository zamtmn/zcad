{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
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
     uzegeomentitiestree,uzbtypes,
     gzctnrVectorTypes,uzgeomline3d,uzgeomproxy;
type
{Export+}
PTZEntityRepresentation=^TZEntityRepresentation;
{REGISTEROBJECTTYPE TZEntityRepresentation}
TZEntityRepresentation= object(GDBaseObject)
                       {-}//private{//}
                       Graphix:ZGLGraphix;
                       Geometry:TGeomEntTreeNode;
                       {-}public{//}
                       constructor init();
                       destructor done;virtual;

                       function CalcTrueInFrustum(frustum:ClipArray; FullCheck:boolean):TInBoundingVolume;
                       procedure DrawGeometry(var rc:TDrawContext);virtual;
                       procedure DrawNiceGeometry(var rc:TDrawContext);virtual;
                       procedure Clear;virtual;
                       procedure Shrink;virtual;

                       function GetGraphix:PZGLGraphix;

                       {Команды которыми примитив рисует сам себя}
                       procedure DrawTextContent(drawer:TZGLAbstractDrawer;content:TDXFEntsInternalStringType;_pfont: PGDBfont;const DrawMatrix,objmatrix:DMatrix4D;const textprop_size:Double;var Outbound:OutBound4V);
                       procedure DrawLineWithLT(var rc:TDrawContext;const startpoint,endpoint:GDBVertex; const vp:GDBObjVisualProp);
                       procedure DrawPolyLineWithLT(var rc:TDrawContext;const points:GDBPoint3dArray; const vp:GDBObjVisualProp; const closed,ltgen:Boolean);virtual;
                       procedure StartSurface;
                       procedure EndSurface;
                       end;
{Export-}
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
procedure TZEntityRepresentation.DrawGeometry(var rc:TDrawContext);
begin
  Graphix.DrawGeometry(rc);
end;
procedure TZEntityRepresentation.DrawNiceGeometry(var rc:TDrawContext);
begin
  Graphix.DrawNiceGeometry(rc);
end;
function TZEntityRepresentation.CalcTrueInFrustum(frustum:ClipArray; FullCheck:boolean):TInBoundingVolume;
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
procedure TZEntityRepresentation.DrawLineWithLT(var rc:TDrawContext;const startpoint,endpoint:GDBVertex; const vp:GDBObjVisualProp);
var
  gl:TGeomLine3D;
  gp:TGeomProxy;
  dr:TLLDrawResult;
begin
  dr:=Graphix.DrawLineWithLT(rc,startpoint,endpoint,vp);
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
procedure TZEntityRepresentation.DrawPolyLineWithLT(var rc:TDrawContext;const points:GDBPoint3dArray; const vp:GDBObjVisualProp; const closed,ltgen:Boolean);
var
  ptv,ptvprev,ptvfisrt: pgdbvertex;
  ir:itrec;
  gl:TGeomLine3D;
  segcounter:integer;
begin
  Graphix.DrawPolyLineWithLT(rc,points,vp,closed,ltgen);
  Geometry.Lock;
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

