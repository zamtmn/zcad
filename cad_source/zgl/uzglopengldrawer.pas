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

unit uzglopengldrawer;
{$INCLUDE def.inc}
interface
uses
    {$IFDEF WINDOWS}GDIPAPI,GDIPOBJ,windows,{$ENDIF}
    LCLIntf,LCLType,Classes,Controls,
    geometry,uzglabstractdrawer,UGDBOpenArrayOfData,uzgprimitivessarray,OGLSpecFunc,Graphics,gdbase;
const
  texturesize=256;
type
TZGLOpenGLDrawer=class(TZGLGeneralDrawer)
                        myscrbuf:tmyscrbuf;
                        public
                        procedure startrender;override;
                        procedure endrender;override;
                        procedure DrawLine(const i1:TLLVertexIndex);override;
                        procedure DrawPoint(const i:TLLVertexIndex);override;
                        procedure SetLineWidth(const w:single);override;
                        procedure SetPointSize(const s:single);override;
                        procedure SetColor(const red, green, blue, alpha: byte);overload;override;
                        procedure SetColor(const color: TRGB);overload;override;
                        procedure SetClearColor(const red, green, blue, alpha: byte);overload;override;
                        procedure ClearScreen(stencil:boolean);override;
                        procedure TranslateCoord2D(const tx,ty:single);override;
                        procedure ScaleCoord2D(const sx,sy:single);override;
                        procedure SetLineSmooth(const smoth:boolean);override;
                        procedure SetPointSmooth(const smoth:boolean);override;
                        procedure ClearStatesMachine;override;
                        procedure SetFillStencilMode;override;
                        procedure SetDrawWithStencilMode;override;
                        procedure DisableStencil;override;
                        procedure SetZTest(Z:boolean);override;
                        procedure SetDisplayCSmode(const width, height:integer);override;
                        {в координатах окна}
                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:integer);override;
                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:single);override;
                        procedure DrawClosedPolyLine2DInDCS(const coords:array of single);override;
                        {в координатах модели}
                        procedure DrawLine3DInModelSpace(const p1,p2:gdbvertex;var matrixs:tmatrixs);override;
                        procedure SaveBuffers(w,h:integer);override;
                        procedure RestoreBuffers(w,h:integer);override;
                        procedure CreateScrbuf(w,h:integer); override;
                        procedure delmyscrbuf; override;
                   end;
TZGLCanvasDrawer=class(TZGLGeneralDrawer)
                        public
                        canvas:tcanvas;
                        panel:TCustomControl;
                        midline:integer;
                        sx,sy,tx,ty:single;
                        ClearColor: TColor;
                        OffScreedDC:HDC;
                        CanvasDC:HDC;
                        OffscreenBitmap:HBITMAP;
                        SavedBitmap:HBITMAP;
                        SavedDC:HDC;
                        ClearBrush: HBRUSH;
                        hLinePen:HPEN;
                        constructor create;
                        procedure startpaint;override;
                        procedure endpaint;override;

                        function TranslatePoint(const p:GDBVertex3S):GDBVertex3S;
                        procedure DrawLine(const i1:TLLVertexIndex);override;
                        procedure DrawPoint(const i:TLLVertexIndex);override;

                        procedure DrawLine3DInModelSpace(const p1,p2:gdbvertex;var matrixs:tmatrixs);override;

                        procedure ClearScreen(stencil:boolean);override;
                        procedure SetClearColor(const red, green, blue, alpha: byte);overload;override;
                        procedure SetColor(const red, green, blue, alpha: byte);overload;override;
                        procedure SetColor(const color: TRGB);overload;override;
                        procedure SetDisplayCSmode(const width, height:integer);override;
                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:integer);override;
                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:single);override;

                        procedure CreateScrbuf(w,h:integer); override;
                        procedure delmyscrbuf; override;
                        procedure SaveBuffers(w,h:integer);override;
                        procedure RestoreBuffers(w,h:integer);override;


                   end;
{$IFDEF WINDOWS}
TZGLGDIPlusDrawer=class(TZGLCanvasDrawer)
                        graphicsGDIPlus:TGPGraphics;
                        pen: TGPPen;
                        HDC: HDC;
                        lpPaint: TPaintStruct;
                        public
                        procedure startrender;override;
                        procedure endrender;override;
                        procedure DrawLine(const i1:TLLVertexIndex);override;
                        procedure DrawPoint(const i:TLLVertexIndex);override;
                   end;
{$ENDIF}
var
   OGLDrawer:TZGLAbstractDrawer;
   CanvasDrawer:TZGLCanvasDrawer;
   {$IFDEF WINDOWS}GDIPlusDrawer:TZGLGDIPlusDrawer;{$ENDIF}
