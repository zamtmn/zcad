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

unit uzglabstractdrawer;
{$INCLUDE def.inc}
interface
uses types,Classes,UGDBOpenArrayOfData,uzgprimitivessarray,Graphics,gdbase,gdbasetypes,GDBCamera,geometry;
type
TRenderMode=(TRM_ModelSpace,TRM_DisplaySpace,TRM_WindowSpace);
TZGLPenStyle=(TPS_Solid,TPS_Dot,TPS_Dash,TPS_Selected);
TZGLDrawMode=(TDM_OR,TDM_XOR,TDM_Normal);
TZGLAbstractDrawer=class
                        public
                        PVertexBuffer:PGDBOpenArrayOfData;
                        procedure DrawLine(const i1:TLLVertexIndex);virtual;abstract;
                        procedure DrawPoint(const i:TLLVertexIndex);virtual;abstract;
                        procedure startrender(const mode:TRenderMode;var matrixs:tmatrixs);virtual;abstract;
                        procedure endrender;virtual;abstract;
                        function startpaint(InPaintMessage:boolean;w,h:integer):boolean;virtual;abstract;
                        procedure endpaint(InPaintMessage:boolean);virtual;abstract;
                        procedure SetLineWidth(const w:single);virtual;abstract;
                        procedure SetPointSize(const s:single);virtual;abstract;
                        procedure SetColor(const red, green, blue, alpha: byte);overload;virtual;abstract;
                        procedure SetClearColor(const red, green, blue, alpha: byte);overload;virtual;abstract;
                        procedure SetColor(const color: TRGB);overload;virtual;abstract;
                        procedure ClearScreen(stencil:boolean);virtual;abstract;
                        procedure TranslateCoord2D(const tx,ty:single);virtual;abstract;
                        procedure ScaleCoord2D(const sx,sy:single);virtual;abstract;
                        procedure SetLineSmooth(const smoth:boolean);virtual;abstract;
                        procedure SetPointSmooth(const smoth:boolean);virtual;abstract;
                        procedure ClearStatesMachine;virtual;abstract;
                        procedure SetFillStencilMode;virtual;abstract;
                        procedure SetSelectedStencilMode;virtual;abstract;
                        procedure SetDrawWithStencilMode;virtual;abstract;
                        procedure DisableStencil;virtual;abstract;
                        procedure SetZTest(Z:boolean);virtual;abstract;
                        procedure WorkAreaResize(rect:trect);virtual;abstract;
                        procedure SaveBuffers;virtual;abstract;
                        procedure RestoreBuffers;virtual;abstract;
                        function CreateScrbuf:boolean; virtual;abstract;
                        procedure delmyscrbuf; virtual;abstract;
                        procedure SwapBuffers; virtual;abstract;
                        procedure SetPenStyle(const style:TZGLPenStyle);virtual;abstract;
                        procedure SetDrawMode(const mode:TZGLDrawMode);virtual;abstract;



                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:integer);overload;virtual;abstract;
                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:single);overload;virtual;abstract;
                        procedure DrawQuad2DInDCS(const x1,y1,x2,y2:single);virtual;abstract;
                        procedure DrawClosedPolyLine2DInDCS(const coords:array of single);overload;virtual;abstract;
                        procedure DrawLine3DInModelSpace(const p1,p2:gdbvertex;var matrixs:tmatrixs);virtual;abstract;
                        procedure DrawPoint3DInModelSpace(const p:gdbvertex;var matrixs:tmatrixs);virtual;abstract;
                        procedure DrawTriangle3DInModelSpace(const normal,p1,p2,p3:gdbvertex;var matrixs:tmatrixs);virtual;abstract;
                        procedure DrawQuad3DInModelSpace(const normal,p1,p2,p3,p4:gdbvertex;var matrixs:tmatrixs);virtual;abstract;overload;
                        procedure DrawQuad3DInModelSpace(const p1,p2,p3,p4:gdbvertex;var matrixs:tmatrixs);virtual;abstract;overload;
                        procedure DrawAABB3DInModelSpace(const BoundingBox:GDBBoundingBbox;var matrixs:tmatrixs);virtual;abstract;
                        procedure SetOGLMatrix(const cam:GDBObjCamera;const w,h:integer);virtual;abstract;
                        procedure DrawDebugGeometry;virtual;abstract;
                   end;
