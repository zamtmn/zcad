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
unit usimplegenerics;
{$INCLUDE def.inc}

interface
uses strproc,gdbase,gdbasetypes,
     sysutils,
     gutil,gmap,ghashmap,gvector;
type
LessPointer= TLess<pointer>;
LessGDBString= TLess<GDBString>;
LessDWGHandle= TLess<TDWGHandle>;
LessObjID= TLess<TObjID>;
LessInteger= TLess<Integer>;

TMyMap <TKey, TValue, TCompare> = class( TMap<TKey, TValue, TCompare>)
  function MyGetValue(key:TKey):TValue;inline;
  procedure MyGetOrCreateValue(const key:TKey; var Value:TValue; out OutValue:TValue);inline;
end;
TMyMapCounter <TKey, TCompare> = class( TMyMap<TKey, SizeUInt, TCompare>)
  procedure CountKey(const key:TKey; const InitialCounter:SizeUInt);inline;
end;
GKey2DataMap <TKey, TValue, TCompare> = class(TMap<TKey, TValue, TCompare>)
        procedure RegisterKey(const key:TKey; const Value:TValue);
        function MyGetValue(key:TKey; out Value:TValue):boolean;
        function MyGetMutableValue(key:TKey; out PValue:PTValue):boolean;
        function MyContans(key:TKey):boolean;
end;
TMyVector <T> = class(TVector<T>)
end;

TMyVectorArray <T> = class
        type
        TVec=TMyVector <T>;
        TArrayOfVec=TMyVector <TVec>;
        var
        VArray:TArrayOfVec;
        CurrentArray:SizeInt;
        constructor create;
        destructor destroy;virtual;
        function AddArray:SizeInt;
        procedure SetCurrentArray(ai:SizeInt);
        procedure AddDataToCurrentArray(data:T);
end;

TMyHashMap <TKey, TValue, Thash> = class(THashMap<TKey, TValue, Thash>)
  function MyGetValue(key:TKey; out Value:TValue):boolean;
end;

GDBStringHash=class
  class function hash(s:GDBstring; n:longint):SizeUInt;
end;
TMyGDBStringDictionary <TValue> = class(TMyHashMap<GDBString, TValue, GDBStringHash>)
end;


TGDBString2GDBStringDictionary=TMyGDBStringDictionary<GDBString>;

TMapPointerToHandle=TMyMap<pointer,TDWGHandle, LessPointer>;

TMapHandleToHandle=TMyMap<TDWGHandle,TDWGHandle, LessDWGHandle>;
TMapHandleToPointer=TMyMap<TDWGHandle,pointer, LessDWGHandle>;

TMapBlockHandle_BlockNames=TMap<TDWGHandle,string,LessDWGHandle>;

TEntUpgradeKey=record
                      EntityID:TObjID;
                      UprradeInfo:TEntUpgradeInfo;
               end;
LessEntUpgradeKey=class
  class function c(a,b:TEntUpgradeKey):boolean;inline;
end;

implementation
{uses
    log;}
constructor TMyVectorArray<T>.create;
begin
     VArray:=TArrayOfVec.create;
end;
destructor TMyVectorArray<T>.destroy;
begin
     VArray.destroy;
end;
function TMyVectorArray<T>.AddArray:SizeInt;
begin
     result:=VArray.size;
     VArray.PushBack(TVec.create);
end;
procedure TMyVectorArray<T>.SetCurrentArray(ai:SizeInt);
begin
     CurrentArray:=ai;
end;
procedure TMyVectorArray<T>.AddDataToCurrentArray(data:T);
begin
     (VArray[CurrentArray]){brackets for 2.6.x compiler version}.PushBack(data);
end;
function TMyHashMap<TKey, TValue, Thash>.MyGetValue(key:TKey; out Value:TValue):boolean;
var i,h,bs:longint;
begin
  {$IF FPC_FULlVERSION<=20701}
  result:=contains(key);
  if result then value:=self.GetData(key);
  {$ELSE}
  h:=Thash.hash(key,FData.size);
  bs:=(FData[h]).size;
  for i:=0 to bs-1 do begin
    if (((FData[h])[i]).Key=key) then
                                     begin
                                          value:=((FData[h])[i]).Value;
                                          exit(true);
                                     end;
  end;
  exit(false);
  {$ENDIF}
