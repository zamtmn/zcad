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

unit uzgldrawergeneral2d;
{$INCLUDE zcadconfig.inc}
interface
uses uzgindexsarray,{$IFNDEF DELPHI}LCLIntf,{$ENDIF}{$IFDEF DELPHI}windows,Types,{$ENDIF}Controls,
     uzegeometrytypes,uzglviewareaabstract,uzgldrawergeneral,uzgprimitivescreator,
     uzgvertex3sarray,uzgldrawerabstract,uzepalette,Classes,Graphics,uzbtypes,uzegeometry;
type
DMatrix4DStackArray=array[0..10] of DMatrix4D;

TZGLGeneral2DDrawer=class(TZGLGeneralDrawer)
                          matr:DMatrix4D;
                          mstack:DMatrix4DStackArray;
                          mstackindex:integer;
                          sx,sy,tx,ty:single;
                          wa:TAbstractViewArea;
                          canvas:tcanvas;
                          panel:TCustomControl;

                          ClearColor: TColor;
                          PenColor: TColor;
                          linewidth:Integer;
                          PointSize:Single;
                          penstyle:TZGLPenStyle;
                          ScreenInvalidRect:Trect;

                          constructor create;

                          procedure startrender(const mode:TRenderMode;var matrixs:tmatrixs);override;

                          procedure SetClearColor(const red, green, blue, alpha: byte);overload;override;
                          procedure SetColor(const red, green, blue, alpha: byte);overload;override;
                          procedure SetColor(const color: TRGB);overload;override;
                          procedure SetLineWidth(const w:single);override;
                          procedure SetPointSize(const s:single);override;
                          procedure SetPenStyle(const style:TZGLPenStyle);override;
                          procedure _createPen;virtual;abstract;

                          procedure TranslateCoord2D(const tx,ty:single);override;
                          procedure ScaleCoord2D(const sx,sy:single);override;

                          procedure pushMatrixAndSetTransform(Transform:DMatrix4D);overload;override;
                          procedure pushMatrixAndSetTransform(Transform:DMatrix4F);overload;override;
                          procedure popMatrix;override;
                          function TranslatePointWithLocalCS(const p:GDBVertex3S):GDBVertex3S;
                          function TranslatePoint(const p:GDBVertex3S):GDBVertex3S;

                          procedure InitScreenInvalidrect(w,h:integer);
                          procedure CorrectScreenInvalidrect(w,h:integer);
                          procedure ProcessScreenInvalidrect(const x,y:integer);

                          procedure InternalDrawLine(const x1,y1,x2,y2:Single);virtual;abstract;
                          procedure InternalDrawTriangle(const x1,y1,x2,y2,x3,y3:Single);virtual;abstract;
                          procedure InternalDrawQuad(const x1,y1,x2,y2,x3,y3,x4,y4:Single);virtual;abstract;
                          procedure InternalDrawPoint(const x,y:Single);virtual;abstract;

                          procedure DrawLine(const PVertexBuffer:PZGLVertex3Sarray;const i1,i2:TLLVertexIndex);override;
                          procedure DrawTriangle(const PVertexBuffer:PZGLVertex3Sarray;const i1,i2,i3:TLLVertexIndex);override;
                          procedure DrawQuad(const PVertexBuffer:PZGLVertex3Sarray;const i1,i2,i3,i4:TLLVertexIndex);override;
                          procedure DrawPoint(const PVertexBuffer:PZGLVertex3Sarray;const i:TLLVertexIndex);override;
                          procedure DrawTrianglesFan(const PVertexBuffer:PZGLVertex3Sarray;const PIndexBuffer:PZGLIndexsArray;const i1,IndexCount:TLLVertexIndex);override;
                          procedure DrawTrianglesStrip(const PVertexBuffer:PZGLVertex3Sarray;const PIndexBuffer:PZGLIndexsArray;const i1,IndexCount:TLLVertexIndex);override;

                          procedure DrawLine2DInDCS(const x1,y1,x2,y2:integer);override;
                          procedure DrawLine2DInDCS(const x1,y1,x2,y2:single);override;
                          procedure DrawClosedPolyLine2DInDCS(const coords:array of single);override;

                          procedure DrawLine3DInModelSpace(const p1,p2:gdbvertex;var matrixs:tmatrixs);override;
                          procedure DrawPoint3DInModelSpace(const p:gdbvertex;var matrixs:tmatrixs);override;
                          procedure DrawTriangle3DInModelSpace(const normal,p1,p2,p3:gdbvertex;var matrixs:tmatrixs);override;
                          procedure DrawQuad3DInModelSpace(const normal,p1,p2,p3,p4:gdbvertex;var matrixs:tmatrixs);override;
                          procedure DrawQuad3DInModelSpace(const p1,p2,p3,p4:gdbvertex;var matrixs:tmatrixs);override;

                          function ProjectPoint3DInModelSpace(const p:gdbvertex;var matrixs:tmatrixs):GDBvertex2D;override;

                          function CheckOutboundInDisplay(const PVertexBuffer:PZGLVertex3Sarray;const i1:TLLVertexIndex):boolean;override;

                    end;
