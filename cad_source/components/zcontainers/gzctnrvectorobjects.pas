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

unit gzctnrvectorobjects;
{$INCLUDE def.inc}
interface
uses uzbtypesbase,gzctnrvectordata,
     uzbtypes,uzbmemman;
type
{Export+}
{-----------REGISTEROBJECTTYPE GZVectorObjects}
GZVectorObjects{-}<T>{//}=object
                                (GZVectorData{-}<T>{//})
                             function CreateObject:PGDBaseObject;
                             procedure free;virtual;
                       end;
{Export-}
implementation
function GZVectorObjects<T>.CreateObject;
{var addr: GDBPlatformint;}
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
procedure GZVectorObjects<T>.free;
var i:integer;
begin
     for i:=0 to count-1 do
     begin
       parray[i].done;
     end;
end;
begin
end.
