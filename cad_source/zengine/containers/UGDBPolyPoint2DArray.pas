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

unit UGDBPolyPoint2DArray;
{$INCLUDE zcadconfig.inc}
interface
uses uzegeometrytypes,gzctnrVector,sysutils,uzegeometry;
type
{Export+}
PGDBPolyPoint2DArray=^GDBPolyPoint2DArray;
{REGISTEROBJECTTYPE GDBPolyPoint2DArray}
GDBPolyPoint2DArray= object(GZVector{-}<GDBPolyVertex2D>{//})
                      //procedure DrawGeometry;virtual;
                      function InRect(Frame1, Frame2: GDBvertex2DI):TInBoundingVolume;virtual;
                      procedure freeelement(PItem:PT);virtual;
                end;
{Export-}
implementation
procedure GDBPolyPoint2DArray.freeelement;
begin
end;
(*procedure GDBPolyPoint2DArray.drawgeometry;
var p:PGDBPolyVertex2D;
    i:Integer;
begin
  if count<2 then exit;


  if count>1 then
  begin
  oglsm.myglbegin(GL_LINES);
  p:=parray;
  oglsm.myglvertex2dv(@p^.coord);
  inc(p);
  for i:=0 to count-2 do
  begin
          oglsm.myglvertex2dv(@p^.coord);
          if p^.count<0 then
                            oglsm.myglvertex2dv(@p^.coord);
     inc(p);
  end;
  oglsm.myglend;

  end;
end;*)
function GDBPolyPoint2DArray.inrect;
var p,pp:PGDBPolyVertex2D;
    counter:Integer;
    i:Integer;
    //lines:Boolean;
begin
  if (count<2){or(not POGLWND^.seldesc.MouseFrameInverse)} then exit;
  p:=GetParrayAsPointer;
  counter:=0;
  i:=count;
  while i>0 do{or i:=0 to count-1 do}
  begin
     if counter<=0 then
     begin
          if p^.count=0
          then
              begin
                   {if counter=0 then
                                    lines:=true; }
              end
          else
              begin
                   //lines:=false;
                   counter:=p^.count;
              end;
     end;
     if counter<=0 then
     begin
          pp:=p;
          inc(p);
          dec(i);
          if pointinquad2d(Frame1.x, Frame1.y, Frame2.x, Frame2.y, p.coord.x,p.coord.y)
          then
          begin
               result := IRPartially;
               exit;
          end
          else
          if pointinquad2d(Frame1.x, Frame1.y, Frame2.x, Frame2.y, pp.coord.x,pp.coord.y)
          then
          begin
               result := IRPartially;
               exit;
          end
          else
          if
          intercept2d2(Frame1.x, Frame1.y, Frame2.x, Frame1.y, p.coord.x,p.coord.y,pp.coord.x,pp.coord.y)
       or intercept2d2(Frame2.x, Frame1.y, Frame2.x, Frame2.y, p.coord.x,p.coord.y,pp.coord.x,pp.coord.y)
       or intercept2d2(Frame2.x, Frame2.y, Frame1.x, Frame2.y, p.coord.x,p.coord.y,pp.coord.x,pp.coord.y)
       or intercept2d2(Frame1.x, Frame2.y, Frame1.x, Frame1.y, p.coord.x,p.coord.y,pp.coord.x,pp.coord.y)
          then
          begin
               result := IRPartially;
               exit;
          end;
          inc(p);
          dec(i);
     end
     else
     while counter>0 do
     begin
          pp:=p;
          inc(p);
          dec(i);
          dec(counter);
          if pointinquad2d(Frame1.x, Frame1.y, Frame2.x, Frame2.y, pp.coord.x,pp.coord.y)
          then
          begin
               result := IRPartially;
               exit;
          end
          else
          if
          intercept2d2(Frame1.x, Frame1.y, Frame2.x, Frame1.y, p.coord.x,p.coord.y,pp.coord.x,pp.coord.y)
       or intercept2d2(Frame2.x, Frame1.y, Frame2.x, Frame2.y, p.coord.x,p.coord.y,pp.coord.x,pp.coord.y)
       or intercept2d2(Frame2.x, Frame2.y, Frame1.x, Frame2.y, p.coord.x,p.coord.y,pp.coord.x,pp.coord.y)
       or intercept2d2(Frame1.x, Frame2.y, Frame1.x, Frame1.y, p.coord.x,p.coord.y,pp.coord.x,pp.coord.y)
          then
          begin
               result := IRPartially;
               exit;
          end;
     end;
  end;
end;
begin
end.