implementation
//uses log;
procedure TZGLGeneral2DDrawer.DrawQuad3DInModelSpace(const p1,p2,p3,p4:gdbvertex;var matrixs:tmatrixs);
var
   pp1,pp2,pp3,pp4:GDBVertex;
   //sp:array [1..4]of TPoint;
begin
    _myGluProject2(p1,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp1);
    _myGluProject2(p2,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp2);
    _myGluProject2(p3,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp3);
    _myGluProject2(p4,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp4);

    InternalDrawQuad(pp1.x,wh.cy-pp1.y,pp2.x,wh.cy-pp2.y,pp3.x,wh.cy-pp3.y,pp4.x,wh.cy-pp4.y);

     {sp[1].x:=round(pp1.x);
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
     ProcessScreenInvalidrect(sp[4].x,sp[4].y);}
end;
procedure TZGLGeneral2DDrawer.DrawQuad3DInModelSpace(const normal,p1,p2,p3,p4:gdbvertex;var matrixs:tmatrixs);
begin
     DrawQuad3DInModelSpace(p1,p2,p3,p4,matrixs);
end;
procedure TZGLGeneral2DDrawer.DrawTriangle3DInModelSpace(const normal,p1,p2,p3:gdbvertex;var matrixs:tmatrixs);
var
   pp1,pp2,pp3:GDBVertex;
   //sp:array [1..3]of TPoint;
begin
    _myGluProject2(p1,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp1);
    _myGluProject2(p2,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp2);
    _myGluProject2(p3,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp3);

    InternalDrawTriangle(pp1.x,wh.cy-pp1.y,pp2.x,wh.cy-pp2.y,pp3.x,wh.cy-pp3.y);
     {sp[1].x:=round(pp1.x);
     sp[1].y:=round(wh.cy-pp1.y);
     sp[2].x:=round(pp2.x);
     sp[2].y:=round(wh.cy-pp2.y);
     sp[3].x:=round(pp3.x);
     sp[3].y:=round(wh.cy-pp3.y);

     PolyGon(OffScreedDC,@sp[1],3,false);
     ProcessScreenInvalidrect(sp[1].x,sp[1].y);
     ProcessScreenInvalidrect(sp[2].x,sp[2].y);
     ProcessScreenInvalidrect(sp[3].x,sp[3].y);}
end;
procedure TZGLGeneral2DDrawer.DrawPoint3DInModelSpace(const p:gdbvertex;var matrixs:tmatrixs);
var
   pp:GDBVertex;
   ps:integer;
   x,y:integer;
begin
    _myGluProject2(p,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp);

     ps:=round(PointSize/2);

     x:=round(pp.x);
     y:=round(wh.cy-pp.y);
     ProcessScreenInvalidrect(x,y);

     InternalDrawQuad(x-ps, y-ps, x-ps, y+ps, x+ps, y+ps, x+ps, y-ps);
     //Rectangle(OffScreedDC, x-ps, y-ps, x+ps,y+ps);
end;
function TZGLGeneral2DDrawer.ProjectPoint3DInModelSpace(const p:gdbvertex;var matrixs:tmatrixs):GDBvertex2D;
var
   pp:GDBVertex;
