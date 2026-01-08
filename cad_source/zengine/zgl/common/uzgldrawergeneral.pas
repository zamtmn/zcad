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

unit uzgldrawergeneral;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses
  uzegeometrytypes,uzgvertex3sarray,uzgprimitivescreatorabstract,uzgprimitivescreator,
  uzgldrawerabstract,uzepalette,types,Classes,Graphics,
  uzeTypes,uzecamera,uzegeometry,UGDBPoint3DArray,uzbLogIntf;
type
TPaintState=(TPSBufferNotSaved,TPSBufferSaved);
TZGLGeneralDrawer=class(TZGLAbstractDrawer)
                        drawrect:trect;
                        wh:tsize;
                        PState:TPaintState;
                        public
                        function GetLLPrimitivesCreator:TLLPrimitivesCreatorAbstract;override;

                        procedure DrawLine(const PVertexBuffer:PZGLVertex3Sarray;const i1,i2:TLLVertexIndex);override;
                        procedure DrawPoint(const PVertexBuffer:PZGLVertex3Sarray;const i:TLLVertexIndex);override;
                        procedure startrender(const mode:TRenderMode;var matrixs:tmatrixs);override;
                        procedure endrender;override;
                        function startpaint(InPaintMessage:boolean;w,h:integer):boolean;override;
                        procedure endpaint(InPaintMessage:boolean);override;
                        procedure SetLineWidth(const w:single);override;
                        procedure SetPointSize(const s:single);override;
                        procedure SetColor(const red, green, blue, alpha: byte);overload;override;
                        procedure SetClearColor(const red, green, blue, alpha: byte);overload;override;
                        procedure SetColor(const color: TRGB);overload;override;
                        procedure ClearScreen(stencil:boolean);override;
                        procedure TranslateCoord2D(const tx,ty:single);override;
                        procedure ScaleCoord2D(const sx,sy:single);override;
                        procedure SetLineSmooth(const smoth:boolean);override;
                        procedure SetPointSmooth(const smoth:boolean);override;
                        procedure ClearStatesMachine;override;
                        procedure SetFillStencilMode;override;
                        procedure SetSelectedStencilMode;override;
                        procedure SetDrawWithStencilMode;override;
                        procedure DisableStencil;override;
                        procedure SetZTest(Z:boolean);override;
                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:integer);override;
                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:TStoredType);override;
                        procedure DrawClosedPolyLine2DInDCS(const coords:array of TStoredType);overload;override;
                        procedure DrawLine3DInModelSpace(const p1,p2:TzePoint3d;var matrixs:tmatrixs);override;
                        procedure DrawPoint3DInModelSpace(const p:TzePoint3d;var matrixs:tmatrixs);override;
                        procedure DrawTriangle3DInModelSpace(const normal,p1,p2,p3:TzePoint3d;var matrixs:tmatrixs);override;
                        procedure DrawQuad3DInModelSpace(const normal,p1,p2,p3,p4:TzePoint3d;var matrixs:tmatrixs);override;
                        procedure DrawQuad3DInModelSpace(const p1,p2,p3,p4:TzePoint3d;var matrixs:tmatrixs);override;
                        procedure DrawAABB3DInModelSpace(const BoundingBox:TBoundingBox;var matrixs:tmatrixs);override;
                        procedure DrawContour3DInModelSpace(const pa:GDBPoint3dArray;var matrixs:tmatrixs;Closed:boolean=true);override;
                        procedure WorkAreaResize(rect:trect);override;
                        procedure SaveBuffers;override;
                        procedure RestoreBuffers;override;
                        function CreateScrbuf:boolean; override;
                        procedure delmyscrbuf; override;
                        procedure SwapBuffers; override;
                        procedure SetPenStyle(const style:TZGLPenStyle);override;
                        procedure SetDrawMode(const mode:TZGLDrawMode);override;
                        procedure DrawQuad2DInDCS(const x1,y1,x2,y2:TStoredType);override;
                        procedure SetOGLMatrix(const cam:GDBObjCamera;const w,h:integer);override;
                        procedure PostRenderDraw;override;

                        procedure pushMatrixAndSetTransform(const Transform:TzeTypedMatrix4d;FromOneMatrix:Boolean=False);overload;override;
                        procedure pushMatrixAndSetTransform(const Transform:TzeTypedMatrix4s;FromOneMatrix:Boolean=False);overload;override;
                        procedure popMatrix;override;
                        procedure AddToLCS(const v:TzePoint3d);override;
                        function SetLCSState(State:boolean):boolean;override;
                        function SetLCS(const newLCS:TzePoint3d):TzePoint3d;override;
                        function GetLCS:TzePoint3d;override;
                   end;
   TLCSProp=record
     CurrentCamCSOffset:TzePoint3d;
     CurrentCamCSOffsetS:TzePoint3s;
     notuseLCS:Boolean;
   end;

