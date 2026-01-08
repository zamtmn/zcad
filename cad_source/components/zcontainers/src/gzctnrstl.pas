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
uses
  gvector,
  gutil,gmap,ghashmap,generics.collections,
  sysutils;
type
TMyMapGenOld <TKey, TValue, TCompare> = class( TMap<TKey, TValue, TCompare>);
TMyMapGen <TKey,TValue> = class( TDictionary<TKey,TValue>)
  function MyGetValue(const key:TKey):TValue;inline;
 {$If FPC_FULLVERSION <= 30204}
  function GetMutableValue(const AKey: TKey): PValue; inline;
  function TryGetMutableValue(const AKey: TKey; out APValue: PValue): Boolean;
 {$EndIf}
end;
TMyMap <TKey, TValue> = class( TMyMapGen<TKey, TValue>)
  procedure MyGetOrCreateValue(const key:TKey; var Value:TValue; out OutValue:TValue);inline;
end;
TMyGenMapCounter<TKey,TValue> = class( TMyMap<TKey,TValue>)
  function CountKey(const key:TKey; const InitialCounter:TValue=1):TValue;inline;
end;

TMyMapCounter<TKey>=class(TMyGenMapCounter<TKey,SizeUInt>);

GKey2DataMap <TKey, TValue> = class(TMyMapGen<TKey, TValue>)
        procedure RegisterKey(const key:TKey; const Value:TValue);
        function MyGetValue(const key:TKey; out Value:TValue):boolean;
        function MyContans(const key:TKey):boolean;
end;
  GKey2DataMapOld <TKey, TValue, TCompare> = class(TMap<TKey, TValue, TCompare>)
    procedure RegisterKey(const key:TKey; const Value:TValue);
    //function MyGetValue(key:TKey; out Value:TValue):boolean;
    //function MyGetMutableValue(key:TKey; out PValue:{$IFNDEF DELPHI}PTValue{$ENDIF}{$IFDEF DELPHI}pointer{$ENDIF}):boolean;
    function MyContans(const key:TKey):boolean;
   {$If FPC_FULLVERSION <= 30204}
    function GetMutableValue(key:TKey):PTValue;inline;
    function TryGetMutableValue(key:TKey;out pvalue:PTValue):boolean;inline;
   {$EndIf}
end;
TMyVector <T> = class(TVector<T>)
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

TMyHashMap <TKey, TValue, Thash> = class(ghashmap.THashMap<TKey, TValue, Thash>)
  //function MyGetValue(key:TKey; out Value:TValue):boolean;
end;
StringHash=class
  class function hash(const s:AnsiString; n:longint):SizeUInt;
end;
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
constructor TMyVectorArray<T,TVec>.create;
begin
     VArray:=TArrayOfVec.create;
end;
destructor TMyVectorArray<T,TVec>.destroy;
var
  i:integer;
begin
  for i:=0 to VArray.size-1 do
    VArray[i].destroy;
  VArray.destroy;
end;
function TMyVectorArray<T,TVec>.AddArray:SizeInt;
begin
     result:=VArray.size;
     VArray.PushBack(TVec.create);
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
     (VArray[CurrentArray]){brackets for 2.6.x compiler version}.PushBack(data);
end;
function TMyVectorArray<T,TVec>.GetCurrentArray:TVec;
begin
  result:=VArray[CurrentArray];
end;

{function TMyHashMap<TKey, TValue,Thash>.MyGetValue(key:TKey; out Value:TValue):boolean;
var i,h,bs:longint;
begin
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
end;}
function MakeHash(const s:AnsiString):SizeUInt;//TODO это копия процедуры из uzbstrproc
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to Length(s) do
    Result := ((Result shl 7) or (Result shr 25)) + Ord(s[I]);
end;
class function StringHash.hash(const s:AnsiString; n:longint):SizeUInt;
begin
     result:=makehash(s) mod SizeUInt(n);
