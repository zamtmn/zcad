{
   This file is part of the Free Pascal FCL library.
   BSD parts (c) 2011 Vlado Boza

   See the file COPYING.FPC, included in this distribution,
   for details about the copyright.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY;without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

**********************************************************************}
{$mode objfpc}

{$IFNDEF FPC_DOTTEDUNITS}
unit gzmap;
{$ENDIF FPC_DOTTEDUNITS}

interface

{$IFDEF FPC_DOTTEDUNITS}
uses System.Stl.Sets;
{$ELSE FPC_DOTTEDUNITS}
uses gset;
{$ENDIF FPC_DOTTEDUNITS}

type
  generic TMapCompare<TPair, TKeyCompare>=class
    class function c(a,b :TPair):boolean;
  end;

  { TMapIterator }

  generic TMapIterator<TKey, TValue, TPair, TNode>=class
    public
    type PNode=^TNode;
         TLMapIterator = specialize TMapIterator<TKey, TValue, TPair, TNode>;
    var FNode, FNext:PNode; // FNext is for MoveNext only, which has different semantics than Next in that it starts in the state 'before first'.
    type PValue=^TValue;
    function GetData:TPair;inline;
    function GetKey:TKey;inline;
    function GetValue:TValue;inline;
    function GetMutable:PValue;inline;
    procedure SetValue(value:TValue);inline;
    function MoveNext:boolean;inline;
    function Next:boolean;inline;
    function Prev:boolean;inline;
    function GetEnumerator: TLMapIterator; inline;
    property Data:TPair read GetData;
    property Key:TKey read GetKey;
    property Value:TValue read GetValue write SetValue;
    property MutableValue:PValue read GetMutable;
    property Current : TPair read GetData;
  end;

  generic TMap<TKey, TValue, TCompare>=class
  public
  type
    TPair=record
      Value:TValue;
      Key:TKey;
    end;
    TMCompare = specialize TMapCompare<TPair, TCompare>;
    TMSet = specialize TSet<TPair, TMCompare>;
    TIterator = specialize TMapIterator<TKey, TValue, TPair, TMSet.Node>;
    PTValue = ^TValue;
    PTPair = ^TPair;
  var
  private
    FSet:TMSet;
  public
    function Find(key:TKey):TIterator;inline;
    function FindLess(key:TKey):TIterator;inline;
    function FindLessEqual(key:TKey):TIterator;inline;
    function FindGreater(key:TKey):TIterator;inline;
    function FindGreaterEqual(key:TKey):TIterator;inline;
    function GetValue(key:TKey):TValue;inline;
    function GetMutableValue(key:TKey):PTValue;inline;
    function TryGetValue(key:TKey; out Value: TValue): boolean;inline;
    function TryGetMutableValue(key:TKey;out pvalue:PTValue):boolean;inline;
    procedure Insert(key:TKey; value:TValue);inline;
    function InsertAndGetIterator(key:TKey; value:TValue):TIterator;inline;
    function Min:TIterator;inline;
    function Max:TIterator;inline;
    procedure Delete(key:TKey);inline;
    function Size:SizeUInt;inline;
    function IsEmpty:boolean;inline;
    function GetEnumerator: TIterator; inline;
    constructor Create;
    destructor Destroy;override;
    property Items[i : TKey]: TValue read GetValue write Insert; default;
  end;

implementation

class function TMapCompare.c(a,b: TPair):boolean;
begin
  c:= TKeyCompare.c(a.Key, b.Key);
end;

constructor TMap.Create;
begin
  FSet:=TMSet.Create;
end;

destructor TMap.Destroy;
begin
  FSet.Destroy;
end;

procedure TMap.Delete(key:TKey);inline;
var Pair:TPair;
begin
  Pair.Key:=key;
  FSet.Delete(Pair);
end;

function TMap.Find(key:TKey):TIterator;inline;
var Pair:TPair; ret:TIterator;
begin
  Pair.Key:=key;
  ret := TIterator.create;
  ret.FNode:=FSet.NFind(Pair);
  if ret.FNode = nil then begin
    ret.Destroy; ret := nil;
  end;
  Find := ret;
end;

function TMap.FindLess(key:TKey):TIterator;inline;
var Pair:TPair; ret:TIterator;
begin
  Pair.Key:=key;
  ret := TIterator.create;
  ret.FNode:=FSet.NFindLess(Pair);
  if ret.FNode = nil then begin
    ret.Destroy; ret := nil;
  end;
  FindLess := ret;
end;

function TMap.FindLessEqual(key:TKey):TIterator;inline;
var Pair:TPair; ret:TIterator;
begin
  Pair.Key:=key;
  ret := TIterator.create;
  ret.FNode:=FSet.NFindLessEqual(Pair);
  if ret.FNode = nil then begin
    ret.Destroy; ret := nil;
  end;
  FindLessEqual := ret;
end;

function TMap.FindGreater(key:TKey):TIterator;inline;
var Pair:TPair; ret:TIterator;
begin
  Pair.Key:=key;
  ret := TIterator.create;
  ret.FNode:=FSet.NFindGreater(Pair);
  if ret.FNode = nil then begin
    ret.Destroy; ret := nil;
  end;
  FindGreater := ret;
end;