implementation
uses log;
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

procedure TZGLGDIPlusDrawer.DrawLine(const i1:TLLVertexIndex);
var
   pv1,pv2:PGDBVertex3S;
begin
    pv1:=PGDBVertex3S(PVertexBuffer.getelement(i1));
    pv2:=PGDBVertex3S(PVertexBuffer.getelement(i1+1));
    graphicsGDIPlus.DrawLine(Pen,pv1.x,midline-pv1.y,pv2.x,midline-pv2.y);
end;

procedure TZGLGDIPlusDrawer.DrawPoint(const i:TLLVertexIndex);
var
   pv:PGDBVertex3S;
begin
     pv:=PGDBVertex3S(PVertexBuffer.getelement(i));
     //graphicsGDIPlus.Drawpoint(Pen,pv.x,midline-pv.y);
end;
{$ENDIF}
procedure TZGLOpenGLDrawer.DrawLine(const i1:TLLVertexIndex);
begin
    oglsm.myglbegin(GL_LINES);
    oglsm.myglVertex3fV(PVertexBuffer.getelement(i1));
    oglsm.myglVertex3fV(PVertexBuffer.getelement(i1+1));
    oglsm.myglend;
end;

procedure TZGLOpenGLDrawer.DrawPoint(const i:TLLVertexIndex);
begin
    oglsm.myglbegin(GL_points);
    oglsm.myglVertex3fV(PVertexBuffer.getelement(i));
    oglsm.myglend;
end;
procedure TZGLOpenGLDrawer.TranslateCoord2D(const tx,ty:single);
begin
     oglsm.mygltranslated(tx, ty,0);
end;
procedure TZGLOpenGLDrawer.ScaleCoord2D(const sx,sy:single);
begin
     oglsm.myglscalef(sx,sy,1);
end;
procedure TZGLOpenGLDrawer.SetLineSmooth(const smoth:boolean);
begin
     if smoth then
                 begin
                      oglsm.myglEnable(GL_BLEND);
                      oglsm.myglBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
                      oglsm.myglEnable(GL_LINE_SMOOTH);
                      oglsm.myglHint(GL_LINE_SMOOTH_HINT,GL_NICEST);
                 end
             else
                 begin
                      oglsm.myglDisable(GL_BLEND);
                      oglsm.myglDisable(GL_LINE_SMOOTH);
                 end;
end;
procedure TZGLOpenGLDrawer.SetPointSmooth(const smoth:boolean);
begin
     if smoth then
                 begin
                      oglsm.myglEnable(gl_point_smooth);
                 end
             else
                 begin
                      oglsm.myglDisable(gl_point_smooth);
                 end;
end;
procedure TZGLOpenGLDrawer.ClearStatesMachine;
begin
     oglsm.mytotalglend;
end;
procedure TZGLOpenGLDrawer.SetFillStencilMode;
begin
     oglsm.myglEnable(GL_STENCIL_TEST);
     oglsm.myglStencilFunc(GL_NEVER, 1, 0); // значение mask не используется
     oglsm.myglStencilOp(GL_REPLACE, GL_KEEP, GL_KEEP);
end;
procedure TZGLOpenGLDrawer.SetDrawWithStencilMode;
begin
    oglsm.myglEnable(GL_STENCIL_TEST);
    oglsm.myglStencilFunc(GL_EQUAL,0,1);
    oglsm.myglStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
