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

unit UGDBPolyLine2DArray;
{$Mode delphi}{$H+}
{$Include zengineconfig.inc}
interface
uses uzegeometrytypes,gzctnrVector,sysutils,uzegeometry,
     gzctnrVectorTypes,math;
type
{Export+}
{REGISTEROBJECTTYPE GDBPolyline2DArray}
PGDBPolyline2DArray=^GDBPolyline2DArray;
GDBPolyline2DArray= object(GZVector{-}<TzePoint2d>{//})
                      closed:Boolean;
                      constructor init(m:Integer;c:Boolean);

                      //function onmouse(mc:TzePoint2i):Boolean;virtual;
                      procedure optimize;virtual;
                      function _optimize:Boolean;virtual;
                      function inrect(Frame1, Frame2: TzePoint2i;inv:Boolean):Boolean;virtual;
                      function inrectd(Frame1, Frame2: TzePoint2d;inv:Boolean):Boolean;virtual;
                      function ispointinside(const point:TzePoint2d):Boolean;virtual;
                      procedure transform(const t_matrix:DMatrix4d);virtual;
                      function getoutbound:TBoundingBox;virtual;
                end;
{Export-}
function _intercept2d(const p1,p2,p:TzePoint2d;const dirx, diry: Double): Boolean;
implementation
function GDBPolyline2DArray.getoutbound;
var
    tt,b,l,r:Double;
    ptv:PzePoint2d;
    ir:itrec;
begin
  l:=Infinity;
  b:=Infinity;
  r:=NegInfinity;
  tt:=NegInfinity;
  ptv:=beginiterate(ir);
  if ptv<>nil then
  begin
  repeat
        if ptv.x<l then
                 l:=ptv.x;
        if ptv.x>r then
                 r:=ptv.x;
        if ptv.y<b then
                 b:=ptv.y;
        if ptv.y>tt then
                 tt:=ptv.y;
        ptv:=iterate(ir);
  until ptv=nil;
  result.LBN:=CreateVertex(l,B,0);
  result.RTF:=CreateVertex(r,Tt,0);

  end
              else
  begin
  result.LBN:=CreateVertex(-1,-1,-1);
  result.RTF:=CreateVertex(1,1,1);
  end;
end;

procedure GDBPolyline2DArray.transform(const t_matrix:DMatrix4d);
var
    pv:PzePoint2d;
    tv:TzePoint3d;
    i{,c}:integer;

begin
    pv:=GetParrayAsPointer;
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
function _intercept2d(const p1,p2,p:TzePoint2d;const dirx, diry: Double): Boolean;
var
   t1, t2, d, d1, d2: Double;
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
    pvprev,pv,pvnext:PzePoint2d;
    v1,v2:TzePoint3d;
    i{,c}:integer;

begin
    result:=false;
    if count<2 then exit;
    //c:=0;
    pv:=GetParrayAsPointer;
    pvnext:=pv;
    inc(pvnext);
    pvprev:=self.getDataMutable(count-1);
    for i:=0 to count-1 do
    begin
             if i=count-1 then
                      pvnext:=GetParrayAsPointer;
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

function GDBPolyline2DArray.ispointinside(const point:TzePoint2d):Boolean;
var
    pv,pvnext:PzePoint2d;
    i,c:integer;

begin
    result:=false;
    if count<2 then exit;
    c:=0;
    pv:=GetParrayAsPointer;
    pvnext:=pv;
    inc(pvnext);
    for i:=1 to count do
    begin
       if i=count then
                      pvnext:=GetParrayAsPointer;
       if _intercept2d(pv^,pvnext^,point,1,0) then
                                                  inc(c);
       inc(pv);
       inc(pvnext);
    end;
    result:=((c mod 2)=1);
end;

constructor GDBPolyline2DArray.init;
begin
  inherited init(m);
  closed:=c;
end;
function GDBPolyline2DArray.inrect;
var p,pp:PzePoint2d;
//    counter:Integer;
    i:Integer;
//    lines:Boolean;
begin
  result := false;
  if (count<2){or(not POGLWND^.seldesc.MouseFrameInverse)} then exit;
  p:=GetParrayAsPointer;
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
function GDBPolyline2DArray.inrectd;
var p,pp:PzePoint2d;
//    counter:Integer;
    i:Integer;
//    lines:Boolean;
begin
  result := false;
  if (count<2){or(not POGLWND^.seldesc.MouseFrameInverse)} then exit;
  p:=GetParrayAsPointer;
  i:=count;

  if {GDB.GetCurrentDWG.OGLwindow1.param.seldesc.MouseFrame}Inv{erse} then
  begin
  while i>0 do{or i:=0 to count-1 do}
  begin
     begin
          pp:=p;
          //inc(p);
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
begin
end.
