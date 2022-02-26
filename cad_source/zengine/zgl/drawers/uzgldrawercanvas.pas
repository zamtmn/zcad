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

unit uzgldrawercanvas;
{$INCLUDE zcadconfig.inc}
interface
uses
    FPCanvas,uzgldrawergeneral2d,uzcsysvars,
    {$IFDEF LCLGTK2}
    Gtk2Def,
    {$ENDIF}
    LCLIntf,LCLType,Classes,Controls,
    uzegeometry,uzgldrawergeneral,uzgldrawerabstract,Graphics,LazLogger;
const
  NeedScreenInvalidrect=true;
type
TZGLCanvasDrawer=class(TZGLGeneral2DDrawer)
                        public

                        constructor create;

                        function startpaint(InPaintMessage:boolean;w,h:integer):boolean;override;

                        procedure InternalDrawLine(const x1,y1,x2,y2:Single);override;
                        procedure InternalDrawTriangle(const x1,y1,x2,y2,x3,y3:Single);override;
                        procedure InternalDrawQuad(const x1,y1,x2,y2,x3,y3,x4,y4:Single);override;
                        procedure InternalDrawPoint(const x,y:Single);override;

                        procedure SetDrawMode(const mode:TZGLDrawMode);override;
                        procedure ClearScreen(stencil:boolean);override;
                        procedure _createPen;override;
                   end;
var
   CanvasDrawer:TZGLCanvasDrawer;
implementation
//uses log;
constructor TZGLCanvasDrawer.create;
begin
     inherited;
end;
procedure TZGLCanvasDrawer.SetDrawMode(const mode:TZGLDrawMode);
begin
     case mode of
        TDM_Normal:
                   begin
                        canvas.Pen.Mode:=pmCopy;
                   end;
            TDM_OR:
                   begin
                        canvas.Pen.Mode:=pmMerge;
                   end;
           TDM_XOR:
                     begin
                          canvas.Pen.Mode:=pmXor;
                     end;
     end;
end;
function TZGLCanvasDrawer.startpaint;
begin
     result:=true;
     PState:=TPaintState.TPSBufferNotSaved;
end;
procedure TZGLCanvasDrawer.InternalDrawLine(const x1,y1,x2,y2:Single);
var
   _x1,_y1,_x2,_y2:integer;
begin
     _x1:=round(x1);
     _y1:=round(y1);
     _x2:=round(x2);
     _y2:=round(y2);
     canvas.Line(_x1,_y1,_x2,_y2);
end;
procedure TZGLCanvasDrawer.InternalDrawPoint(const x,y:Single);
var
   _x,_y:integer;
begin
     _x:=round(x);
     _y:=round(y);
     //Canvas.Pixels[round(pv.x),round(pv.y)]:=canvas.Pen.Color;
     if NeedScreenInvalidrect then
                                  begin
                                       ProcessScreenInvalidrect(_x,_y);
                                  end;
end;
procedure TZGLCanvasDrawer.InternalDrawTriangle(const x1,y1,x2,y2,x3,y3:Single);
var
    sp:array [1..3]of TPoint;
begin
    sp[1].x:=round(x1);
    sp[1].y:=round(y1);
    sp[2].x:=round(x2);
    sp[2].y:=round(y2);
    sp[3].x:=round(x3);
    sp[3].y:=round(y3);
    Canvas.Polygon(@sp[1],3,false);
    {PolyGon(OffScreedDC,@sp[1],3,false);
    if NeedScreenInvalidrect then
                                 begin
                                      ProcessScreenInvalidrect(sp[1].x,sp[1].y);
                                      ProcessScreenInvalidrect(sp[2].x,sp[2].y);
                                      ProcessScreenInvalidrect(sp[3].x,sp[3].y);
                                 end;}
end;
procedure TZGLCanvasDrawer.InternalDrawQuad(const x1,y1,x2,y2,x3,y3,x4,y4:Single);
var
    sp:array [1..4]of TPoint;
begin
    sp[1].x:=round(x1);
    sp[1].y:=round(y1);
    sp[2].x:=round(x2);
    sp[2].y:=round(y2);
    sp[3].x:=round(x3);
    sp[3].y:=round(y3);
    sp[4].x:=round(x4);
    sp[4].y:=round(y4);
    Canvas.Polygon(@sp[1],4,false);
    {PolyGon(OffScreedDC,@sp[1],4,false);
    if NeedScreenInvalidrect then
                                 begin
                                      ProcessScreenInvalidrect(sp[1].x,sp[1].y);
                                      ProcessScreenInvalidrect(sp[2].x,sp[2].y);
                                      ProcessScreenInvalidrect(sp[3].x,sp[3].y);
                                      ProcessScreenInvalidrect(sp[4].x,sp[4].y);
                                 end;}
end;
procedure TZGLCanvasDrawer._createPen;
var
   ps:TFPPenStyle;
begin
  case penstyle of
              TPS_Solid:
                        ps:=PSSOLID;
              TPS_Dot:
                      ps:=PSDOT;
              TPS_Dash:
                       ps:=PSDASH;
          TPS_Selected:
                       ps:={PSDOT}PSDASH;
  end;
  //SetBkColor(OffScreedDC,ClearColor);
  canvas.Pen.Cosmetic:=false;
  canvas.Pen.Style:=ps;
  canvas.Pen.Width:=linewidth;
  canvas.Pen.Color:=PenColor;
  //hLinePen:=CreatePen(ps,linewidth,PenColor);

  //SelectObject(OffScreedDC, hLinePen);

  canvas.Brush.Color:=PenColor;
  //hBrush:=CreateSolidBrush(PenColor);
  //SelectObject(OffScreedDC, hBrush);}
end;

procedure TZGLCanvasDrawer.ClearScreen(stencil:boolean);
var
  mRect: TRect;
begin
     mrect:=Rect(0,0,wh.cx,wh.cy);
     {with LogBrush do
     begin
       lbStyle := BS_SOLID;
       lbColor := ClearColor;
       lbHatch := HS_CROSS
     end;}
     //ClearBrush:=CreateBrushIndirect(LogBrush);
     //isWindowsErrors;
     canvas.Brush.Style:=bsSolid;
     canvas.Brush.Color:=ClearColor;
     canvas.FillRect(mRect);
     //isWindowsErrors;
     //deleteobject(ClearBrush);
     //isWindowsErrors;
end;
initialization
  CanvasDrawer:=TZGLCanvasDrawer.create;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  CanvasDrawer.Destroy;
end.

