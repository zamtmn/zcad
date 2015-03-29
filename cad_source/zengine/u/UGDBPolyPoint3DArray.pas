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
     {varmandef,}OGLSpecFunc;
type
{Export+}
PGDBPolyPoint3DArray=^GDBPolyPoint3DArray;
GDBPolyPoint3DArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      procedure DrawGeometry;virtual;
                      procedure DrawNiceGeometry;virtual;
                      procedure SimpleDrawGeometry(const num:integer);virtual;
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
    emptycount,fullycount:GDBInteger;
    //d:GDBDouble;
    //ptpv0,ptpv1:PGDBPolyVertex3D;
    subresult:TInRect;
begin
  result:=IREmpty;
  if count<2 then
                 exit;
  p:=parray;
  counter:=0;
  points:=-1;
  emptycount:=0;
  fullycount:=0;
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
     if (subresult=IRFully)then
                               begin
                                  if emptycount>0 then
                                                      begin
                                                           result:=IRPartially;
                                                           exit;
                                                      end;
                                  inc(fullycount);
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
     if (fullycount>0)and(emptycount=0) then
                                            result:=IRFully
else if (fullycount>0)and(emptycount>0) then
                                            result:=IRPartially;
                     {else
                       result:=IREmpty;}
end;
constructor GDBPolyPoint3DArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(GDBPolyVertex3D));
end;
procedure GDBPolyPoint3DArray.drawnicegeometry;
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
                                                      oglsm.myglbegin(GL_LINES)
                                end
                              else
                                  begin
                                       if counter<0 then oglsm.myglend;
                                       oglsm.myglbegin(GL_LINE_STRIP);
                                       counter:=p^.count;
                                  end;
         end;
     oglsm.myglvertex3dv(@p^.coord);
     inc(p);
     dec(counter);
     if (counter=0)then
                       begin
                            oglsm.myglend;
                       end;
  end;
  oglsm.myglend;
end;
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
    //counter,lines,points:GDBInteger;
    i:GDBInteger;
    //v1,v2:gdbvertex;
    //ir:itrec;
    //emptycount:GDBInteger;
    //d:GDBDouble;
    //ptpv0,ptpv1:PGDBPolyVertex3D;
    //subresult:TInRect;
begin

  if count>1 then
  begin
  oglsm.myglbegin(GL_LINES);
  p:=parray;
  for i:=0 to count-1 do
  begin
          //oglsm.myglvertex3dv(pointer(p));
          //inc(p);
     //myglVertex(p.coord.x+random(5)/10,p.coord.y+random(5)/10,p.coord.z+random(5)/10);
          if p^.count<0 then
                            begin
                            oglsm.myglvertex3dv(pointer(p));
                            oglsm.myglvertex3dv(pointer(p));
                            end
                        else
                            oglsm.myglvertex3dv(pointer(p));
                            //myglVertex(p.coord.x+random(5)/10,p.coord.y+random(5)/10,p.coord.z+random(5)/10);
     inc(p);
  end;
  oglsm.myglend;

  end;

  (*p:=beginiterate(ir);
  if p<>nil then
  begin
        myglbegin(GL_LINES);
        repeat
          {if p^.count>=0 then} myglvertex3dv(pointer(p));
          if p^.count<0 then
                            myglvertex3dv(pointer(p));
          p:=iterate(ir);
        until p=nil;
        myglend;
  end;*)
  {myglbegin(GL_LINEs);
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
     begin
     myglvertex3dv(@v1);
     myglvertex3dv(@v2);
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
  myglend;}
end;
procedure GDBPolyPoint3DArray.simpledrawgeometry(const num:integer);
var p,pp:PGDBPolyVertex3D;
    totalcounter,{counter,lines,points,}linenumber:GDBInteger;
    i:GDBInteger;
    //v1,v2:gdbvertex;
    //ir:itrec;
    //emptycount:GDBInteger;
    //d:GDBDouble;
    //ptpv0,ptpv1:PGDBPolyVertex3D;
    //subresult:TInRect;
begin
  if self.Count>10 then
  if self.PArray<>nil then
  begin
        case num of
        1:
          begin
                oglsm.myglbegin(GL_LINES);
                oglsm.myglvertex3dv(self.PArray);
                oglsm.myglvertex3dv(self.getelement(self.Count-1));
                oglsm.myglend;
          end;
        2:
          begin
                oglsm.myglbegin(GL_LINES);
                //if count<num then exit;
                p:=parray;
                pp:=nil;
                linenumber:=0;
                for i:=0 to count-1 do
                begin
                   if linenumber<>p^.LineNumber then
                   begin
                        if pp<>nil then
                                       oglsm.myglvertex3dv(@pp^.coord);
                        oglsm.myglvertex3dv(@p^.coord);
                        linenumber:=p^.LineNumber;
                   end;
                   pp:=p;
                   inc(p);
                   inc(totalcounter);
                end;
                oglsm.myglvertex3dv(@pp^.coord);
                oglsm.myglend;
          end;
        end;
  end;

  {
  myglbegin(GL_LINE_strip);
  if count<num then exit;
  p:=parray;
  counter:=0;
  points:=-1;
  totalcounter:=0;
  for i:=0 to count-1 do
  begin
     if (totalcounter mod num)=1 then
     myglvertex3dv(@p^.coord);
     inc(p);
     inc(totalcounter);
  end;
  myglend;
  }


  {myglbegin(GL_LINEs);
  if count<2 then exit;
  p:=parray;
  counter:=0;
  points:=-1;
  totalcounter:=0;
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
     //myglbegin(GL_LINEs);
     if 2<p^.len then
     begin
     //if (totalcounter mod num)=1 then
     begin
          myglvertex3dv(@v1);
          myglvertex3dv(@v2);
     end;
     inc(totalcounter);
     end;
     //myglend;
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
  myglend;}
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBPolyPoint3DArray.initialization');{$ENDIF}
end.

