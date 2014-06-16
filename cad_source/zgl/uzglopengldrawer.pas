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
    GDIPAPI,GDIPOBJ,windows,
    uzglabstractdrawer,UGDBOpenArrayOfData,uzgprimitivessarray,OGLSpecFunc,Graphics,gdbase;
type
TZGLOpenGLDrawer=class(TZGLAbstractDrawer)
                        public
                        procedure DrawLine(const i1:TLLVertexIndex);override;
                        procedure DrawPoint(const i:TLLVertexIndex);override;
                   end;
TZGLCanvasDrawer=class(TZGLAbstractDrawer)
                        public
                        canvas:tcanvas;
                        midline:integer;
                        procedure DrawLine(const i1:TLLVertexIndex);override;
                        procedure DrawPoint(const i:TLLVertexIndex);override;
                   end;
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
var
   OGLDrawer:TZGLAbstractDrawer;
   CanvasDrawer:TZGLCanvasDrawer;
   GDIPlusDrawer:TZGLGDIPlusDrawer;
implementation
uses log;
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

procedure TZGLCanvasDrawer.DrawLine(const i1:TLLVertexIndex);
var
   pv1,pv2:PGDBVertex3S;
begin
    pv1:=PGDBVertex3S(PVertexBuffer.getelement(i1));
    pv2:=PGDBVertex3S(PVertexBuffer.getelement(i1+1));
    canvas.Line(round(pv1.x),round(midline-pv1.y),round(pv2.x),round(midline-pv2.y));
end;

procedure TZGLCanvasDrawer.DrawPoint(const i:TLLVertexIndex);
var
   pv:PGDBVertex3S;
begin
    pv:=PGDBVertex3S(PVertexBuffer.getelement(i));
    Canvas.Pixels[round(pv.x),round(midline-pv.y)]:=canvas.Pen.Color;
end;

initialization
  {$IFDEF DEBUGINITSECTION}LogOut('uzglabstractdrawer.initialization');{$ENDIF}
  OGLDrawer:=TZGLOpenGLDrawer.create;
  CanvasDrawer:=TZGLCanvasDrawer.create;
  GDIPlusDrawer:=TZGLGDIPlusDrawer.create;
finalization
end.

