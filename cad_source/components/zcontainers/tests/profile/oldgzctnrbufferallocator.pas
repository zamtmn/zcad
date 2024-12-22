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
  GBufferAllocator<GOffset,GSize>=object
    public
      type
        TOffset=GOffset;
        TSize=GSize;
        TBufferRange=record
          public
            type
              TRangeState=(RSFree,RSAllocated);
            var
              Offset:TOffset;
              Size:TSize;
              State:TRangeState;
          public
            Constructor CreateFreeRange(const AOffset:TOffset;const ASize:TSize);
         end;
        PBufferRange=^TBufferRange;
        TRanges=TVector<TBufferRange>;
        TIndexInRanges=SizeInt;
        TFreeRangesIndexs=TVector<TIndexInRanges>;
      var
        Ranges:TRanges;
        FreeRangesIndexs:TFreeRangesIndexs;
      const
        CWrongIndexInRanges=-1;
    private
      function FindFreeRange(const ASize:TSize; out FreeRangesIndex:SizeUInt):TIndexInRanges;
    public
      constructor Init(ABufSize:TSize);
      function Allocate(ASize:TSize):TIndexInRanges;
      procedure Release(Index:TIndexInRanges);
      function CalcFragmentation:Double;
  end;
implementation
Constructor GBufferAllocator<GOffset,GSize>.TBufferRange.CreateFreeRange(const AOffset:TOffset;const ASize:TSize);
begin
  Offset:=AOffset;
  Size:=ASize;
  State:=RSFree;
end;

constructor GBufferAllocator<GOffset,GSize>.Init(ABufSize:TSize);
begin
  Ranges:=TRanges.Create;
  Ranges.Reserve(4*1024*1024);
  FreeRangesIndexs:=TFreeRangesIndexs.Create;

  FreeRangesIndexs.PushBack(Ranges.size);
  //FirstFreeRange:=Ranges.size;
  //FreeRangeCount:=1;
  Ranges.PushBack(TBufferRange.CreateFreeRange(0,ABufSize));
end;

function GBufferAllocator<GOffset,GSize>.FindFreeRange(const ASize:TSize; out FreeRangesIndex:SizeUInt):TIndexInRanges;
var
  fi:SizeUInt;
  i:TIndexInRanges;
  pbr:PBufferRange;
  tds,ds:SizeInt;
begin
  result:=CWrongIndexInRanges;
  ds:=high(ds);
  for fi:=0 to FreeRangesIndexs.size-1 do begin
    i:=FreeRangesIndexs[fi];
    pbr:=Ranges.Mutable[i];
    if pbr^.State=RSFree then begin
      tds:=pbr^.Size-ASize;
      if tds=0 then begin
        FreeRangesIndex:=fi;
        exit(i);
      end else if pbr^.Size>ASize then begin
        if (tds<ds)or(result=CWrongIndexInRanges) then begin
          ds:=tds;
          FreeRangesIndex:=fi;
          result:=i;
        end;
      end;
    end;
  end;
end;

function GBufferAllocator<GOffset,GSize>.CalcFragmentation:Double;
var
  fi:SizeUInt;
  pbr:PBufferRange;
  total,largest:TSize;
begin
  pbr:=Ranges.Mutable[FreeRangesIndexs[0]];
  total:=pbr^.Size;
  largest:=pbr^.Size;
  for fi:=1 to FreeRangesIndexs.size-1 do begin
    pbr:=Ranges.Mutable[FreeRangesIndexs[fi]];
    if largest<pbr^.Size then
      largest:=pbr^.Size;
    total:=total+pbr^.Size;
  end;
  result:=(Total-Largest)/total;
end;

function GBufferAllocator<GOffset,GSize>.Allocate(ASize:TSize):TIndexInRanges;
var
  SuitableRangeIndex:TIndexInRanges;
  FreeRangesIndex:SizeUInt;
  pbr:PBufferRange;
  nbr:TBufferRange;
begin
  SuitableRangeIndex:=FindFreeRange(ASize,FreeRangesIndex);
  if SuitableRangeIndex=CWrongIndexInRanges then
    raise Exception.Create('Cannot allocate');
  pbr:=Ranges.Mutable[SuitableRangeIndex];
  Result:=SuitableRangeIndex;
  if pbr^.Size<>ASize then begin
    nbr.CreateFreeRange(pbr^.Offset+Asize,pbr^.Size-Asize);
    pbr^.Size:=Asize;
    pbr^.State:=RSAllocated;
    {if FreeRangeCount=1 then
      FirstFreeRange:=Ranges.size;}
    FreeRangesIndexs.mutable[FreeRangesIndex]^:=Ranges.size;
    Ranges.PushBack(nbr);
  end else begin
    pbr^.State:=RSAllocated;
    //dec(FreeRangeCount);
    FreeRangesIndexs.mutable[FreeRangesIndex]^:=FreeRangesIndexs.back;
    FreeRangesIndexs.popback;
  end;
end;
procedure GBufferAllocator<GOffset,GSize>.Release(Index:TIndexInRanges);
var
  SuitableRangeIndex:TIndexInRanges;
  pbr:PBufferRange;
  nbr:TBufferRange;
begin
  pbr:=Ranges.Mutable[Index];
  pbr^.State:=RSFree;
  FreeRangesIndexs.PushBack(Index);
end;
begin
end.
