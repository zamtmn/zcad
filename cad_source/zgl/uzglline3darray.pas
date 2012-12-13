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

unit uzglline3darray;
{$INCLUDE def.inc}
interface
uses gdbasetypes,UGDBOpenArrayOfData,sysutils,gdbase,memman,
{$IFNDEF DELPHI}gl,glu,{$ELSE}opengl,{$ENDIF}
geometry;
type
{Export+}
ZGLLine3DArray=object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBVertex*)
                constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                constructor initnul;
                {function onpoint(p:gdbvertex;closed:GDBBoolean):gdbboolean;
                function onmouse(const mf:ClipArray;const closed:GDBBoolean):GDBBoolean;virtual;
                function CalcTrueInFrustum(frustum:ClipArray):TInRect;virtual;}
                procedure DrawGeometry;virtual;
                {procedure DrawGeometry2;virtual;
                procedure DrawGeometryWClosed(closed:GDBBoolean);virtual;}
             end;
{Export-}
implementation
uses OGLSpecFunc,log;
procedure ZGLLine3DArray.drawgeometry;
var p:PGDBVertex;
    i:GDBInteger;
begin
  //if count<2 then exit;
  p:=parray;
  oglsm.myglbegin(GL_LINES);
  for i:=0 to count-{3}1 do
  begin
     oglsm.myglVertex3dV(@p^);
     //oglsm.myglVertex3dV(@p^);

     inc(p);
  end;
  //oglsm.myglVertex3dV(@p^);
  oglsm.myglend;
end;
{procedure GDBPoint3DArray.drawgeometry2;
var p:PGDBVertex;
    i:GDBInteger;
begin
  if count<2 then exit;
  p:=parray;
  oglsm.myglbegin(GL_LINE_STRIP);
  oglsm.myglVertex3dV(@p^);
  inc(p);
  for i:=0 to count-3 do
  begin
     oglsm.myglVertex3dV(@p^);
     inc(p);
  end;
  oglsm.myglVertex3dV(@p^);
  oglsm.myglend;
end;
procedure GDBPoint3DArray.DrawGeometryWClosed(closed:GDBBoolean);
var p:PGDBVertex;
    i:GDBInteger;
begin
  if closed then
  begin
  if count<2 then exit;
  p:=parray;
  oglsm.myglbegin(GL_LINES);
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
end;
function GDBPoint3DArray.CalcTrueInFrustum;
var i,emptycount:GDBInteger;
    ptpv0,ptpv1:PGDBVertex;
    subresult:TInRect;
begin
   emptycount:=0;
   ptpv0:=parray;
   ptpv1:=ptpv0;
   inc(ptpv1);
   i:=0;
   while i<(count-1) do
   begin
     subresult:=geometry.CalcTrueInFrustum (ptpv0^,ptpv1^,frustum);
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
     if emptycount=0 then
                       result:=IRFully
                     else
                       result:=IREmpty;
end;
function GDBPoint3DArray.onmouse;
var i:GDBInteger;
    ptpv0,ptpv1:PGDBVertex;
begin
  result:=false;
   ptpv0:=parray;
   ptpv1:=ptpv0;
   inc(ptpv1);
   i:=0;
   while i<(count-1) do
   begin
     if geometry.CalcTrueInFrustum (ptpv0^,ptpv1^,mf)<>IREmpty
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
        ptpv1:=parray;
   if geometry.CalcTrueInFrustum (ptpv0^,ptpv1^,mf)<>IREmpty
                                                                        then
                                                                            result:=true
                                                                        else
                                                                            result:=false;
   end;
end;

function GDBPoint3DArray.onpoint(p:gdbvertex;closed:GDBBoolean):gdbboolean;
var i:GDBInteger;
    d:GDBDouble;
    ptpv0,ptpv1:PGDBVertex;
    a,b:integer;
begin
   result:=false;
   ptpv0:=parray;
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
                                       ptpv1:=parray;
     end;
   end;
end;}
constructor ZGLLine3DArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(gdbvertex));
end;
constructor ZGLLine3DArray.initnul;
begin
  inherited initnul;
  size:=sizeof(gdbvertex);
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBPoint3DArray.initialization');{$ENDIF}
end.

