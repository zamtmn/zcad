{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file GPL-3.0.txt, included in this distribution,                 *
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

unit uzeFileStream;
{$Include zengineconfig.inc}
{$Mode objfpc}{$H+}
{$ModeSwitch advancedrecords}
{$PointerMath ON}
{$Interfaces CORBA}
{Inline off}
interface
uses
  SysUtils,
  uzctnrVectorBytes,
  Classes,BeRoFileMappedStream,FileUtil;

type
  TSetOfBytes=set of AnsiChar;
const
  CSpaces:TSetOfBytes=[' '];
  CSpacesAndCR:TSetOfBytes=[' ',#13];
  CLF:TSetOfBytes=[#10];
  CLFCR:TSetOfBytes=[#10,#13];
  CDecDigits:TSetOfBytes=['0','1','2','3','4','5','6','7','8','9'];
  ChLF=#10;
  ChCR=#13;
  CNotInThisPage=low(Int64);//возвращаем когда конец строки не найден на текущей странице
type
  TZFileStream=TZctnrVectorBytes;

  TMemViewInfo=record
    Memory:pointer;
    CurrentViewOffset:int64;
    CurrentViewSize:int64;
    Position:int64;
    Size:int64;
  end;
  TMoveMemViewProc=function (ANewPosition:int64):TMemViewInfo of object;

  IMemViewSource=interface
    function MoveMemViewProc(ANewPosition:int64):TMemViewInfo;
    function GetMemViewInfo:TMemViewInfo;
  end;

  {TFileStream}{TMemoryStream}{TBufferedFileStream}
  TZFileStream2=class(TBeRoFileMappedStream,IMemViewSource)

    function MoveMemViewProc(ANewPosition:int64):TMemViewInfo;
    function GetMemViewInfo:TMemViewInfo;
  end;
  TZInMemoryReader=class
    protected
      type
        TCurrentViewPos=(CVPNext  //не последняя страница
                        ,CVPLast);//последняя/единственная страница;
      var
        fMemory:pbyte;
        fCurrentViewOffset:int64;
        fCurrentViewSize:int64;
        fInMemPosition:int64;
        fSize:int64;
        fIS:IMemViewSource;
        FCurrentViewPos:TCurrentViewPos;
        FNeedScipEOL:boolean;
    public
      procedure setSource(AIS:IMemViewSource);
      procedure setFromTMemViewInfo(AMVI:TMemViewInfo);

      function fastReadByte:byte;inline;

      function EOF:Boolean;inline;
      procedure ResetLastChar;inline;
      function InternalParseInteger(const ASkipLeft:TSetOfBytes;out Value:Integer;const ASkipRight,AEnd:TSetOfBytes):boolean;inline;
      function InternalGetStr(const AEnd:TSetOfBytes):ShortString;inline;
      function ParseInteger(out Value:Integer):Integer;inline;
      function ParseString:String;

      function FindEOL:int64;
      procedure ScipEOL;
      procedure ScipEOLifNeed;


  end;

implementation

function TZFileStream2.GetMemViewInfo:TMemViewInfo;
begin
  result.Memory:=fMemory;
  result.CurrentViewOffset:=fCurrentViewOffset;
  result.CurrentViewSize:=fCurrentViewSize;
  result.Position:=fPosition;
  result.Size:=fSize;
end;
function TZFileStream2.MoveMemViewProc(ANewPosition:int64):TMemViewInfo;
begin
  Seek(ANewPosition,soBeginning);
  result:=GetMemViewInfo;
end;


procedure TZInMemoryReader.ResetLastChar;
begin
  if fInMemPosition>0 then
    dec(fInMemPosition);
end;


function TZInMemoryReader.InternalParseInteger(const ASkipLeft:TSetOfBytes;out Value:Integer;const ASkipRight,AEnd:TSetOfBytes):boolean;
var
  CurrentByte:Byte;
  DigitCounter:integer;
begin

  if ASkipRight<>[] then
    repeat
      CurrentByte:=fastReadByte;
      //Read(CurrentByte,1);
    until not (AnsiChar(CurrentByte) in ASkipRight)
  else
    CurrentByte:=fastReadByte;

  value:=0;
  DigitCounter:=0;
  if ASkipLeft<>[] then
    repeat
      CurrentByte:=fastReadByte;
      //Read(CurrentByte,1);
    until not (AnsiChar(CurrentByte) in ASkipLeft)
  else
    CurrentByte:=fastReadByte;

  while AnsiChar(CurrentByte) in CDecDigits do begin
    inc(DigitCounter);
    value:=value*10+CurrentByte-Ord('0');
    CurrentByte:=fastReadByte;
    //Read(CurrentByte,1);
  end;

  if DigitCounter=0 then begin
    ResetLastChar;
    exit(False);
  end;

  if ASkipRight<>[] then
  while AnsiChar(CurrentByte) in ASkipRight do begin
    CurrentByte:=fastReadByte;
    //Read(CurrentByte,1);
  end;

  if AEnd<>[] then
  if not(AnsiChar(CurrentByte) in AEnd)then begin
    ResetLastChar;
    exit(False);
  end;

  Result:=true;
end;


function TZInMemoryReader.fastReadByte:byte;
begin
  result:=fMemory[fInMemPosition];
  if (fInMemPosition<fCurrentViewSize-1)or(fInMemPosition+fCurrentViewOffset=fSize-1) then
    inc(fInMemPosition)
  else
    {Seek(1,soCurrent)};
end;


function TZInMemoryReader.ParseInteger(out Value:Integer):Integer;
begin
  InternalParseInteger(CSpaces,Value,CSpacesAndCR,CLF);
end;


function TZInMemoryReader.EOF:Boolean;
begin
  ScipEOLifNeed;
  if FCurrentViewPos<>CVPLast then
    result:=false
  else
    result:=(fCurrentViewOffset+fInMemPosition)>=fSize;
end;

procedure TZInMemoryReader.setFromTMemViewInfo(AMVI:TMemViewInfo);
begin
  with AMVI do begin
    fMemory:=Memory;
    fCurrentViewOffset:=CurrentViewOffset;
    fCurrentViewSize:=CurrentViewSize;
    fInMemPosition:=Position-CurrentViewOffset;
    fSize:=Size;

    {if CurrentViewOffset=0 then
      FCurrentViewPos:=CVPFirst
    else }if fCurrentViewOffset+fCurrentViewSize>=fSize then
      FCurrentViewPos:=CVPLast
    else
      FCurrentViewPos:=CVPNext;
  end;
end;

procedure TZInMemoryReader.setSource(AIS:IMemViewSource);
begin
  fIS:=AIS;
  FNeedScipEOL:=false;
  setFromTMemViewInfo(fIS.GetMemViewInfo);
end;

function TZInMemoryReader.InternalGetStr(const AEnd:TSetOfBytes):ShortString;
var
  CurrentByte:Byte;
  DigitCounter:integer;
begin
  DigitCounter:=0;
  CurrentByte:=fastReadByte;
  while  not(AnsiChar(CurrentByte) in AEnd)do begin
    inc(DigitCounter);
    result[DigitCounter]:=char(CurrentByte);
    CurrentByte:=fastReadByte;
  end;
  setlength(result,DigitCounter);
end;

procedure TZInMemoryReader.ScipEOLifNeed;
begin
  if FNeedScipEOL then begin
    ScipEOL;
    FNeedScipEOL:=false;
  end;
end;
procedure TZInMemoryReader.ScipEOL;
var
  CurrentByte:Byte;
begin
  CurrentByte:=fastReadByte;
  if CurrentByte=byte(ChCR)then begin
    CurrentByte:=fastReadByte;
    if CurrentByte=byte(ChLF)then
      //CurrentByte:=fastReadByte
    else
      ResetLastChar;
  end;
end;

function TZInMemoryReader.FindEOL:int64;
var
  InMemPos:int64;
begin
  ScipEOLifNeed;

  InMemPos:=fInMemPosition;

  while InMemPos<fCurrentViewSize do begin
    if AnsiChar(fMemory[InMemPos]) in CLFCR then begin
      FNeedScipEOL:=True;
      exit(InMemPos)
    end;
    inc(InMemPos);
  end;
  if InMemPos=fSize then
    exit(InMemPos);
  //if fCurrentViewSize+fCurrentViewOffset=InMemPos then
    result:=CNotInThisPage;
end;


function TZInMemoryReader.ParseString:String;
var
  PEOL:int64;
  l:int64;
  ts:string;
begin
  PEOL:=FindEOL;
  if PEOL=fInMemPosition then
    exit('')
  else if PEOL=CNotInThisPage then begin
    l:=fCurrentViewSize-fInMemPosition;
    SetLength(Result,l);
    Move(fMemory[fInMemPosition],Result[1],l);
    setFromTMemViewInfo(fIS.MoveMemViewProc(fCurrentViewOffset+fCurrentViewSize));
    ts:=ParseString();
    result:=result+ts;
  end else begin
    l:=PEOL-fInMemPosition;
    SetLength(Result,l);
    Move(fMemory[fInMemPosition],Result[1],l);
    fInMemPosition:=PEOL;
  end;
end;

begin
end.
