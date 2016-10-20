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

unit uzctnrobjectschunk;
{$INCLUDE def.inc}
interface
uses uzbtypesbase,gzctnrvectordata,sysutils,uzbtypes,uzbmemman,
     uzegeometry;
type
{Export+}
PTObjectsChunk=^TObjectsChunk;
TObjectsChunk={$IFNDEF DELPHI}packed{$ENDIF} object(GZVectorData{-}<GDBByte>{//})(*OpenArrayOfData=GDBByte*)
                function beginiterate(out ir:itrec):GDBPointer;virtual;
                function iterate(var ir:itrec):GDBPointer;virtual;
             end;
{Export-}
implementation
function TObjectsChunk.beginiterate(out ir:itrec):GDBPointer;
begin
     if parray=nil then
                       result:=nil
                   else
                       begin
                             ir.itp:=pointer(parray);
                             ir.itc:=0;
                             result:=pointer(parray);
                       end;
end;
function TObjectsChunk.iterate(var ir:itrec):GDBPointer;
var
  s:integer;
begin
  if count=0 then result:=nil
  else
  begin
      s:=sizeof(PGDBaseObject(ir.itp)^);
      if ir.itc<(count-s) then
                      begin

                           inc(pGDBByte(ir.itp),s);
                           inc(ir.itc,s);

                           result:=ir.itp;
                      end
                  else result:=nil;
  end;
end;

begin
end.

