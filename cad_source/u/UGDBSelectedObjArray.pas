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

unit UGDBSelectedObjArray;
{$INCLUDE def.inc}
interface
uses GDBEntity,UGDBControlPointArray,UGDBOpenArrayOfData{, oglwindowdef},sysutils,gdbase, geometry,
     gl,
     gdbasetypes{,varmandef,gdbobjectsconstdef},memman,OGLSpecFunc;
type
{Export+}
PSelectedObjDesc=^SelectedObjDesc;
SelectedObjDesc=record
                      objaddr:PGDBObjEntity;
                      pcontrolpoint:PGDBControlPointArray;
                      ptempobj:PGDBObjEntity;
                end;
GDBSelectedObjArray=object(GDBOpenArrayOfData)
                          SelectedCount:GDBInteger;
                          constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);

                          function addobject(objnum:PGDBObjEntity):pselectedobjdesc;virtual;
                          procedure clearallobjects;virtual;
                          procedure remappoints;virtual;
                          procedure drawpoint;virtual;
                          procedure drawobject(infrustumactualy:TActulity);virtual;
                          function getnearesttomouse:tcontrolpointdist;virtual;
                          procedure selectcurrentcontrolpoint(key:GDBByte);virtual;
                          procedure RenderFeedBack;virtual;
                          //destructor done;virtual;
                          procedure modifyobj(dist,wc:gdbvertex;save:GDBBoolean;pconobj:pgdbobjEntity);virtual;
                          procedure drawobj(infrustumactualy:TActulity);virtual;
                          procedure freeelement(p:GDBPointer);virtual;
                          function calcvisible(frustum:cliparray;infrustumactualy:TActulity;visibleactualy:TActulity):GDBBoolean;virtual;
                          procedure resprojparam;
                    end;
{EXPORT-}
implementation
uses {oglwindow,}ugdbdescriptor,log;
procedure GDBSelectedObjArray.resprojparam;
var tdesc:pselectedobjdesc;
    i:GDBInteger;
begin
  if count<>0 then
  begin
       tdesc:=parray;
       for i:=0 to count-1 do
       begin
            //dec(tdesc^.objaddr^.vp.LastCameraPos);
            tdesc^.objaddr^.Renderfeedback;
            inc(tdesc);
       end;
  end;
end;
procedure GDBSelectedObjArray.freeelement;
begin
  if PSelectedObjDesc(p).pcontrolpoint<>nil then
                                                begin
                                                     PSelectedObjDesc(p).pcontrolpoint^.FreeAndDone;
                                                     gdbfreemem(GDBPointer(PSelectedObjDesc(p).pcontrolpoint));
                                                end;
  if PSelectedObjDesc(p).ptempobj<>nil then
                                           begin
                                                PSelectedObjDesc(p).ptempobj^.done;
                                                gdbfreemem(GDBPointer(PSelectedObjDesc(p).ptempobj));
                                           end;
  //PGDBObjBlockdef(p).Entities.ClearAndDone;
end;
constructor GDBSelectedObjArray.init;
begin
  {Count := 0;
  Max := m;
  Size := sizeof(selectedobjdesc);
  GDBGetMem(PArray, size * max);}
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(selectedobjdesc));
end;
function GDBSelectedObjArray.addobject;
var tdesc:pselectedobjdesc;
    i:GDBInteger;
begin
  result:=nil;
  if PARRAY=nil then
                    createarray;
  tdesc:=parray;
  if count<>0 then
  begin
       for i:=0 to count-1 do
       begin
            if tdesc^.objaddr=objnum then
            begin
                 result:=tdesc;
                 exit;
            end;
            inc(tdesc);
       end;
  end;
  if count=max then exit;
  result:=tdesc;
  inc(count);
  tdesc^.objaddr:=objnum;
  tdesc^.pcontrolpoint:=nil;
  tdesc^.ptempobj:=nil;
end;
procedure GDBSelectedObjArray.clearallobjects;
var tdesc:pselectedobjdesc;
    i:GDBInteger;
begin
  tdesc:=parray;
  if count<>0 then
  begin
       for i:=0 to count-1 do
       begin
            if tdesc^.pcontrolpoint<>nil then
            begin
                tdesc^.pcontrolpoint^.done;
                GDBFreeMem(GDBPointer(tdesc^.pcontrolpoint));
            end;
            if tdesc^.ptempobj<>nil then
            begin
                 tdesc^.ptempobj^.done;
                 GDBFreeMem(GDBPointer(tdesc^.ptempobj));
            end;
            inc(tdesc);
       end;
  end;
  count:=0;
end;
procedure GDBSelectedObjArray.drawpoint;
var tdesc:pselectedobjdesc;
    i:GDBInteger;
begin
  if count<>0 then
  begin
       tdesc:=parray;
       glpointsize(10);
       myglbegin(gl_points);
       for i:=0 to count-1 do
       begin
            if tdesc^.pcontrolpoint<>nil then
            begin
                 tdesc^.pcontrolpoint^.draw;
            end;
            inc(tdesc);
       end;
       myglend;
       glpointsize(1);
  end;
