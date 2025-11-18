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

unit UGDBPoint3DArray;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses uzegeometrytypes,gzctnrVector,sysutils,math,
     gzctnrVectorTypes,{uzgloglstatemanager,}uzegeometry;
type
{Export+}
{REGISTEROBJECTTYPE GDBPoint3dArray}
PGDBPoint3dArray=^GDBPoint3dArray;
GDBPoint3dArray= object(GZVector{-}<TzePoint3d>{//})
                function onpoint(const p:TzePoint3d;closed:Boolean):Boolean;
                function onmouse(const mf:ClipArray;const closed:Boolean):Boolean;virtual;
                function CalcTrueInFrustum(const frustum:ClipArray; const closed:boolean):TInBoundingVolume;virtual;
                {procedure DrawGeometry;virtual;
                procedure DrawGeometry2;virtual;
                procedure DrawGeometryWClosed(closed:Boolean);virtual;}
                function getoutbound:TBoundingBox;virtual;
             end;
{Export-}
implementation
function GDBPoint3DArray.getoutbound;
var
    tt,b,l,r,n,f:Double;
    ptv:PzePoint3d;
    ir:itrec;
begin
  l:=Infinity;
  b:=Infinity;
  n:=Infinity;
  r:=NegInfinity;
  tt:=NegInfinity;
  f:=NegInfinity;
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
        if ptv.z<n then
                 n:=ptv.z;
        if ptv.z>f then
                 f:=ptv.z;
        ptv:=iterate(ir);
  until ptv=nil;
  result.LBN:=CreateVertex(l,B,n);
  result.RTF:=CreateVertex(r,Tt,f);

  end
              else
  begin
  result.LBN:=CreateVertex(-1,-1,-1);
  result.RTF:=CreateVertex(1,1,1);
  end;
end;

(*procedure GDBPoint3DArray.drawgeometry;
var p:PzePoint3d;
    i:Integer;
begin
  if count<2 then exit;
  p:=GetParrayAsPointer;
  oglsm.myglbegin(GL_LINES{_STRIP});
  oglsm.myglVertex3dV(@p^);
  inc(p);
  for i:=0 to count-3 do
  begin
     oglsm.myglVertex3dV(@p^);
     oglsm.myglVertex3dV(@p^);

     inc(p);
  end;
  oglsm.myglVertex3dV(@p^);
  oglsm.myglend;
end;
procedure GDBPoint3DArray.drawgeometry2;
var p:PzePoint3d;
    i:Integer;
begin
  if count<2 then exit;
  p:=GetParrayAsPointer;
  oglsm.myglbegin(GL_LINE_STRIP);
  oglsm.myglVertex3dV(@p^);
  inc(p);
  for i:=0 to count-3 do
  begin
     oglsm.myglVertex3dV(@p^);
     //oglsm.myglVertex3dV(@p^);

     inc(p);
  end;
  oglsm.myglVertex3dV(@p^);
  oglsm.myglend;
end;
procedure GDBPoint3DArray.DrawGeometryWClosed(closed:Boolean);
var p:PzePoint3d;
    i:Integer;
begin
  if closed then
  begin
  if count<2 then exit;
  p:=GetParrayAsPointer;
  oglsm.myglbegin(GL_LINES{_STRIP});
  oglsm.myglVertex3dV(@p^);
  inc(p);
  for i:=0 to count-3 do
  begin
     oglsm.myglVertex3dV(@p^);
     oglsm.myglVertex3dV(@p^);

     inc(p);
  end;
  oglsm.myglVertex3dV(@p^);
  oglsm.myglVertex3dV(@p^);
  oglsm.myglVertex3dV(@parray^);

  oglsm.myglend;
  end
     else drawgeometry;
end;*)
function GDBPoint3DArray.CalcTrueInFrustum;
var i,{counter,}emptycount:Integer;
//    d:Double;
    ptpv0,ptpv1:PzePoint3d;
    subresult:TInBoundingVolume;
begin
   //result:=IREmpty;
  if count=0 then
    exit(IRNotAplicable);
   emptycount:=0;
   ptpv0:=GetParrayAsPointer;
   ptpv1:=ptpv0;
   inc(ptpv1);
   i:=0;
   while i<(count-1) do
   begin
     subresult:=uzegeometry.CalcTrueInFrustum (ptpv0^,ptpv1^,frustum);
    if subresult=IREmpty then
                            begin
                                 inc(emptycount);
                            end;
     if subresult=IRPartially then
                                  begin
                                       result:=IRPartially;
                                       exit;
                                  end;
     if (subresult=IRFully)and(emptycount>0) then
                                  begin
                                       result:=IRPartially;
                                       exit;
                                  end;

      inc(i);
      inc(ptpv1);
      inc(ptpv0);
   end;

   if Closed then
     if count>2 then begin
       ptpv1:=getPFirst;
       ptpv0:=getPLast;
       subresult:=uzegeometry.CalcTrueInFrustum(ptpv0^,ptpv1^,frustum);
       if subresult=IREmpty then
         inc(emptycount);
       if subresult=IRPartially then
         exit(IRPartially);
       if (subresult=IRFully)and(emptycount>0) then
         exit(IRPartially)
     end;

   if emptycount=0 then
     result:=IRFully
   else
     result:=IREmpty;
end;
function GDBPoint3DArray.onmouse;
var i{,counter}:Integer;
//    d:Double;
    ptpv0,ptpv1:PzePoint3d;
begin
  result:=false;
   ptpv0:=GetParrayAsPointer;
   ptpv1:=ptpv0;
   inc(ptpv1);
   i:=0;
   while i<(count-1) do
   begin
     if uzegeometry.CalcTrueInFrustum (ptpv0^,ptpv1^,mf)<>IREmpty
                                                                          then
                                                                              result:=true
                                                                          else
                                                                              result:=false;
     if result then
     begin
          exit;
     end;
     begin
                            inc(i);
                            inc(ptpv1);
                            inc(ptpv0);
                       end;
   end;
   if closed then
   begin
        ptpv1:=GetParrayAsPointer;
   if uzegeometry.CalcTrueInFrustum (ptpv0^,ptpv1^,mf)<>IREmpty
                                                                        then
                                                                            result:=true
                                                                        else
                                                                            result:=false;
   end;
end;

function GDBPoint3DArray.onpoint(const p:TzePoint3d;closed:Boolean):Boolean;
var i{,counter}:Integer;
    d:Double;
    ptpv0,ptpv1:PzePoint3d;
    a,b:integer;
begin
   result:=false;
   ptpv0:=GetParrayAsPointer;
   ptpv1:=ptpv0;
   inc(ptpv1);
   i:=0;
   if closed then
                 a:=count
             else
                 a:=count-1;
   b:=count-1;
   while i<a do
   begin
     d:=SQRdist_Point_to_Segment(p,ptpv0^,ptpv1^);
     if d<=bigeps then
     begin
          result:=true;
          exit;
     end;
     begin
                            inc(i);
                            inc(ptpv1);
                            inc(ptpv0);
                            if i=b then
                                       ptpv1:=GetParrayAsPointer;
     end;
   end;
end;
begin
end.

