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

unit uzctnrAlignedVectorBytes;
interface
uses uzctnrVectorBytes,gzctnrVector,sysutils,gzctnrVectorTypes;
const
  cAlignment=SizeOf(Pointer);
  cAlignmentMask=cAlignment-1;
  cnAlignmentMask=not cAlignmentMask;
  cAlignmentBit=cAlignment{*2};

type

TZctnrAlignedVectorBytes=
  object(TZctnrVectorBytes)
                function beginiterate(out ir:itrec):Pointer;virtual;
                function iterate(var ir:itrec):Pointer;virtual;

                class function Align(SData:Integer):Integer; static; inline;
                procedure AlignDataSize;

                function AllocData(SData:Word):Integer;virtual;
             end;

implementation
class function TZctnrAlignedVectorBytes.Align(SData:Integer):Integer;
//var
//  m:integer;
begin

  //m:=sdata and cAlignmentMask;
  //m:=m xor cAlignmentMask;
  //inc(m);
  //m:=m and cnAlignmentMask;
  //m:= m xor cAlignmentBit;
  //Result:=SData and cnAlignmentMask;
  //Result:=SData + m;


  //m:=SData mod cAlignment;
  //if m=0 then
  //  result:=SData
  //else
  //  result:=SData+cAlignment-m;
  result:=(SData+cAlignmentMask) and cnAlignmentMask;
end;

procedure TZctnrAlignedVectorBytes.AlignDataSize;
var
  m:integer;
begin
  if not((parray=nil)or(count=0))then begin
    m:=Count mod cAlignment;
    if m<>0 then
      inherited AllocData(cAlignment-m);
    //m:=Count mod cAlignment
  end;
end;

function TZctnrAlignedVectorBytes.AllocData(SData:Word):Integer;
var
  m:integer;
begin
  if not((parray=nil)or(count=0))then begin
    m:=Count mod cAlignment;
    if m<>0 then
      inherited AllocData(cAlignment-m);
    //m:=Count mod cAlignment
  end;
  result:=inherited;
end;
function TZctnrAlignedVectorBytes.beginiterate(out ir:itrec):Pointer;
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
function TZctnrAlignedVectorBytes.iterate(var ir:itrec):Pointer;
var
  s:integer;
  m:integer;
begin
  if count=0 then result:=nil
  else
  begin
      s:=cAlignment;
      if ir.itc<(count-s) then
                      begin
                           m:=s mod cAlignment;
                           if m<>0 then
                             s:=s+cAlignment-m;
                           inc(PByte(ir.itp),s);
                           inc(ir.itc,s);

                           result:=ir.itp;
                      end
                  else result:=nil;
  end;
end;

begin
end.