end;
class function GDBStringHash.hash(s:GDBString; n:longint):SizeUInt;
begin
     result:=makehash(s) mod SizeUInt(n);
end;

class function LessEntUpgradeKey.c(a,b:TEntUpgradeKey):boolean;inline;
begin
  //c:=a<b;
  if a.UprradeInfo=b.UprradeInfo then
                                     exit(a.EntityID<b.EntityID)
  else result:=a.UprradeInfo<b.UprradeInfo;

end;
procedure GKey2DataMap<TKey, TValue, TCompare>.RegisterKey(const key:TKey; const Value:TValue);
var
   {$IFDEF OldIteratorDef}
   TParent:specialize TMap<TKey, TValue, TCompare>;
   Iterator:TParent.TIterator;
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
function GKey2DataMap<TKey, TValue, TCompare>.MyGetValue(key:TKey; out Value:TValue):boolean;
var
   {$IFDEF OldIteratorDef}
   TParent:specialize TMap<TKey, TValue, TCompare>;
   Iterator:TParent.TIterator;
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
function GKey2DataMap<TKey, TValue, TCompare>.MyGetMutableValue(key:TKey; out PValue:PTValue):boolean;
var
   {$IFDEF OldIteratorDef}
   TParent:specialize TMap<TKey, TValue, TCompare>;
   Iterator:TParent.TIterator;
   {$ELSE}
   Iterator:TIterator;
   {$ENDIF}
begin
  Iterator:=Find(key);
  if  Iterator=nil then
                       result:=false
                   else
                       begin
                            PValue:=Iterator.MutableValue;
                            Iterator.Destroy;
                            result:=true;
                       end;
end;
function GKey2DataMap<TKey, TValue, TCompare>.MyContans(key:TKey):boolean;
var
   {$IF FPC_FULlVERSION<=20701}
   {$IFDEF OldIteratorDef}
   TParent:specialize TMap<TKey, TValue, TCompare>;
   Iterator:TParent.TIterator;
   {$ELSE}
   Iterator:TIterator;
   {$ENDIF}
   {$ELSE}
   Pair:TPair;
   Node: TMSet.PNode;
   {$ENDIF}
begin
  {$IF FPC_FULlVERSION<=20701}
  Iterator:=Find(key);
  if Iterator<>nil then
                           begin
                                result:=true;
                                Iterator.Destroy;
                           end
                       else
                           result:=false;
  {$ELSE}
  Pair.Key:=key;
  Node := FSet.NFind(Pair);
  Result := Node <> nil;
  {$ENDIF}
end;

function TMyMap<TKey, TValue, TCompare>.MyGetValue(key:TKey):TValue;
var
   {$IFDEF OldIteratorDef}
   TParent:specialize TMap<TKey, TValue, TCompare>;
   Iterator:TParent.TIterator;
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
procedure TMyMapCounter<TKey, TCompare>.CountKey(const key:TKey; const InitialCounter:SizeUInt);
var
   {$IFDEF OldIteratorDef}
   TParent:specialize TMap<TKey, TValue, TCompare>;
   Iterator:TParent.TIterator;
   {$ELSE}
   Iterator:TIterator;
   {$ENDIF}
begin
  Iterator:=Find(key);
  if  Iterator=nil then
                       begin
                            Insert(Key, InitialCounter);
                       end
                   else
                       begin
                            Iterator.SetValue(Iterator.GetValue+1);
                            Iterator.Destroy;
                       end;
end;

procedure TMyMap<TKey, TValue, TCompare>.MyGetOrCreateValue(const key:TKey; var Value:TValue; out OutValue:TValue);
var
   {$IFDEF OldIteratorDef}
   TParent:specialize TMap<TKey, TValue, TCompare>;
   Iterator:TParent.TIterator;
   {$ELSE}
   Iterator:TIterator;
   {$ENDIF}
begin
  Iterator:=Find(key);
  if  Iterator=nil then
                       begin
                            Insert(Key, Value);
                            OutValue:=Value;
                            value:=value+1;
                            //inc(Value);
                       end
                   else
                       begin
                            OutValue:=Iterator.GetValue;
                            Iterator.Destroy;
                       end;
end;
begin
end.
