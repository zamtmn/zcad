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

unit gzctnrvectorsimple;
{$INCLUDE def.inc}
interface
uses {uzbtypesbase,uzbtypes,}gzctnrvector;
type
{Export+}
{----REGISTEROBJECTTYPE GZVectorSimple}
GZVectorSimple{-}<T>{//}=object
                               (GZVector{-}<T>{//})
                                   function PushBackIfNotPresent(data:T):Integer;
                                   function IsDataExist(pobj:T):Integer;
                                   {**Удалить элемент по содержимому, с уменьшениием размера массива}
                                   procedure EraseData(data:T);
                                 end;
{Export-}
implementation

function GZVectorSimple<T>.IsDataExist;
var i:integer;
begin
     for i:=0 to count-1 do
     if parray[i]=pobj then
                           begin
                                result:=i;
                                exit;
                           end;
     result:=-1;
end;
function GZVectorSimple<T>.PushBackIfNotPresent;
begin
  result:=IsDataExist(data);
  if result=-1 then
                   result:=PushBackData(data);
  {if result:=IsDataExist(data)then
                        begin
                          result := -1;
                          exit;
                        end;
  result:=PushBackData(data);}
end;
procedure GZVectorSimple<T>.EraseData(data:T);
var i:integer;
begin
  for i:=0 to count-1 do
    if PArray^[i]=data then
      EraseElement(i);
end;
begin
end.
