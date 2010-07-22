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

unit UGDBPolyPoint3DArray;
{$INCLUDE def.inc}
interface
uses gdbasetypes,UGDBOpenArrayOfData{, oglwindowdef},sysutils,gdbase, geometry,
     gl,
     {varmandef,}OGLSpecFunc;
type
{Export+}
PGDBPolyPoint3DArray=^GDBPolyPoint3DArray;
GDBPolyPoint3DArray=object(GDBOpenArrayOfData)
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      procedure DrawGeometry;virtual;
                      function CalcTrueInFrustum(frustum:ClipArray):TInRect;virtual;
                end;
{Export-}
implementation
uses
    log;
{function GDBPolyPoint3DArray.CalcTrueInFrustum;
var i,emptycount,counter:GDBInteger;
    d:GDBDouble;
    ptpv0,ptpv1:PGDBPolyVertex3D;
    subresult:TInRect;
begin
   result:=IREmpty;
   if count<2 then exit;
   ptpv0:=parray;
   ptpv1:=ptpv0;
   inc(ptpv1);
   counter:=0;
   i:=0;
   emptycount:=0;
   while i<(count-1) do
   begin
     if counter<=0 then counter:=ptpv0^.count;

     subresult:=geometry.CalcTrueInFrustum (ptpv1^.coord,ptpv0^.coord,frustum);
    if subresult=IREmpty then
                            begin
                                 inc(emptycount);
                            end;
     if subresult=IRPartially then
                                  begin
                                       result:=IRPartially;
                                       exit;
                                  end;
     if (result=IRFully)and(emptycount>0) then
                                  begin
                                       result:=IRPartially;
                                       exit;
                                  end;
     if counter<=0 then
                       begin
                            i:=i+2;
                            inc(ptpv1,2);
                            inc(ptpv0,2);
                       end
                   else
                       begin
                            inc(i);
                            //dec(counter);
                            counter:=ptpv0^.count;
                            inc(ptpv1);
                            inc(ptpv0);
                       end;
   end;
   if emptycount=0 then
                       result:=IRFully;

end;}
function GDBPolyPoint3DArray.CalcTrueInFrustum;
var p:PGDBPolyVertex3D;
    counter,lines,points:GDBInteger;
    i:GDBInteger;
    v1,v2:gdbvertex;
    emptycount:GDBInteger;
    //d:GDBDouble;
    //ptpv0,ptpv1:PGDBPolyVertex3D;
    subresult:TInRect;
begin
  if count<2 then
                 begin
                      result:=IREmpty;
                      exit;
                 end;
  p:=parray;
  counter:=0;
  points:=-1;
  emptycount:=0;
  for i:=0 to count-1 do
  begin
     if counter<=0
     then
         begin
              if p^.count=0 then
                                begin
                                     if counter=0 then
                                                      begin
                                                      points:=0;
                                                      lines:=1;
                                                      end;
                                end
                              else
                                  begin
                                       //if counter<0 then points:=-1;
                                       points:=0;
                                       lines:=0;
                                       counter:=p^.count;
                                  end;
         end;
     if points<>-1 then
     begin
     v1:=v2;
     v2:=p^.coord;
     inc(points);
     end;
     if points>=2 then
     begin

     subresult:=geometry.CalcTrueInFrustum (v1,v2,frustum);
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


     if lines=1 then
                    points:=0;
     end;



     inc(p);
     dec(counter);
     if (counter=0)then
                       begin
                            points:=-1;
                       end;
  end;
     if emptycount=0 then
                       result:=IRFully
                     else
                       result:=IREmpty;
end;
constructor GDBPolyPoint3DArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(GDBPolyVertex3D));
end;
{procedure GDBPolyPoint3DArray.drawgeometry;
var p:PGDBPolyVertex3D;
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
     glvertex3dv(@p^.coord);
     inc(p);
     dec(counter);
     if (counter=0)then
                       begin
                            myglend;
                       end;
  end;
  myglend;
end;}
{procedure GDBPolyPoint3DArray.drawgeometry;
var i,emptycount,counter:GDBInteger;
    d:GDBDouble;
    ptpv0,ptpv1:PGDBPolyVertex3D;
    subresult:TInRect;
begin
   if count<2 then exit;
   ptpv0:=parray;
   ptpv1:=ptpv0;
   inc(ptpv1);
   counter:=0;
   i:=0;
   emptycount:=0;
   counter:=ptpv0^.count;
   while i<(count-1) do
   begin
     //if counter=0 then counter:=ptpv0^.count;

     myglbegin(GL_LINEs);
     glvertex3dv(@ptpv1^.coord);
     glvertex3dv(@ptpv0^.coord);
     //subresult:=geometry.CalcTrueInFrustum (ptpv1^.coord,ptpv0^.coord,frustum);
     myglend;
     if counter<=0 then
                       begin
                            i:=i+2;
                            inc(ptpv1,2);
                            inc(ptpv0,2);
                            counter:=ptpv0^.count;
                       end
                   else
                       begin
                            inc(i);
                            dec(counter);
                            //counter:=ptpv0^.count;
                            inc(ptpv1);
                            inc(ptpv0);
                       end;
   end;
end;}
procedure GDBPolyPoint3DArray.drawgeometry;
var p:PGDBPolyVertex3D;
    counter,lines,points:GDBInteger;
    i:GDBInteger;
    v1,v2:gdbvertex;
    //emptycount:GDBInteger;
    //d:GDBDouble;
    //ptpv0,ptpv1:PGDBPolyVertex3D;
    //subresult:TInRect;
begin
  if count<2 then exit;
  p:=parray;
  counter:=0;
  points:=-1;
  for i:=0 to count-1 do
  begin
     if counter<=0
     then
         begin
              if p^.count=0 then
                                begin
                                     if counter=0 then
                                                      begin
                                                      points:=0;
                                                      lines:=1;
                                                      end;
                                end
                              else
                                  begin
                                       //if counter<0 then points:=-1;
                                       points:=0;
                                       lines:=0;
                                       counter:=p^.count;
                                  end;
         end;
     if points<>-1 then
     begin
     v1:=v2;
     v2:=p^.coord;
     inc(points);
     end;
     if points>=2 then
     begin
     myglbegin(GL_LINEs);
     myglvertex3dv(@v1);
     myglvertex3dv(@v2);
     myglend;
     if lines=1 then
                    points:=0;
     end;



     inc(p);
     dec(counter);
     if (counter=0)then
                       begin
                            points:=-1;
                       end;
  end;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBPolyPoint3DArray.initialization');{$ENDIF}
end.

