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

unit uzglgdidrawer;
{$INCLUDE def.inc}
interface
uses
    uzglgeomdata,gdbdrawcontext,uzgprimitives,uzgprimitivescreatorabstract,uzgprimitivescreator,UGDBOpenArrayOfData,gdbpalette,{$IFDEF WINDOWS}GDIPAPI,GDIPOBJ,windows,{$ENDIF}
    {$IFDEF LCLGTK2}
    Gtk2Def,
    {$ENDIF}
    LCLIntf,LCLType,Classes,Controls,
    geometry,uzglgeneraldrawer,uzglabstractdrawer,glstatemanager,Graphics,gdbase;
type
PTLLGDISymbol=^TLLGDISymbol;
TLLGDISymbol={$IFNDEF DELPHI}packed{$ENDIF} object(TLLSymbol)
              procedure drawSymbol(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData);virtual;
        end;
TLLGDIPrimitivesCreator=class(TLLPrimitivesCreator)
                             function CreateLLSymbol(var pa:GDBOpenArrayOfData):TArrayIndex;override;
                        end;

DMatrix4DStackArray=array[0..10] of DMatrix4D;
TPaintState=(TPSBufferNotSaved,TPSBufferSaved);
TZGLGDIDrawer=class(TZGLGeneralDrawer)
                        public
                        canvas:tcanvas;
                        panel:TCustomControl;
                        midline:integer;
                        sx,sy,tx,ty:single;
                        ClearColor: TColor;
                        PenColor: TColor;
                        OffScreedDC:HDC;
                        CanvasDC:HDC;
                        OffscreenBitmap:HBITMAP;
                        SavedBitmap:HBITMAP;
                        SavedDC:HDC;
                        hLinePen:HPEN;
                        hBrush:HBRUSH;
                        linewidth:integer;
                        penstyle:TZGLPenStyle;
                        PState:TPaintState;
                        ScreenInvalidRect:Trect;
                        PointSize:single;
                        matr:DMatrix4D;
                        mstack:DMatrix4DStackArray;
                        mstackindex:integer;
                        constructor create;

                        procedure startrender(const mode:TRenderMode;var matrixs:tmatrixs);override;

                        function startpaint(InPaintMessage:boolean;w,h:integer):boolean;override;
                        procedure createoffscreendc;
                        procedure deleteoffscreendc;
                        procedure endpaint(InPaintMessage:boolean);override;

                        function TranslatePointWithLocalCS(const p:GDBVertex3S):GDBVertex3S;
                        function TranslatePoint(const p:GDBVertex3S):GDBVertex3S;
                        procedure DrawLine(const PVertexBuffer:PGDBOpenArrayOfData;const i1,i2:TLLVertexIndex);override;
                        procedure DrawTriangle(const PVertexBuffer:PGDBOpenArrayOfData;const i1,i2,i3:TLLVertexIndex);override;
                        procedure DrawTrianglesFan(const PVertexBuffer,PIndexBuffer:PGDBOpenArrayOfData;const i1,IndexCount:TLLVertexIndex);override;
                        procedure DrawTrianglesStrip(const PVertexBuffer,PIndexBuffer:PGDBOpenArrayOfData;const i1,IndexCount:TLLVertexIndex);override;
                        procedure DrawQuad(const PVertexBuffer:PGDBOpenArrayOfData;const i1,i2,i3,i4:TLLVertexIndex);override;
                        function CheckOutboundInDisplay(const PVertexBuffer:PGDBOpenArrayOfData;const i1:TLLVertexIndex):boolean;override;
                        procedure DrawPoint(const PVertexBuffer:PGDBOpenArrayOfData;const i:TLLVertexIndex);override;

                        procedure DrawLine3DInModelSpace(const p1,p2:gdbvertex;var matrixs:tmatrixs);override;
                        procedure DrawPoint3DInModelSpace(const p:gdbvertex;var matrixs:tmatrixs);override;
                        procedure DrawTriangle3DInModelSpace(const normal,p1,p2,p3:gdbvertex;var matrixs:tmatrixs);override;
                        procedure DrawQuad3DInModelSpace(const normal,p1,p2,p3,p4:gdbvertex;var matrixs:tmatrixs);override;
                        procedure DrawQuad3DInModelSpace(const p1,p2,p3,p4:gdbvertex;var matrixs:tmatrixs);override;
                        procedure SetPointSize(const s:single);override;

                        procedure ClearScreen(stencil:boolean);override;
                        procedure SetClearColor(const red, green, blue, alpha: byte);overload;override;
                        procedure SetColor(const red, green, blue, alpha: byte);overload;override;
                        procedure SetColor(const color: TRGB);overload;override;
                        procedure SetLineWidth(const w:single);override;
                        procedure _createPen;
                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:integer);override;
                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:single);override;
                        procedure DrawClosedPolyLine2DInDCS(const coords:array of single);override;

                        function CreateScrbuf:boolean; override;
                        procedure delmyscrbuf; override;
                        procedure SaveBuffers;override;
                        procedure RestoreBuffers;override;
                        procedure SwapBuffers;override;
                        procedure TranslateCoord2D(const tx,ty:single);override;
                        procedure ScaleCoord2D(const sx,sy:single);override;
                        procedure SetPenStyle(const style:TZGLPenStyle);override;
                        procedure SetDrawMode(const mode:TZGLDrawMode);override;
                        procedure InitScreenInvalidrect(w,h:integer);
                        procedure CorrectScreenInvalidrect(w,h:integer);
                        procedure ProcessScreenInvalidrect(const x,y:integer);
                        procedure DrawDebugGeometry;override;

                        procedure pushMatrixAndSetTransform(Transform:DMatrix4D);override;overload;
                        procedure pushMatrixAndSetTransform(Transform:DMatrix4F);override;overload;
                        procedure popMatrix;override;

                        function GetLLPrimitivesCreator:TLLPrimitivesCreatorAbstract;override;
                   end;
{$IFDEF WINDOWS}
TZGLGDIPlusDrawer=class(TZGLGDIDrawer)
                        graphicsGDIPlus:TGPGraphics;
                        pen: TGPPen;
                        HDC: HDC;
                        lpPaint: TPaintStruct;
                        public
                        procedure startrender(const mode:TRenderMode;var matrixs:tmatrixs);override;
                        procedure endrender;override;
                        procedure DrawLine(const PVertexBuffer:PGDBOpenArrayOfData;const i1,i2:TLLVertexIndex);override;
                        procedure DrawPoint(const PVertexBuffer:PGDBOpenArrayOfData;const i:TLLVertexIndex);override;
                   end;
{$ENDIF}
var
   OGLDrawer:TZGLAbstractDrawer;
   CanvasDrawer:TZGLGDIDrawer;
   code:integer;
   LLGDIPrimitivesCreator:TLLGDIPrimitivesCreator;
   {$IFDEF WINDOWS}GDIPlusDrawer:TZGLGDIPlusDrawer;{$ENDIF}
