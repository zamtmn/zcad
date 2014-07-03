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
    {$IFDEF LCLGTK2}
    Gtk2Def,
    {$ENDIF}
    LCLIntf,LCLType,Classes,Controls,
    geometry,uzglabstractdrawer,UGDBOpenArrayOfData,uzgprimitivessarray,OGLSpecFunc,Graphics,gdbase;
const
  texturesize=256;
type
TZGLOpenGLDrawer=class(TZGLGeneralDrawer)
                        myscrbuf:tmyscrbuf;
                        public
                        function startpaint(InPaintMessage:boolean;w,h:integer):boolean;override;
                        procedure startrender(const mode:TRenderMode;var matrixs:tmatrixs);override;
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
                        {в координатах окна}
                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:integer);override;
                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:single);override;
                        procedure DrawClosedPolyLine2DInDCS(const coords:array of single);override;
                        {в координатах модели}
                        procedure DrawLine3DInModelSpace(const p1,p2:gdbvertex;var matrixs:tmatrixs);override;
                        procedure SaveBuffers(w,h:integer);override;
                        procedure RestoreBuffers(w,h:integer);override;
                        function CreateScrbuf(w,h:integer):boolean; override;
                        procedure delmyscrbuf; override;
                   end;
TZGLCanvasDrawer=class(TZGLGeneralDrawer)
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
                        linewidth:integer;
                        constructor create;

                        procedure startrender(const mode:TRenderMode;var matrixs:tmatrixs);override;

                        function startpaint(InPaintMessage:boolean;w,h:integer):boolean;override;
                        procedure endpaint(InPaintMessage:boolean);override;

                        function TranslatePoint(const p:GDBVertex3S):GDBVertex3S;
                        procedure DrawLine(const i1:TLLVertexIndex);override;
                        procedure DrawPoint(const i:TLLVertexIndex);override;

                        procedure DrawLine3DInModelSpace(const p1,p2:gdbvertex;var matrixs:tmatrixs);override;

                        procedure ClearScreen(stencil:boolean);override;
                        procedure SetClearColor(const red, green, blue, alpha: byte);overload;override;
                        procedure SetColor(const red, green, blue, alpha: byte);overload;override;
                        procedure SetColor(const color: TRGB);overload;override;
                        procedure SetLineWidth(const w:single);override;
                        procedure _createPen;
                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:integer);override;
                        procedure DrawLine2DInDCS(const x1,y1,x2,y2:single);override;
                        procedure DrawClosedPolyLine2DInDCS(const coords:array of single);override;

                        function CreateScrbuf(w,h:integer):boolean; override;
                        procedure delmyscrbuf; override;
                        procedure SaveBuffers(w,h:integer);override;
                        procedure RestoreBuffers(w,h:integer);override;
                        procedure SwapBuffers;override;
                        procedure TranslateCoord2D(const tx,ty:single);override;
                        procedure ScaleCoord2D(const sx,sy:single);override;
                   end;
{$IFDEF WINDOWS}
TZGLGDIPlusDrawer=class(TZGLCanvasDrawer)
                        graphicsGDIPlus:TGPGraphics;
                        pen: TGPPen;
                        HDC: HDC;
                        lpPaint: TPaintStruct;
                        public
                        procedure startrender(const mode:TRenderMode;var matrixs:tmatrixs);override;
                        procedure endrender;override;
                        procedure DrawLine(const i1:TLLVertexIndex);override;
                        procedure DrawPoint(const i:TLLVertexIndex);override;
                   end;
{$ENDIF}
var
   OGLDrawer:TZGLAbstractDrawer;
   CanvasDrawer:TZGLCanvasDrawer;
   code:integer;
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
     case mode of
                 TRM_ModelSpace:
                 begin
                 end;
                 TRM_DisplaySpace,TRM_WindowSpace:
                 begin
                  oglsm.myglMatrixMode(GL_PROJECTION);
                  oglsm.myglLoadIdentity;
                  oglsm.myglOrtho(0.0,matrixs.pviewport[2],matrixs.pviewport[3], 0.0, -1.0, 1.0);
                  oglsm.myglMatrixMode(GL_MODELVIEW);
                  oglsm.myglLoadIdentity;
                  if mode=TRM_DisplaySpace then
                  begin
                  oglsm.myglscalef(1, -1, 1);
                  oglsm.mygltranslated(0, -matrixs.pviewport[3], 0);
                  end;
                 end;
     end;
