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

unit UGDBPolyLine2DArray;
{$INCLUDE def.inc}
interface
uses gdbasetypes,UGDBOpenArrayOfData{, oglwindowdef},sysutils,gdbase, geometry,
     gl,
     varmandef,OGLSpecFunc;
type
{Export+}
PGDBPolyline2DArray=^GDBPolyline2DArray;
GDBPolyline2DArray=object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBVertex2D*)
                      closed:GDBBoolean;(*saved_to_shd*)
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger;c:GDBBoolean);
                      constructor initnul;

                      function onmouse:GDBBoolean;virtual;
                      procedure DrawGeometry;virtual;
                      function inrect:GDBBoolean;virtual;
                end;
{Export-}
implementation
uses UGDBDescriptor,log;
constructor GDBPolyline2DArray.initnul;
begin
  inherited initnul;
  size:=sizeof(GDBVertex2D);
end;
constructor GDBPolyline2DArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(GDBVertex2D));
end;
procedure GDBPolyline2DArray.drawgeometry;
//var p:PGDBVertex2D;
//    counter:GDBInteger;
//    i:GDBInteger;
begin
  if count<2 then exit;
  //p:=parray;
  //counter:=0;
  myglbegin(GL_LINE_STRIP);
  iterategl(@glvertex2dv);
  myglend;
end;
function GDBPolyline2DArray.inrect;
var p,pp:PGDBVertex2D;
//    counter:GDBInteger;
    i:GDBInteger;
//    lines:GDBBoolean;
begin
  result := false;
  if (count<2){or(not POGLWND^.seldesc.MouseFrameInverse)} then exit;
  p:=parray;
  i:=count;

  if GDB.GetCurrentDWG.OGLwindow1.param.seldesc.MouseFrameInverse then
  begin
  while i>0 do{or i:=0 to count-1 do}
  begin
     begin
          pp:=p;
          inc(p);
          if (i<>1) and pointinquad2d(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, p.x,p.y)
          then
          begin
               result := true;
               exit;
          end
          else
          if pointinquad2d(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, pp.x,pp.y)
          then
          begin
               result := true;
               exit;
          end
          else
          if
          (i<>1) and
          intercept2d2(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, p.x,p.y,pp.x,pp.y)
       or intercept2d2(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, p.x,p.y,pp.x,pp.y)
       or intercept2d2(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, p.x,p.y,pp.x,pp.y)
       or intercept2d2(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, p.x,p.y,pp.x,pp.y)
          then
          begin
               result := true;
               exit;
          end;
          inc(p);
          dec(i);
     end
  end;
  end
  else
  begin
  result := true;
  while i>0 do{or i:=0 to count-1 do}
  begin
     begin
          if not pointinquad2d(GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame1.y, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.x, GDB.GetCurrentDWG.OGLwindow1.param.seldesc.Frame2.y, p.x,p.y)
          then
          begin
               result := false;
               exit;
          end;
          inc(p);
          dec(i);
     end
  end;
  end;
end;
function GDBPolyline2DArray.onmouse;
var i{,counter}:GDBInteger;
    d:GDBDouble;
    ptpv0,ptpv1:PGDBVertex2D;
begin
  result:=false;
   ptpv0:=parray;
   ptpv1:=ptpv0;
   inc(ptpv1);
   i:=0;
   while i<(count-1) do
   begin
     d:=distance2piece(GDB.GetCurrentDWG.OGLwindow1.param.md.glmouse,ptpv1^,ptpv0^);
     if d<2*sysvar.DISP.DISP_CursorSize^ then
     begin
          result:=true;
          exit;
     end;
     begin
                            inc(i);
                            inc(ptpv1);
                            inc(ptpv0);
                       end;
   end;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBPolyLine2DArray.initialization');{$ENDIF}
end.