implementation
uses log;
procedure isWindowsErrors;
begin

     {$IFDEF WINDOWS}
     code:=code;
     code:=0;
     code:=GetLastError;
     if code<>0 then
                    code:=code;
     SetLastError(0);
     code:=0;
     {$ENDIF}

end;

{$IFDEF WINDOWS}
procedure TZGLGDIPlusDrawer.startrender;
begin
     canvas:=canvas;
     {if not assigned(graphicsGDIPlus)then
     begin}
     graphicsGDIPlus := TGPGraphics.Create(Canvas.Handle);
     pen:= TGPPen.Create(MakeColor(255, 0, 0, 0), 1);
     //end;
end;

procedure TZGLGDIPlusDrawer.endrender;
begin
     canvas:=canvas;
     pen.Free;
     graphicsGDIPlus.Free;
end;

procedure TZGLGDIPlusDrawer.DrawLine(const PVertexBuffer:PGDBOpenArrayOfData;const i1,i2:TLLVertexIndex);
var
   pv1,pv2:PGDBVertex3S;
begin
    pv1:=PGDBVertex3S(PVertexBuffer.getelement(i1));
    pv2:=PGDBVertex3S(PVertexBuffer.getelement(i2));
    graphicsGDIPlus.DrawLine(Pen,pv1.x,midline-pv1.y,pv2.x,midline-pv2.y);
end;

procedure TZGLGDIPlusDrawer.DrawPoint(const PVertexBuffer:PGDBOpenArrayOfData;const i:TLLVertexIndex);
var
   pv:PGDBVertex3S;
begin
     pv:=PGDBVertex3S(PVertexBuffer.getelement(i));
     //graphicsGDIPlus.Drawpoint(Pen,pv.x,midline-pv.y);
end;
{$ENDIF}
function TZGLGDIDrawer.TranslatePointWithLocalCS(const p:GDBVertex3S):GDBVertex3S;
begin
     if mstackindex>-1 then
                           begin
                               result:=geometry.VectorTransform3D(p,matr);
                               result.x:=result.x*sx+tx;
                               result.y:=result.y*sy+ty;
                               result.z:=result.z;
                           end
                       else
                       begin
                           result.x:=p.x*sx+tx;
                           result.y:=p.y*sy+ty;
                           result.z:=p.z;
                       end;
end;
function TZGLGDIDrawer.TranslatePoint(const p:GDBVertex3S):GDBVertex3S;
begin
     result.x:=p.x*sx+tx;
     result.y:=p.y*sy+ty;
     result.z:=p.z;
end;
procedure TZGLGDIDrawer.TranslateCoord2D(const tx,ty:single);
begin
     self.tx:=self.tx+tx;
     self.ty:=self.ty+ty;
end;
procedure TZGLGDIDrawer.ScaleCoord2D(const sx,sy:single);
begin
  self.sx:=self.sx*sx;
  self.sy:=self.sy*sy;
end;

procedure TZGLGDIDrawer.pushMatrixAndSetTransform(Transform:DMatrix4D);
begin
     inc(mstackindex);
     mstack[mstackindex]:=matr;
     matr:=MatrixMultiply(matr,Transform);
end;
procedure TZGLGDIDrawer.pushMatrixAndSetTransform(Transform:DMatrix4F);
begin
     inc(mstackindex);
     mstack[mstackindex]:=matr;
     matr:=MatrixMultiply(matr,Transform);
end;
procedure TZGLGDIDrawer.popMatrix;
begin
     if mstackindex>-1 then
                           begin
                                 matr:=mstack[mstackindex];
                                 dec(mstackindex);
                           end;
