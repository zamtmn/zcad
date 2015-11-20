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
{$MODE DELPHI}
interface
uses gdbasetypes,UGDBOpenArrayOfData,
     gdbase,memman;
type
{Export+}
PGDBOpenArrayOfObjects=^GDBOpenArrayOfObjects;
GDBOpenArrayOfObjects={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfData)
                             procedure cleareraseobj;virtual;
                             function CreateObject:PGDBaseObject;
                             procedure free;virtual;
                             procedure freeandsubfree;virtual;
                             procedure AfterObjectDone(p:PGDBaseObject);virtual;
                       end;
{Export-}
implementation
//uses
//    log;
procedure GDBOpenArrayOfObjects.AfterObjectDone;
begin

end;
procedure GDBOpenArrayOfObjects.cleareraseobj;
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
function GDBOpenArrayOfObjects.CreateObject;
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
procedure GDBOpenArrayOfObjects.free;
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
procedure GDBOpenArrayOfObjects.freeandsubfree;
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
end;
begin
end.
