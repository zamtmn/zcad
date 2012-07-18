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

unit UGDBOpenArrayOfPointer;
{$INCLUDE def.inc}
interface
uses gdbasetypes,sysutils,UGDBOpenArray;
type
GDBPointerArray=array [0..0] of GDBPointer;
PGDBPointerArray=^GDBPointerArray;
{Export+}
PGDBOpenArrayOfGDBPointer=^GDBOpenArrayOfGDBPointer;
GDBOpenArrayOfGDBPointer=object(GDBOpenArray)
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      constructor initnul;
                      function iterate (var ir:itrec):GDBPointer;virtual;
                      function addnodouble(pobj:GDBPointer):GDBInteger;virtual;
                      //function add(p:GDBPointer):GDBInteger;virtual;
                      destructor FreeAndDone;virtual;
                      procedure cleareraseobj;virtual;abstract;
                      function IsObjExist(pobj:GDBPointer):GDBBoolean;
                      function copyto(source:PGDBOpenArray):GDBInteger;virtual;
             end;
{Export-}
implementation
uses
    log;
function GDBOpenArrayOfGDBPointer.copyto;
var p:GDBPointer;
    ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        source.add(@p{^});  //-----------------//-----------
        p:=iterate(ir);
  until p=nil;
  result:=count;
end;
function GDBOpenArrayOfGDBPointer.IsObjExist;
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
  if count = max then {exit}grow;
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
{function GDBOpenArrayOfGDBPointer.add;
begin
  if count = max then
                     begin
                     count:=count;
                     exit;
                     end;
  Move(p^,PGDBPointerArray(parray)^[count], size);
  result := count;
  inc(count);
end;}
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
  inc(pGDBByte(ir.itp),size);//inc(ir.itp);
  inc(ir.itc);
  if ir.itc<>count then p:=ir.itp^;
  until (ir.itc=count)or(p<>nil);
  result:=p;
end;
constructor GDBOpenArrayOfGDBPointer.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(GDBPointer));
  //GDBGetMem(PArray, size * max);
end;
constructor GDBOpenArrayOfGDBPointer.initnul;
begin
  Count := 0;
  Max := 0;
  Size := sizeof(GDBPointer);
  PArray:=nil;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBOpenArrayOfPointers.initialization');{$ENDIF}
end.