end;

constructor TZGLGDIDrawer.create;
begin
     sx:=0.1;
     sy:=-0.1;
     tx:=0;
     ty:=400;
     SavedBitmap:=0;
     penstyle:=TPS_Solid;
     OffScreedDC:=0;
     matr:=OneMatrix;
     mstackindex:=-1;
end;
procedure TZGLGDIDrawer.SetPenStyle(const style:TZGLPenStyle);
begin
     if penstyle<>style then
     begin
          penstyle:=style;
          Self._createPen;
     end;
end;
procedure TZGLGDIDrawer.SetDrawMode(const mode:TZGLDrawMode);
begin
     case mode of
        TDM_Normal:
                   begin
                        SetROP2(OffScreedDC,R2_COPYPEN);
                   end;
            TDM_OR:
                   begin
                        SetROP2(OffScreedDC,R2_MERGEPEN);
                   end;
           TDM_XOR:
                     begin
                          SetROP2(OffScreedDC,R2_XORPEN);
                     end;
     end;
end;
procedure TZGLGDIDrawer.startrender;
var
   m:DMatrix4D;
begin
     case mode of
                 TRM_ModelSpace:
                 begin
                      m:=geometry.MatrixMultiply(matrixs.pmodelMatrix^,matrixs.pprojMatrix^);
                      sx:=(m[0][0]/m[3][3]*0.5)*matrixs.pviewport[2] ;
                      sy:=-(m[1][1]/m[3][3]*0.5)*matrixs.pviewport[3] ;
                      tx:=(m[3][0]/m[3][3]*0.5+0.5)*matrixs.pviewport[2];
                      ty:=matrixs.pviewport[3]-(m[3][1]/m[3][3]*0.5+0.5)*matrixs.pviewport[3];
                 end;
                 TRM_DisplaySpace:
                 begin
                      sx:=1;
                      sy:=-1;
                      tx:=0;
                      ty:=matrixs.pviewport[3];
                 end;
                 TRM_WindowSpace:
                 begin
                      sx:=1;
                      sy:=1;
                      tx:=0;
                      ty:=0;
                 end;
     end;
end;
procedure TZGLGDIDrawer.createoffscreendc;
begin
     if OffScreedDC=0 then
     begin
        OffScreedDC:=CreateCompatibleDC(CanvasDC);
        OffscreenBitmap:=CreateCompatibleBitmap(CanvasDC,wh.cx,wh.cy);
        SelectObject(OffScreedDC,OffscreenBitmap);
        hLinePen:=CreatePen(PS_SOLID, 1, PenColor);
        SelectObject(OffScreedDC, hLinePen);
     end;
end;
procedure TZGLGDIDrawer.deleteoffscreendc;
begin
     if OffScreedDC<>0 then
     begin
         DeleteObject(OffscreenBitmap);
         OffscreenBitmap:=0;
         DeleteObject(hLinePen);
         hLinePen:=0;
         DeleteDC(OffScreedDC);
         OffScreedDC:=0;
     end;
end;

function TZGLGDIDrawer.startpaint;
begin
     CanvasDC:=0;
     isWindowsErrors;
     if InPaintMessage then
                           CanvasDC:=(canvas.Handle)
                       else
                           CanvasDC:=GetDC(panel.Handle);
     createoffscreendc;
     isWindowsErrors;
     result:=CreateScrbuf;
     PState:=TPaintState.TPSBufferNotSaved;
end;
procedure TZGLGDIDrawer.endpaint;
begin
     if not InPaintMessage then
     ReleaseDC(panel.Handle,CanvasDC);
end;
function TZGLGDIDrawer.CreateScrbuf:boolean;
begin
     result:=false;
     {$IFNDEF LCLGTK2}if (wh.cx>0)and(wh.cy>0) then{$ENDIF}
     if SavedBitmap=0 then
     if CanvasDC<>0 then
     begin
          SavedDC:=CreateCompatibleDC({CanvasDC}0);
          isWindowsErrors;
          SavedBitmap:=CreateCompatibleBitmap({SavedDC}CanvasDC,wh.cx,wh.cy);
          isWindowsErrors;
          SelectObject(SavedDC,SavedBitmap);
          isWindowsErrors;
          result:=true;
          createoffscreendc;
     end;
end;
procedure TZGLGDIDrawer.delmyscrbuf;
begin
     if SavedBitmap<>0 then
     begin
     DeleteObject(SavedBitmap);
     isWindowsErrors;
     DeleteDC(SavedDC);
     isWindowsErrors;
     SavedBitmap:=0;
     SavedDC:=0;
     end;
     deleteoffscreendc;
end;
procedure TZGLGDIDrawer.SaveBuffers;
begin
    {$IFDEF LCLGTK2}
     if TGtkDeviceContext(SavedDC).drawable=nil
     then
         delmyscrbuf
     else
    {$ENDIF}
         {$IFDEF WINDOWS}windows.{$ENDIF}BitBlt(SavedDC,0,0,wh.cx,wh.cy,OffScreedDC,0,0,SRCCOPY);
     isWindowsErrors;
     PState:=TPaintState.TPSBufferSaved;
     InitScreenInvalidrect(wh.cx,wh.cy);
     isWindowsErrors;
