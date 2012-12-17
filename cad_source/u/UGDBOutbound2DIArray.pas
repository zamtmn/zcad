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

unit UGDBOutbound2DIArray;
{$INCLUDE def.inc}
interface
uses zcadsysvars,gdbasetypes,UGDBOpenArrayOfData, {oglwindowdef,}sysutils,gdbase, geometry,
     gl,
     varmandef,OGLSpecFunc;
type
{Export+}
PGDBOOutbound2DIArray=^GDBOOutbound2DIArray;
GDBOOutbound2DIArray=object(GDBOpenArrayOfData)
                     constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      procedure DrawGeometry;virtual;
                      procedure addpoint(point:GDBvertex2DI);virtual;
                      procedure addlastpoint(point:GDBvertex2DI);virtual;
                      procedure addgdbvertex(point:GDBvertex);virtual;
                      procedure addlastgdbvertex(point:GDBvertex);virtual;
                      procedure clear;virtual;
                      function onmouse(mc:GDBvertex2DI):GDBInteger;virtual;
                      function InRect(Frame1, Frame2: GDBvertex2DI):TInRect;virtual;
                      function perimetr:GDBDouble;virtual;
                end;
{Export-}
implementation
uses {UGDBDescriptor,}log;
constructor GDBOOutbound2DIArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(GDBvertex2DI));
end;
procedure GDBOOutbound2DIArray.clear;
begin
  count:=0;
end;
procedure GDBOOutbound2DIArray.addpoint;
begin
     if (count=0)or((PGDBvertex2DIArray(parray)^[count-1].x<>point.x)or
                    (PGDBvertex2DIArray(parray)^[count-1].y<>point.y))
     then
     begin
          add(@point);
          //PGDBvertex2DIArray(parray)^[count]:=point;
          //inc(count);
     end;
end;
procedure GDBOOutbound2DIArray.addlastpoint;
begin
     if ((PGDBvertex2DIArray(parray)^[count-1].x<>point.x)or(PGDBvertex2DIArray(parray)^[count-1].y<>point.y))
        and
        ((PGDBvertex2DIArray(parray)^[0].x<>point.x)or(PGDBvertex2DIArray(parray)^[0].y<>point.y))
     then
     begin
          PGDBvertex2DIArray(parray)^[count]:=point;
          inc(count);
     end;
end;
procedure GDBOOutbound2DIArray.addgdbvertex;
var p1:GDBvertex2DI;
begin
     p1.x:=round(point.x);
     p1.y:=round(point.y);
     addpoint(p1);
end;
procedure GDBOOutbound2DIArray.addlastgdbvertex;
var p1:GDBvertex2DI;
begin
     p1.x:=round(point.x);
     p1.y:=round(point.y);
     addlastpoint(p1);
end;
procedure GDBOOutbound2DIArray.drawgeometry;
var p:PGDBvertex2DI;
    i:GDBInteger;
begin
  case count of
               1:begin
                      oglsm.myglbegin(GL_POINTS);
                      glvertex2iv(@PGDBvertex2DIArray(parray)^[0]);
                      oglsm.myglend;
                 end;
               else
               begin
                    p:=parray;
                    oglsm.myglbegin(GL_line_loop);
                    for i:=1 to count do
                    begin
                      glvertex2iv(@p^);
                      inc(p);
                    end;
                    oglsm.myglend;
               end;
  end;
end;
function GDBOOutbound2DIArray.inrect;
var i:GDBInteger;
    p:PGDBVertex2DI;
begin
     result:=IREmpty;
     if Count=0 then exit
     else
     begin
          p:=PGDBVertex2DI(parray);
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
var i,j:GDBInteger;
begin
     result:=0;
     if count<2 then exit;
     for i:=0 to count-1 do
     begin
          if i=count-1 then j:=0
                       else j:=i+1;
          result:=result+vertexlen2df(PGDBvertex2DIArray(parray)^[i].x, PGDBvertex2DIArray(parray)^[i].y,PGDBvertex2DIArray(parray)^[j].x,PGDBvertex2DIArray(parray)^[j].y);
     end;
end;


function GDBOOutbound2DIArray.onmouse;
var p:PGDBvertex2DI;
    i,j,cm,cp,cc:GDBInteger;
    d,t1,t2:GDBDouble;
    DISP_CursorSize_2:GDBInteger;
begin
  DISP_CursorSize_2:=sysvar.DISP.DISP_CursorSize^*sysvar.DISP.DISP_CursorSize^;
  result:=0;
  case count of
               1:begin
                      if distance2point_2(PGDBvertex2DIArray(parray)^[0],mc)<DISP_CursorSize_2 then
                      begin
                           result:=2;
                           exit;
                      end;
                 end;
               2:begin
                      p:=parray;
                      inc(p);
                      if distance2piece_2(mc,PGDBvertex2DIArray(parray)^[0],p^)<DISP_CursorSize_2
                      then
                      begin
                           result:=2;
                           exit;
                      end;
                 end;
               else
               begin
  cp:=0;
  cm:=0;
  cc:=count-1;
  for i:=0 to cc do
  begin
  if i<>cc then j:=i+1
           else j:=0;
  {d:=PGDBvertex2DIArray(parray)^[i].x*poglwnd^.md.glmouse.y+
     poglwnd^.md.glmouse.x*PGDBvertex2DIArray(parray)^[j].y+
     PGDBvertex2DIArray(parray)^[j].x*PGDBvertex2DIArray(parray)^[i].y-
     PGDBvertex2DIArray(parray)^[j].x*poglwnd^.md.glmouse.y-poglwnd^.md.glmouse.x*
     PGDBvertex2DIArray(parray)^[i].y-PGDBvertex2DIArray(parray)^[i].x*
     PGDBvertex2DIArray(parray)^[j].y;}
  t1:=PGDBvertex2DIArray(parray)^[i].x;
  t2:=mc.y;
  d:=t1*t2;
  t1:=mc.x;
  t2:=PGDBvertex2DIArray(parray)^[j].y;
  d:=d+t1*t2;
  t1:=PGDBvertex2DIArray(parray)^[j].x;
  t2:=PGDBvertex2DIArray(parray)^[i].y;
  d:=d+t1*t2;
  t1:=PGDBvertex2DIArray(parray)^[j].x;
  t2:=mc.y;
  d:=d-t1*t2;
  t1:=mc.x;
  t2:=PGDBvertex2DIArray(parray)^[i].y;
  d:=d-t1*t2;
  t1:=PGDBvertex2DIArray(parray)^[i].x;
  t2:=PGDBvertex2DIArray(parray)^[j].y;
  d:=d-t1*t2;

  if d>0 then
        begin
            cp:=cp+1;
        end
        else
        begin
            cm:=cm+1;
        end;
   end;
   if not((cp=count)or(cm=count)) then exit;
   result:=1;
   end;
  end;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBOutBound2DIArray.initialization');{$ENDIF}
end.
