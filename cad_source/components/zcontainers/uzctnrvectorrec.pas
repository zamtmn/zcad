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
                                                     destructor FreeAndDone;virtual;
                                                     function deleteelement(index:GDBInteger):GDBPointer;
                                                     function DeleteElementByP(pel:GDBPointer):GDBPointer;
                                                     function InsertElement(index,dir:GDBInteger;p:GDBPointer):GDBPointer;
                                 end;
{Export-}
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
  inc(pGDBByte(del),SizeOfData*index);
  GDBPlatformUInt(afterdel):=GDBPlatformUInt(del)+SizeOfData;
  s:=(count-index-1)*SizeOfData;
  Move(del^,afterdel^,s);
  Move(p^,del^,SizeOfData);
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
  inc(pGDBByte(del),SizeOfData*index);
  GDBPlatformUInt(afterdel):=GDBPlatformUInt(del)+SizeOfData;
  s:=(count-index-1)*SizeOfData;
  Move(afterdel^,del^,s);
  dec(count);
  result:=parray;
end;
function TZctnrVectorRec<T>.DeleteElementByP;
var
   afterdel:pointer;
   s:integer;
begin
  GDBPlatformUInt(afterdel):=GDBPlatformUInt(pel)+SizeOfData;
  s:=GDBPlatformUInt(parray)+count*SizeOfData-GDBPlatformUInt(pel);
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
begin
end.
