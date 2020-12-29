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

unit gzctnrvectordata;
{$INCLUDE def.inc}
interface
uses gzctnrvector;
type
{Export+}
{--------REGISTEROBJECTTYPE GZVectorData}
GZVectorData{-}<T>{//}=object
                         (GZVector{-}<T>{//})
                         procedure freewithproc(freeproc:TProcessProc);virtual;
                       end;
{Export-}
implementation
procedure GZVectorData<T>.freewithproc;
var i:integer;
begin
     for i:=0 to self.count-1 do
     begin
       freeproc(@parray[i]);
     end;
     self.count:=0;
end;
begin
end.
