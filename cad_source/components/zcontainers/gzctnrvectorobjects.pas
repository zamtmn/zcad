{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
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

unit gzctnrVectorObjects;

interface
uses gzctnrVector;
type

GZVectorObjects<TData>=object
                                (GZVector<TData>)
                             function CreateObject:PT;
                             procedure free;virtual;
                       end;

implementation
function GZVectorObjects<TData>.CreateObject;
{var addr: PtrInt;}
begin
     result:=getdatamutable(pushbackdata(default(TData)));
  {if parray=nil then
                    createarray;
  if count = max then grow;
  begin
       Pointer(addr) := parray;
       addr := addr + PtrInt(count*SizeOfData);
       result:=pointer(addr);
       inc(count);
  end;}
end;
procedure GZVectorObjects<TData>.free;
var i:integer;
begin
     for i:=0 to count-1 do
     begin
       parray[i].done;
     end;
end;
begin
end.
