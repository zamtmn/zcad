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
unit gzctnrSTL;

interface
uses {$IFNDEF DELPHI}gutil,gmap,ghashmap,gvector,generics.collections,{$ENDIF}
     {$IFDEF DELPHI}generics.collections,{$ENDIF}
     sysutils;
type
{$IFDEF DELPHI}
TMapForDelphi <TKey, TValue> = class( TDictionary<TKey, TValue>)
end;
{$ENDIF}
{$IFNDEF DELPHI}TMyMapGenOld <TKey, TValue, TCompare> = class( TMap<TKey, TValue, TCompare>);{$ENDIF}
{$IFNDEF DELPHI}TMyMapGen <TKey,TValue> = class( TDictionary<TKey,TValue>){TMyMapGen <TKey, TValue, TCompare> = class( TMap<TKey, TValue, TCompare>)}{$ENDIF}
 {$IFDEF DELPHI}TMyMapGen <TKey,TValue> = class( TDictionary<TKey,TValue>){$ENDIF}
  function MyGetValue(const key:TKey):TValue;inline;
  function MyGetMutableValue(const key:TKey; out PAValue:{$IFNDEF DELPHI}PValue{$ENDIF}{$IFDEF DELPHI}pointer{$ENDIF}):boolean;
end;
{$IFNDEF DELPHI}TMyMap <TKey, TValue> = class( TMyMapGen<TKey, TValue>){$ENDIF}
 {$IFDEF DELPHI}TMyMap <TKey,TValue> = class( TMyMapGen<TKey,TValue>){$ENDIF}
  procedure MyGetOrCreateValue(const key:TKey; var Value:TValue; out OutValue:TValue);inline;
end;
TMyGenMapCounter<TKey,TValue> = class( TMyMap<TKey,TValue>)
  function CountKey(const key:TKey; const InitialCounter:TValue=1):TValue;inline;
end;

TMyMapCounter<TKey>=class(TMyGenMapCounter<TKey,SizeUInt>);

 {$IFNDEF DELPHI}GKey2DataMap <TKey, TValue> = class(TMyMapGen<TKey, TValue>){$ENDIF}
 {$IFDEF DELPHI}GKey2DataMap <TKey, TValue> = class(TDictionary<TKey, TValue>){$ENDIF}
        {$IFDEF DELPHI}type PTValue=^TValue;{$ENDIF}
        procedure RegisterKey(const key:TKey; const Value:TValue);
        function MyGetValue(const key:TKey; out Value:TValue):boolean;
        //function MyGetMutableValue(key:TKey; out PValue:{$IFNDEF DELPHI}PTValue{$ENDIF}{$IFDEF DELPHI}pointer{$ENDIF}):boolean;
        function MyContans(const key:TKey):boolean;
end;
  GKey2DataMapOld <TKey, TValue, TCompare> = class(TMap<TKey, TValue, TCompare>)
    procedure RegisterKey(const key:TKey; const Value:TValue);
    function MyGetValue(const key:TKey; out Value:TValue):boolean;
    function MyGetMutableValue(const key:TKey; out PValue:{$IFNDEF DELPHI}PTValue{$ENDIF}{$IFDEF DELPHI}pointer{$ENDIF}):boolean;
    function MyContans(const key:TKey):boolean;
end;
{$IFNDEF DELPHI}TMyVector <T> = class(TVector<T>){$ENDIF}
 {$IFDEF DELPHI}TMyVector <T> = class(Generics.Collections.TList<T>)
                                     function Size: SizeUInt; inline;
                                     procedure PushBack(const Value: T); inline;
                                     function mutable(const i:integer):pointer; inline;
 {$ENDIF}
   procedure CopyTo(Dst:TMyVector<T>);
end;

TMyVectorArray<T,TVec> = class
        type
        //TVec=TMyVector <T>;
        TArrayOfVec=TMyVector <TVec>;
        var
        VArray:TArrayOfVec;
        CurrentArray:SizeInt;
        public
        constructor create;
        destructor destroy;override;
        function AddArray:SizeInt;
        function AddArrayAndSetCurrent:SizeInt;
        procedure SetCurrentArray(ai:SizeInt);
        procedure AddDataToCurrentArray(const data:T);
        function GetCurrentArray:TVec;
end;

{$IFNDEF DELPHI}TMyHashMap <TKey, TValue, Thash> = class(THashMap<TKey, TValue, Thash>){$ENDIF}
 {$IFDEF DELPHI}TMyHashMap <TKey, TValue> = class(TDictionary<TKey, TValue>){$ENDIF}
  function MyGetValue(const key:TKey; out Value:TValue):boolean;
end;
{$IFNDEF DELPHI}
StringHash=class
  class function hash(const s:AnsiString; n:longint):SizeUInt;
