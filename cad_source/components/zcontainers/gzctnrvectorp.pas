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

unit gzctnrVectorP;

interface
uses gzctnrVectorTypes,sysutils,gzctnrVector,gzctnrVectorSimple;
type

GZVectorP<T>=object
                          (GZVectorSimple<T>)
                                       Deleted:TArrayIndex;(*hidden_in_objinsp*)
                                       function iterate (var ir:itrec):Pointer;virtual;
                                       function beginiterate(out ir:itrec):Pointer;virtual;
                                       procedure RemoveData(const data:T);virtual;
                                       procedure RemoveDataFromArray(const data:T);virtual;
                                       function DeleteElement(index:Integer):Pointer;
                                       function GetRealCount:Integer;

                                       constructor init(m:TArrayIndex);
                                       constructor initnul;
                                       procedure Clear;virtual;
                                       //function GetCount:Integer;
                                 end;

function EqualFuncPointer(const a, b: pointer):Boolean;
implementation
function EqualFuncPointer(const a, b: pointer):Boolean;
begin
  result:=(a=b);
end;
function GZVectorP<T>.DeleteElement(index:Integer):Pointer;
begin
  if (index>=0)and(index<count)then
  begin
    parray^[index]:=default(t);
  end;
  result:=parray;
end;

{function GZVectorP<T>.GetCount:Integer;
begin
  result:=count-deleted;
end;}
procedure GZVectorP<T>.clear;
begin
  inherited;
  deleted:=0;
end;
constructor GZVectorP<T>.initnul;
begin
  inherited;
  Deleted:=0;
end;
constructor GZVectorP<T>.init;
begin
  inherited;
  Deleted:=0;
end;
function GZVectorP<T>.beginiterate;
begin
  if parray=nil then
                    result:=nil
                else
                    begin
                          {ir.itp:=pointer(PtrUInt(parray)-SizeOfData);}
                          ir.itp:=pointer(parray);
                          dec(pt(ir.itp));
                          ir.itc:=-1;
                          result:=iterate(ir);
                    end;
end;
function GZVectorP<T>.GetRealCount:Integer;
var p:Pointer;
    ir:itrec;
begin
  result:=0;
  p:=beginiterate(ir);
  if p<>nil then
  repeat
        inc(result);
        p:=iterate(ir);
  until p=nil;
end;
function GZVectorP<T>.iterate;
var
  p:Pointer;
begin
  result:=nil;
  if count=0 then exit;

  inc(ir.itc);
  pointer(ir.itp):=PArray;
  inc(pByte(ir.itp),SizeOfData*ir.itc);

  //inc(pByte(ir.itp),SizeOfData);
  //inc(ir.itc);

  if ir.itc>=count then exit;
  p:=ir.itp^;

  if p=nil then
  repeat
  inc(pByte(ir.itp),SizeOfData);
  inc(ir.itc);
  if ir.itc<>count then p:=ir.itp^;
  until (ir.itc=count)or(p<>nil);
  result:=p;
end;
procedure GZVectorP<T>.RemoveData(const data:T);
var p:Pointer;
    ir:itrec;
begin
       p:=beginiterate(ir);
       if p<>nil then
       repeat
             if p=data then
                           begin
                                pointer(ir.itp^):=nil;
                                exit;
                           end;
             p:=iterate(ir);
       until p=nil;
end;
procedure GZVectorP<T>.RemoveDataFromArray(const data:T);
var p:Pointer;
    ir:itrec;
begin
       p:=beginiterate(ir);
       if p<>nil then
       repeat
             if p=data then
                           begin
                                //pointer(ir.itp^):=nil;
                                EraseElement(ir.itc);
                                exit;
                           end;
             p:=iterate(ir);
       until p=nil;
end;
begin
end.
