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

unit uzctnrvectorrec;
{$INCLUDE def.inc}
interface
uses uzbtypesbase,uzbtypes,uzctnrvector;
type
{Export+}
TZctnrVectorRec{-}<T>{//}={$IFNDEF DELPHI}packed{$ENDIF}
                                 object(TZctnrVector{-}<T>{//})
                                                     function iterate(var ir:itrec):GDBPointer;virtual;
                                                     destructor FreeAndDone;virtual;
                                                     function deleteelement(index:GDBInteger):GDBPointer;
                                                     function DeleteElementByP(pel:GDBPointer):GDBPointer;
                                                     function InsertElement(index,dir:GDBInteger;p:GDBPointer):GDBPointer;
                                 end;
{Export-}
(*
PGDBOpenArrayOfData=^GDBOpenArrayOfData;
GDBOpenArrayOfData=packed object(TZctnrVectorData{-}<byte>{//})
                                   end;
*)
implementation
function TZctnrVectorRec<T>.InsertElement;
var
   del,afterdel:pointer;
   s:integer;
begin
     AddByPointer(p);
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
function TZctnrVectorRec<T>.deleteelement;
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
function TZctnrVectorRec<T>.DeleteElementByP;
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
destructor TZctnrVectorRec<T>.FreeAndDone;
begin
     free;
     done;
end;
function TZctnrVectorRec<T>.iterate;
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