end;
procedure GDBSelectedObjArray.RenderFeedBack;
var tdesc:pselectedobjdesc;
    i:GDBInteger;
begin
  if count<>0 then
  begin
       tdesc:=parray;
       for i:=0 to count-1 do
       begin
            if tdesc^.objaddr<>nil then
            begin
                 tdesc^.objaddr^.RenderFeedbackIFNeed;
            end;
            inc(tdesc);
       end;
  end;
end;procedure GDBSelectedObjArray.drawobject;
var tdesc:pselectedobjdesc;
    i:GDBInteger;
begin
  if count<>0 then
  begin
       tdesc:=parray;
       for i:=0 to count-1 do
       begin
            if tdesc^.objaddr<>nil then
            begin
                 tdesc^.objaddr^.DrawWithOutAttrib(infrustumactualy); //DrawGeometry(tdesc^.objaddr^.CalculateLineWeight);
            end;
            inc(tdesc);
       end;
  end;
end;
procedure GDBSelectedObjArray.remappoints;
var tdesc:pselectedobjdesc;
    i:GDBInteger;
begin
  if count<>0 then
  begin
       tdesc:=parray;
       for i:=0 to count-1 do
       begin
            if tdesc^.pcontrolpoint<>nil then
            begin
                 tdesc^.objaddr^.remapcontrolpoints(tdesc^.pcontrolpoint);
            end;
            inc(tdesc);
       end;
  end;
end;
function GDBSelectedObjArray.getnearesttomouse;
var i: GDBInteger;
//  d: GDBDouble;
  td:tcontrolpointdist;
  tdesc:pselectedobjdesc;
begin
  td.pcontrolpoint := nil;
  td.disttomouse:=9999;
  if count > 0 then
  begin
    tdesc:=parray;
    for i := 0 to count - 1 do
    begin
      if tdesc^.pcontrolpoint<>nil then tdesc^.pcontrolpoint^.getnearesttomouse(td);
      inc(tdesc);
    end;
  end;
  result:=td;
end;
procedure GDBSelectedObjArray.modifyobj;
var i: GDBInteger;
//  d: GDBDouble;
//  td:tcontrolpointdist;
  tdesc:pselectedobjdesc;
begin
  if count > 0 then
  begin
    tdesc:=parray;
    for i := 0 to count - 1 do
    begin
      if tdesc^.pcontrolpoint<>nil then
        if tdesc^.pcontrolpoint^.SelectedCount<>0 then
        begin
           {tdesc^.objaddr^}gdb.rtmodify(tdesc^.objaddr,tdesc,dist,wc,save);
        end;
      inc(tdesc);
    end;
  end;
  if save then
              gdb.GetCurrentROOT.FormatAfterEdit;

end;
function GDBSelectedObjArray.calcvisible;
{var
  p:pGDBObjEntity;
  q:GDBBoolean;}
var i: GDBInteger;
//  d: GDBDouble;
//  td:tcontrolpointdist;
  tdesc:pselectedobjdesc;
begin
  {result:=false;
  p:=beginiterate;
  if p<>nil then
  repeat
       q:=p^.calcvisible;
       result:=result or q;
       p:=iterate;
  until p=nil;}
  if count > 0 then
  begin
    tdesc:=parray;
    for i := 0 to count - 1 do
    begin
      if tdesc^.ptempobj<>nil then
                                  tdesc^.ptempobj^.calcvisible(frustum,infrustumactualy,visibleactualy);
      inc(tdesc);
    end;
  end;

end;
procedure GDBSelectedObjArray.drawobj;
var i: GDBInteger;
//  d: GDBDouble;
//  td:tcontrolpointdist;
  tdesc:pselectedobjdesc;
begin
  if count > 0 then
  begin
    tdesc:=parray;
    for i := 0 to count - 1 do
    begin
      if tdesc^.ptempobj<>nil then
                                  tdesc^.ptempobj^.DrawWithAttrib(infrustumactualy);
      inc(tdesc);
    end;
  end;

end;
procedure GDBSelectedObjArray.selectcurrentcontrolpoint;
var i: GDBInteger;
//  d: GDBDouble;
  td:tcontrolpointdist;
  tdesc:pselectedobjdesc;
begin
  td.pcontrolpoint := nil;
  td.disttomouse:=9999;
  SelectedCount:=0;
  if count > 0 then
  begin
    tdesc:=parray;
    for i := 0 to count - 1 do
    begin
      if tdesc^.pcontrolpoint<>nil then tdesc^.pcontrolpoint^.selectcurrentcontrolpoint(key);
      SelectedCount:=SelectedCount+tdesc^.pcontrolpoint^.SelectedCount;
      inc(tdesc);
    end;
  end;
end;
{destructor GDBSelectedObjArray.done;
begin
  if pa then

  GDBFreeMem(PArray);
end;}
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBSelectedObjArray.initialization');{$ENDIF}
end.
