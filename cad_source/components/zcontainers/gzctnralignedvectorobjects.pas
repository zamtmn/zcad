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

unit gzctnrAlignedVectorObjects;

interface

uses
  uzctnrAlignedVectorBytes,gzctnrVectorTypes;

type

  //<PObj> тут используется только для определения размера объекта
  GZAlignedVectorObjects<PObj>=object(TZctnrAlignedVectorBytes)
    function iterate(var ir:itrec):Pointer;virtual;
    procedure Clear;virtual;
    procedure free;virtual;
  end;

implementation
procedure GZAlignedVectorObjects<PObj>.free;
begin
  clear;
  inherited;
end;

function GZAlignedVectorObjects<PObj>.iterate(var ir:itrec):Pointer;
var
  s:integer;
  m:integer;
begin
  if count=0 then
    result:=nil
  else begin
    s:=sizeof(PObj(ir.itp)^);
    if ir.itc<(count-s) then begin
      m:=s mod cAlignment;
      if m<>0 then
       s:=s+cAlignment-m;
      inc(PByte(ir.itp),s);
      inc(ir.itc,s);
      result:=ir.itp;
    end else result:=nil;
  end;
end;
procedure GZAlignedVectorObjects<PObj>.Clear;
var
   PEnt:PObj;
   ProcessedSize:TArrayIndex;
   CurrentSize:TArrayIndex;
begin
  if count>0 then begin
    ProcessedSize:=0;
    PEnt:=GetParrayAsPointer;
    while ProcessedSize<count do begin
      CurrentSize:=Align(sizeof(PEnt^));
      PEnt^.done;
      ProcessedSize:=ProcessedSize+CurrentSize;
      inc(pbyte(PEnt),CurrentSize);
    end;
  end;
  inherited;
end;
begin
end.

