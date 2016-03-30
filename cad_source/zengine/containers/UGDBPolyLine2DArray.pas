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
uses uzbtypesbase,UGDBOpenArrayOfData,sysutils,uzbtypes, uzegeometry,uzgloglstatemanager;
type
{REGISTEROBJECTTYPE GDBPolyline2DArray}
{Export+}
PGDBPolyline2DArray=^GDBPolyline2DArray;
GDBPolyline2DArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBVertex2D*)
                      closed:GDBBoolean;(*saved_to_shd*)
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger;c:GDBBoolean);
                      constructor initnul;

                      //function onmouse(mc:GDBvertex2DI):GDBBoolean;virtual;
                      procedure DrawGeometry;virtual;
                      procedure optimize;virtual;
                      function _optimize:GDBBoolean;virtual;
                      function inrect(Frame1, Frame2: GDBvertex2DI;inv:GDBBoolean):GDBBoolean;virtual;
                      function ispointinside(point:GDBVertex2D):GDBBoolean;virtual;
                      procedure transform(const t_matrix:DMatrix4D);virtual;

                end;
{Export-}
function _intercept2d(const p1,p2,p:GDBVertex2D;const dirx, diry: GDBDouble): GDBBoolean;
implementation
//uses {UGDBDescriptor,}log;
procedure GDBPolyline2DArray.transform(const t_matrix:DMatrix4D);
var
    pv:PGDBVertex2D;
    tv:GDBVertex;
    i{,c}:integer;

begin
    pv:=parray;
    for i:=1 to count do
    begin
         tv.x:=pv^.x;
         tv.y:=pv^.y;
         tv.z:=0;
         tv:=VectorTransform3D(tv,t_matrix);
         pv^.x:=tv.x;
         pv^.y:=tv.y;
       inc(pv);
    end;
end;
function _intercept2d(const p1,p2,p:GDBVertex2D;const dirx, diry: GDBDouble): GDBBoolean;
var
   t1, t2, d, d1, d2: GDBDouble;
begin
  result := false;
  D := (p2.y - p1.y) * (dirx) - (diry) * (p2.x - p1.x);
  D1 := (p2.y - p1.y) * (p.x - p1.x) - (p.y - p1.y) * (p2.x - p1.x);
  D2 := (p.y - p1.y) * (dirx) - (diry) * (p.x - p1.x);
  if (D <> 0) then
  begin
    t1 := D2 / D;
    t2 := D1 / D;
    if ((t1 <= 1) and (t1 >= 0) and (t2 >= 0)) then
    begin
      result := true;
    end;
  end;
end;
procedure GDBPolyline2DArray.optimize;
begin
     while _optimize do
     begin

     end;
end;

function GDBPolyline2DArray._optimize;
var
    pvprev,pv,pvnext:PGDBVertex2D;
    v1,v2:gdbvertex;
    i{,c}:integer;

begin
    result:=false;
    if count<2 then exit;
    //c:=0;
    pv:=parray;
    pvnext:=pv;
    inc(pvnext);
    pvprev:=self.getelement(count-1);
    for i:=0 to count-1 do
    begin
             if i=count-1 then
                      pvnext:=parray;
       v1.x:=pv.x-pvprev.x;
       v1.y:=pv.y-pvprev.y;
       v1.z:=0;
       v2.x:=pvnext.x-pv.x;
       v2.y:=pvnext.y-pv.y;
       v2.z:=0;

       if IsVectorNul(vectordot(v1,v2))then
       begin
            result:=true;
            self.deleteelement(i);
            exit;
       end;

       pvprev:=pv;
       inc(pv);
       inc(pvnext);
    end;
end;

function GDBPolyline2DArray.ispointinside(point:GDBVertex2D):GDBBoolean;
var
    pv,pvnext:PGDBVertex2D;
    i,c:integer;

begin
    result:=false;
    if count<2 then exit;
    c:=0;
    pv:=parray;
    pvnext:=pv;
    inc(pvnext);
    for i:=1 to count do
    begin
       if i=count then
                      pvnext:=parray;
       if _intercept2d(pv^,pvnext^,point,1,0) then
                                                  inc(c);
       inc(pv);
       inc(pvnext);
    end;
    result:=((c mod 2)=1);
end;

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
  oglsm.myglbegin(GL_LINE_STRIP);
  iterategl(oglsm.myglvertex2dv);
  oglsm.myglend;
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

  if {GDB.GetCurrentDWG.OGLwindow1.param.seldesc.MouseFrame}Inv{erse} then
  begin
  while i>0 do{or i:=0 to count-1 do}
  begin
     begin
          pp:=p;
          inc(p);
          if (i<>1) and pointinquad2d(Frame1.x, Frame1.y, Frame2.x, Frame2.y, p.x,p.y)
          then
          begin
               result := true;
               exit;
          end
          else
          if pointinquad2d(Frame1.x, Frame1.y, Frame2.x, Frame2.y, pp.x,pp.y)
          then
          begin
               result := true;
               exit;
          end
          else
          if
          (i<>1) and
          intercept2d2(Frame1.x, Frame1.y, Frame2.x, Frame1.y, p.x,p.y,pp.x,pp.y)
       or intercept2d2(Frame2.x, Frame1.y, Frame2.x, Frame2.y, p.x,p.y,pp.x,pp.y)
       or intercept2d2(Frame2.x, Frame2.y, Frame1.x, Frame2.y, p.x,p.y,pp.x,pp.y)
       or intercept2d2(Frame1.x, Frame2.y, Frame1.x, Frame1.y, p.x,p.y,pp.x,pp.y)
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
          if not pointinquad2d(Frame1.x, Frame1.y, Frame2.x, Frame2.y, p.x,p.y)
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
{function GDBPolyline2DArray.onmouse;
var i:GDBInteger;
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
     d:=distance2piece(mc,ptpv1^,ptpv0^);
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
end;}
begin
end.