end;
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
var
  pv:^TValue;
begin
  if tryGetMutableValue(key,pv) then
    result:=pv^
  else
    result:=default(TValue);
  {if not GetValue(Key,result) then
    result:=default(TValue);}
end;
{function TMyMapGen<TKey, TValue>.MyGetMutableValue(key:TKey; out PAValue:PValue):Boolean;
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
end;}
{$If FPC_FULLVERSION <= 30204}
function TMyMapGen<TKey, TValue>.GetMutableValue(const AKey: TKey): PValue;
var
  LIndex: SizeInt;
  LHash: UInt32;
begin
  LIndex := FindBucketIndex(FItems, AKey, LHash);
  if LIndex < 0 then
    Result := Nil
  else
    Result := @FItems[LIndex].Pair.Value;
end;

function TMyMapGen<TKey, TValue>.TryGetMutableValue(const AKey: TKey; out APValue: PValue): Boolean;
begin
  APValue := GetMutableValue(AKey);
  Result := APValue <>Nil;
end;

function GKey2DataMapOld<TKey, TValue, TCompare>.GetMutableValue(key:TKey):PTValue;inline;
var Pair:TPair;
    Node:TMSet.PNode;
begin
 Pair.Key:=key;
 Node:=FSet.NFind(Pair);
 if Node=nil then
   result:=nil
 else
   result:=@Node^.Data.Value;
end;

function GKey2DataMapOld<TKey, TValue, TCompare>.TryGetMutableValue(key:TKey;out pvalue:PTValue):boolean;
var Pair:TPair;
    Node:TMSet.PNode;
begin
  pvalue:=GetMutableValue(key);
  Result:=pvalue<>nil;
end;
{$EndIf}

function TMyGenMapCounter<TKey,TValue>.CountKey(const key:TKey; const InitialCounter:TValue=1):TValue;inline;
var
  PAValue:PValue;
begin
  if tryGetMutableValue(key,PAValue) then begin
    PAValue^:=PAValue^+InitialCounter;
    result:=PAValue^;
  end else begin
    add(key,InitialCounter);
    result:=InitialCounter;
  end;
end;

procedure TMyMap<TKey, TValue>.MyGetOrCreateValue(const key:TKey; var Value:TValue; out OutValue:TValue);
begin
  if not TryGetValue(key,OutValue) then begin
    add(Key,Value);
    OutValue:=Value;
    value:=value+1;
  end
end;
procedure GKey2DataMapOld<TKey, TValue{$IFNDEF DELPHI},TCompare{$ENDIF}>.RegisterKey(const key:TKey; const Value:TValue);
var
  Iterator:TIterator;
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
{function GKey2DataMapOld<TKey, TValue,TCompare>.MyGetValue(key:TKey; out Value:TValue):boolean;
var
   Pair:TPair;
   Node:TMSet.PNode;
begin
  Pair.Key:=key;
  Node:=FSet.NFind(Pair);
  if Node=nil then
    result:=false
  else begin
    result:=true;
    Value:=Node^.Data.Value;
  end;
end;}
{function GKey2DataMapOld<TKey, TValue,TCompare>.MyGetMutableValue(key:TKey; out PValue:PTValue):boolean;
var
  Pair:TPair;
  Node:TMSet.PNode;
begin
  Pair.Key:=key;
  Node:=FSet.NFind(Pair);
  if Node=nil then
    result:=false
  else begin
    result:=true;
    PValue:=@Node^.Data.Value;
  end;
end;}
function GKey2DataMapOld<TKey, TValue,TCompare>.MyContans(const key:TKey):boolean;
var
   //Pair:TPair;
   //Node: TMSet.PNode;
   p:pointer;
begin
  result:=tryGetMutableValue(key,p);
  {
  Pair.Key:=key;
  Node := FSet.NFind(Pair);
  Result := Node <> nil;
  }
end;
begin
end.