end;
function TZGLOpenGLDrawer.startpaint(InPaintMessage:boolean;w,h:integer):boolean;
begin
     if myscrbuf[0]=0 then
                          begin
                               result:=true;
                               CreateScrbuf(w,h);
                          end
                       else
                           result:=false;
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
     if w>1 then begin
                      oglsm.mygllinewidth(w);
                      oglsm.myglEnable(GL_LINE_SMOOTH);
                      oglsm.myglpointsize(w);
                      oglsm.myglEnable(gl_point_smooth);
                 end
            else
                begin
                      oglsm.mygllinewidth(1);
                      oglsm.myglDisable(GL_LINE_SMOOTH);
                      oglsm.myglpointsize(1);
                      oglsm.myglDisable(gl_point_smooth);
                end;
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
function TZGLOpenGLDrawer.CreateScrbuf(w,h:integer):boolean;
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
     result:=false;
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
constructor TZGLCanvasDrawer.create;
begin
     sx:=0.1;
     sy:=-0.1;
     tx:=0;
     ty:=400;
     SavedBitmap:=0;
end;
procedure TZGLCanvasDrawer.startrender;
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
function TZGLCanvasDrawer.startpaint;
var
  mRect: TRect;
begin
     CanvasDC:=0;
     isWindowsErrors;
     if InPaintMessage then
                           CanvasDC:=(canvas.Handle)
                       else
                           CanvasDC:=GetDC(panel.Handle);
     isWindowsErrors;
     OffScreedDC:=CreateCompatibleDC(CanvasDC);
     isWindowsErrors;
     OffscreenBitmap:=CreateCompatibleBitmap(CanvasDC,panel.Width,panel.Height);
     isWindowsErrors;
     SelectObject(OffScreedDC,OffscreenBitmap);
     isWindowsErrors;
     hLinePen:=CreatePen(PS_SOLID, 1, PenColor);
     isWindowsErrors;
     SelectObject(OffScreedDC, hLinePen);
     isWindowsErrors;
     result:=CreateScrbuf(canvas.Width,canvas.Height);
     isWindowsErrors;
end;
procedure TZGLCanvasDrawer.endpaint;
begin
     DeleteObject(OffscreenBitmap);
     isWindowsErrors;
     OffscreenBitmap:=0;
     DeleteObject(hLinePen);
     isWindowsErrors;
     hLinePen:=0;
     if not InPaintMessage then
     ReleaseDC(panel.Handle,CanvasDC);
     isWindowsErrors;
     DeleteDC(OffScreedDC);
     isWindowsErrors;
     OffScreedDC:=0;
end;
function TZGLCanvasDrawer.CreateScrbuf(w,h:integer):boolean;
begin
     result:=false;
     if SavedBitmap=0 then
     if CanvasDC<>0 then
     begin
          SavedDC:=CreateCompatibleDC({CanvasDC}0);
          isWindowsErrors;
          SavedBitmap:=CreateCompatibleBitmap({SavedDC}CanvasDC,w,h);
          isWindowsErrors;
          SelectObject(SavedDC,SavedBitmap);
          isWindowsErrors;
          result:=true;
     end;
end;
procedure TZGLCanvasDrawer.delmyscrbuf;
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
end;
procedure TZGLCanvasDrawer.SaveBuffers(w,h:integer);
begin
    {$IFDEF LCLGTK2}
     if TGtkDeviceContext(SavedDC).drawable=nil
     then
         delmyscrbuf
     else
    {$ENDIF}
         BitBlt(SavedDC,0,0,w,h,OffScreedDC,0,0,SRCCOPY);
     isWindowsErrors;
end;
procedure TZGLCanvasDrawer.RestoreBuffers(w,h:integer);
begin
     BitBlt(OffScreedDC,0,0,w,h,SavedDC,0,0,SRCCOPY);
     isWindowsErrors;
end;
procedure TZGLCanvasDrawer.SwapBuffers;
begin
     isWindowsErrors;
     BitBlt({canvas.Handle}CanvasDC,0,0,panel.Width,panel.Height,OffScreedDC,0,0,SRCCOPY);
     isWindowsErrors;
end;
function TZGLCanvasDrawer.TranslatePoint(const p:GDBVertex3S):GDBVertex3S;
begin
     result.x:=p.x*sx+tx;
     result.y:=p.y*sy+ty;
     result.z:=p.z;
end;
procedure TZGLCanvasDrawer.TranslateCoord2D(const tx,ty:single);
begin
     self.tx:=self.tx+tx;
     self.ty:=self.ty+ty;
end;
procedure TZGLCanvasDrawer.ScaleCoord2D(const sx,sy:single);
begin
  self.sx:=self.sx*sx;
  self.sy:=self.sy*sy;
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
    //canvas.Pie(1,1,1,1,
    //              1,1,1,1);
    MoveToEx(OffScreedDC, round(p1.x),round(p1.y), nil);
    isWindowsErrors;
    LineTo(OffScreedDC, round(p2.x),round(p2.y));
    isWindowsErrors;
end;

procedure TZGLCanvasDrawer.DrawPoint(const i:TLLVertexIndex);
var
   pv:PGDBVertex3S;
   p:GDBVertex3S;
