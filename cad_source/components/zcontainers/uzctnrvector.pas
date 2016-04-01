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

unit uzctnrvector;
{$INCLUDE def.inc}
interface
uses uzbmemman,uzbtypesbase,sysutils,uzbtypes;
type
{Export+}
TZctnrVector{-}<T>{//}={$IFNDEF DELPHI}packed{$ENDIF}
            object(GDBaseObject)
                  {-}type{//}
                      {-}PT=^T;{//}
                      {-}TArr=array[0..0] of T;{//}
                      {-}PTArr=^TArr;{//}
                  {-}var{//}
                  PArray:{-}PTArr{/GDBPointer/};(*hidden_in_objinsp*)
                  GUID:GDBString;(*hidden_in_objinsp*)
                  Count:TArrayIndex;(*hidden_in_objinsp*)
                  Deleted:TArrayIndex;(*hidden_in_objinsp*)
                  Max:TArrayIndex;(*hidden_in_objinsp*)

                  constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:TArrayIndex);
                  constructor initnul;
                  destructor done;virtual;
                  destructor ClearAndDone;virtual;
                  function Size:TArrayIndex;
                  procedure Clear;virtual;
                  function CreateArray:GDBPointer;virtual;
                  procedure Grow(newmax:GDBInteger=0);virtual;
                  procedure Shrink;virtual;
                  procedure setsize(nsize:TArrayIndex);
                  function getelement(index:TArrayIndex):GDBPointer;
                  procedure freeelement(p:GDBPointer);virtual;abstract;
                  function GetElemCount:GDBInteger;

                  function AddByPointer(p:GDBPointer):TArrayIndex;virtual;
                  function AddByRef(var obj):TArrayIndex;virtual;

                  function beginiterate(out ir:itrec):GDBPointer;virtual;
                  function iterate(var ir:itrec):GDBPointer;virtual;

                  procedure free;virtual;
                  procedure freewithproc(freeproc:freeelproc);virtual;
                  function SetCount(index:GDBInteger):GDBPointer;virtual;
                  procedure Invert;
                  function copyto(var source:TZctnrVector<T>):GDBInteger;virtual;
                  function GetRealCount:GDBInteger;
                  function AddData(PData:GDBPointer;SData:GDBword):GDBInteger;virtual;
                  function AllocData(SData:GDBword):GDBPointer;virtual;
            end;
{Export-}
implementation
function TZctnrVector<T>.AllocData(SData:GDBword):GDBPointer;
begin
  if parray=nil then
                    createarray;
  if count+sdata>max then
                         Grow((count+sdata)*2);
  result:=pointer(GDBPlatformUInt(parray)+count*size);
  {$IFDEF FILL0ALLOCATEDMEMORY}
  fillchar(result^,sdata,0);
  {$ENDIF}
  inc(count,SData);
end;
function TZctnrVector<T>.AddData(PData:GDBPointer;SData:GDBword):GDBInteger;
var addr:GDBPlatformint;
begin
  if parray=nil then
                    createarray;
  if count+sdata>max then
                         begin
                              if count+sdata>2*max then
                                                       {Grow}SetSize(count+sdata)
                                                   else
                                                        Grow;
                         end;
  {if count = max then
                     begin
                          parray := enlargememblock(parray, size * max, 2*size * max);
                          max:=2*max;
                     end;}
  begin
       GDBPointer(addr) := parray;
       addr := addr + count;
       Move(PData^, GDBPointer(addr)^,SData);
       result:=count;
       inc(count,SData);
  end;
end;
function TZctnrVector<T>.GetRealCount:GDBInteger;
var p:GDBPointer;
    ir:itrec;
begin
  result:=0;
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        inc(result);
        p:=iterate(ir);
  until p=nil;
end;
function TZctnrVector<T>.copyto(var source:TZctnrVector<T>):GDBInteger;
var p:GDBPointer;
    ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        source.AddByPointer(@p^);  //-----------------//-----------
        p:=iterate(ir);
  until p=nil;
  result:=count;
end;
procedure TZctnrVector<T>.Invert;
var p,pl,tp:GDBPointer;
    ir:itrec;
begin
  p:=beginiterate(ir);
  p:=getelement({count-1}0);
  pl:=getelement(count-1);
  GDBGetMem({$IFDEF DEBUGBUILD}'{D9D91D43-BD6A-450A-B07E-E964425E7C99}',{$ENDIF}tp, size);
  if p<>nil then
  repeat
        if GDBPlatformUInt(pl)<=GDBPlatformUInt(p) then
                                         break;
        Move(p^,tp^,size);
        Move(pl^,p^,size);
        Move(tp^,pl^,size);
        dec(GDBPlatformUInt(pl),size);
        inc(GDBPlatformUInt(p),size);
        //p:=iterate(ir);
  until {p=nil}false;
  GDBFreeMem(tp);
end;
function TZctnrVector<T>.SetCount;
begin
     count:=index;
     if parray=nil then
                        createarray;
     if count>=max then
                       begin
                            if count>2*max then
                                               setsize(2*count)
                                           else
                                               setsize(2*max);
                       end;
     result:=parray;
end;
procedure TZctnrVector<T>.freewithproc;
var p:GDBPointer;
    ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        freeproc(p);
        p:=iterate(ir);
  until p=nil;
  clear;
end;
procedure TZctnrVector<T>.free;
var p:GDBPointer;
    ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        freeelement(p);
        p:=iterate(ir);
  until p=nil;
  clear;
end;
function TZctnrVector<T>.beginiterate;
begin
  if parray=nil then
                    result:=nil
                else
                    begin
                          ir.itp:=pointer(GDBPlatformUInt(parray)-size);
                          ir.itc:=-1;
                          result:=iterate(ir);
                    end;
end;
function TZctnrVector<T>.iterate;
begin
  if count=0 then result:=nil
  else if ir.itc<(count-1) then
                      begin
                           inc(pGDBByte(ir.itp),size);
                           inc(ir.itc);

                           result:=ir.itp;
                      end
                  else result:=nil;
end;
function TZctnrVector<T>.AddByRef;
var
   p:pointer;
begin
     p:=@obj;
     result:=AddByPointer(@p)
end;
function TZctnrVector<T>.AddByPointer;
var addr: GDBPlatformint;
begin
  if parray=nil then
                     CreateArray;
  if count = max then
                     grow;
  begin
       GDBPointer(addr) := parray;
       addr := addr + count * size;
       Move(p^, GDBPointer(addr)^,size);
       result:=count;
       inc(count);
  end;
end;
constructor TZctnrVector<T>.initnul;
begin
  PArray:=nil;
  pointer(GUID):=nil;
  Count:=0;
  Deleted:=0;
  Max:=0;
end;
constructor TZctnrVector<T>.init;
begin
  PArray:=nil;
  pointer(GUID):=nil;
  Count:=0;
  Deleted:=0;
  Max:=m;
  {$IFDEF DEBUGBUILD}Guid:=ErrGuid;{$ENDIF}
  //CreateArray;
  { TODO: делаем познее выделение }
  //GDBGetMem({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}PArray, size * max);
end;
destructor TZctnrVector<T>.done;
begin
  if PArray<>nil then
                     GDBFreeMem(PArray);
  PArray:=nil;
  {$IFDEF DEBUGBUILD}Guid:='';{$ENDIF}
end;
destructor TZctnrVector<T>.clearanddone;
begin
     clear;
     done;
end;
function TZctnrVector<T>.Size:TArrayIndex;
begin
  result:=sizeof(T);
end;
procedure TZctnrVector<T>.clear;
begin
  count:=0;
  deleted:=0;
end;
function TZctnrVector<T>.CreateArray;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}@Guid[1],{$ENDIF}PArray, size*max);
  result:=parray;
end;
procedure TZctnrVector<T>.Grow;
begin
     if newmax<=0 then
                     newmax:=2*max;
     parray := enlargememblock({$IFDEF DEBUGBUILD}@Guid[1],{$ENDIF}parray, size * max, size * newmax);
     max:=newmax;
end;
procedure TZctnrVector<T>.Shrink;
begin
  if (count<>0)and(count<max) then
  begin
       parray := remapmememblock({$IFDEF DEBUGBUILD}@Guid[1],{$ENDIF}parray, size * count);
       max := count;
  end;
end;
procedure TZctnrVector<T>.SetSize;
begin
     if nsize>max then
                      begin
                           parray := enlargememblock({$IFDEF DEBUGBUILD}@Guid[1],{$ENDIF}parray, size * max, size*nsize);
                      end
else if nsize<max then
                      begin
                           parray := enlargememblock({$IFDEF DEBUGBUILD}@Guid[1],{$ENDIF}parray, size * max, size*nsize);
                           if count>nsize then count:=nsize;

                      end;
max:=nsize;
end;
function TZctnrVector<T>.getelement;
begin
     if (index>=max)or(index<0) then
                        result:=nil
                    else
     begin
  result := PArray;
  inc(pGDBByte(result),size*index);
     end;
end;
function TZctnrVector<T>.GetElemCount:GDBInteger;
begin
  result:=count-deleted;
end;
begin
end.
