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
unit gzcDiapazon;
{$Codepage UTF8}
{$Mode delphi}
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  gzctnrSTL;

type
  GDiapazon<GIndexType>=class
  public
  type
    TIndex=GIndexType;
    TIndexs=record
      Start,&End:GIndexType;
      constructor CreateRec(const AStart,AEnd:GIndexType);
    end;
    TVec=TMyVector<TIndexs>;
  private
    fDiapozon:TVec;
    function FindNearest(index:GIndexType):SizeUInt;
    function Compare(const index:GIndexType;var Indexs:TIndexs):integer;
    procedure TryCombine;
  public
    constructor Create;
    destructor Destroy;override;
    procedure AddIndex(index:GIndexType);
    property Diap:TVec read fDiapozon;
  end;

implementation
{type
  TTestDiapazon=GDiapazon<integer>;
var
  TestDiapazon:TTestDiapazon;
  i:integer;}

constructor GDiapazon<GIndexType>.TIndexs.CreateRec(const AStart,AEnd:TIndex);
begin
  Start:=AStart;
  &End:=AEnd;
end;

constructor GDiapazon<GIndexType>.Create;
begin
  fDiapozon:=TVec.create;
end;

destructor GDiapazon<GIndexType>.Destroy;
begin
  fDiapozon.Destroy;
end;

function GDiapazon<GIndexType>.Compare(const index:GIndexType;var Indexs:TIndexs):integer;
begin
  if index<Indexs.Start then
    exit(index-Indexs.Start)
  else if index>Indexs.&End then
    exit(index-Indexs.&End)
  else
    result:=0;
end;

procedure GDiapazon<GIndexType>.TryCombine;
var
  pcurrent,pnext:TVec.PT;
  processedsize,movedcount:integer;
begin
  processedsize:=1;
  movedcount:=0;
  if fDiapozon.Size>1 then begin
    pcurrent:=fDiapozon.Mutable[0];
    pnext:=fDiapozon.Mutable[1];
    repeat
      while (pnext^.Start-pcurrent^.&End=1)and(processedsize<fDiapozon.Size) do begin
        pcurrent^.&End:=pnext^.&End;
        inc(movedcount);
        inc(pnext);
        inc(processedsize);
      end;
      inc(pcurrent);
      if movedcount>0 then begin
        if processedsize<fDiapozon.Size then begin
          pcurrent^:=pnext^;
        end;
      end;// else
        inc(processedsize);
      inc(pnext);
    until processedsize>=fDiapozon.Size;
    if movedcount>0 then
      fDiapozon.Resize(fDiapozon.Size-movedcount);
  end;
end;

procedure GDiapazon<GIndexType>.AddIndex(index:GIndexType);
var
  nearest:SizeUInt;
  distance:integer;
  pd:TVec.PT;
begin
  if fDiapozon.Size=0 then
    fDiapozon.PushBack(TIndexs.CreateRec(index,index))
  else begin
    nearest:=FindNearest(index);
    pd:=fDiapozon.Mutable[nearest];
    distance:=Compare(index,pd^);
    case distance of
      1:begin
          pd.&End:=index;
          TryCombine;
      end;
      0:;
      -1:begin
          pd.Start:=index;
          TryCombine;
      end;
      else
      begin
        if distance<0 then
          fDiapozon.Insert(nearest,TIndexs.CreateRec(index,index))
        else
          fDiapozon.Insert(nearest+1,TIndexs.CreateRec(index,index));
      end;
    end;
  end;
end;
function GDiapazon<GIndexType>.FindNearest(index:GIndexType):SizeUInt;
var
  First,Last,Temp:integer;
  iprev,inext:integer;
  function CompareDiap(var Indexs:TIndexs):integer;
  begin
    if iprev<Indexs.Start then
      exit(-1)
    else if inext>Indexs.&End then
      exit(1)
    else
      result:=0;
  end;
begin
  iprev:=pred(index);
  inext:=Succ(index);
  Result:=0;
  First:=0;
  Last:=fDiapozon.Size-1;
  while First<=Last do begin
    Temp:=(First+Last) div 2;
    case CompareDiap(fDiapozon.Mutable[Temp]^) of
      1:First:=Temp+1;
      0:exit(Temp);
     -1:Last:=Temp-1;
    end;
  end;
  result:=temp;
end;

initialization
  {TestDiapazon:=TTestDiapazon.create;
  for i:=50 to 100 do
    TestDiapazon.AddIndex(i*2+1);
  TestDiapazon.AddIndex(10);
  for i:=50 to 100 do
    TestDiapazon.AddIndex(i*2);
  TestDiapazon.AddIndex(10);
  TestDiapazon.AddIndex(8);
  TestDiapazon.AddIndex(12);
  TestDiapazon.AddIndex(11);
  TestDiapazon.AddIndex(9);
  TestDiapazon.AddIndex(7);
  TestDiapazon.AddIndex(1);
  TestDiapazon.AddIndex(3);
  TestDiapazon.AddIndex(5);
  TestDiapazon.AddIndex(2);
  TestDiapazon.AddIndex(6);
  TestDiapazon.AddIndex(4);}

finalization
end.