end;
procedure TZGLOpenGLDrawer.DisableStencil;
begin
     oglsm.myglDisable(GL_STENCIL_TEST);
end;
procedure TZGLOpenGLDrawer.SetZTest(Z:boolean);
begin
     if Z then
             begin
                  oglsm.myglEnable(GL_DEPTH_TEST);
             end
         else
             begin
                  oglsm.myglDisable(GL_DEPTH_TEST);
             end;
end;
procedure TZGLOpenGLDrawer.startrender;
begin
     OGLSM.startrender;
end;
procedure TZGLOpenGLDrawer.endrender;
begin
     OGLSM.endrender;
end;
procedure TZGLOpenGLDrawer.SetColor(const red, green, blue, alpha: byte);
begin
     oglsm.glcolor3ub(red, green, blue);
end;
procedure TZGLOpenGLDrawer.ClearScreen(stencil:boolean);
begin
     if stencil then
                    oglsm.myglClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT)
                else
                    oglsm.myglClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
end;
procedure TZGLOpenGLDrawer.SetColor(const color: TRGB);
begin
     oglsm.glcolor3ubv(color);
end;
procedure TZGLOpenGLDrawer.SetClearColor(const red, green, blue, alpha: byte);
begin
     oglsm.myglClearColor(red/255,green/255,blue/255,alpha/255);
end;
procedure TZGLOpenGLDrawer.SetLineWidth(const w:single);
begin
     oglsm.mygllinewidth(w);
end;
procedure TZGLOpenGLDrawer.SetPointSize(const s:single);
begin
     oglsm.myglpointsize(s);
end;
procedure TZGLOpenGLDrawer.DrawLine2DInDCS(const x1,y1,x2,y2:integer);
begin
    oglsm.myglbegin(GL_lines);
              oglsm.myglVertex2i(x1,y1);
              oglsm.myglVertex2i(x2,y2);
    oglsm.myglend;
end;
procedure TZGLOpenGLDrawer.DrawLine2DInDCS(const x1,y1,x2,y2:single);
begin
    oglsm.myglbegin(GL_lines);
              oglsm.myglVertex2f(x1,y1);
              oglsm.myglVertex2f(x2,y2);
    oglsm.myglend;
end;
procedure TZGLOpenGLDrawer.DrawClosedPolyLine2DInDCS(const coords:array of single);
var
   i:integer;
begin
     i:=0;
     oglsm.myglbegin(GL_line_loop);
     while i<high(coords) do
     begin
          oglsm.myglVertex2f(coords[i],coords[i+1]);
          inc(i,2);
     end;
     oglsm.myglend;
end;
procedure TZGLOpenGLDrawer.SaveBuffers;
  var
    scrx,scry,texture{,e}:integer;
begin
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.SaveBuffers',lp_incPos);{$ENDIF};
  oglsm.myglEnable(GL_TEXTURE_2D);
  //isOpenGLError;

   scrx:=0;
   scry:=0;
   texture:=0;
   repeat
         repeat
               oglsm.myglbindtexture(GL_TEXTURE_2D,myscrbuf[texture]);
               //isOpenGLError;
               oglsm.myglCopyTexSubImage2D(GL_TEXTURE_2D,0,0,0,scrx,scry,texturesize,texturesize);
               //isOpenGLError;
               scrx:=scrx+texturesize;
               inc(texture);
         until scrx>w;
   scrx:=0;
   scry:=scry+texturesize;
   until scry>h;


  oglsm.myglDisable(GL_TEXTURE_2D);
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.SaveBuffers----{end}',lp_decPos);{$ENDIF}
end;
procedure TZGLOpenGLDrawer.RestoreBuffers;
  var
    scrx,scry,texture{,e}:integer;
    _NotUseLCS:boolean;