TZGLGeneralDrawer=class(TZGLAbstractDrawer)
                        drawrect:trect;
                        wh:tsize;
                        public
                        procedure DrawLine(const i1:TLLVertexIndex);override;
                        procedure DrawPoint(const i:TLLVertexIndex);override;
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
                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:single);override;
                        procedure DrawClosedPolyLine2DInDCS(const coords:array of single);overload;override;
                        procedure DrawLine3DInModelSpace(const p1,p2:gdbvertex;var matrixs:tmatrixs);override;
                        procedure DrawPoint3DInModelSpace(const p:gdbvertex;var matrixs:tmatrixs);override;
                        procedure DrawTriangle3DInModelSpace(const normal,p1,p2,p3:gdbvertex;var matrixs:tmatrixs);override;
                        procedure DrawQuad3DInModelSpace(const normal,p1,p2,p3,p4:gdbvertex;var matrixs:tmatrixs);override;
                        procedure DrawQuad3DInModelSpace(const p1,p2,p3,p4:gdbvertex;var matrixs:tmatrixs);override;
                        procedure DrawAABB3DInModelSpace(const BoundingBox:GDBBoundingBbox;var matrixs:tmatrixs);override;
                        procedure WorkAreaResize(rect:trect);override;
                        procedure SaveBuffers;override;
                        procedure RestoreBuffers;override;
                        function CreateScrbuf:boolean; override;
                        procedure delmyscrbuf; override;
                        procedure SwapBuffers; override;
                        procedure SetPenStyle(const style:TZGLPenStyle);override;
                        procedure SetDrawMode(const mode:TZGLDrawMode);override;
                        procedure DrawQuad2DInDCS(const x1,y1,x2,y2:single);override;
                        procedure SetOGLMatrix(const cam:GDBObjCamera;const w,h:integer);override;
                        procedure DrawDebugGeometry;override;
                   end;
var
  testrender:TZGLAbstractDrawer;
  CurrentCamCSOffset:GDBvertex;
  CurrentCamCSOffsetS:GDBvertex3S;
  notuseLCS:GDBBOOLEAN;
implementation
uses log;
procedure TZGLGeneralDrawer.DrawLine(const i1:TLLVertexIndex);
begin
end;
procedure TZGLGeneralDrawer.DrawPoint(const i:TLLVertexIndex);
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
procedure TZGLGeneralDrawer.DrawLine2DInDCS(const x1,y1,x2,y2:single);
begin
end;
procedure TZGLGeneralDrawer.DrawClosedPolyLine2DInDCS(const coords:array of single);
begin
end;
procedure TZGLGeneralDrawer.DrawLine3DInModelSpace(const p1,p2:gdbvertex;var matrixs:tmatrixs);
begin
end;
procedure TZGLGeneralDrawer.DrawPoint3DInModelSpace(const p:gdbvertex;var matrixs:tmatrixs);
begin
end;
procedure TZGLGeneralDrawer.DrawTriangle3DInModelSpace(const normal,p1,p2,p3:gdbvertex;var matrixs:tmatrixs);
begin
end;
procedure TZGLGeneralDrawer.DrawQuad3DInModelSpace(const normal,p1,p2,p3,p4:gdbvertex;var matrixs:tmatrixs);
begin
end;
procedure TZGLGeneralDrawer.DrawQuad3DInModelSpace(const p1,p2,p3,p4:gdbvertex;var matrixs:tmatrixs);
begin
end;
procedure TZGLGeneralDrawer.DrawAABB3DInModelSpace(const BoundingBox:GDBBoundingBbox;var matrixs:tmatrixs);
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
end;
procedure TZGLGeneralDrawer.RestoreBuffers;
begin
end;
function TZGLGeneralDrawer.CreateScrbuf:boolean;
begin
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
procedure TZGLGeneralDrawer.DrawQuad2DInDCS(const x1,y1,x2,y2:single);
begin
end;
procedure TZGLGeneralDrawer.SetOGLMatrix(const cam:GDBObjCamera;const w,h:integer);
begin
end;
procedure TZGLGeneralDrawer.DrawDebugGeometry;
begin
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('uzglabstractdrawer.initialization');{$ENDIF}
end.