end;
procedure TZGLGDIDrawer.RestoreBuffers;
//var i:integer;
begin
     //windows.BitBlt(OffScreedDC,0,0,100,100,SavedDC,0,0,SRCCOPY);
    CorrectScreenInvalidrect(wh.cx,wh.cy);
    //{$IFDEF WINDOWS}windows.{$ENDIF}BitBlt(OffScreedDC,0,0,w,h,SavedDC,0,0,SRCCOPY);
    {$IFDEF WINDOWS}windows.{$ENDIF}BitBlt(OffScreedDC,ScreenInvalidRect.Left,ScreenInvalidRect.Top,ScreenInvalidRect.Right-ScreenInvalidRect.Left+1,ScreenInvalidRect.bottom-ScreenInvalidRect.top+1,SavedDC,ScreenInvalidRect.Left,ScreenInvalidRect.Top,SRCCOPY{WHITENESS});

    {StretchBlt experiments}
    //SetStretchBltMode(OffScreedDC,HALFTONE);
    //SetBrushOrgEx(OffScreedDC, 1, 1, nil);
    //for i:=0 to 1000 do
    //{$IFDEF WINDOWS}windows.{$ENDIF}StretchBlt(OffScreedDC,ScreenInvalidRect.Left-100,ScreenInvalidRect.Top-100,ScreenInvalidRect.Right-ScreenInvalidRect.Left+1+200,ScreenInvalidRect.bottom-ScreenInvalidRect.top+1+200,SavedDC,ScreenInvalidRect.Left,ScreenInvalidRect.Top,ScreenInvalidRect.Right-ScreenInvalidRect.Left+1,ScreenInvalidRect.bottom-ScreenInvalidRect.top+1,SRCCOPY);
    //{$IFDEF WINDOWS}windows.{$ENDIF}StretchBlt(OffScreedDC,ScreenInvalidRect.Left-100,ScreenInvalidRect.Top-100,ScreenInvalidRect.Right-ScreenInvalidRect.Left+1+200,ScreenInvalidRect.bottom-ScreenInvalidRect.top+1+200,SavedDC,ScreenInvalidRect.Left-350,ScreenInvalidRect.Top-350,ScreenInvalidRect.Right-ScreenInvalidRect.Left+1+700,ScreenInvalidRect.bottom-ScreenInvalidRect.top+1+700,SRCCOPY);

    PState:=TPaintState.TPSBufferSaved;
    InitScreenInvalidrect(wh.cx,wh.cy);
     isWindowsErrors;
end;
procedure TZGLGDIDrawer.SwapBuffers;
begin
     //isWindowsErrors;
     //windows.BitBlt({canvas.Handle}CanvasDC,0,0,100,100,OffScreedDC,0,0,SRCCOPY);
     {$IFDEF WINDOWS}windows.{$ENDIF}BitBlt({canvas.Handle}CanvasDC,0,0,wh.cx,wh.cy,OffScreedDC,0,0,SRCCOPY);
     isWindowsErrors;
end;
procedure TZGLGDIDrawer.DrawLine(const PVertexBuffer:PGDBOpenArrayOfData;const i1,i2:TLLVertexIndex);
var
   pv1,pv2:PGDBVertex3S;
   p1,p2:GDBVertex3S;
   x,y:integer;
begin
    pv1:=PGDBVertex3S(PVertexBuffer.getelement(i1));
    pv2:=PGDBVertex3S(PVertexBuffer.getelement(i2));
    p1:=TranslatePointWithLocalCS(pv1^);
    p2:=TranslatePointWithLocalCS(pv2^);
    //canvas.Line(round(p1.x),round(p1.y),round(p2.x),round(p2.y));
    //canvas.Pie(1,1,1,1,
    //              1,1,1,1);
    x:=round(p1.x);
    y:=round(p1.y);
    ProcessScreenInvalidrect(x,y);
    MoveToEx(OffScreedDC,x,y, nil);
    x:=round(p2.x);
    y:=round(p2.y);
    ProcessScreenInvalidrect(x,y);
    LineTo(OffScreedDC,x,y);
end;
procedure TZGLGDIDrawer.DrawTriangle(const PVertexBuffer:PGDBOpenArrayOfData;const i1,i2,i3:TLLVertexIndex);
var
   pv1,pv2,pv3:PGDBVertex3S;
   p1,p2,p3:GDBVertex3S;
   x,y:integer;
   sp:array [1..3]of TPoint;
begin
    pv1:=PGDBVertex3S(PVertexBuffer.getelement(i1));
    pv2:=PGDBVertex3S(PVertexBuffer.getelement(i2));
    pv3:=PGDBVertex3S(PVertexBuffer.getelement(i3));
    p1:=TranslatePointWithLocalCS(pv1^);
    p2:=TranslatePointWithLocalCS(pv2^);
    p3:=TranslatePointWithLocalCS(pv3^);

    sp[1].x:=round(p1.x);
    sp[1].y:=round(p1.y);
    ProcessScreenInvalidrect(sp[1].x,sp[1].y);
    sp[2].x:=round(p2.x);
    sp[2].y:=round(p2.y);
    ProcessScreenInvalidrect(sp[2].x,sp[2].y);
    sp[3].x:=round(p3.x);
    sp[3].y:=round(p3.y);
    ProcessScreenInvalidrect(sp[3].x,sp[3].y);
    PolyGon(OffScreedDC,@sp[1],3,false);
