{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
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

unit UGDBOutbound2DIArray;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses uzegeometrytypes,uzgldrawcontext,gzctnrVector,sysutils,uzegeometry;
type
{Export+}
PGDBOOutbound2DIArray=^GDBOOutbound2DIArray;
{REGISTEROBJECTTYPE GDBOOutbound2DIArray}
GDBOOutbound2DIArray= object(GZVector{-}<TzePoint2i>{//})
                      procedure DrawGeometry(var DC:TDrawContext);virtual;
                      function InRect(Frame1, Frame2: TzePoint2i):TInBoundingVolume;virtual;
                      function perimetr:Double;virtual;
                end;
{Export-}
function EqualVertex2DI(const a, b: TzePoint2i):Boolean;
implementation
function EqualVertex2DI(const a, b: TzePoint2i):Boolean;
begin
  if (a.x=b.x)and(a.y=b.y) then
                               result:=true
                           else
                               result:=false;
end;
procedure GDBOOutbound2DIArray.drawgeometry;
var oldp,p:PzePoint2i;
    i:Integer;
begin
  case count of
               1:begin
                      //oglsm.myglbegin(GL_POINTS);
                      //oglsm.myglvertex2iv(@PzePoint2iArray(parray)^[0]);
                      //oglsm.myglend;
                 end;
               else
               begin

                    p:=GetParrayAsPointer;
                    oldp:=p;
                    inc(p);
                    //oglsm.myglbegin(GL_line_loop);
                    for i:=1 to count-1 do
                    begin
                      //oglsm.myglvertex2iv(@p^);
                      dc.drawer.DrawLine2DInDCS(p^.x,p^.y,oldp^.x,oldp^.y);
                      oldp:=p;
                      inc(p);
                    end;
                    dc.drawer.DrawLine2DInDCS(PzePoint2i(parray)^.x,PzePoint2i(parray)^.y,oldp^.x,oldp^.y);
                    //oglsm.myglend;
               end;
  end;
end;
function GDBOOutbound2DIArray.inrect;
var i:Integer;
    p:PzePoint2i;
begin
     result:=IREmpty;
     if Count=0 then exit
     else
     begin
          p:=PzePoint2i(parray);
          if count=1 then
          begin
               if pointinquad2d(Frame1.x,
                                Frame1.y,

                                Frame2.x,
                                Frame2.y,
                                p^.x,p.y)
                                                          then result:=IRFully;
          end
          else
          begin
               for i:=0 to count-1 do
               begin
                    if not pointinquad2d(Frame1.x,
                                         Frame1.y,
                                         Frame2.x,
                                         Frame2.y,
                                         p^.x,p.y)
                                                                   then exit;
                    inc(p);
               end;
               result:=IRFully;
         end;
     end;
end;
function GDBOOutbound2DIArray.perimetr;
var i,j:Integer;
begin
     result:=0;
     if count<2 then exit;
     for i:=0 to count-1 do
     begin
          if i=count-1 then j:=0
                       else j:=i+1;
          result:=result+vertexlen2df(parray^[i].x, parray^[i].y,parray^[j].x,parray^[j].y);
     end;
end;
begin
end.
