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

unit UGDBOpenArrayOfObjects;
{$INCLUDE def.inc}
interface
uses uzbtypesbase,UGDBOpenArrayOfData,
     uzbtypes,uzbmemman;
type
{Export+}
GDBOpenArrayOfObjects{-}<T>{//}={$IFNDEF DELPHI}packed{$ENDIF}
                      object(GDBOpenArrayOfData{-}<T>{//})
                             procedure cleareraseobj;virtual;
                             function CreateObject:PGDBaseObject;
                             procedure free;virtual;
                             //procedure freeandsubfree;virtual;
                             procedure AfterObjectDone(p:PGDBaseObject);virtual;
                       end;
{Export-}
implementation
//uses
//    log;
procedure GDBOpenArrayOfObjects<T>.AfterObjectDone;
begin

end;
procedure GDBOpenArrayOfObjects<T>.cleareraseobj;
var
  p:PGDBaseObject;
    ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       p^.done;
       p:=iterate(ir);
  until p=nil;
  count:=0;
end;
function GDBOpenArrayOfObjects<T>.CreateObject;
var addr: GDBPlatformint;
begin
  if parray=nil then
                    createarray;
  if count = max then grow;
  begin
       GDBPointer(addr) := parray;
       addr := addr + GDBPlatformint(count * size);
       //Move(p^, GDBPointer(addr)^,size);
       result:=pointer(addr);
       inc(count);
  end;
end;
procedure GDBOpenArrayOfObjects<T>.free;
var p:GDBPointer;
    ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        pgdbaseobject(p).done;
        AfterObjectDone(p);
        p:=iterate(ir);
  until p=nil;
  clear;
end;
{procedure GDBOpenArrayOfObjects<T>.freeandsubfree;
var p:GDBPointer;
    ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        PGDBOpenArrayOfData(p).freeanddone;
        p:=iterate(ir);
  until p=nil;
  clear;
end;}
begin
end.