begin
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.RestoreBuffers',lp_incPos);{$ENDIF};
  _NotUseLCS:=NotUseLCS;
  NotUseLCS:=true;
  oglsm.myglEnable(GL_TEXTURE_2D);
  oglsm.myglDisable(GL_DEPTH_TEST);
       oglsm.myglMatrixMode(GL_PROJECTION);
       oglsm.myglPushMatrix;
       oglsm.myglLoadIdentity;
       oglsm.myglOrtho(0.0, w, 0.0, h, -10.0, 10.0);
       oglsm.myglMatrixMode(GL_MODELVIEW);
       oglsm.myglPushMatrix;
       oglsm.myglLoadIdentity;
  begin
   scrx:=0;
   scry:=0;
   texture:=0;
   repeat
   repeat
         oglsm.myglbindtexture(GL_TEXTURE_2D,myscrbuf[texture]);
         //isOpenGLError;
         SetColor(255,255,255,255);
         oglsm.myglbegin(GL_quads);
                 oglsm.myglTexCoord2d(0,0);
                 oglsm.myglVertex2d(scrx,scry);
                 oglsm.myglTexCoord2d(1,0);
                 oglsm.myglVertex2d(scrx+texturesize,scry);
                 oglsm.myglTexCoord2d(1,1);
                 oglsm.myglVertex2d(scrx+texturesize,scry+texturesize);
                 oglsm.myglTexCoord2d(0,1);
                 oglsm.myglVertex2d(scrx,scry+texturesize);
         oglsm.myglend;
         oglsm.mytotalglend;
         //isOpenGLError;
         scrx:=scrx+texturesize;
         inc(texture);
   until scrx>w;
   scrx:=0;
   scry:=scry+texturesize;
   until scry>h;
  end;
  oglsm.myglDisable(GL_TEXTURE_2D);
       oglsm.myglPopMatrix;
       oglsm.myglMatrixMode(GL_PROJECTION);
       oglsm.myglPopMatrix;
       oglsm.myglMatrixMode(GL_MODELVIEW);
   NotUseLCS:=_NotUseLCS;
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.RestoreBuffers----{end}',lp_decPos);{$ENDIF}
end;
procedure TZGLOpenGLDrawer.CreateScrbuf(w,h:integer);
var scrx,scry,texture{,e}:integer;
begin
     //oglsm.mytotalglend;

     oglsm.myglEnable(GL_TEXTURE_2D);
     scrx:=0;  { TODO : Сделать генер текстур пакетом }
     scry:=0;
     texture:=0;
     repeat
           repeat
                 //if texture>80 then texture:=0;

                 oglsm.myglGenTextures(1, @myscrbuf[texture]);
                 //isOpenGLError;
                 oglsm.myglbindtexture(GL_TEXTURE_2D,myscrbuf[texture]);
                 //isOpenGLError;
                 oglsm.myglTexImage2D(GL_TEXTURE_2D,0,GL_RGB,texturesize,texturesize,0,GL_RGB,GL_UNSIGNED_BYTE,@TZGLOpenGLDrawer.CreateScrbuf);
                 //isOpenGLError;
                 oglsm.myglTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
                 //isOpenGLError;
                 oglsm.myglTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
                 //isOpenGLError;
                 scrx:=scrx+texturesize;
                 inc(texture);
           until scrx>w;
           scrx:=0;
           scry:=scry+texturesize;
     until scry>h;
     oglsm.myglDisable(GL_TEXTURE_2D);
end;
procedure TZGLOpenGLDrawer.delmyscrbuf;
var i:integer;
begin
     for I := 0 to high(tmyscrbuf) do
       begin
             if myscrbuf[i]<>0 then
                                   oglsm.mygldeletetextures(1,@myscrbuf[i]);
             myscrbuf[i]:=0;
       end;

end;

procedure TZGLOpenGLDrawer.DrawLine3DInModelSpace(const p1,p2:gdbvertex;var matrixs:tmatrixs);
begin
     oglsm.myglbegin(GL_LINES);
      oglsm.myglVertex3dv(@p1);
      oglsm.myglVertex3dv(@p2);
     oglsm.myglend;
