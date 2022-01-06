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
uses gzctnrvectordata;
type
{Export+}
{-----------REGISTEROBJECTTYPE GZVectorObjects}
GZVectorObjects{-}<PTData,TData>{//}=object
                                (GZVectorData{-}<TData>{//})
                             function CreateObject:PTData;
                             procedure free;virtual;
                       end;
{Export-}
implementation
function GZVectorObjects<PTData,TData>.CreateObject;
{var addr: GDBPlatformint;}
begin
     result:=getdatamutable(pushbackdata(default(TData)));
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
procedure GZVectorObjects<PTData,TData>.free;
var i:integer;
begin
     for i:=0 to count-1 do
     begin
       parray[i].done;
     end;
end;
begin
end.
