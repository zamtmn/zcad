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
{$INCLUDE def.inc}
interface
uses uzgldrawcontext,uzgldrawerabstract,
     uzbtypesbase,sysutils,uzbmemman,
     uzbgeomtypes,uzegeometry,uzglgeometry,uzefont,uzeentitiesprop,UGDBPoint3DArray,
     uzgeomentity3d;
type
{Export+}
TZEntityRepresentation={$IFNDEF DELPHI}packed{$ENDIF} object
                       {-}private{//}
                       Graphix:ZGLGraphix;(*hidden_in_objinsp*)
                       {-}public{//}
                       constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar{$ENDIF});
                       destructor done;virtual;

                       function CalcTrueInFrustum(frustum:ClipArray; FullCheck:boolean):TInBoundingVolume;
                       procedure DrawGeometry(var rc:TDrawContext);virtual;
                       procedure DrawNiceGeometry(var rc:TDrawContext);virtual;
                       procedure Clear;virtual;
                       procedure Shrink;virtual;

                       function GetGraphix:PZGLGraphix;

                       procedure DrawTextContent(drawer:TZGLAbstractDrawer;content:gdbstring;_pfont: PGDBfont;const DrawMatrix,objmatrix:DMatrix4D;const textprop_size:GDBDouble;var Outbound:OutBound4V);
                       procedure DrawLineWithLT(var rc:TDrawContext;const startpoint,endpoint:GDBVertex; const vp:GDBObjVisualProp);
                       procedure DrawPolyLineWithLT(var rc:TDrawContext;const points:GDBPoint3dArray; const vp:GDBObjVisualProp; const closed,ltgen:GDBBoolean);virtual;
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
  Graphix.init({$IFDEF DEBUGBUILD}ErrGuid:pansichar{$ENDIF});
end;
destructor TZEntityRepresentation.done;
begin
  Graphix.done;
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
end;
procedure TZEntityRepresentation.Shrink;
begin
  Graphix.Shrink;
end;
procedure TZEntityRepresentation.DrawTextContent(drawer:TZGLAbstractDrawer;content:gdbstring;_pfont: PGDBfont;const DrawMatrix,objmatrix:DMatrix4D;const textprop_size:GDBDouble;var Outbound:OutBound4V);
begin
  Graphix.DrawTextContent(drawer,content,_pfont,DrawMatrix,objmatrix,textprop_size,Outbound);
end;
procedure TZEntityRepresentation.DrawLineWithLT(var rc:TDrawContext;const startpoint,endpoint:GDBVertex; const vp:GDBObjVisualProp);
begin
  Graphix.DrawLineWithLT(rc,startpoint,endpoint,vp);
end;
procedure TZEntityRepresentation.DrawPolyLineWithLT(var rc:TDrawContext;const points:GDBPoint3dArray; const vp:GDBObjVisualProp; const closed,ltgen:GDBBoolean);
begin
  Graphix.DrawPolyLineWithLT(rc,points,vp,closed,ltgen);
end;
begin
end.

