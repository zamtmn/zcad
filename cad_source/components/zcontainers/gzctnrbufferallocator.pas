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
unit gzctnrBufferAllocator;
{$Mode delphi}

interface
uses
  gvector,//gzctnrVector,
  garrayutils,
  sysutils;
type
  GBufferAllocator<GOffset,GSize,GData>=object
    public
      type
        TOffset=GOffset;
        TSize=GSize;
        TData=GData;
        TBufferRange=record
          public
            var
              Offset:TOffset;
              Size:TSize;
              Data:TData;
          public
            Constructor CreateFreeRange(const AOffset:TOffset;const ASize:TSize;const AData:TData);
         end;
        PBufferRange=^TBufferRange;
        TRanges=TVector<TBufferRange>;
        TIndexInRanges=SizeInt;
        TFreeRangesIndexs=TVector<TIndexInRanges>;
        TMoveAllocadetRange=procedure(const oldI,newI:TIndexInRanges;const AData:TData);
      var
        AllocatedRanges:TRanges;
        FreeRanges:TRanges;
        onMoveAllocadetRange:TMoveAllocadetRange;
      const
        CWrongIndexInRanges=-1;
    private
      function FindFreeRange(const ASize:TSize):TIndexInRanges;
    public
      constructor Init(ABufSize:TSize);
      destructor done;virtual;
      function Allocate(ASize:TSize;Adata:GData):TIndexInRanges;
      procedure Release(Index:TIndexInRanges);
      function CalcFragmentation:Double;
  end;
implementation
Constructor GBufferAllocator<GOffset,GSize,GData>.TBufferRange.CreateFreeRange(const AOffset:TOffset;const ASize:TSize;const AData:TData);
begin
  Offset:=AOffset;
  Size:=ASize;
  Data:=Adata;
end;

constructor GBufferAllocator<GOffset,GSize,GData>.Init(ABufSize:TSize);
begin
  AllocatedRanges:=TRanges.Create;
  AllocatedRanges.Reserve(4*1024*1024);
  FreeRanges:=TRanges.Create;
  FreeRanges.Reserve(4*1024);
  FreeRanges.PushBack(TBufferRange.CreateFreeRange(0,ABufSize,-1));
  onMoveAllocadetRange:=nil;
end;
destructor GBufferAllocator<GOffset,GSize,GData>.done;
begin
  AllocatedRanges.destroy;
  FreeRanges.destroy;
end;

function GBufferAllocator<GOffset,GSize,GData>.FindFreeRange(const ASize:TSize):TIndexInRanges;
var
  i:TIndexInRanges;
  pbr:PBufferRange;
  tds,ds:SizeInt;
begin
  result:=CWrongIndexInRanges;
  ds:=high(ds);
  for i:=0 to FreeRanges.size-1 do begin
    pbr:=FreeRanges.Mutable[i];
    tds:=pbr^.Size-ASize;
    if tds=0 then begin
      exit(i);
    end else if pbr^.Size>ASize then begin
      if (tds<ds)or(result=CWrongIndexInRanges) then begin
        ds:=tds;
        result:=i;
      end;
    end;
  end;
end;

function GBufferAllocator<GOffset,GSize,GData>.CalcFragmentation:Double;
var
  i:SizeUInt;
  pbr:PBufferRange;
  total,largest:TSize;
begin
  pbr:=FreeRanges.Mutable[0];
  total:=pbr^.Size;
  largest:=pbr^.Size;
  for i:=1 to FreeRanges.size-1 do begin
    pbr:=FreeRanges.Mutable[i];
    if largest<pbr^.Size then
      largest:=pbr^.Size;
    total:=total+pbr^.Size;
  end;
  result:=(Total-Largest)/total;
end;

function GBufferAllocator<GOffset,GSize,GData>.Allocate(ASize:TSize;Adata:GData):TIndexInRanges;
var
  SuitableFreeRangeIndex:TIndexInRanges;
  FreeRangesIndex:SizeUInt;
  pbr:PBufferRange;
  nbr:TBufferRange;
begin
  SuitableFreeRangeIndex:=FindFreeRange(ASize);
  if SuitableFreeRangeIndex=CWrongIndexInRanges then
    raise Exception.Create('Cannot allocate');
  pbr:=FreeRanges.Mutable[SuitableFreeRangeIndex];
  if pbr^.Size<>ASize then begin
    nbr.CreateFreeRange(pbr^.Offset,Asize,Adata);
    pbr^.Offset:=pbr^.Offset+Asize;
    pbr^.Size:=pbr^.Size-Asize;
    Result:=AllocatedRanges.size;
    AllocatedRanges.PushBack(nbr);
  end else begin
    Result:=AllocatedRanges.size;
    AllocatedRanges.PushBack(FreeRanges.mutable[SuitableFreeRangeIndex]^);
    FreeRanges.mutable[SuitableFreeRangeIndex]^:=FreeRanges.back;
    FreeRanges.popback;
  end;
end;
procedure GBufferAllocator<GOffset,GSize,GData>.Release(Index:TIndexInRanges);
var
  SuitableRangeIndex:TIndexInRanges;
  pbr:PBufferRange;
  nbr:TBufferRange;
begin
  FreeRanges.PushBack(AllocatedRanges.Mutable[Index]^);
  if @onMoveAllocadetRange<>nil then
    onMoveAllocadetRange(AllocatedRanges.size-1,Index,AllocatedRanges.back.data);
  AllocatedRanges.mutable[Index]^:=AllocatedRanges.back;
  AllocatedRanges.popback;
end;
begin
end.