end;
procedure TZGLGDIDrawer.DrawTrianglesFan(const PVertexBuffer,PIndexBuffer:PGDBOpenArrayOfData;const i1,IndexCount:TLLVertexIndex);
var
   i,index:integer;
   pindex:PTLLVertexIndex;

   pv1,pv2,pv3:PGDBVertex3S;
   p1,p2,p3:GDBVertex3S;
   sp:array [1..3]of TPoint;
begin
    index:=i1;
    pindex:=PIndexBuffer.getelement(index);
    pv1:=PGDBVertex3S(PVertexBuffer.getelement(pindex^));
    inc(index);
    pindex:=PIndexBuffer.getelement(index);
    pv2:=PGDBVertex3S(PVertexBuffer.getelement(pindex^));
    inc(index);
    pindex:=PIndexBuffer.getelement(index);
    pv3:=PGDBVertex3S(PVertexBuffer.getelement(pindex^));
    inc(index);

    p1:=TranslatePointWithLocalCS(pv1^);
    p2:=TranslatePointWithLocalCS(pv2^);
    p3:=TranslatePointWithLocalCS(pv3^);

    sp[1].x:=round(p1.x);
    sp[1].y:=round(p1.y);
    ProcessScreenInvalidrect(sp[1].x,sp[1].y);
    sp[2].x:=round(p2.x);
    sp[2].y:=round(p2.y);
    ProcessScreenInvalidrect(sp[2].x,sp[2].y);
    sp[3].x:=round(p3.x);
    sp[3].y:=round(p3.y);
    ProcessScreenInvalidrect(sp[3].x,sp[3].y);

    PolyGon(OffScreedDC,@sp[1],3,false);


    for i:=index to i1+IndexCount-1 do
    begin

        sp[2]:=sp[3];
        pindex:=PIndexBuffer.getelement(i);
        pv3:=PGDBVertex3S(PVertexBuffer.getelement(pindex^));

        p3:=TranslatePointWithLocalCS(pv3^);

        sp[3].x:=round(p3.x);
        sp[3].y:=round(p3.y);
        ProcessScreenInvalidrect(sp[3].x,sp[3].y);

        PolyGon(OffScreedDC,@sp[1],3,false);

    end;
end;
procedure TZGLGDIDrawer.DrawTrianglesStrip(const PVertexBuffer,PIndexBuffer:PGDBOpenArrayOfData;const i1,IndexCount:TLLVertexIndex);
var
   i,index:integer;
   pindex:PTLLVertexIndex;

   pv1,pv2,pv3:PGDBVertex3S;
   p1,p2,p3:GDBVertex3S;
   sp:array [1..3]of TPoint;
begin
    index:=i1;
    pindex:=PIndexBuffer.getelement(index);
    pv1:=PGDBVertex3S(PVertexBuffer.getelement(pindex^));
    inc(index);
    pindex:=PIndexBuffer.getelement(index);
    pv2:=PGDBVertex3S(PVertexBuffer.getelement(pindex^));
    inc(index);
    pindex:=PIndexBuffer.getelement(index);
    pv3:=PGDBVertex3S(PVertexBuffer.getelement(pindex^));
    inc(index);

    p1:=TranslatePointWithLocalCS(pv1^);
    p2:=TranslatePointWithLocalCS(pv2^);
    p3:=TranslatePointWithLocalCS(pv3^);

    sp[1].x:=round(p1.x);
    sp[1].y:=round(p1.y);
    ProcessScreenInvalidrect(sp[1].x,sp[1].y);
    sp[2].x:=round(p2.x);
    sp[2].y:=round(p2.y);
    ProcessScreenInvalidrect(sp[2].x,sp[2].y);
    sp[3].x:=round(p3.x);
    sp[3].y:=round(p3.y);
    ProcessScreenInvalidrect(sp[3].x,sp[3].y);

    PolyGon(OffScreedDC,@sp[1],3,false);


    for i:=index to i1+IndexCount-1 do
    begin

        sp[1]:=sp[2];
        sp[2]:=sp[3];
        pindex:=PIndexBuffer.getelement(i);
        pv3:=PGDBVertex3S(PVertexBuffer.getelement(pindex^));

        p3:=TranslatePointWithLocalCS(pv3^);

        sp[3].x:=round(p3.x);
        sp[3].y:=round(p3.y);
        ProcessScreenInvalidrect(sp[3].x,sp[3].y);

        PolyGon(OffScreedDC,@sp[1],3,false);

    end;
end;
procedure TZGLGDIDrawer.DrawQuad(const PVertexBuffer:PGDBOpenArrayOfData;const i1,i2,i3,i4:TLLVertexIndex);var
   pv1,pv2,pv3,pv4:PGDBVertex3S;
   p1,p2,p3,p4:GDBVertex3S;
   x,y:integer;
   sp:array [1..4]of TPoint;
