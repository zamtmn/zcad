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

unit gzctnrvectorp;
{$INCLUDE def.inc}
interface
uses uzbtypes,uzbtypesbase,sysutils,gzctnrvector,gzctnrvectorsimple;
type
{Export+}
GZVectorP{-}<T>{//}={$IFNDEF DELPHI}packed{$ENDIF}
                                 object(GZVectorSimple{-}<T>{//})
                                       Deleted:TArrayIndex;(*hidden_in_objinsp*)
                                       function iterate (var ir:itrec):GDBPointer;virtual;
                                       function beginiterate(out ir:itrec):GDBPointer;virtual;
                                       procedure RemoveData(const data:T);virtual;
                                       function DeleteElement(index:GDBInteger):GDBPointer;
                                       function GetRealCount:GDBInteger;

                                       constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:TArrayIndex);
                                       constructor initnul;
                                       procedure Clear;virtual;
                                       function GetCount:GDBInteger;
                                 end;
{Export-}
function EqualFuncPointer(const a, b: pointer):Boolean;
implementation
function EqualFuncPointer(const a, b: pointer):Boolean;
begin
  result:=(a=b);
end;
function GZVectorP<T>.DeleteElement(index:GDBInteger):GDBPointer;
begin
  if (index>=0)and(index<count)then
  begin
    parray^[index]:=default(t);
  end;
  result:=parray;
end;

function GZVectorP<T>.GetCount:GDBInteger;
begin
  result:=count-deleted;
end;
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
                          {ir.itp:=pointer(GDBPlatformUInt(parray)-SizeOfData);}
                          ir.itp:=pointer(parray);
                          dec(pt(ir.itp));
                          ir.itc:=-1;
                          result:=iterate(ir);
                    end;
end;
function GZVectorP<T>.GetRealCount:GDBInteger;
var p:GDBPointer;
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
  p:GDBPointer;
begin
  result:=nil;
  if count=0 then exit;

  inc(pGDBByte(ir.itp),SizeOfData);
  inc(ir.itc);

  if ir.itc>=count then exit;
  p:=ir.itp^;

  if p=nil then
  repeat
  inc(pGDBByte(ir.itp),SizeOfData);
  inc(ir.itc);
  if ir.itc<>count then p:=ir.itp^;
  until (ir.itc=count)or(p<>nil);
  result:=p;
end;
procedure GZVectorP<T>.RemoveData(const data:T);
var p:GDBPointer;
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
begin
end.
