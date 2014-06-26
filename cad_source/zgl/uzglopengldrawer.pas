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
    uzglabstractdrawer,UGDBOpenArrayOfData,uzgprimitivessarray,OGLSpecFunc,Graphics,gdbase;
type
TZGLOpenGLDrawer=class(TZGLGeneralDrawer)
                        public
                        procedure startrender;override;
                        procedure endrender;override;
                        procedure DrawLine(const i1:TLLVertexIndex);override;
                        procedure DrawPoint(const i:TLLVertexIndex);override;
                        procedure SetLineWidth(const w:single);override;
                        procedure SetPointSize(const s:single);override;
                        procedure SetColor(const red, green, blue: byte);overload;override;
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
                   end;
TZGLCanvasDrawer=class(TZGLGeneralDrawer)
                        public
                        canvas:tcanvas;
                        midline:integer;
                        sx,sy,tx,ty:single;
                        ClearColor: TColor;
                        constructor create;
                        function TranslatePoint(const p:GDBVertex3S):GDBVertex3S;
                        procedure DrawLine(const i1:TLLVertexIndex);override;
                        procedure DrawPoint(const i:TLLVertexIndex);override;

                        procedure ClearScreen(stencil:boolean);override;
                        procedure SetClearColor(const red, green, blue, alpha: byte);overload;override;
                        procedure SetColor(const red, green, blue: byte);overload;override;
                        procedure SetColor(const color: TRGB);overload;override;

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
procedure TZGLOpenGLDrawer.SetColor(const red, green, blue: byte);
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
constructor TZGLCanvasDrawer.create;
begin
     sx:=0.1;
     sy:=-0.1;
     tx:=0;
     ty:=400;
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
    canvas.Line(round(p1.x),round(p1.y),round(p2.x),round(p2.y));
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
procedure TZGLCanvasDrawer.SetClearColor(const red, green, blue, alpha: byte);
begin
     ClearColor:=RGBToColor(red,green,blue);
end;
procedure TZGLCanvasDrawer.SetColor(const red, green, blue: byte);
begin
     canvas.Pen.Color:=RGBToColor(red,green,blue);
end;
procedure TZGLCanvasDrawer.SetColor(const color: TRGB);
begin
     canvas.Pen.Color:=RGBToColor(color.r,color.g,color.b);
end;
procedure TZGLCanvasDrawer.ClearScreen(stencil:boolean);
begin
     canvas.Brush.Color:=ClearColor;
     canvas.FillRect(0,0,canvas.width,canvas.height);
end;
initialization
  {$IFDEF DEBUGINITSECTION}LogOut('uzglabstractdrawer.initialization');{$ENDIF}
  OGLDrawer:=TZGLOpenGLDrawer.create;
  CanvasDrawer:=TZGLCanvasDrawer.create;
  {$IFDEF WINDOWS}GDIPlusDrawer:=TZGLGDIPlusDrawer.create;{$ENDIF}
finalization
end.

