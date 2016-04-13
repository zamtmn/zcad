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

unit uzctnrvectorp;
{$INCLUDE def.inc}
interface
uses uzbtypes,uzbtypesbase,sysutils,uzctnrvector,uzctnrvectorsimple;
type
GDBPointerArray=array [0..0] of GDBPointer;
PGDBPointerArray=^GDBPointerArray;
{Export+}
TZctnrVectorP{-}<T>{//}={$IFNDEF DELPHI}packed{$ENDIF}
                                 object(TZctnrVectorSimple{-}<T>{//})
                                       Deleted:TArrayIndex;(*hidden_in_objinsp*)
                                       function iterate (var ir:itrec):GDBPointer;virtual;
                                       function beginiterate(out ir:itrec):GDBPointer;virtual;
                                       destructor FreeAndDone;virtual;
                                       procedure cleareraseobj;virtual;abstract;
                                       procedure RemoveData(const data:T);virtual;
                                       function GetRealCount:GDBInteger;

                                       constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:TArrayIndex);
                                       constructor initnul;
                                       procedure Clear;virtual;
                                       function GetElemCount:GDBInteger;
                                 end;
PGDBOpenArrayOfGDBPointer=^GDBOpenArrayOfGDBPointer;
GDBOpenArrayOfGDBPointer=packed object(TZctnrVectorP{-}<GDBPointer>{//}) //TODO:почемуто не работают синонимы с объектами, приходится наследовать
                                   end;
{Export-}
function EqualFuncPointer(const a, b: pointer):Boolean;
implementation
function EqualFuncPointer(const a, b: pointer):Boolean;
begin
  result:=(a=b);
end;
function TZctnrVectorP<T>.GetElemCount:GDBInteger;
begin
  result:=count-deleted;
end;
procedure TZctnrVectorP<T>.clear;
begin
  inherited;
  deleted:=0;
end;
constructor TZctnrVectorP<T>.initnul;
begin
  inherited;
  Deleted:=0;
end;
constructor TZctnrVectorP<T>.init;
begin
  inherited;
  Deleted:=0;
end;
function TZctnrVectorP<T>.beginiterate;
begin
  if parray=nil then
                    result:=nil
                else
                    begin
                          ir.itp:=pointer(GDBPlatformUInt(parray)-SizeOfData);
                          ir.itc:=-1;
                          result:=iterate(ir);
                    end;
end;
function TZctnrVectorP<T>.GetRealCount:GDBInteger;
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
{function TZctnrVectorP<T>.AddByPointer;
var addr: GDBPlatformint;
begin
  if parray=nil then
                     CreateArray;
  if count = max then
                     grow;
  begin
       GDBPointer(addr) := parray;
       addr := addr + count * SizeOfData;
       Move(p^, GDBPointer(addr)^,SizeOfData);
       result:=count;
       inc(count);
  end;
end;}
{function TZctnrVectorP<T>.AddByRef;
var
   p:pointer;
begin
     p:=@obj;
     result:=AddByPointer(@p)
end;}
{function TZctnrVectorP<T>.addnodouble;
var p,newp:GDBPointer;
    ir:itrec;
begin
  result := -1;
  if parray=nil then
                    createarray;
  if count = max then grow;
  newp:=pGDBPointer(pobj)^;
  if count >0 then
  begin
       p:=beginiterate(ir);
       if p<>nil then
       repeat
             if p=newp then exit;
             p:=iterate(ir);
       until p=nil;
  end;
  Move(pobj^, PGDBPointerArray(parray)^[count],SizeOfData);
  result := count;
  inc(count);
end;}
destructor TZctnrVectorP<T>.FreeAndDone;
begin
     cleareraseobj;
     done;
end;
function TZctnrVectorP<T>.iterate;
var
  p:GDBPointer;
begin
  result:=nil;
  if count=0 then exit;

  inc(pGDBByte(ir.itp),SizeOfData);
  inc(ir.itc);

  if ir.itc>=count then exit;
  p:=ir.itp^;

  if p=nil then
  repeat
  inc(pGDBByte(ir.itp),SizeOfData);
  inc(ir.itc);
  if ir.itc<>count then p:=ir.itp^;
  until (ir.itc=count)or(p<>nil);
  result:=p;
end;
procedure TZctnrVectorP<T>.RemoveData(const data:T);
var p:GDBPointer;
    ir:itrec;
begin
       p:=beginiterate(ir);
       if p<>nil then
       repeat
             if p=data then
                           begin
                                pointer(ir.itp^):=nil;
                                exit;
                           end;
             p:=iterate(ir);
       until p=nil;
end;
{procedure TZctnrVectorP<T>.AddToArray(const pdata:GDBPointer);
begin
     PushBackData(pdata);
end;}

(*
function GDBOpenArrayOfGDBPointer.copyto;
var p:GDBPointer;
    ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        source.AddByPointer(@p{^});  //-----------------//-----------
        p:=iterate(ir);
  until p=nil;
  result:=count;
end;
procedure GDBOpenArrayOfGDBPointer.RemoveData(const pdata:GDBPointer);
var p:GDBPointer;
    ir:itrec;
begin
       p:=beginiterate(ir);
       if p<>nil then
       repeat
             if p=pdata then
                           begin
                                pointer(ir.itp^):=nil;
                                exit;
                           end;
             p:=iterate(ir);
       until p=nil;
end;
procedure GDBOpenArrayOfGDBPointer.AddToArray(const pdata:GDBPointer);
begin
     AddByPointer(@pdata);
end;

function GDBOpenArrayOfGDBPointer.IsDataExistWithCompareProc;
var p:GDBPointer;
    ir:itrec;
begin
       p:=beginiterate(ir);
       if p<>nil then
       repeat
             if p=pobj then
                           begin
                                result:=true;
                                exit;
                           end;
             p:=iterate(ir);
       until p=nil;
       result:=false;
end;
destructor GDBOpenArrayOfGDBPointer.FreeAndDone;
begin
     cleareraseobj;
     done;
end;
function GDBOpenArrayOfGDBPointer.addnodouble;
var p,newp:GDBPointer;
    ir:itrec;
begin
  result := -1;
  if parray=nil then
                    createarray;
  if count = max then grow;
  newp:=pGDBPointer(pobj)^;
  if count >0 then
  begin
       p:=beginiterate(ir);
       if p<>nil then
       repeat
             if p=newp then exit;
             p:=iterate(ir);
       until p=nil;
  end;
  Move(pobj^, PGDBPointerArray(parray)^[count], size);
  result := count;
  inc(count);
end;
function GDBOpenArrayOfGDBPointer.iterate;
var
  p:GDBPointer;
begin
  result:=nil;
  if count=0 then exit;

  inc(pGDBByte(ir.itp),size);
  inc(ir.itc);

  if ir.itc>=count then exit;
  p:=ir.itp^;

  if p=nil then
  repeat
  inc(pGDBByte(ir.itp),size);
  inc(ir.itc);
  if ir.itc<>count then p:=ir.itp^;
  until (ir.itc=count)or(p<>nil);
  result:=p;
end;
constructor GDBOpenArrayOfGDBPointer.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(GDBPointer));
end;
constructor GDBOpenArrayOfGDBPointer.initnul;
begin
  Count := 0;
  Max := 0;
  Size := sizeof(GDBPointer);
  PArray:=nil;
end;
*)
begin
end.