begin
    _myGluProject2(p,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp);

     result.x:=round(pp.x);
     result.y:=round(wh.cy-pp.y);
end;
procedure TZGLGeneral2DDrawer.DrawLine3DInModelSpace(const p1,p2:gdbvertex;var matrixs:tmatrixs);
var
   pp1,pp2:GDBVertex;
   x1,y1,x2,y2:Single;
begin
    _myGluProject2(p1,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp1);
    _myGluProject2(p2,matrixs.pmodelMatrix,matrixs.pprojMatrix,matrixs.pviewport,pp2);

     x1:=pp1.x;
     y1:=wh.cy-pp1.y;
     x2:=pp2.x;
     y2:=wh.cy-pp2.y;
     InternalDrawLine(x1,y1,x2,y2);
end;

procedure TZGLGeneral2DDrawer.DrawClosedPolyLine2DInDCS(const coords:array of single);
var
   i:integer;
   x0,y0,x1,y1,x2,y2:integer;
begin
     x1:=round(coords[0]*sx+tx);
     y1:=round(coords[1]*sy+ty);
     x0:=x1;
     y0:=y1;
     {ProcessScreenInvalidrect(x1,y1);
     MoveToEx(OffScreedDC,x1,y1, nil);}

     i:=2;
     while i<length(coords) do
     begin
     x2:=round(coords[i]*sx+tx);
     y2:=round(coords[i+1]*sy+ty);
     InternalDrawLine(x1,y1,x2,y2);
     {ProcessScreenInvalidrect(x1,y1);
     LineTo(OffScreedDC,x1,y1);}
     x1:=x2;
     y1:=y2;
     inc(i,2);
     end;
     //LineTo(OffScreedDC,round(coords[0]*sx+tx),round(coords[1]*sy+ty));
     InternalDrawLine(x2,y2,x0,y0);
end;
procedure TZGLGeneral2DDrawer.DrawLine2DInDCS(const x1,y1,x2,y2:integer);
{var
   x,y:integer;}
begin
     InternalDrawLine(x1*sx+tx,y1*sy+ty,x2*sx+tx,y2*sy+ty);
     {x:=round(x1*sx+tx);
     y:=round(y1*sy+ty);
     ProcessScreenInvalidrect(x,y);

     MoveToEx(OffScreedDC,x,y, nil);

     x:=round(x2*sx+tx);
     y:=round(y2*sy+ty);
     ProcessScreenInvalidrect(x,y);

     LineTo(OffScreedDC,x,y);}
end;
procedure TZGLGeneral2DDrawer.DrawLine2DInDCS(const x1,y1,x2,y2:single);
{var
   x,y:integer;}
begin
     InternalDrawLine(x1*sx+tx,y1*sy+ty,x2*sx+tx,y2*sy+ty);
     {x:=round(x1*sx+tx);
     y:=round(y1*sy+ty);
     ProcessScreenInvalidrect(x,y);

     MoveToEx(OffScreedDC,x,y, nil);

     x:=round(x2*sx+tx);
     y:=round(y2*sy+ty);
     ProcessScreenInvalidrect(x,y);

     LineTo(OffScreedDC,x,y);}
end;
function TZGLGeneral2DDrawer.CheckOutboundInDisplay(const PVertexBuffer:PZGLVertex3Sarray;const i1:TLLVertexIndex):boolean;
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
 pv1:=PGDBVertex3S(PVertexBuffer.getDataMutable(i1));
 pv2:=PGDBVertex3S(PVertexBuffer.getDataMutable(i1+1));
 pv3:=PGDBVertex3S(PVertexBuffer.getDataMutable(i1+2));
 pv4:=PGDBVertex3S(PVertexBuffer.getDataMutable(i1+3));
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

procedure TZGLGeneral2DDrawer.DrawTrianglesStrip(const PVertexBuffer:PZGLVertex3Sarray;const PIndexBuffer:PZGLIndexsArray;const i1,IndexCount:TLLVertexIndex);
var
   i,index:integer;
   pindex:PTLLVertexIndex;

   pv1,pv2,pv3:PGDBVertex3S;
   p1,p2,p3:GDBVertex3S;
   //sp:array [1..3]of TPoint;
