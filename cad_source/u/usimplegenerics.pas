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
{$MODE OBJFPC}
unit usimplegenerics;
{$INCLUDE def.inc}

interface
uses LCLVersion,gdbase,gdbasetypes,
     sysutils,
     gutil,gmap;
{$if LCL_FULLVERSION<1030000}{$DEFINE OldIteratorDef}{$ENDIF}
//{$if LCL_FULLVERSION>=1030000}{$ENDIF}
type
{$IFNDEF DELPHI}
LessPointer=specialize TLess<pointer>;
LessGDBString=specialize TLess<GDBString>;
LessDWGHandle=specialize TLess<TDWGHandle>;
LessObjID=specialize TLess<TObjID>;

generic TMyMap <TKey, TValue, TCompare> = class(specialize TMap<TKey, TValue, TCompare>)
  function MyGetValue(key:TKey):TValue;inline;
  procedure MyGetOrCreateValue(const key:TKey; var Value:TValue; out OutValue:TValue);inline;
end;
generic GKey2DataMap <TKey, TValue, TCompare> = class(specialize TMap<TKey, TValue, TCompare>)
        procedure RegisterKey(const key:TKey; const Value:TValue);
        function MyGetValue(key:TKey; out Value:TValue):boolean;
end;



TMapPointerToHandle=specialize TMyMap<pointer,TDWGHandle, LessPointer>;

TMapHandleToHandle=specialize TMyMap<TDWGHandle,TDWGHandle, LessDWGHandle>;
TMapHandleToPointer=specialize TMyMap<TDWGHandle,pointer, LessDWGHandle>;

TMapBlockHandle_BlockNames=specialize TMap<TDWGHandle,string,LessDWGHandle>;

TEntUpgradeKey=record
                      EntityID:TObjID;
                      UprradeInfo:TEntUpgradeInfo;
               end;
LessEntUpgradeKey=class
  class function c(a,b:TEntUpgradeKey):boolean;inline;
end;
{$ENDIF}

implementation
uses
    log;
class function LessEntUpgradeKey.c(a,b:TEntUpgradeKey):boolean;inline;
begin
  //c:=a<b;
  if a.UprradeInfo=b.UprradeInfo then
                                     exit(a.EntityID<b.EntityID)
  else result:=a.UprradeInfo<b.UprradeInfo;

end;
procedure GKey2DataMap.RegisterKey(const key:TKey; const Value:TValue);
var
   {$IFDEF OldIteratorDef}
   Iterator:specialize TMap<TKey, TValue, TCompare>.TIterator;
   {$ELSE}
   Iterator:TIterator;
   {$ENDIF}
begin
  Iterator:=Find(key);
  if  Iterator=nil then
                       begin
                            Insert(Key,Value);
                       end
                   else
                       begin
                            Iterator.Value:=value;
                            Iterator.Destroy;
                       end;
end;
function GKey2DataMap.MyGetValue(key:TKey; out Value:TValue):boolean;
var
   {$IFDEF OldIteratorDef}
   Iterator:specialize TMap<TKey, TValue, TCompare>.TIterator;
   {$ELSE}
   Iterator:TIterator;
   {$ENDIF}
begin
  Iterator:=Find(key);
  if  Iterator=nil then
                       result:=false
                   else
                       begin
                            Value:=Iterator.GetValue;
                            Iterator.Destroy;
                            result:=true;
                       end;
end;

function TMyMap.MyGetValue(key:TKey):TValue;
var
   {$IFDEF OldIteratorDef}
   Iterator:specialize TMap<TKey, TValue, TCompare>.TIterator;
   {$ELSE}
   Iterator:TIterator;
   {$ENDIF}
begin
  Iterator:=Find(key);
  if  Iterator=nil then
                       result:=TValue(0)
                   else
                       begin
                            result:=Iterator.GetValue;
                            Iterator.Destroy;
                       end;
end;
procedure TMyMap.MyGetOrCreateValue(const key:TKey; var Value:TValue; out OutValue:TValue);
var
   {$IFDEF OldIteratorDef}
   Iterator:specialize TMap<TKey, TValue, TCompare>.TIterator;
   {$ELSE}
   Iterator:TIterator;
   {$ENDIF}
begin
  Iterator:=Find(key);
  if  Iterator=nil then
                       begin
                            Insert(Key, Value);
                            OutValue:=Value;
                            inc(Value);
                       end
                   else
                       begin
                            OutValue:=Iterator.GetValue;
                            Iterator.Destroy;
                       end;
end;
begin
     {$IFDEF DEBUGINITSECTION}LogOut('dxftypes.initialization');{$ENDIF}
end.