end;
procedure TZGLOpenGLDrawer.SetDisplayCSmode(const width, height:integer);
begin
     oglsm.myglMatrixMode(GL_PROJECTION);
     oglsm.myglLoadIdentity;
     oglsm.myglOrtho(0.0, width, height, 0.0, -1.0, 1.0);
     oglsm.myglMatrixMode(GL_MODELVIEW);
     oglsm.myglLoadIdentity;
     oglsm.myglscalef(1, -1, 1);
     oglsm.myglpushmatrix;
     oglsm.mygltranslated(0, -height, 0);
end;

constructor TZGLCanvasDrawer.create;
begin
     sx:=0.1;
     sy:=-0.1;
     tx:=0;
     ty:=400;
     SavedBitmap:=0;
end;
procedure TZGLCanvasDrawer.startpaint;
var
  LogBrush: TLogBrush;
  mRect: TRect;
begin
     CanvasDC:=GetDC({canvas}panel.Handle);
     OffScreedDC:=CreateCompatibleDC(CanvasDC);
     OffscreenBitmap:=CreateCompatibleBitmap(CanvasDC,canvas.Width,canvas.Height);
     SelectObject(OffScreedDC,OffscreenBitmap);
     with LogBrush do
     begin
       lbStyle := {BS_HATCHED}BS_SOLID;
       lbColor := clBlue;
       lbHatch := HS_CROSS
     end;
     mrect:=Rect(0,0,canvas.Width,canvas.Height);
     ClearBrush:=CreateBrushIndirect(LogBrush);
     //FillRect(OffScreedDC,mRect,ClearBrush);

     hLinePen:=CreatePen(PS_SOLID, 1, RGB(255, 255, 255));
     SelectObject(OffScreedDC, hLinePen);
     CreateScrbuf(canvas.Width,canvas.Height)
end;
procedure TZGLCanvasDrawer.endpaint;
begin
     BitBlt({canvas.Handle}CanvasDC,0,0,canvas.Width,canvas.Height,OffScreedDC,0,0,SRCCOPY);
     DeleteObject(OffscreenBitmap);
     DeleteObject(hLinePen);
     ReleaseDC(canvas.Handle,CanvasDC);
     DeleteDC(OffScreedDC);
end;
procedure TZGLCanvasDrawer.CreateScrbuf(w,h:integer);
begin
     if SavedBitmap=0 then
     begin
          SavedDC:=CreateCompatibleDC(CanvasDC);
          SavedBitmap:=CreateCompatibleBitmap(SavedDC,w,h);
          SelectObject(SavedDC,SavedBitmap);
     end;
end;
procedure TZGLCanvasDrawer.delmyscrbuf;
begin
     DeleteObject(SavedBitmap);
     DeleteDC(SavedDC);
     SavedBitmap:=0;
     SavedDC:=0;
end;
procedure TZGLCanvasDrawer.SaveBuffers(w,h:integer);
begin
     BitBlt(SavedDC,0,0,w,h,OffScreedDC,0,0,SRCCOPY);
end;
procedure TZGLCanvasDrawer.RestoreBuffers(w,h:integer);
var
  code:integer;
begin
     BitBlt(OffScreedDC,0,0,w,h,SavedDC,0,0,SRCCOPY);
     code:=GetLastError
end;
function TZGLCanvasDrawer.TranslatePoint(const p:GDBVertex3S):GDBVertex3S;
begin
     result.x:=p.x*sx+tx;
     result.y:=p.y*sy+ty;
     result.z:=p.z;
end;

procedure TZGLCanvasDrawer.DrawLine(const i1:TLLVertexIndex);
var
   pv1,pv2:PGDBVertex3S;
   p1,p2:GDBVertex3S;
begin
    pv1:=PGDBVertex3S(PVertexBuffer.getelement(i1));
    pv2:=PGDBVertex3S(PVertexBuffer.getelement(i1+1));
    p1:=TranslatePoint(pv1^);
    p2:=TranslatePoint(pv2^);
    //canvas.Line(round(p1.x),round(p1.y),round(p2.x),round(p2.y));
    MoveToEx(OffScreedDC, round(p1.x),round(p1.y), nil);
    LineTo(OffScreedDC, round(p2.x),round(p2.y));