begin
    index:=i1;
    pindex:=pointer(PIndexBuffer.getDataMutable(index));
    pv1:=PGDBVertex3S(PVertexBuffer.getDataMutable(pindex^));
    inc(index);
    pindex:=pointer(PIndexBuffer.getDataMutable(index));
    pv2:=PGDBVertex3S(PVertexBuffer.getDataMutable(pindex^));
    inc(index);
    pindex:=pointer(PIndexBuffer.getDataMutable(index));
    pv3:=PGDBVertex3S(PVertexBuffer.getDataMutable(pindex^));
    inc(index);

    p1:=TranslatePointWithLocalCS(pv1^);
    p2:=TranslatePointWithLocalCS(pv2^);
    p3:=TranslatePointWithLocalCS(pv3^);

    {sp[1].x:=round(p1.x);
    sp[1].y:=round(p1.y);
    ProcessScreenInvalidrect(sp[1].x,sp[1].y);
    sp[2].x:=round(p2.x);
    sp[2].y:=round(p2.y);
    ProcessScreenInvalidrect(sp[2].x,sp[2].y);
    sp[3].x:=round(p3.x);
    sp[3].y:=round(p3.y);
    ProcessScreenInvalidrect(sp[3].x,sp[3].y);

    PolyGon(OffScreedDC,@sp[1],3,false);}
    InternalDrawTriangle(p1.x,p1.y,p2.x,p2.y,p3.x,p3.y);


    for i:=index to i1+IndexCount-1 do
    begin

        p1:=p2;
        p2:=p3;
        //sp[1]:=sp[2];
        //sp[2]:=sp[3];
        pindex:=pointer(PIndexBuffer.getDataMutable(i));
        pv3:=PGDBVertex3S(PVertexBuffer.getDataMutable(pindex^));

        p3:=TranslatePointWithLocalCS(pv3^);

        {sp[3].x:=round(p3.x);
        sp[3].y:=round(p3.y);
        ProcessScreenInvalidrect(sp[3].x,sp[3].y);

        PolyGon(OffScreedDC,@sp[1],3,false);}
        InternalDrawTriangle(p1.x,p1.y,p2.x,p2.y,p3.x,p3.y);
    end;
end;

procedure TZGLGeneral2DDrawer.DrawTrianglesFan(const PVertexBuffer:PZGLVertex3Sarray;const PIndexBuffer:PZGLIndexsArray;const i1,IndexCount:TLLVertexIndex);
var
   i,index:integer;
   pindex:PTLLVertexIndex;

   pv1,pv2,pv3:PGDBVertex3S;
   p1,p2,p3:GDBVertex3S;
   //sp:array [1..3]of TPoint;
begin
    index:=i1;
    pindex:=pointer(PIndexBuffer.getDataMutable(index));
    pv1:=PGDBVertex3S(PVertexBuffer.getDataMutable(pindex^));
    inc(index);
    pindex:=pointer(PIndexBuffer.getDataMutable(index));
    pv2:=PGDBVertex3S(PVertexBuffer.getDataMutable(pindex^));
    inc(index);
    pindex:=pointer(PIndexBuffer.getDataMutable(index));
    pv3:=PGDBVertex3S(PVertexBuffer.getDataMutable(pindex^));
    inc(index);

    p1:=TranslatePointWithLocalCS(pv1^);
    p2:=TranslatePointWithLocalCS(pv2^);
    p3:=TranslatePointWithLocalCS(pv3^);

    {sp[1].x:=round(p1.x);
    sp[1].y:=round(p1.y);
    ProcessScreenInvalidrect(sp[1].x,sp[1].y);
    sp[2].x:=round(p2.x);
    sp[2].y:=round(p2.y);
    ProcessScreenInvalidrect(sp[2].x,sp[2].y);
    sp[3].x:=round(p3.x);
    sp[3].y:=round(p3.y);
    ProcessScreenInvalidrect(sp[3].x,sp[3].y);

    PolyGon(OffScreedDC,@sp[1],3,false);}
    InternalDrawTriangle(p1.x,p1.y,p2.x,p2.y,p3.x,p3.y);


    for i:=index to i1+IndexCount-1 do
    begin
        p2:=p3;
        //sp[2]:=sp[3];
        pindex:=pointer(PIndexBuffer.getDataMutable(i));
        pv3:=PGDBVertex3S(PVertexBuffer.getDataMutable(pindex^));

        p3:=TranslatePointWithLocalCS(pv3^);

        //sp[3].x:=round(p3.x);
        //sp[3].y:=round(p3.y);
        //ProcessScreenInvalidrect(sp[3].x,sp[3].y);

        //PolyGon(OffScreedDC,@sp[1],3,false);
        InternalDrawTriangle(p1.x,p1.y,p2.x,p2.y,p3.x,p3.y);
    end;
