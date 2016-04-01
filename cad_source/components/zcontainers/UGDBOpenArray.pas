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

unit UGDBOpenArray;
{$INCLUDE def.inc}
interface
uses uzctnrvector,uzbtypesbase,sysutils,uzbmemman,uzbtypes;
type
{Export+}
PGDBOpenArray=^GDBOpenArray;
GDBOpenArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
           {released} Deleted:TArrayIndex;(*hidden_in_objinsp*)
           {released} Count:TArrayIndex;(*saved_to_shd*)(*hidden_in_objinsp*)
           {released} Max:TArrayIndex;(*hidden_in_objinsp*)
           {released} Size:TArrayIndex;(*hidden_in_objinsp*)
           {released} PArray:GDBPointer;(*hidden_in_objinsp*)
           {released} guid:GDBString;
           {released} constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m,s:GDBInteger);
           {released} constructor initnul;
           {released} function beginiterate(out ir:itrec):GDBPointer;virtual;
           {released} function iterate(var ir:itrec):GDBPointer;virtual;
           {released} destructor done;virtual;
           {released} destructor ClearAndDone;virtual;
           {released} procedure Clear;virtual;
           {released} function AddByPointer(p:GDBPointer):TArrayIndex;virtual;
           {released} function AddByRef(var obj):TArrayIndex;virtual;
           {released} procedure Shrink;virtual;
           {released} procedure Grow(newmax:GDBInteger=0);virtual;
           {released} procedure setsize(nsize:TArrayIndex);
           {released} function getelement(index:TArrayIndex):GDBPointer;
           {released} procedure Invert;
           {released} procedure free;virtual;
           {released} procedure freewithproc(freeproc:freeelproc);virtual;
           {released} procedure freeelement(p:GDBPointer);virtual;abstract;
           {released} function CreateArray:GDBPointer;virtual;
           {released} function SetCount(index:GDBInteger):GDBPointer;virtual;
           {released} function copyto(source:PGDBOpenArray):GDBInteger;virtual;
           {released} function GetRealCount:GDBInteger;
           {released} function AddData(PData:GDBPointer;SData:GDBword):GDBInteger;virtual;
           {released} function AllocData(SData:GDBword):GDBPointer;virtual;
           {released} function GetElemCount:GDBInteger;
             end;
{Export-}
implementation
//uses
//    log;
function GDBOpenArray.GetElemCount:GDBInteger;
begin
  result:=count-deleted;
end;
function GDBOpenArray.AllocData(SData:GDBword):GDBPointer;
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
function GDBOpenArray.AddData(PData:GDBPointer;SData:GDBword):GDBInteger;
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

function GDBOpenArray.copyto(source:PGDBOpenArray):GDBInteger;
var p:GDBPointer;
    ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        source^.AddByPointer(@p^);  //-----------------//-----------
        p:=iterate(ir);
  until p=nil;
  result:=count;
end;
function GDBOpenArray.GetRealCount:GDBInteger;
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
procedure GDBOpenArray.freewithproc;
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
procedure GDBOpenArray.free;
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
procedure GDBOpenArray.Invert;
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
function GDBOpenArray.iterate;
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
function GDBOpenArray.beginiterate;
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
function GDBOpenArray.SetCount;
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
function GDBOpenArray.CreateArray;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}@Guid[1],{$ENDIF}PArray, size * max);
  result:=parray;
end;
constructor GDBOpenArray.init;
begin
  Count := 0;
  Deleted:=0;
  Max := m;
  Size := s;
  PArray:=nil;
  pointer(guid):=nil;
  {$IFDEF DEBUGBUILD}Guid:=ErrGuid;{$ENDIF}
  //CreateArray;
  { TODO: делаем познее выделение }
  //GDBGetMem({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}PArray, size * max);
end;
constructor GDBOpenArray.initnul;
begin
  Count := 0;
  Max := 0;
  Size := 0;
  PArray:=nil;
end;
procedure GDBOpenArray.SetSize;
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
procedure GDBOpenArray.Grow;
begin
     if newmax<=0 then
                     newmax:=2*max;
     parray := enlargememblock({$IFDEF DEBUGBUILD}@Guid[1],{$ENDIF}parray, size * max, size * newmax);
     max:=newmax;
end;

function GDBOpenArray.AddByPointer;
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
function GDBOpenArray.AddByRef;
var
   p:pointer;
begin
     p:=@obj;
     result:=AddByPointer(@p)
end;
procedure GDBOpenArray.Shrink;
begin
  if (count<>0)and(count<max) then
  begin
       parray := remapmememblock({$IFDEF DEBUGBUILD}@Guid[1],{$ENDIF}parray, size * count);
       max := count;
  end;
end;
destructor GDBOpenArray.done;
begin
  if PArray<>nil then
                     GDBFreeMem(PArray);
  PArray:=nil;
  {$IFDEF DEBUGBUILD}Guid:='';{$ENDIF}                   
end;
destructor GDBOpenArray.clearanddone;
begin
     clear;
     done;
end;
procedure GDBOpenArray.clear;
begin
  count:=0;
  deleted:=0;
end;
function GDBOpenArray.getelement;
begin
     if (index>=max)or(index<0) then
                        result:=nil
                    else
     begin
  result := PArray;
  inc(pGDBByte(result),size*index);
     end;
end;
begin
end.
