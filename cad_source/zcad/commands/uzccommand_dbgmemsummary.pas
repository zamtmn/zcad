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
{$mode delphi}
unit uzccommand_dbgmemsummary;

{$INCLUDE zengineconfig.inc}

interface
uses
  {$IFDEF REPORTMMEMORYLEAKS}heaptrc,{$ENDIF}
  SysUtils,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcinfoform,
  uzcinterface
  {$IFDEF REPORTMMEMORYLEAKS}
  ,gmap,gvector,garrayutils, gzctnrSTL,math,Generics.Collections
  {$ENDIF}
  ;

implementation
{$IFDEF REPORTMMEMORYLEAKS}
type
  TCodePointerArrayCompare=class
    class function c(a,b:tcodepointerarray):boolean;
  end;

  TtmemallocinfoCompare=class
    class function c(a,b:tmemallocinfo):boolean;
  end;

  TBTDic=TDictionary<codepointer,string>;

  TMyMap<TKey,TValue,TCompare>=class(TMap<TKey, TValue, TCompare>)
    function TryGetMutableValue(key:TKey; out PValue:PTValue):boolean;
  end;

  TStackCounter=TMyMap<tcodepointerarray,Integer,TCodePointerArrayCompare>;

  TSizeSorter=TVector<tmemallocinfo>;

  TSizeSorterUtils=TOrderingArrayUtils<TSizeSorter,tmemallocinfo,TtmemallocinfoCompare>;

function TMyMap<TKey,TValue,TCompare>.TryGetMutableValue(key:TKey; out PValue:PTValue):boolean;
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
end;


class function TCodePointerArrayCompare.c(a,b:tcodepointerarray):boolean;
var
  i:Integer;
begin
  for i:=1 to tracesize do
    if a[i]<b[i] then
      exit(true)
    else if a[i]>b[i] then
      exit (false);

  exit (false);
end;

class function TtmemallocinfoCompare.c(a,b:tmemallocinfo):boolean;
begin
  result:=a.size>b.size;
end;
{$ENDIF}

function dbgMemSummary_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
{$IFDEF REPORTMMEMORYLEAKS}
const
  DefaultArrSize=1000000;
{$ENDIF}
var
  InfoForm:TInfoForm;
{$IFDEF REPORTMMEMORYLEAKS}
  MemAllocInfoArray:tmemallocinfoarray;
  Size,i,j,UniqueCount:Integer;
  StackCounter:TStackCounter;
  PValue:TStackCounter.PTValue;
  Iter:TStackCounter.TIterator;
  SizeSorter:TSizeSorter;
  pmemallocinfo:^tmemallocinfo;
  s:string;
  BTDic:TBTDic;
{$ENDIF}
begin
  InfoForm:=TInfoForm.create(nil);
  InfoForm.DialogPanel.HelpButton.Hide;
  InfoForm.DialogPanel.CancelButton.Hide;
  InfoForm.DialogPanel.CloseButton.Hide;
  InfoForm.caption:=('Memory is used to:');

{$IFDEF REPORTMMEMORYLEAKS}
  if not TryStrToInt(operands,Size) then
    Size:=DefaultArrSize;
  if Size<=0 then
    Size:=DefaultArrSize;
  SetLength(MemAllocInfoArray,Size);
  Size:=MyDumpHeap(MemAllocInfoArray);

  StackCounter:=TStackCounter.Create;
  SizeSorter:=TSizeSorter.Create;
  BTDic:=TBTDic.Create;
  UniqueCount:=0;
  for i:=low(MemAllocInfoArray) to abs(Size) do
    if StackCounter.TryGetMutableValue(MemAllocInfoArray[i].stack,PValue) then
      PValue^:=PValue^+MemAllocInfoArray[i].size
    else begin
      StackCounter.Insert(MemAllocInfoArray[i].stack,MemAllocInfoArray[i].size);
      inc(UniqueCount);
    end;

  SizeSorter.Resize(UniqueCount);
  Iter:=StackCounter.Min;
  for i:=0 to UniqueCount-1 do begin
    //pmemallocinfo:=izeSorter.Mutable(i);
    with SizeSorter.Mutable[i]^ do begin
      size:=Iter.Value;
      stack:=Iter.Key;
    end;
    Iter.Next;
  end;
  if Assigned(Iter) then
    iter.Free;

  InfoForm.Memo.lines.Add(format('Total allocations %d',[Size]));
  InfoForm.Memo.lines.Add(format('Unique allocations %d',[UniqueCount]));

  TSizeSorterUtils.Sort(SizeSorter,SizeSorter.Size-1);
  for i:=0 to SizeSorter.Size{ min(SizeSorter.Size-1,10)} do begin
    InfoForm.Memo.lines.Add(format('Allocation %d, %d bytes total, %d count',[i,SizeSorter[i].Size,-1]));
    for j:=low(tcodepointerarray) to high(tcodepointerarray) do begin
      if not BTDic.TryGetValue(SizeSorter[i].stack[j],s) then begin
        try
          s:=BackTraceStrFunc(SizeSorter[i].stack[j]);
        except
          s:=SysBackTraceStr(SizeSorter[i].stack[j]);
        end;
        BTDic.Add(SizeSorter[i].stack[j],s)
      end;
      InfoForm.Memo.lines.Add(format('%5d, %s',[j,s]));
    end;
  end;

  BTDic.Free;
  SizeSorter.Free;
  StackCounter.Free;
{$ELSE}
  InfoForm.Memo.lines.Add('You need use {$DEFINE REPORTMMEMORYLEAKS} when compiling ZCAD');
{$ENDIF}

  ZCMsgCallBackInterface.DOShowModal(InfoForm);
  InfoForm.Free;
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@dbgMemSummary_com,'dbgMemSummary',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