var
  testrender:TZGLAbstractDrawer;
  LCS,LCSSave:TLCSProp;
implementation
//uses log;
var
  DrawerLLPCreator:TLLPrimitivesCreator;
function TZGLGeneralDrawer.SetLCSState(State:boolean):boolean;
begin
  Result:=LCS.notuseLCS;
  LCS.notuseLCS:=State;
end;
function TZGLGeneralDrawer.SetLCS(const newLCS:TzePoint3d):TzePoint3d;
begin
  Result:=LCS.CurrentCamCSOffset;
  LCS.CurrentCamCSOffset:=newLCS;
  LCS.CurrentCamCSOffsetS.x:=newLCS.x;
  LCS.CurrentCamCSOffsetS.y:=newLCS.y;
  LCS.CurrentCamCSOffsetS.z:=newLCS.z
end;
function TZGLGeneralDrawer.GetLCS:TzePoint3d;
begin
  Result:=LCS.CurrentCamCSOffset;
end;

procedure TZGLGeneralDrawer.AddToLCS(const v:TzePoint3d);
begin
  LCS.CurrentCamCSOffset:=LCS.CurrentCamCSOffset+v;
  LCS.CurrentCamCSOffsetS.x:=LCS.CurrentCamCSOffsetS.x+v.x;
  LCS.CurrentCamCSOffsetS.y:=LCS.CurrentCamCSOffsetS.y+v.y;
  LCS.CurrentCamCSOffsetS.z:=LCS.CurrentCamCSOffsetS.z+v.z;
end;
procedure TZGLGeneralDrawer.popMatrix;
begin
end;
procedure TZGLGeneralDrawer.pushMatrixAndSetTransform(const Transform:TzeTypedMatrix4d;FromOneMatrix:Boolean=False);
begin
end;
procedure TZGLGeneralDrawer.pushMatrixAndSetTransform(const Transform:TzeTypedMatrix4s;FromOneMatrix:Boolean=False);
begin
end;
function TZGLGeneralDrawer.GetLLPrimitivesCreator:TLLPrimitivesCreatorAbstract;
begin
     result:=DrawerLLPCreator;
end;

procedure TZGLGeneralDrawer.DrawLine(const PVertexBuffer:PZGLVertex3Sarray;const i1,i2:TLLVertexIndex);
begin
end;
procedure TZGLGeneralDrawer.DrawPoint(const PVertexBuffer:PZGLVertex3Sarray;const i:TLLVertexIndex);
begin
end;
procedure TZGLGeneralDrawer.startrender;
begin
end;
procedure TZGLGeneralDrawer.endrender;
begin
end;
function TZGLGeneralDrawer.startpaint;
begin
     result:=false;