begin
    pv1:=PGDBVertex3S(PVertexBuffer.getelement(i1));
    pv2:=PGDBVertex3S(PVertexBuffer.getelement(i2));
    pv3:=PGDBVertex3S(PVertexBuffer.getelement(i3));
    pv4:=PGDBVertex3S(PVertexBuffer.getelement(i4));
    p1:=TranslatePointWithLocalCS(pv1^);
    p2:=TranslatePointWithLocalCS(pv2^);
    p3:=TranslatePointWithLocalCS(pv3^);
    p4:=TranslatePointWithLocalCS(pv4^);

    sp[1].x:=round(p1.x);
    sp[1].y:=round(p1.y);
    ProcessScreenInvalidrect(sp[1].x,sp[1].y);
    sp[2].x:=round(p2.x);
    sp[2].y:=round(p2.y);
    ProcessScreenInvalidrect(sp[2].x,sp[2].y);
    sp[3].x:=round(p3.x);
    sp[3].y:=round(p3.y);
    ProcessScreenInvalidrect(sp[3].x,sp[3].y);
    sp[4].x:=round(p4.x);
    sp[4].y:=round(p4.y);
    ProcessScreenInvalidrect(sp[4].x,sp[4].y);
    PolyGon(OffScreedDC,@sp[1],4,false);
end;
function TZGLGDIDrawer.CheckOutboundInDisplay(const PVertexBuffer:PGDBOpenArrayOfData;const i1:TLLVertexIndex):boolean;
var
pv1,pv2,pv3,pv4:PGDBVertex3S;
p1,p2,p3,p4:GDBVertex3S;
l,r,t,b:integer;

procedure checkpointoutsidedisplay(const p:GDBVertex3S);
begin
     if (p.x<drawrect.Left)then
                               inc(l);
     if (p.x>drawrect.Right)then
                               inc(r);
     if (p.y<drawrect.Top)then
                               inc(t);
     if (p.y>drawrect.Bottom)then
                               inc(b);
end;

begin
 pv1:=PGDBVertex3S(PVertexBuffer.getelement(i1));
 pv2:=PGDBVertex3S(PVertexBuffer.getelement(i1+1));
 pv3:=PGDBVertex3S(PVertexBuffer.getelement(i1+2));
 pv4:=PGDBVertex3S(PVertexBuffer.getelement(i1+3));
 p1:=TranslatePoint{WithLocalCS}(pv1^);
 p2:=TranslatePoint{WithLocalCS}(pv2^);
 p3:=TranslatePoint{WithLocalCS}(pv3^);
 p4:=TranslatePoint{WithLocalCS}(pv4^);

 l:=0;
 r:=0;
 t:=0;
 b:=0;

 checkpointoutsidedisplay(p1);
 checkpointoutsidedisplay(p2);
 checkpointoutsidedisplay(p3);
 checkpointoutsidedisplay(p4);

 if (l=4)or(r=4)or(t=4)or(b=4)then
                                  result:=false
                              else
                                  result:=true;
end;
procedure TZGLGDIDrawer.DrawPoint(const PVertexBuffer:PGDBOpenArrayOfData;const i:TLLVertexIndex);
var
   pv:PGDBVertex3S;
   p:GDBVertex3S;
begin
    pv:=PGDBVertex3S(PVertexBuffer.getelement(i));
    p:=TranslatePointWithLocalCS(pv^);
    //Canvas.Pixels[round(pv.x),round(pv.y)]:=canvas.Pen.Color;
end;
procedure TZGLGDIDrawer.DrawLine3DInModelSpace(const p1,p2:gdbvertex;var matrixs:tmatrixs);
var
   pp1,pp2:GDBVertex;
   x,y:integer;
begin
     //_myGluProject(const objx,objy,objz:GDBdouble;const modelMatrix,projMatrix:PDMatrix4D;const viewport:PIMatrix4; out winx,winy,winz:GDBdouble):Integer;
    _myGluProject2(p1,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp1);
    _myGluProject2(p2,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp2);
     {pp1:=geometry.VectorTransform3D(p1,matrixs.pprojMatrix^);
     pp1:=geometry.VectorTransform3D(pp1,matrixs.pmodelMatrix^);

     pp2:=geometry.VectorTransform3D(p2,matrixs.pprojMatrix^);
     pp2:=geometry.VectorTransform3D(pp2,matrixs.pmodelMatrix^);}

     //canvas.Line(round(pp1.x),h-round(pp1.y),round(pp2.x),h-round(pp2.y));

     x:=round(pp1.x);
     y:=round(wh.cy-pp1.y);
     ProcessScreenInvalidrect(x,y);
     MoveToEx(OffScreedDC,x,y,nil);

     x:=round(pp2.x);
     y:=round(wh.cy-pp2.y);
     ProcessScreenInvalidrect(x,y);
     LineTo(OffScreedDC,x,y);
end;
procedure TZGLGDIDrawer.SetPointSize(const s:single);
begin
     PointSize:=s;
end;

procedure TZGLGDIDrawer.DrawPoint3DInModelSpace(const p:gdbvertex;var matrixs:tmatrixs);
var
   pp:GDBVertex;
   ps:integer;
   x,y:integer;
