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

unit uzctnrvectorsimple;
{$INCLUDE def.inc}
interface
uses uzbtypesbase,uzbtypes,uzctnrvector;
type
{Export+}
TZctnrVectorSimple{-}<T>{//}={$IFNDEF DELPHI}packed{$ENDIF}
                                 object(TZctnrVector{-}<T>{//})
                                   function PushBackIfNotPresent(data:T):GDBInteger;
                                   function IsDataExist(pobj:T):GDBBoolean;
                                 end;
{Export-}
implementation

function TZctnrVectorSimple<T>.IsDataExist;
var i:integer;
begin
     for i:=0 to count-1 do
     if parray[i]=pobj then
                           begin
                                result:=true;
                                exit;
                           end;
     result:=false;
end;
function TZctnrVectorSimple<T>.PushBackIfNotPresent;
begin
  if IsDataExist(data)then
                        begin
                          result := -1;
                          exit;
                        end;
  result:=PushBackData(data);
end;
begin
end.