end;
procedure TZGLGeneralDrawer.endpaint;
begin
end;
procedure TZGLGeneralDrawer.SetLineWidth(const w:single);
begin
end;
procedure TZGLGeneralDrawer.SetPointSize(const s:single);
begin
end;
procedure TZGLGeneralDrawer.SetColor(const red, green, blue, alpha: byte);
begin
end;
procedure TZGLGeneralDrawer.SetClearColor(const red, green, blue, alpha: byte);
begin
end;
procedure TZGLGeneralDrawer.SetColor(const color: TRGB);
begin
end;
procedure TZGLGeneralDrawer.ClearScreen(stencil:boolean);
begin
end;
procedure TZGLGeneralDrawer.TranslateCoord2D(const tx,ty:single);
begin
end;
procedure TZGLGeneralDrawer.ScaleCoord2D(const sx,sy:single);
begin
end;
procedure TZGLGeneralDrawer.SetLineSmooth(const smoth:boolean);
begin
end;
procedure TZGLGeneralDrawer.SetPointSmooth(const smoth:boolean);
begin
end;
procedure TZGLGeneralDrawer.ClearStatesMachine;
begin
end;
procedure TZGLGeneralDrawer.SetFillStencilMode;
begin
end;
procedure TZGLGeneralDrawer.SetSelectedStencilMode;
begin
end;
procedure TZGLGeneralDrawer.SetDrawWithStencilMode;
begin
end;
procedure TZGLGeneralDrawer.DisableStencil;
begin
end;
procedure TZGLGeneralDrawer.SetZTest(Z:boolean);
begin
end;
procedure TZGLGeneralDrawer.DrawLine2DInDCS(const x1,y1,x2,y2:integer);
begin
end;
procedure TZGLGeneralDrawer.DrawLine2DInDCS(const x1,y1,x2,y2:TStoredType);
begin
end;
procedure TZGLGeneralDrawer.DrawClosedPolyLine2DInDCS(const coords:array of TStoredType);
begin
end;
procedure TZGLGeneralDrawer.DrawLine3DInModelSpace(const p1,p2:TzePoint3d;var matrixs:tmatrixs);
begin
end;
procedure TZGLGeneralDrawer.DrawPoint3DInModelSpace(const p:TzePoint3d;var matrixs:tmatrixs);
begin
end;
procedure TZGLGeneralDrawer.DrawTriangle3DInModelSpace(const normal,p1,p2,p3:TzePoint3d;var matrixs:tmatrixs);
begin
end;
procedure TZGLGeneralDrawer.DrawQuad3DInModelSpace(const normal,p1,p2,p3,p4:TzePoint3d;var matrixs:tmatrixs);
begin
end;
procedure TZGLGeneralDrawer.DrawQuad3DInModelSpace(const p1,p2,p3,p4:TzePoint3d;var matrixs:tmatrixs);
begin
end;
procedure TZGLGeneralDrawer.DrawAABB3DInModelSpace(const BoundingBox:TBoundingBox;var matrixs:tmatrixs);
begin
        DrawLine3DInModelSpace(createvertex(BoundingBox.LBN.x,BoundingBox.LBN.y,BoundingBox.LBN.Z),
                               createvertex(BoundingBox.RTF.x,BoundingBox.LBN.y,BoundingBox.LBN.Z),matrixs);
        DrawLine3DInModelSpace(createvertex(BoundingBox.RTF.x,BoundingBox.LBN.y,BoundingBox.LBN.Z),
                               createvertex(BoundingBox.RTF.x,BoundingBox.RTF.y,BoundingBox.LBN.Z),matrixs);
        DrawLine3DInModelSpace(createvertex(BoundingBox.RTF.x,BoundingBox.RTF.y,BoundingBox.LBN.Z),
                               createvertex(BoundingBox.LBN.x,BoundingBox.RTF.y,BoundingBox.LBN.Z),matrixs);
        DrawLine3DInModelSpace(createvertex(BoundingBox.LBN.x,BoundingBox.RTF.y,BoundingBox.LBN.Z),
                               createvertex(BoundingBox.LBN.x,BoundingBox.LBN.y,BoundingBox.LBN.Z),matrixs);
        DrawLine3DInModelSpace(createvertex(BoundingBox.LBN.x,BoundingBox.LBN.y,BoundingBox.RTF.Z),
                               createvertex(BoundingBox.RTF.x,BoundingBox.LBN.y,BoundingBox.RTF.Z),matrixs);
        DrawLine3DInModelSpace(createvertex(BoundingBox.RTF.x,BoundingBox.LBN.y,BoundingBox.RTF.Z),
                               createvertex(BoundingBox.RTF.x,BoundingBox.RTF.y,BoundingBox.RTF.Z),matrixs);
        DrawLine3DInModelSpace(createvertex(BoundingBox.RTF.x,BoundingBox.RTF.y,BoundingBox.RTF.Z),
                               createvertex(BoundingBox.LBN.x,BoundingBox.RTF.y,BoundingBox.RTF.Z),matrixs);
        DrawLine3DInModelSpace(createvertex(BoundingBox.LBN.x,BoundingBox.RTF.y,BoundingBox.RTF.Z),
                               createvertex(BoundingBox.LBN.x,BoundingBox.LBN.y,BoundingBox.RTF.Z),matrixs);
        DrawLine3DInModelSpace(createvertex(BoundingBox.LBN.x,BoundingBox.LBN.y,BoundingBox.LBN.Z),
                               createvertex(BoundingBox.LBN.x,BoundingBox.LBN.y,BoundingBox.RTF.Z),matrixs);
        DrawLine3DInModelSpace(createvertex(BoundingBox.RTF.x,BoundingBox.LBN.y,BoundingBox.LBN.Z),
                               createvertex(BoundingBox.RTF.x,BoundingBox.LBN.y,BoundingBox.RTF.Z),matrixs);
        DrawLine3DInModelSpace(createvertex(BoundingBox.RTF.x,BoundingBox.RTF.y,BoundingBox.LBN.Z),
                               createvertex(BoundingBox.RTF.x,BoundingBox.RTF.y,BoundingBox.RTF.Z),matrixs);
        DrawLine3DInModelSpace(createvertex(BoundingBox.LBN.x,BoundingBox.RTF.y,BoundingBox.LBN.Z),
                               createvertex(BoundingBox.LBN.x,BoundingBox.RTF.y,BoundingBox.RTF.Z),matrixs);