end;
{$ENDIF}
TMyAnsiStringDictionary <TValue> = class(TMyHashMap<AnsiString, TValue{$IFNDEF DELPHI},StringHash{$ENDIF}>)
end;
implementation
procedure TMyVector<T>.CopyTo(Dst:TMyVector<T>);
var
  Data:T;
begin
  Dst.Reserve(Dst.Size+Self.Size);
  for Data in Self do
    Dst.PushBack(Data);
end;
{$IFDEF DELPHI}
function TMyVector<T>.Size: SizeUInt;
begin
  result:=count;
end;
procedure TMyVector<T>.PushBack(const Value: T);
begin
  Add(value);
end;
function TMyVector<T>.mutable(const i:integer):pointer;
begin
  result:=@FItems[i];
end;
{$ENDIF}
constructor TMyVectorArray<T,TVec>.create;
begin
     VArray:=TArrayOfVec.create;
end;
destructor TMyVectorArray<T,TVec>.destroy;
var
  i:integer;
begin
  for i:=0 to{$IFNDEF DELPHI}VArray.size{$ENDIF}{$IFDEF DELPHI}VArray.Count{$ENDIF}-1 do
    VArray[i].destroy;
  VArray.destroy;
end;
function TMyVectorArray<T,TVec>.AddArray:SizeInt;
begin
     result:=VArray.{$IFNDEF DELPHI}size{$ENDIF}{$IFDEF DELPHI}Count{$ENDIF};
     VArray.{$IFNDEF DELPHI}PushBack{$ENDIF}{$IFDEF DELPHI}Add{$ENDIF}(TVec.create);
end;
function TMyVectorArray<T,TVec>.AddArrayAndSetCurrent:SizeInt;
begin
  result:=AddArray;
  SetCurrentArray(result);
end;

procedure TMyVectorArray<T,TVec>.SetCurrentArray(ai:SizeInt);
begin
     CurrentArray:=ai;
end;
procedure TMyVectorArray<T,TVec>.AddDataToCurrentArray(const data:T);
begin
     (VArray[CurrentArray]){brackets for 2.6.x compiler version}.{$IFNDEF DELPHI}PushBack{$ENDIF}{$IFDEF DELPHI}Add{$ENDIF}(data);
end;
function TMyVectorArray<T,TVec>.GetCurrentArray:TVec;
begin
  result:=VArray[CurrentArray];
end;

function TMyHashMap<TKey, TValue{$IFNDEF DELPHI},Thash{$ENDIF}>.MyGetValue(const key:TKey; out Value:TValue):boolean;
{$IFNDEF DELPHI}var i,h,bs:longint;{$ENDIF}
begin
  {$IFNDEF DELPHI}
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
  {$IFDEF DELPHI}
    result:=TryGetValue(Key,Value);
  {$ENDIF}
end;
{$IFNDEF DELPHI}
function MakeHash(const s:AnsiString):SizeUInt;//TODO это копия процедуры из uzbstrproc
var
  I: Integer;
begin
  Result := 0;
  I:=Length(s);
  while I<>0 do
  begin
    Result := ((Result shl 7) or (Result shr 25)) + Ord(s[I]);
    dec(I);
  end;
end;
class function StringHash.hash(const s:AnsiString; n:longint):SizeUInt;
begin
     result:=makehash(s) mod SizeUInt(n);
end;
{$ENDIF}
procedure GKey2DataMap<TKey, TValue>.RegisterKey(const key:TKey; const Value:TValue);
begin
  AddOrSetValue(Key,Value);
end;
function GKey2DataMap<TKey, TValue>.MyGetValue(const key:TKey; out Value:TValue):boolean;
begin
  result:=TryGetValue(Key,Value);
end;
function GKey2DataMap<TKey, TValue>.MyContans(const key:TKey):boolean;
begin
  result:=ContainsKey(Key);
end;

function TMyMapGen<TKey, TValue>.MyGetValue(const key:TKey):TValue;
begin
  if not TryGetValue(Key,result) then
    result:=default(TValue);
end;
function TMyMapGen<TKey, TValue>.MyGetMutableValue(const key:TKey; out PAValue:PValue):Boolean;
var
  LIndex: SizeInt;
  LHash: UInt32;
begin
  LIndex := FindBucketIndex(FItems, key, LHash);

  if LIndex < 0 then begin
    result:=false;
    PAValue:=nil;
  end else begin
    result:=true;
    PAValue:=@FItems[LIndex].Pair.Value;
  end;
end;

function TMyGenMapCounter<TKey,TValue>.CountKey(const key:TKey; const InitialCounter:TValue=1):TValue;inline;
var
  PAValue:PValue;
begin
  if MyGetMutableValue(key,PAValue) then begin
    PAValue^:=PAValue^+InitialCounter;
    result:=PAValue^;
  end else begin
    add(key,InitialCounter);
    result:=InitialCounter;
  end;