begin
    _myGluProject2(p,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp);
     {pp1:=geometry.VectorTransform3D(p1,matrixs.pprojMatrix^);
     pp1:=geometry.VectorTransform3D(pp1,matrixs.pmodelMatrix^);

     pp2:=geometry.VectorTransform3D(p2,matrixs.pprojMatrix^);
     pp2:=geometry.VectorTransform3D(pp2,matrixs.pmodelMatrix^);}

     //canvas.Line(round(pp1.x),h-round(pp1.y),round(pp2.x),h-round(pp2.y));

     ps:=round(PointSize/2);

     x:=round(pp.x);
     y:=round(wh.cy-pp.y);
     ProcessScreenInvalidrect(x,y);
     Rectangle(OffScreedDC, x-ps, y-ps, x+ps,y+ps);
end;
procedure TZGLGDIDrawer.DrawTriangle3DInModelSpace(const normal,p1,p2,p3:gdbvertex;var matrixs:tmatrixs);
var
   pp1,pp2,pp3:GDBVertex;
   sp:array [1..3]of TPoint;
begin
    _myGluProject2(p1,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp1);
    _myGluProject2(p2,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp2);
    _myGluProject2(p3,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp3);

     sp[1].x:=round(pp1.x);
     sp[1].y:=round(wh.cy-pp1.y);
     sp[2].x:=round(pp2.x);
     sp[2].y:=round(wh.cy-pp2.y);
     sp[3].x:=round(pp3.x);
     sp[3].y:=round(wh.cy-pp3.y);

     PolyGon(OffScreedDC,@sp[1],3,false);
     ProcessScreenInvalidrect(sp[1].x,sp[1].y);
     ProcessScreenInvalidrect(sp[2].x,sp[2].y);
     ProcessScreenInvalidrect(sp[3].x,sp[3].y);
end;
procedure TZGLGDIDrawer.DrawQuad3DInModelSpace(const p1,p2,p3,p4:gdbvertex;var matrixs:tmatrixs);
var
   pp1,pp2,pp3,pp4:GDBVertex;
   sp:array [1..4]of TPoint;
begin
    _myGluProject2(p1,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp1);
    _myGluProject2(p2,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp2);
    _myGluProject2(p3,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp3);
    _myGluProject2(p4,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp4);

     sp[1].x:=round(pp1.x);
     sp[1].y:=round(wh.cy-pp1.y);
     sp[2].x:=round(pp2.x);
     sp[2].y:=round(wh.cy-pp2.y);
     sp[3].x:=round(pp3.x);
     sp[3].y:=round(wh.cy-pp3.y);
     sp[4].x:=round(pp4.x);
     sp[4].y:=round(wh.cy-pp4.y);

     //PolyGon(OffScreedDC,@sp[1],4,false);
     PolyGon(OffScreedDC,@sp[1],3,false);
     PolyGon(OffScreedDC,@sp[2],3,false);
     ProcessScreenInvalidrect(sp[1].x,sp[1].y);
     ProcessScreenInvalidrect(sp[2].x,sp[2].y);
     ProcessScreenInvalidrect(sp[3].x,sp[3].y);
     ProcessScreenInvalidrect(sp[4].x,sp[4].y);
end;
procedure TZGLGDIDrawer.DrawQuad3DInModelSpace(const normal,p1,p2,p3,p4:gdbvertex;var matrixs:tmatrixs);
begin
     DrawQuad3DInModelSpace(p1,p2,p3,p4,matrixs);
end;
procedure TZGLGDIDrawer.SetClearColor(const red, green, blue, alpha: byte);
begin
     ClearColor:=RGB(red,green,blue);
end;
procedure TZGLGDIDrawer._createPen;
var
   ps:integer;
begin
  deleteobject(hLinePen);
  deleteobject(hBrush);

  case penstyle of
              TPS_Solid:
                        ps:=PS_SOLID;
              TPS_Dot:
                      ps:=PS_DOT;
              TPS_Dash:
                       ps:=PS_DASH;
          TPS_Selected:
                       ps:=PS_DOT;
  end;
  SetBkColor(OffScreedDC,ClearColor);
  hLinePen:=CreatePen(ps,linewidth,PenColor);

  SelectObject(OffScreedDC, hLinePen);


  hBrush:=CreateSolidBrush(PenColor);
  SelectObject(OffScreedDC, hBrush);
end;

procedure TZGLGDIDrawer.SetColor(const red, green, blue, alpha: byte);
var
   oldColor:TColor;
begin
     oldColor:=PenColor;
     PenColor:=RGB(red,green,blue);
     if oldColor<>PenColor then
     begin
         _createPen;
     end;
end;
procedure TZGLGDIDrawer.SetLineWidth(const w:single);
var
   oldlinewidth:integer;
begin
     oldlinewidth:=linewidth;
     linewidth:=round(w);
     if oldlinewidth<>linewidth then
     begin
         _createPen;
     end;
end;
procedure TZGLGDIDrawer.SetColor(const color: TRGB);
begin
     SetColor(color.r,color.g,color.b,255);
end;
procedure TZGLGDIDrawer.ClearScreen(stencil:boolean);
var
  mRect: TRect;
  ClearBrush: HBRUSH;
  LogBrush: TLogBrush;
begin
     mrect:=Rect(0,0,wh.cx,wh.cy);
     with LogBrush do
     begin
       lbStyle := {BS_HATCHED}BS_SOLID;
       lbColor := ClearColor;
       lbHatch := HS_CROSS
     end;
     ClearBrush:=CreateBrushIndirect(LogBrush);
     isWindowsErrors;
     FillRect(OffScreedDC,mRect,ClearBrush);
     isWindowsErrors;
     deleteobject(ClearBrush);
     isWindowsErrors;