end;
procedure TZGLGeneralDrawer.DrawContour3DInModelSpace(const pa:GDBPoint3dArray;var matrixs:tmatrixs;Closed:boolean=true);
var p,pold,pstart:PzePoint3d;
    i:Integer;
begin
  if pa.count<2 then exit;
  p:=pa.GetParrayAsPointer;
  pold:=p;
  pstart:=p;
  inc(p);
  for i:=0 to pa.count-2 do
  begin
     DrawLine3DInModelSpace(pold^,p^,matrixs);
     inc(p);
     inc(pold);
  end;
  if closed then
    DrawLine3DInModelSpace(pold^,pstart^,matrixs);
end;
procedure TZGLGeneralDrawer.WorkAreaResize;
begin
     drawrect:=rect;
     wh.cx:=rect.Right-rect.Left;
     wh.cy:=rect.Bottom-rect.Top;
     delmyscrbuf;
     //CreateScrbuf(w,h);
end;
procedure TZGLGeneralDrawer.SaveBuffers;
begin
     PState:=TPaintState.TPSBufferNotSaved;
end;
procedure TZGLGeneralDrawer.RestoreBuffers;
begin
end;
function TZGLGeneralDrawer.CreateScrbuf:boolean;
begin
     result:=false;
end;
procedure TZGLGeneralDrawer.delmyscrbuf;
begin
end;
procedure TZGLGeneralDrawer.SwapBuffers;
begin
end;
procedure TZGLGeneralDrawer.SetPenStyle(const style:TZGLPenStyle);
begin
end;
procedure TZGLGeneralDrawer.SetDrawMode(const mode:TZGLDrawMode);
begin
end;
procedure TZGLGeneralDrawer.DrawQuad2DInDCS(const x1,y1,x2,y2:TStoredType);
begin
end;
procedure TZGLGeneralDrawer.SetOGLMatrix(const cam:GDBObjCamera;const w,h:integer);
begin
end;
procedure TZGLGeneralDrawer.PostRenderDraw;
begin
end;
initialization
  DrawerLLPCreator:=TLLPrimitivesCreator.create;
finalization
  zDebugln('{I}[UnitsFinalization] Unit "'+{$INCLUDE %FILE%}+'" finalization');
  DrawerLLPCreator.Destroy;
end.

