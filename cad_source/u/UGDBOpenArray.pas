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
uses gdbasetypes,sysutils,UOpenArray,memman,gdbase;
type
{Export+}
PGDBOpenArray=^GDBOpenArray;
GDBOpenArray=object(OpenArray)
                      PArray:GDBPointer;(*hidden_in_objinsp*)
                      guid:GDBString;
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m,s:GDBInteger);
                      constructor initnul;
                      function beginiterate(out ir:itrec):GDBPointer;virtual;
                      function iterate(var ir:itrec):GDBPointer;virtual;
                      destructor done;virtual;
                      destructor ClearAndDone;virtual;
                      procedure Clear;virtual;
                      function Add(p:GDBPointer):GDBInteger;virtual;
                      function AddRef(var obj):GDBInteger;virtual;
                      procedure Shrink;virtual;
                      procedure Grow;virtual;
                      procedure setsize(nsize:GDBLongword);
                      procedure iterategl(proc:GDBITERATEPROC);
                      function getelement(index:GDBInteger):GDBPointer;
                      procedure Invert;
                      function getGDBString(index:GDBInteger):GDBString;
                      function AfterDeSerialize(SaveFlag:GDBWord;membuf:GDBPointer):integer;virtual;
                      procedure free;virtual;
                      procedure freewithproc(freeproc:freeelproc);virtual;
                      procedure freeelement(p:GDBPointer);virtual;abstract;
                      function CreateArray:GDBPointer;virtual;
                      function SetCount(index:GDBInteger):GDBPointer;virtual;
                      function copyto(source:PGDBOpenArray):GDBInteger;virtual;
             end;
{Export-}
implementation
uses
    log;
function GDBOpenArray.copyto;
var p:GDBPointer;
    ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        source.add(@p);  //-----------------//-----------
        p:=iterate(ir);
  until p=nil;
  result:=count;
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
        if GDBPlatformint(pl)<=GDBPlatformint(p) then
                                         break;
        Move(p^,tp^,size);
        Move(pl^,p^,size);
        Move(tp^,pl^,size);
        dec(GDBPlatformint(pl),size);
        inc(GDBPlatformint(p),size);
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
function GDBOpenArray.AfterDeSerialize;
var temp:GDBLongword;
begin
  max:=count;
  temp:=count * size;
  if temp>0 then
                GDBGetMem({$IFDEF DEBUGBUILD}'{94D787E9-97EE-4198-8A72-5B904B98F275}',{$ENDIF}PArray,temp);
  result:=0;
end;

function GDBOpenArray.beginiterate;
begin
  if parray=nil then
                    result:=nil
                else
                    begin
                          ir.itp:=pointer(GDBPlatformint(parray)-size);
                          ir.itc:=-1;
                          result:=iterate(ir);
                    end;
end;
function GDBOpenArray.SetCount;
begin
     count:=index;
     if parray=nil then
                        createarray;
     result:=parray;
end;
function GDBOpenArray.CreateArray;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}@Guid[1],{$ENDIF}PArray, size * max);
  result:=parray;
end;
constructor GDBOpenArray.init;
begin
  inherited init(m,s);
  PArray:=nil;
  pointer(guid):=nil;
  {$IFDEF DEBUGBUILD}Guid:=ErrGuid;{$ENDIF}
  //CreateArray; { TODO: делаем познее выделение }
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
                           parray := enlargememblock({$IFDEF DEBUGBUILD}@Guid[1],{$ENDIF}parray, size * max, nsize*max);
                      end
else if nsize<max then
                      begin
                           parray := enlargememblock({$IFDEF DEBUGBUILD}@Guid[1],{$ENDIF}parray, size * max, nsize*max);
                           if count>nsize then count:=nsize;

                      end;
max:=nsize;
end;
procedure GDBOpenArray.Grow;
begin
     parray := enlargememblock({$IFDEF DEBUGBUILD}@Guid[1],{$ENDIF}parray, size * max, 2*size * max);
     max:=max+max;
end;

function GDBOpenArray.add;
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
function GDBOpenArray.AddRef;
var
   p:pointer;
begin
     p:=@obj;
     result:=add(@p)
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
procedure GDBOpenArray.iterategl;
var i: GDBInteger;
  p: pgdbvertex;
begin
  p := PArray;
  for i := 0 to Count - 1 do
  begin
    proc(@p^);
    inc(pGDBByte(p),size);
  end;
end;
function GDBOpenArray.getelement;
begin
     if (index>=max) then
                        result:=nil
                    else
     begin
  result := PArray;
  inc(pGDBByte(result),size*index);
     end;
end;
function GDBOpenArray.getGDBString;
begin
  result := pGDBString(getelement(index))^;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBOpenArray.initialization');{$ENDIF}
end.
