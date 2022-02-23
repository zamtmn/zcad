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

unit gzctnrAlignedVectorObjects;

interface

uses
  uzctnrAlignedVectorBytes,gzctnrvectortypes;

type
{Export+}
{----REGISTEROBJECTTYPE GZAlignedVectorObjects}
GZAlignedVectorObjects{-}<PBaseObj>{//}=
  object(TZctnrAlignedVectorBytes)(*OpenArrayOfData=Byte*)
                function iterate(var ir:itrec):Pointer;virtual;
             end;
{Export-}
implementation
function GZAlignedVectorObjects<PBaseObj>.iterate(var ir:itrec):Pointer;
var
  s:integer;
  m:integer;
begin
  if count=0 then result:=nil
  else
  begin
      s:=sizeof(PBaseObj(ir.itp)^);
      if ir.itc<(count-s) then
                      begin
                           m:=s mod ObjAlign;
                           if m<>0 then
                             s:=s+ObjAlign-m;
                           inc(PByte(ir.itp),s);
                           inc(ir.itc,s);

                           result:=ir.itp;
                      end
                  else result:=nil;
  end;
end;
begin
end.

