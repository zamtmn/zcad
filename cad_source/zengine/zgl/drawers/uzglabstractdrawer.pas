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
uses gdbpalette,Classes,UGDBOpenArrayOfData,Graphics,gdbase,gdbasetypes,GDBCamera,geometry;
type
TRenderMode=(TRM_ModelSpace,TRM_DisplaySpace,TRM_WindowSpace);
TZGLPenStyle=(TPS_Solid,TPS_Dot,TPS_Dash,TPS_Selected);
TZGLDrawMode=(TDM_OR,TDM_XOR,TDM_Normal);
TZGLAbstractDrawer=class
                        public
                        PVertexBuffer:PGDBOpenArrayOfData;
                        procedure DrawLine(const i1:TLLVertexIndex);virtual;abstract;
                        procedure DrawTriangle(const i1:TLLVertexIndex);virtual;abstract;
                        procedure DrawQuad(const i1:TLLVertexIndex);virtual;abstract;
                        function CheckOutboundInDisplay(const i1:TLLVertexIndex):boolean;virtual;abstract;
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
implementation
uses log;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('uzglgeneraldrawer.initialization');{$ENDIF}
end.