function TMap.FindGreaterEqual(key:TKey):TIterator;inline;
var Pair:TPair; ret:TIterator;
begin
  Pair.Key:=key;
  ret := TIterator.create;
  ret.FNode:=FSet.NFindGreaterEqual(Pair);
  if ret.FNode = nil then begin
    ret.Destroy; ret := nil;
  end;
  FindGreaterEqual := ret;
end;

function TMap.GetValue(key:TKey):TValue;inline;
var Pair:TPair;
begin
  Pair.Key:=key;
  GetValue:=FSet.NFind(Pair)^.Data.Value;
end;

function TMap.GetMutableValue(key:TKey):PTValue;inline;
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

function TMap.TryGetValue(key: TKey; out Value: TValue): boolean;
var Pair:TPair;
    Node: TMSet.PNode;
begin
  Pair.Key:=key;
  Node := FSet.NFind(Pair);
  Result := Node <> nil;
  if Result then
    Value := Node^.Data.Value;
end;

function TMap.TryGetMutableValue(key:TKey;out pvalue:PTValue):boolean;
//var Pair:TPair;
    //Node:TMSet.PNode;
begin
  pvalue:=GetMutableValue(key);
  Result:=pvalue<>nil;
end;

procedure TMap.Insert(key:TKey; value:TValue);inline;
var Pair:TPair;
begin
  Pair.Key:=key;
  FSet.NInsert(Pair)^.Data.Value := value;
end;

function TMap.InsertAndGetIterator(key:TKey; value:TValue):TIterator;inline;
var Pair:TPair; ret:TIterator;
begin
  ret := TIterator.create;
  Pair.Key:=key;
  ret.FNode := FSet.NInsert(Pair);
  ret.FNode^.Data.Value := value;
  InsertAndGetIterator := ret;
end;

function TMap.Min:TIterator;inline;
var ret:TIterator;
begin
  ret := TIterator.create;
  ret.FNode:=FSet.NMin;
  if ret.FNode = nil then begin
    ret.Destroy; ret := nil;
  end;
  Min := ret;
end;

function TMap.Max:TIterator;inline;
var ret:TIterator;
begin
  ret := TIterator.create;
  ret.FNode:=FSet.NMax;
  if ret.FNode = nil then begin
    ret.Destroy; ret := nil;
  end;
  Max := ret;
end;

function TMap.Size:SizeUInt;inline;
begin
  Size:=FSet.Size;
end;

function TMap.IsEmpty:boolean;inline;
begin
  IsEmpty:=FSet.IsEmpty;
end;

function TMap.GetEnumerator: TIterator;
var
  setn: TMSet.PNode;
begin
  result:=titerator.create;
  setn := FSet.NMin;
  result.FNode := setn; // for Next/Prev
  result.FNext := setn; // for MoveNext
end;

function TMapIterator.GetData:TPair;inline;
begin
  GetData:=FNode^.Data;
end;

function TMapIterator.GetKey:TKey;inline;
begin
  GetKey:=FNode^.Data.Key;
end;

function TMapIterator.GetValue:TValue;inline;
begin
  GetValue:=FNode^.Data.Value;
end;

function TMapIterator.GetMutable:PValue;inline;
begin
  GetMutable:=@(FNode^.Data.Value);
end;

procedure TMapIterator.SetValue(value:TValue);inline;
begin
  FNode^.Data.Value := value;
end;

function TMapIterator.MoveNext: boolean;
var
  n, child: PNode;
begin
  n := FNext;
  result := n <> nil;
  if not result then exit;

  FNode := n;
  child := n^.Right;
  if child <> nil then begin
    repeat
      n := child;
      child := n^.Left;
    until child = nil;
  end
  else begin
    repeat
      child := n;
      n := n^.Parent;
    until (n = nil) or (child = n^.Left);
  end;
  FNext := n;
end;

function TMapIterator.Next:boolean;inline;
var temp:PNode;
begin
  if(FNode=nil) then exit(false);
  if(FNode^.Right<>nil) then begin
    temp:=FNode^.Right;
    while(temp^.Left<>nil) do temp:=temp^.Left;
  end
  else begin
    temp:=FNode;
    while(true) do begin
      if(temp^.Parent=nil) then begin temp:=temp^.Parent; break; end;
      if(temp^.Parent^.Left=temp) then begin temp:=temp^.Parent; break; end;
      temp:=temp^.Parent;
    end;
  end;
  if (temp = nil) then exit(false);
  FNode:=temp;
  Next:=true;
end;

function TMapIterator.Prev:boolean;inline;
var temp:PNode;
begin
  if(FNode=nil) then exit(false);
  if(FNode^.Left<>nil) then begin
    temp:=FNode^.Left;
    while(temp^.Right<>nil) do temp:=temp^.Right;
  end
  else begin
    temp:=FNode;
    while(true) do begin
      if(temp^.Parent=nil) then begin temp:=temp^.Parent; break; end;
      if(temp^.Parent^.Right=temp) then begin temp:=temp^.Parent; break; end;
      temp:=temp^.Parent;
    end;
  end;
  if (temp = nil) then exit(false);
  FNode:=temp;
  Prev:=true;
end;

function TMapIterator.GetEnumerator: TLMapIterator;
begin
  result:=Self;
end;

end.