end;
procedure TZGLGDIDrawer.InitScreenInvalidrect;
begin
     ScreenInvalidRect.Left:=w;
     ScreenInvalidRect.Right:=0;
     ScreenInvalidRect.Top:=h;
     ScreenInvalidRect.Bottom:=0;
end;
procedure TZGLGDIDrawer.CorrectScreenInvalidrect;
begin
     if ScreenInvalidRect.Left<0 then ScreenInvalidRect.Left:=0;
     if ScreenInvalidRect.Right>w then ScreenInvalidRect.Right:=w;
     if ScreenInvalidRect.Top<0 then ScreenInvalidRect.Top:=0;
     if ScreenInvalidRect.Bottom>h then ScreenInvalidRect.Bottom:=h;
end;

procedure TZGLGDIDrawer.ProcessScreenInvalidrect(const x,y:integer);
begin
     if PState=TPSBufferSaved then
     begin
         if ScreenInvalidRect.Left>x then ScreenInvalidRect.Left:=x;
         if ScreenInvalidRect.Right<x then ScreenInvalidRect.Right:=x;
         if ScreenInvalidRect.Top>y then ScreenInvalidRect.Top:=y;
         if ScreenInvalidRect.Bottom<y then ScreenInvalidRect.Bottom:=y;
     end;
end;
procedure TZGLGDIDrawer.DrawDebugGeometry;
begin
     exit;
     CorrectScreenInvalidrect(wh.cx,wh.cy);
     DrawLine2DInDCS(ScreenInvalidRect.Left,ScreenInvalidRect.top,ScreenInvalidRect.right,ScreenInvalidRect.bottom);
     DrawLine2DInDCS(ScreenInvalidRect.right,ScreenInvalidRect.top,ScreenInvalidRect.left,ScreenInvalidRect.bottom);
end;
procedure TZGLGDIDrawer.DrawLine2DInDCS(const x1,y1,x2,y2:integer);
var
   x,y:integer;
begin
     x:=round(x1*sx+tx);
     y:=round(y1*sy+ty);
     ProcessScreenInvalidrect(x,y);

     MoveToEx(OffScreedDC,x,y, nil);

     x:=round(x2*sx+tx);
     y:=round(y2*sy+ty);
     ProcessScreenInvalidrect(x,y);

     LineTo(OffScreedDC,x,y);
end;
procedure TZGLGDIDrawer.DrawLine2DInDCS(const x1,y1,x2,y2:single);
var
   x,y:integer;
begin
     x:=round(x1*sx+tx);
     y:=round(y1*sy+ty);
     ProcessScreenInvalidrect(x,y);

     MoveToEx(OffScreedDC,x,y, nil);

     x:=round(x2*sx+tx);
     y:=round(y2*sy+ty);
     ProcessScreenInvalidrect(x,y);

     LineTo(OffScreedDC,x,y);
end;
procedure TZGLGDIDrawer.DrawClosedPolyLine2DInDCS(const coords:array of single);
var
   i:integer;
   x,y:integer;
begin
     x:=round(coords[0]*sx+tx);
     y:=round(coords[1]*sy+ty);
     ProcessScreenInvalidrect(x,y);
     MoveToEx(OffScreedDC,x,y, nil);

     i:=2;
     while i<length(coords) do
     begin
     x:=round(coords[i]*sx+tx);
     y:=round(coords[i+1]*sy+ty);
     ProcessScreenInvalidrect(x,y);
     LineTo(OffScreedDC,x,y);
     inc(i,2);
     end;
     LineTo(OffScreedDC,round(coords[0]*sx+tx),round(coords[1]*sy+ty));
end;
function TZGLGDIDrawer.GetLLPrimitivesCreator:TLLPrimitivesCreatorAbstract;
begin
     result:=LLGDIPrimitivesCreator;
end;
function TLLGDIPrimitivesCreator.CreateLLSymbol(var pa:GDBOpenArrayOfData):TArrayIndex;
var
   pgdisymbol:PTLLGDISymbol;
begin
     result:=pa.count;
     pgdisymbol:=pa.AllocData(sizeof(TLLGDISymbol));
     pgdisymbol.init;
end;
procedure TLLGDISymbol.drawSymbol(drawer:TZGLAbstractDrawer;var rc:TDrawContext;var GeomData:ZGLGeomData;var LLPArray:GDBOpenArrayOfData;var OptData:ZGLOptimizerData);
begin
  inherited;
  //TextOut(TZGLGDIDrawer(drawer).OffScreedDC, 100, 100, 'h', 1);
end;

initialization
  {$IFDEF DEBUGINITSECTION}LogOut('uzglgdidrawer.initialization');{$ENDIF}
  CanvasDrawer:=TZGLGDIDrawer.create;
  LLGDIPrimitivesCreator:=TLLGDIPrimitivesCreator.Create;
  {$IFDEF WINDOWS}GDIPlusDrawer:=TZGLGDIPlusDrawer.create;{$ENDIF}
finalization
   CanvasDrawer.Destroy;
   LLGDIPrimitivesCreator.Destroy;
  {$IFDEF WINDOWS}GDIPlusDrawer.Destroy;{$ENDIF}
end.

