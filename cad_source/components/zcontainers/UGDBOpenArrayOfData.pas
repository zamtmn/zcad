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

unit UGDBOpenArrayOfData;
{$INCLUDE def.inc}
{$MODE DELPHI}
interface
uses gdbasetypes,UGDBOpenArray,gdbase;
type
{Export+}
PGDBOpenArrayOfData=^GDBOpenArrayOfData;
GDBOpenArrayOfData={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArray)

                    function iterate(var ir:itrec):GDBPointer;virtual;
                    //procedure clear;virtual;
                    //procedure freeelement(p:GDBPointer);virtual;abstract;
                    destructor FreeAndDone;virtual;
                    destructor FreewithprocAndDone(freeproc:freeelproc);virtual;
                    function deleteelement(index:GDBInteger):GDBPointer;
                    function DeleteElementByP(pel:GDBPointer):GDBPointer;
                    function InsertElement(index,dir:GDBInteger;p:GDBPointer):GDBPointer;
                    //function copyto(source:PGDBOpenArrayOfData):GDBInteger;virtual;
              end;
{Export-}
implementation
//uses
//    log;
{function GDBOpenArrayOfData.copyto;
var p:GDBPointer;
    ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        source.add(p);
        p:=iterate(ir);
  until p=nil;
  result:=count;
end;}
function GDBOpenArrayOfData.InsertElement;
var
   del,afterdel:pointer;
   s:integer;
begin
     add(p);
     if (index=count-2)and(dir=1) then
                                      else
begin
  del := PArray;
  inc(pGDBByte(del),size*index);
  GDBPlatformUInt(afterdel):=GDBPlatformUInt(del)+size;
  s:=(count-index-1)*size;
  Move(del^,afterdel^,s);
  Move(p^,del^,size);
  //dec(count);
end;
  result:=parray;
end;
function GDBOpenArrayOfData.deleteelement;
var
   del,afterdel:pointer;
   s:integer;
begin
  del := PArray;
  inc(pGDBByte(del),size*index);
  GDBPlatformUInt(afterdel):=GDBPlatformUInt(del)+size;
  s:=(count-index-1)*size;
  Move(afterdel^,del^,s);
  dec(count);
  result:=parray;
end;
function GDBOpenArrayOfData.DeleteElementByP;
var
   afterdel:pointer;
   s:integer;
begin
  GDBPlatformUInt(afterdel):=GDBPlatformUInt(pel)+size;
  s:=GDBPlatformUInt(parray)+count*size-GDBPlatformUInt(pel);
  //s:=(count-index-1)*size;
  Move(afterdel^,pel^,s);
  dec(count);
  result:=parray;
end;
destructor GDBOpenArrayOfData.FreeAndDone;
begin
     free;
     done;
end;
destructor GDBOpenArrayOfData.FreewithprocAndDone;
begin
     freewithproc(freeproc);
     done;
end;
{procedure GDBOpenArrayOfData.clear;
begin
     count:=0;
end;}
function GDBOpenArrayOfData.iterate;
begin
  if count=0 then result:=nil
  else if ir.itc<count-1 then
                      begin
                           inc(pGDBByte(ir.itp),size);
                           inc(ir.itc);
                           result:=ir.itp;
                      end
                  else result:=nil;
end;
begin
end.