end;

procedure TZGLCanvasDrawer.DrawPoint(const i:TLLVertexIndex);
var
   pv:PGDBVertex3S;
   p:GDBVertex3S;
begin
    pv:=PGDBVertex3S(PVertexBuffer.getelement(i));
    p:=TranslatePoint(pv^);
    Canvas.Pixels[round(pv.x),round(pv.y)]:=canvas.Pen.Color;
end;
procedure TZGLCanvasDrawer.DrawLine3DInModelSpace(const p1,p2:gdbvertex;var matrixs:tmatrixs);
var
   pp1,pp2:GDBVertex;
   h:integer;
begin
     //_myGluProject(const objx,objy,objz:GDBdouble;const modelMatrix,projMatrix:PDMatrix4D;const viewport:PIMatrix4; out winx,winy,winz:GDBdouble):Integer;
    _myGluProject2(p1,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp1);
    _myGluProject2(p2,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp2);
    h:=canvas.Height;
     {pp1:=geometry.VectorTransform3D(p1,matrixs.pprojMatrix^);
     pp1:=geometry.VectorTransform3D(pp1,matrixs.pmodelMatrix^);

     pp2:=geometry.VectorTransform3D(p2,matrixs.pprojMatrix^);
     pp2:=geometry.VectorTransform3D(pp2,matrixs.pmodelMatrix^);}

     //canvas.Line(round(pp1.x),h-round(pp1.y),round(pp2.x),h-round(pp2.y));
     MoveToEx(OffScreedDC, round(pp1.x),h-round(pp1.y), nil);
     LineTo(OffScreedDC, round(pp2.x),h-round(pp2.y));
end;

procedure TZGLCanvasDrawer.SetClearColor(const red, green, blue, alpha: byte);
begin
     ClearColor:=RGBToColor(red,green,blue);
end;
procedure TZGLCanvasDrawer.SetColor(const red, green, blue, alpha: byte);
begin
     canvas.Pen.Color:=RGBToColor(red,green,blue);
end;
procedure TZGLCanvasDrawer.SetColor(const color: TRGB);
begin
     canvas.Pen.Color:=RGBToColor(color.r,color.g,color.b);
end;
procedure TZGLCanvasDrawer.ClearScreen(stencil:boolean);
var
  mRect: TRect;
begin
     //canvas.Brush.Color:=ClearColor;
     //canvas.FillRect(0,0,canvas.width,canvas.height);
     mrect:=Rect(0,0,canvas.Width,canvas.Height);
     FillRect(OffScreedDC,mRect,ClearBrush);
end;
procedure TZGLCanvasDrawer.SetDisplayCSmode(const width, height:integer);
begin
     sx:=1;
     sy:=1;
     tx:=0;
     ty:={height}0;
end;
procedure TZGLCanvasDrawer.DrawLine2DInDCS(const x1,y1,x2,y2:integer);
begin
     MoveToEx(OffScreedDC,round(x1*sx+tx),round(y1*sy+ty), nil);
     LineTo(OffScreedDC,round(x2*sx+tx),round(y2*sy+ty));
     //canvas.Line(round(x1*sx+tx),round(y1*sy+ty),round(x2*sx+tx),round(y2*sy+ty));
end;
procedure TZGLCanvasDrawer.DrawLine2DInDCS(const x1,y1,x2,y2:single);
begin
     //canvas.Line(round(x1*sx+tx),round(y1*sy+ty),round(x2*sx+tx),round(y2*sy+ty));
     MoveToEx(OffScreedDC,round(x1*sx+tx),round(y1*sy+ty), nil);
     LineTo(OffScreedDC,round(x2*sx+tx),round(y2*sy+ty));
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('uzglabstractdrawer.initialization');{$ENDIF}
  OGLDrawer:=TZGLOpenGLDrawer.create;
  CanvasDrawer:=TZGLCanvasDrawer.create;
  {$IFDEF WINDOWS}GDIPlusDrawer:=TZGLGDIPlusDrawer.create;{$ENDIF}
finalization
end.

