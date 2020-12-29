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
     gzctnrvectortypes;
const
  ObjAlign=4;
type
{Export+}
PTObjectsChunk=^TObjectsChunk;
{REGISTEROBJECTTYPE TObjectsChunk}
TObjectsChunk= object(GZVectorData{-}<GDBByte>{//})(*OpenArrayOfData=GDBByte*)
                function beginiterate(out ir:itrec):GDBPointer;virtual;
                function iterate(var ir:itrec):GDBPointer;virtual;

                function Align(SData:Integer):Integer;
                procedure AlignDataSize;

                function AddData(PData:Pointer;SData:Word):Integer;virtual;
                function AllocData(SData:Word):Integer;virtual;
             end;
{Export-}
implementation
function TObjectsChunk.Align(SData:Integer):Integer;
var
  m:integer;
begin
  m:=SData mod ObjAlign;
  if m=0 then
    result:=SData
  else
    result:=SData+ObjAlign-m;
end;

procedure TObjectsChunk.AlignDataSize;
var
  m:integer;
begin
  if not((parray=nil)or(count=0))then begin
    m:=Count mod ObjAlign;
    if m<>0 then
      inherited AllocData(ObjAlign-m);
    m:=Count mod ObjAlign
  end;
end;

function TObjectsChunk.AddData(PData:Pointer;SData:Word):Integer;
begin
  result:=inherited;
end;
function TObjectsChunk.AllocData(SData:Word):Integer;
var
  m:integer;
begin
  if not((parray=nil)or(count=0))then begin
    m:=Count mod ObjAlign;
    if m<>0 then
      inherited AllocData(ObjAlign-m);
    m:=Count mod ObjAlign
  end;
  result:=inherited;
end;
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
  m:integer;
begin
  if count=0 then result:=nil
  else
  begin
      s:=sizeof(PGDBaseObject(ir.itp)^);
      if ir.itc<(count-s) then
                      begin
                           m:=s mod ObjAlign;
                           if m<>0 then
                             s:=s+ObjAlign-m;
                           inc(pGDBByte(ir.itp),s);
                           inc(ir.itc,s);

                           result:=ir.itp;
                      end
                  else result:=nil;
  end;
end;

begin
end.

