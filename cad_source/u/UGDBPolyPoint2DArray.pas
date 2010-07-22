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
{$INCLUDE def.inc}
interface
uses gdbasetypes,UGDBOpenArrayOfData, {oglwindowdef,}sysutils,gdbase, geometry,
     gl,
     {varmandef,}OGLSpecFunc;
type
{Export+}
PGDBPolyPoint2DArray=^GDBPolyPoint2DArray;
GDBPolyPoint2DArray=object(GDBOpenArrayOfData)
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);

                      procedure DrawGeometry;virtual;
                      function InRect:TInRect;virtual;
                      procedure freeelement(p:GDBPointer);virtual;
                end;
{Export-}
implementation
uses UGDBDescriptor,log;
procedure GDBPolyPoint2DArray.freeelement;
begin
end;
constructor GDBPolyPoint2DArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(GDBPolyVertex2D));
end;
procedure GDBPolyPoint2DArray.drawgeometry;
var p:PGDBPolyVertex2D;
    counter:GDBInteger;
    i:GDBInteger;
begin
  if count<2 then exit;
  p:=parray;
  counter:=0;
  for i:=0 to count-1 do
  begin
     if counter<=0
     then
         begin
              if p^.count=0 then
                                begin
                                     if counter=0 then
                                                      myglbegin(GL_LINES)
                                end
                              else
                                  begin
                                       if counter<0 then myglend;
                                       myglbegin(GL_LINE_STRIP);
                                       counter:=p^.count;
                                  end;
         end;
     glvertex2dv(@p^.coord);
     inc(p);
     dec(counter);
     if (counter=0)then
                       begin
                            myglend;
                       end;
  end;
  //myglend;
end;
function GDBPolyPoint2DArray.inrect;
var p,pp:PGDBPolyVertex2D;
    counter:GDBInteger;
    i:GDBInteger;
    //lines:GDBBoolean;
begin
  if (count<2){or(not POGLWND^.seldesc.MouseFrameInverse)} then exit;
  p:=parray;
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
          if pointinquad2d(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, p.coord.x,p.coord.y)
          then
          begin
               result := IRPartially;
               exit;
          end
          else
          if pointinquad2d(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, pp.coord.x,pp.coord.y)
          then
          begin
               result := IRPartially;
               exit;
          end
          else
          if
          intercept2d2(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, p.coord.x,p.coord.y,pp.coord.x,pp.coord.y)
       or intercept2d2(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, p.coord.x,p.coord.y,pp.coord.x,pp.coord.y)
       or intercept2d2(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, p.coord.x,p.coord.y,pp.coord.x,pp.coord.y)
       or intercept2d2(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, p.coord.x,p.coord.y,pp.coord.x,pp.coord.y)
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
          if pointinquad2d(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, pp.coord.x,pp.coord.y)
          then
          begin
               result := IRPartially;
               exit;
          end
          else
          if
          intercept2d2(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, p.coord.x,p.coord.y,pp.coord.x,pp.coord.y)
       or intercept2d2(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, p.coord.x,p.coord.y,pp.coord.x,pp.coord.y)
       or intercept2d2(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, p.coord.x,p.coord.y,pp.coord.x,pp.coord.y)
       or intercept2d2(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, p.coord.x,p.coord.y,pp.coord.x,pp.coord.y)
          then
          begin
               result := IRPartially;
               exit;
          end;
     end;
  end;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBPolyPoint2DArray.initialization');{$ENDIF}
end.