end;

procedure TZGLGeneral2DDrawer.DrawPoint(const PVertexBuffer:PZGLVertex3Sarray;const i:TLLVertexIndex);
var
   pv:PGDBVertex3S;
   p:GDBVertex3S;
begin
    pv:=PGDBVertex3S(PVertexBuffer.getDataMutable(i));
    p:=TranslatePointWithLocalCS(pv^);
    InternalDrawPoint(p.x,p.y);
end;
procedure TZGLGeneral2DDrawer.DrawTriangle(const PVertexBuffer:PZGLVertex3Sarray;const i1,i2,i3:TLLVertexIndex);
var
   pv1,pv2,pv3:PGDBVertex3S;
   p1,p2,p3:GDBVertex3S;
begin
    pv1:=PGDBVertex3S(PVertexBuffer.getDataMutable(i1));
    pv2:=PGDBVertex3S(PVertexBuffer.getDataMutable(i2));
    pv3:=PGDBVertex3S(PVertexBuffer.getDataMutable(i3));
    p1:=TranslatePointWithLocalCS(pv1^);
    p2:=TranslatePointWithLocalCS(pv2^);
    p3:=TranslatePointWithLocalCS(pv3^);

    InternalDrawTriangle(p1.x,p1.y,p2.x,p2.y,p3.x,p3.y);
end;
procedure TZGLGeneral2DDrawer.DrawQuad(const PVertexBuffer:PZGLVertex3Sarray;const i1,i2,i3,i4:TLLVertexIndex);var
   pv1,pv2,pv3,pv4:PGDBVertex3S;
   p1,p2,p3,p4:GDBVertex3S;
   //x,y:integer;
   //sp:array [1..4]of TPoint;
begin
    pv1:=PGDBVertex3S(PVertexBuffer.getDataMutable(i1));
    pv2:=PGDBVertex3S(PVertexBuffer.getDataMutable(i2));
    pv3:=PGDBVertex3S(PVertexBuffer.getDataMutable(i3));
    pv4:=PGDBVertex3S(PVertexBuffer.getDataMutable(i4));
    p1:=TranslatePointWithLocalCS(pv1^);
    p2:=TranslatePointWithLocalCS(pv2^);
    p3:=TranslatePointWithLocalCS(pv3^);
    p4:=TranslatePointWithLocalCS(pv4^);

    InternalDrawQuad(p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,p4.x,p4.y);
end;
procedure TZGLGeneral2DDrawer.DrawLine(const PVertexBuffer:PZGLVertex3Sarray;const i1,i2:TLLVertexIndex);
var
   pv1,pv2:PGDBVertex3S;
   p1,p2:GDBVertex3S;
begin
    pv1:=PGDBVertex3S(PVertexBuffer.getDataMutable(i1));
    pv2:=PGDBVertex3S(PVertexBuffer.getDataMutable(i2));
    p1:=TranslatePointWithLocalCS(pv1^);
    p2:=TranslatePointWithLocalCS(pv2^);

    InternalDrawLine(p1.x,p1.y,p2.x,p2.y);
end;

procedure TZGLGeneral2DDrawer.InitScreenInvalidrect;
begin
     ScreenInvalidRect.Left:=w;
     ScreenInvalidRect.Right:=0;
     ScreenInvalidRect.Top:=h;
     ScreenInvalidRect.Bottom:=0;
