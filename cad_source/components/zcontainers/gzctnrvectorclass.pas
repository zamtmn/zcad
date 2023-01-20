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

unit gzctnrVectorClass;

interface
uses gzctnrVectorTypes,gzctnrVectorc,gvector;
type
{Export+}
{----REGISTEROBJECTTYPE GZVectorClass}
GZVectorClass{-}<T:class>{//}=class
                               (GZVectorc{-}<T>{//})
                               procedure cleareraseobjfrom2(n:Integer);
                                 end;
{Export-}
implementation
procedure GZVectorClass<T>.cleareraseobjfrom2(n:Integer);
var
  p:^TDataType;
  ir:itrec;
begin
  p:={TDataType}(beginiterate(ir));
  if p<>nil then
  repeat
       if ir.itc>=n then
                       begin
                       p^.free;
                       end;
       p:={TDataType}(iterate(ir));
  until p=nil;
  count:=n;
end;
begin
end.
