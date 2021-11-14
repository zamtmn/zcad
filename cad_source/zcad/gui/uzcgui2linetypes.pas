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

unit uzcgui2linetypes;
{$INCLUDE def.inc}

interface

uses
  uzcinterfacedata,uzgldrawergdi,uzegeometry,uzgldrawcontext,uzeentitiesprop,uzbtypes,uzglgeometry,
  uzestyleslinetypes,graphics,usupportgui,StdCtrls,uzcdrawings,
  uzbgeomtypes,uzcstrconsts,Controls,Classes,uzbstrproc,uzcsysvars,uzccommandsmanager;

type
  TSupportLineTypeCombo = class
                             class procedure LTypeBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
                                                              State: StdCtrls.TOwnerDrawState);
  end;

procedure drawLT(const canvas:TCanvas;const ARect: TRect;const s:string;const plt:PGDBLtypeProp);safecall;

implementation
class procedure TSupportLineTypeCombo.LTypeBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
                                               State: StdCtrls.TOwnerDrawState);
var
   plt:PGDBLtypeProp;
   //ll:integer;
   s:string;
begin
    if drawings.GetCurrentDWG=nil then
                                 exit;
    if drawings.GetCurrentDWG.LTypeStyleTable.Count=0 then
                                 exit;
    ComboBoxDrawItem(Control,ARect,State);
    if not TComboBox(Control).DroppedDown then
                                      begin
                                           plt:=IVars.CLType;
                                      end
                                 else
                                     plt:=PGDBLtypeProp(tcombobox(Control).items.Objects[Index]);
   if plt=LTEditor then
                       begin
                       s:=rsSelectLT;
                       plt:=nil;
                       //ll:=0;
                       end
else if plt<>nil then
                   begin
                        s:=Tria_AnsiToUtf8(plt^.Name);
                        //ll:=30;
                   end
               else
                   begin
                       s:=rsDifferent;
                       if drawings.GetCurrentDWG.LTypeStyleTable.Count=0 then
                                 exit;
                       //ll:=0;
                   end;

    ARect.Left:=ARect.Left+2;
    drawLT(TComboBox(Control).canvas,ARect,{ll,}s,plt);
end;

procedure drawLT(const canvas:TCanvas;const ARect: TRect;const s:string;const plt:PGDBLtypeProp);
var
  //y:integer;
  //midline:integer;
  oldw:Integer;
  n:double;
  geom:ZGLGraphix;
  vp:GDBObjVisualProp;
  p1,p2:Gdbvertex;
    //p,pp,ppp:PGDBVertex;
    //i:GDBInteger;
    //Points: array of TPoint;
    //ppoly,poldpoly:PGDBPolyVertex3D;
    ll: Integer;
    DC:TDrawContext;
const
      txtoffset=5;
begin
  if (plt<>nil)and(plt.LengthDXF>0) then
   begin
        if s<>'' then
                     ll:=canvas.TextExtent(s).cx+2*txtoffset
                 else
                     ll:=0;
        geom.init({$IFDEF DEBUGBUILD}'mainwindow.drawLT'{$ENDIF});
        p1:=createvertex(ARect.Left+ll,(ARect.Top+ARect.Bottom)/2,0);
        p2:=createvertex(ARect.Right-txtoffset,p1.y,0);
        vp.LineType:=plt;
        vp.LineTypeScale:=(p2.x-p1.x)*(1/plt.LengthDXF/sysvar.DWG.DWG_LTScale^);
        if (plt^.Textarray.Count=0) then
                        n:=4
                    else
                        n:=1.000001;
        if plt^.h*vp.LineTypeScale>(ARect.Bottom-ARect.Top)/sysvar.DWG.DWG_LTScale^/2 then
                                                                  n:=( 2+2*(plt^.h*vp.LineTypeScale)/((ARect.Bottom-ARect.Top)/sysvar.DWG.DWG_LTScale^));
        vp.LineTypeScale:=vp.LineTypeScale/n;
        dc:=CreateAbstractRC;
        geom.DrawLineWithLT(dc,p1,p2,vp);
        oldw:=canvas.Pen.Width;
        canvas.Pen.Style:=psSolid;
        canvas.Pen.EndCap:=pecFlat;
        //y:=(ARect.Top+ARect.Bottom)div 2;
        //midline:=ARect.Top+ARect.Bottom;

        //CanvasDrawer.midline:=midline;
        GDIDrawer.canvas:=canvas;
        //CanvasDrawer.PVertexBuffer:=@geom.GeomData.Vertex3S;
        //geom.DrawLLPrimitives(CanvasDrawer);

        {if geom.Triangles.count>0 then
        begin
        canvas.Brush.Style:=bsSolid;
        canvas.Brush.Color:=canvas.Pen.Color;
        p:=geom.Triangles.PArray;
        for i:=0 to (geom.Triangles.count-1)div 3 do
        begin
           pp:=p;
           inc(p);
           ppp:=p;
           inc(p);
           setlength(points,3);
           points[0].x:=round(pp.x);
           points[0].y:=round(midline-pp.y);
           points[1].x:=round(ppp.x);
           points[1].y:=round(midline-ppp.y);
           points[2].x:=round(p.x);
           points[2].y:=round(midline-p.y);

           canvas.Polygon(Points);
           inc(p);
        end;
        end;}

        {if geom.SHX.count>1 then
        begin
        ppoly:=geom.SHX.parray;
        poldpoly:=nil;
        for i:=0 to geom.SHX.count-1 do
        begin
                if ppoly^.count<>0 then
                                  begin
                                       if poldpoly<>nil then
                                        begin
                                          canvas.Line(round(poldpoly.coord.x),round(midline-poldpoly.coord.y),round(ppoly.coord.x),round(midline-ppoly.coord.y));
                                        end;
                                       poldpoly:=ppoly;
                                  end
                                  else
                                  begin
                                  if poldpoly<>nil then
                                                       begin
                                                       canvas.Line(round(poldpoly.coord.x),round(midline-poldpoly.coord.y),round(ppoly.coord.x),round(midline-ppoly.coord.y));
                                                       poldpoly:=nil;
                                                       end
                                                   else
                                                       poldpoly:=ppoly;
                                  end;
           inc(ppoly);
        end;
        //oglsm.myglend;
        end;}

        canvas.Pen.Width:=oldw;
        geom.done;
   end;
  canvas.TextRect(ARect,ARect.Left,(ARect.Top+ARect.Bottom-canvas.TextHeight(s)) div 2,s);
end;
end.