begin
    pv:=PGDBVertex3S(PVertexBuffer.getelement(i));
    p:=TranslatePoint(pv^);
    //Canvas.Pixels[round(pv.x),round(pv.y)]:=canvas.Pen.Color;
end;
procedure TZGLCanvasDrawer.DrawLine3DInModelSpace(const p1,p2:gdbvertex;var matrixs:tmatrixs);
var
   pp1,pp2:GDBVertex;
   h:integer;
begin
     //_myGluProject(const objx,objy,objz:GDBdouble;const modelMatrix,projMatrix:PDMatrix4D;const viewport:PIMatrix4; out winx,winy,winz:GDBdouble):Integer;
    _myGluProject2(p1,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp1);
    _myGluProject2(p2,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp2);
    h:=panel.Height;
     {pp1:=geometry.VectorTransform3D(p1,matrixs.pprojMatrix^);
     pp1:=geometry.VectorTransform3D(pp1,matrixs.pmodelMatrix^);

     pp2:=geometry.VectorTransform3D(p2,matrixs.pprojMatrix^);
     pp2:=geometry.VectorTransform3D(pp2,matrixs.pmodelMatrix^);}

     //canvas.Line(round(pp1.x),h-round(pp1.y),round(pp2.x),h-round(pp2.y));
     MoveToEx(OffScreedDC, round(pp1.x),h-round(pp1.y), nil);
     isWindowsErrors;
     LineTo(OffScreedDC, round(pp2.x),h-round(pp2.y));
     isWindowsErrors;
end;

procedure TZGLCanvasDrawer.SetClearColor(const red, green, blue, alpha: byte);
begin
     ClearColor:=RGB(red,green,blue);
end;
procedure TZGLCanvasDrawer._createPen;
begin
  deleteobject(hLinePen);
  isWindowsErrors;
  hLinePen:=CreatePen({PS_DOT}PS_SOLID,linewidth,PenColor);
  isWindowsErrors;
  SelectObject(OffScreedDC, hLinePen);
  isWindowsErrors;
end;

procedure TZGLCanvasDrawer.SetColor(const red, green, blue, alpha: byte);
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
procedure TZGLCanvasDrawer.SetLineWidth(const w:single);
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
procedure TZGLCanvasDrawer.SetColor(const color: TRGB);
begin
     SetColor(color.r,color.g,color.b,255);
end;
procedure TZGLCanvasDrawer.ClearScreen(stencil:boolean);
var
  mRect: TRect;
  ClearBrush: HBRUSH;
  LogBrush: TLogBrush;
begin
     mrect:=Rect(0,0,panel.Width,panel.Height);
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
procedure TZGLCanvasDrawer.DrawLine2DInDCS(const x1,y1,x2,y2:integer);
begin
     MoveToEx(OffScreedDC,round(x1*sx+tx),round(y1*sy+ty), nil);
     isWindowsErrors;
     LineTo(OffScreedDC,round(x2*sx+tx),round(y2*sy+ty));
     //canvas.Line(round(x1*sx+tx),round(y1*sy+ty),round(x2*sx+tx),round(y2*sy+ty));
     isWindowsErrors;
end;
procedure TZGLCanvasDrawer.DrawLine2DInDCS(const x1,y1,x2,y2:single);
begin
     //canvas.Line(round(x1*sx+tx),round(y1*sy+ty),round(x2*sx+tx),round(y2*sy+ty));
     MoveToEx(OffScreedDC,round(x1*sx+tx),round(y1*sy+ty), nil);
     isWindowsErrors;
     LineTo(OffScreedDC,round(x2*sx+tx),round(y2*sy+ty));
     isWindowsErrors;
end;
procedure TZGLCanvasDrawer.DrawClosedPolyLine2DInDCS(const coords:array of single);
var
   i:integer;
begin
     MoveToEx(OffScreedDC,round(coords[0]*sx+tx),round(coords[1]*sy+ty), nil);
     isWindowsErrors;
     i:=2;
     while i<length(coords) do
     begin
     LineTo(OffScreedDC,round(coords[i]*sx+tx),round(coords[i+1]*sy+ty));
     isWindowsErrors;
     inc(i,2);
     end;
     LineTo(OffScreedDC,round(coords[0]*sx+tx),round(coords[1]*sy+ty));
     isWindowsErrors;
end;

initialization
  {$IFDEF DEBUGINITSECTION}LogOut('uzglabstractdrawer.initialization');{$ENDIF}
  OGLDrawer:=TZGLOpenGLDrawer.create;
  CanvasDrawer:=TZGLCanvasDrawer.create;
  {$IFDEF WINDOWS}GDIPlusDrawer:=TZGLGDIPlusDrawer.create;{$ENDIF}
finalization
end.