end;

procedure TMyMap<TKey, TValue>.MyGetOrCreateValue(const key:TKey; var Value:TValue; out OutValue:TValue);
{$IFNDEF DELPHI}
begin
  if not TryGetValue(key,OutValue) then begin
    add(Key,Value);
    OutValue:=Value;
    value:=value+1;
  end
  {Iterator:=Find(key);
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
                       end;}
end;
{$ENDIF}
{$IFDEF DELPHI}
var
  hc: Integer;
  index: Integer;
begin
  hc:=Hash(Key);
  index := GetBucketIndex(Key, hc);
  if index >= 0 then
    begin
      OutValue:=FItems[Index].Value;
    end
  else
    begin
      AddOrSetValue(Key,Value);
      OutValue:=Value;
      //value:=value+1;
    end;
end;
{$ENDIF}
procedure GKey2DataMapOld<TKey, TValue{$IFNDEF DELPHI},TCompare{$ENDIF}>.RegisterKey(const key:TKey; const Value:TValue);
{$IFNDEF DELPHI}
var
   (*
   {IFDEF OldIteratorDef}
   TParent:specialize TMap<TKey, TValue, TCompare>;
   Iterator:TParent.TIterator;
   {ELSE}
   *)
   Iterator:TIterator;
{$ENDIF}
begin
{$IFNDEF DELPHI}
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
{$ENDIF}
{$IFDEF DELPHI}
  AddOrSetValue(Key,Value);
{$ENDIF}
end;
function GKey2DataMapOld<TKey, TValue{$IFNDEF DELPHI},TCompare{$ENDIF}>.MyGetValue(const key:TKey; out Value:TValue):boolean;
{$IFNDEF DELPHI}
var
   //Iterator:TIterator;
   Pair:TPair;
   Node:TMSet.PNode;
{$ENDIF}
begin
{$IFNDEF DELPHI}
  {Iterator:=Find(key);
  if  Iterator=nil then
                       result:=false
                   else
                       begin
                            Value:=Iterator.GetValue;
                            Iterator.Destroy;
                            result:=true;
                       end;}
  Pair.Key:=key;
  Node:=FSet.NFind(Pair);
  if Node=nil then
    result:=false
  else begin
    result:=true;
    Value:=Node^.Data.Value;
  end;
{$ENDIF}
{$IFDEF DELPHI}
  result:=TryGetValue(Key,Value);
{$ENDIF}
end;
function GKey2DataMapOld<TKey, TValue{$IFNDEF DELPHI},TCompare{$ENDIF}>.MyGetMutableValue(const key:TKey; out PValue:{$IFNDEF DELPHI}PTValue{$ENDIF}{$IFDEF DELPHI}pointer{$ENDIF}):boolean;
{$IFNDEF DELPHI}
var
   (*
   {IFDEF OldIteratorDef}
   TParent:specialize TMap<TKey, TValue, TCompare>;
   Iterator:TParent.TIterator;
   {ELSE}
   *)
//   Iterator:TIterator;
    Pair:TPair;
    Node:TMSet.PNode;
{$ENDIF}
{$IFDEF DELPHI}
var
  hc: Integer;
  index: Integer;
{$ENDIF}
begin
{$IFNDEF DELPHI}
  //Iterator:=Find(key);
  //if  Iterator=nil then
  //                     result:=false
  //                 else
  //                     begin
  //                          PValue:=Iterator.MutableValue;
  //                          Iterator.Destroy;
  //                          result:=true;
  //                     end;
    Pair.Key:=key;
    Node:=FSet.NFind(Pair);
    if Node=nil then
      result:=false
    else begin
      result:=true;
      PValue:=@Node^.Data.Value;
    end;
{$ENDIF}
{$IFDEF DELPHI}
  hc:=Hash(Key);
  index := GetBucketIndex(Key, hc);
  if index >= 0 then
    begin
      PValue:=@FItems[Index].Value;
      result:=true;
    end
  else
    begin
      PValue:=nil;
      result:=false;
    end;
{$ENDIF}
end;
function GKey2DataMapOld<TKey, TValue{$IFNDEF DELPHI},TCompare{$ENDIF}>.MyContans(const key:TKey):boolean;
{$IFNDEF DELPHI}
var
   Pair:TPair;
   Node: TMSet.PNode;
begin
  Pair.Key:=key;
  Node := FSet.NFind(Pair);
  Result := Node <> nil;
end;
{$ENDIF}
{$IFDEF DELPHI}
var
  hc: Integer;
  index: Integer;
begin
  hc:=Hash(Key);
  index := GetBucketIndex(Key, hc);
  if index >= 0 then
    begin
      result:=true;
    end
  else
    begin
      result:=false;
    end;
end;
{$ENDIF}
begin
end.