end;
procedure TZGLGeneral2DDrawer.CorrectScreenInvalidrect;
begin
     if ScreenInvalidRect.Left<0 then ScreenInvalidRect.Left:=0;
     if ScreenInvalidRect.Right>w then ScreenInvalidRect.Right:=w;
     if ScreenInvalidRect.Top<0 then ScreenInvalidRect.Top:=0;
     if ScreenInvalidRect.Bottom>h then ScreenInvalidRect.Bottom:=h;
end;

procedure TZGLGeneral2DDrawer.ProcessScreenInvalidrect(const x,y:integer);
begin
     if PState=TPSBufferSaved then
     begin
         if ScreenInvalidRect.Left>x then ScreenInvalidRect.Left:=x;
         if ScreenInvalidRect.Right<x then ScreenInvalidRect.Right:=x;
         if ScreenInvalidRect.Top>y then ScreenInvalidRect.Top:=y;
         if ScreenInvalidRect.Bottom<y then ScreenInvalidRect.Bottom:=y;
     end;
end;

function TZGLGeneral2DDrawer.TranslatePointWithLocalCS(const p:GDBVertex3S):GDBVertex3S;
begin
     if mstackindex>-1 then
                           begin
                               result:=uzegeometry.VectorTransform3D(p,matr);
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
function TZGLGeneral2DDrawer.TranslatePoint(const p:GDBVertex3S):GDBVertex3S;
begin
     result.x:=p.x*sx+tx;
     result.y:=p.y*sy+ty;
     result.z:=p.z;
end;
procedure TZGLGeneral2DDrawer.startrender;
var
   m:DMatrix4D;
begin
     case mode of
                 TRM_ModelSpace:
                 begin
                      m:=uzegeometry.MatrixMultiply(matrixs.pmodelMatrix^,matrixs.pprojMatrix^);
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

constructor TZGLGeneral2DDrawer.create;
begin
     sx:=0.1;
     sy:=-0.1;
     tx:=0;
     ty:=400;
     penstyle:=TPS_Solid;
     matr:=OneMatrix;
     mstackindex:=-1;
end;

procedure TZGLGeneral2DDrawer.pushMatrixAndSetTransform(Transform:DMatrix4D);
begin
     inc(mstackindex);
     mstack[mstackindex]:=matr;
     matr:=MatrixMultiply(matr,Transform);
end;
procedure TZGLGeneral2DDrawer.pushMatrixAndSetTransform(Transform:DMatrix4F);
begin
     inc(mstackindex);
     mstack[mstackindex]:=matr;
     matr:=MatrixMultiply(matr,Transform);
end;
procedure TZGLGeneral2DDrawer.popMatrix;
begin
     if mstackindex>-1 then
                           begin
                                 matr:=mstack[mstackindex];
                                 dec(mstackindex);
                           end;
end;

procedure TZGLGeneral2DDrawer.SetPointSize(const s:single);
begin
     PointSize:=s;
end;
procedure TZGLGeneral2DDrawer.SetColor(const color: TRGB);
begin
     SetColor(color.r,color.g,color.b,255);
end;
procedure TZGLGeneral2DDrawer.SetColor(const red, green, blue, alpha: byte);
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
procedure TZGLGeneral2DDrawer.SetClearColor(const red, green, blue, alpha: byte);
begin
     ClearColor:=RGB(red,green,blue);
end;
procedure TZGLGeneral2DDrawer.SetLineWidth(const w:single);
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
procedure TZGLGeneral2DDrawer.SetPenStyle(const style:TZGLPenStyle);
begin
     if penstyle<>style then
     begin
          penstyle:=style;
          _createPen;
     end;
end;


procedure TZGLGeneral2DDrawer.TranslateCoord2D(const tx,ty:single);
begin
     self.tx:=self.tx+tx;
     self.ty:=self.ty+ty;
end;
procedure TZGLGeneral2DDrawer.ScaleCoord2D(const sx,sy:single);
begin
  self.sx:=self.sx*sx;
  self.sy:=self.sy*sy;
end;


initialization
end.

