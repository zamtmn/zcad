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

unit ugdbopenarrayofgdbdouble;
{$INCLUDE def.inc}
interface
uses uzbtypesbase,sysutils,UGDBOpenArray;
type
GDBDoubleArray=array [0..0] of GDBPointer;
PGDBDoubleArray=^GDBDoubleArray;
{Export+}
PGDBOpenArrayOfGDBDouble=^GDBOpenArrayOfGDBDouble;
GDBOpenArrayOfGDBDouble={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArray)
                      constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                      constructor initnul;
                      function addnodouble(data:GDBDouble):GDBInteger;virtual;
                      destructor FreeAndDone;virtual;
                      procedure cleareraseobj;virtual;abstract;
                      function IsObjExist(pobj:GDBDouble):GDBBoolean;
                      procedure AddToArray(const data:GDBDouble);virtual;
             end;
{Export-}
implementation
//uses
//    log;
procedure GDBOpenArrayOfGDBDouble.AddToArray(const data:GDBDouble);
begin
     add(@data);
end;

function GDBOpenArrayOfGDBDouble.IsObjExist;
var p:PGDBDouble;
    ir:itrec;
begin
       p:=beginiterate(ir);
       if p<>nil then
       repeat
             if p^=pobj then
                           begin
                                result:=true;
                                exit;
                           end;
             p:=iterate(ir);
       until p=nil;
       result:=false;
end;
destructor GDBOpenArrayOfGDBDouble.FreeAndDone;
begin
     cleareraseobj;
     done;
end;
function GDBOpenArrayOfGDBDouble.addnodouble;
var p,newp:PGDBDouble;
    newd:GDBPointer;
    ir:itrec;
begin
  result := -1;
  if parray=nil then
                    createarray;
  if count = max then grow;
  if count >0 then
  begin
       p:=beginiterate(ir);
       if p<>nil then
       repeat
             if p^=data then exit;
             p:=iterate(ir);
       until p=nil;
  end;
  result := add(@data);
end;
constructor GDBOpenArrayOfGDBDouble.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(GDBDouble));
end;
constructor GDBOpenArrayOfGDBDouble.initnul;
begin
  Count := 0;
  Max := 0;
  Size := sizeof(GDBDouble);
  PArray:=nil;
end;
begin
end.
