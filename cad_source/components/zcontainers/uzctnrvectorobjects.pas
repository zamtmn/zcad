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

unit uzctnrvectorobjects;
{$INCLUDE def.inc}
interface
uses uzbtypesbase,uzctnrvectorrec,
     uzbtypes,uzbmemman;
type
{Export+}
GDBOpenArrayOfObjects{-}<T>{//}={$IFNDEF DELPHI}packed{$ENDIF}
                      object(TZctnrVectorRec{-}<T>{//})
                             procedure cleareraseobj;virtual;
                             function CreateObject:PGDBaseObject;
                             procedure free;virtual;
                       end;
{Export-}
implementation
procedure GDBOpenArrayOfObjects<T>.cleareraseobj;
var i:integer;
begin
     for i:=0 to count-1 do
       parray[i].done;
end;
function GDBOpenArrayOfObjects<T>.CreateObject;
var addr: GDBPlatformint;
begin
     result:=getdatamutable(pushbackdata(default(T)));
  {if parray=nil then
                    createarray;
  if count = max then grow;
  begin
       GDBPointer(addr) := parray;
       addr := addr + GDBPlatformint(count*SizeOfData);
       result:=pointer(addr);
       inc(count);
  end;}
end;
procedure GDBOpenArrayOfObjects<T>.free;
var i:integer;
begin
     for i:=0 to count-1 do
     begin
       parray[i].done;
     end;
end;
begin
end.
