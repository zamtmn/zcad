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
  Classes,BeRoFileMappedStream,FileUtil,bufstream;

type
  TSetOfBytes=set of AnsiChar;
  TInMemString=int64;

const
  CSpaces:TSetOfBytes=[' '];
  CSpacesAndCR:TSetOfBytes=[' ',#13];
  CLF:TSetOfBytes=[#10];
  CLFCR:TSetOfBytes=[#10,#13];
  CDecDigits:TSetOfBytes=['0','1','2','3','4','5','6','7','8','9'];
  ChLF=#10;
  ChCR=#13;
  CNotInThisPage=low({Int64}TInMemString);//возвращаем когда конец строки не найден на текущей странице
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

  TZReadBufStream=class(TReadBufStream,IMemViewSource)

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
        fCurrentViewOffset:{Int64}TInMemString;
        fCurrentViewSize:{Int64}TInMemString;
        fInMemPosition:{Int64}TInMemString;
        fSize:{Int64}TInMemString;
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
      function ParseString:String;overload;inline;
      function ParseString(out s:String):boolean;overload;

      function FindEOL:int64;inline;
      procedure ScipEOL;inline;
      procedure ScipEOLifNeed;inline;


  end;

var
  FindEOLcount:Int64=0;
  ScipEOLcount:Int64=0;
  ParseStringcount:Int64=0;
  EOFcount:Int64=0;
  fastReadBytecount:Int64=0;
  fastReadByteAndMoweWindowcount:Int64=0;

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

function TZReadBufStream.GetMemViewInfo:TMemViewInfo;
begin
  result.Memory:=buffer;
  result.Position:=GetPosition;
  result.Size:=GetSize;
  result.CurrentViewSize:=Capacity;//BufferSize;
  result.CurrentViewOffset:=(result.Position-1) div result.CurrentViewSize{BufferPos};
end;
function TZReadBufStream.MoveMemViewProc(ANewPosition:int64):TMemViewInfo;
begin
  Seek(ANewPosition,soBeginning);
  result:=GetMemViewInfo;
  FillBuffer;
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
  inc(fastReadBytecount);
  result:=fMemory[fInMemPosition];
  if (fInMemPosition<(fCurrentViewSize-1))or((fInMemPosition+fCurrentViewOffset)=(fSize-1)) then
    inc(fInMemPosition)
  else begin
    setFromTMemViewInfo(fIS.MoveMemViewProc(fCurrentViewOffset+fCurrentViewSize));
    inc(fastReadByteAndMoweWindowcount);
  end;
end;


function TZInMemoryReader.ParseInteger(out Value:Integer):Integer;
begin
  InternalParseInteger(CSpaces,Value,CSpacesAndCR,CLF);
end;


function TZInMemoryReader.EOF:Boolean;
begin
  inc(EOFcount);
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
  CurrentWord:Word;
begin
  inc(ScipEOLcount);

  if fCurrentViewSize-fInMemPosition<2 then begin
    CurrentByte:=fastReadByte;
    if CurrentByte=byte(ChCR)then begin
      CurrentByte:=fastReadByte;
      if CurrentByte<>byte(ChLF)then
        ResetLastChar;
    end;
  end else begin
    CurrentWord:=PWord(@fMemory[fInMemPosition])^;
  {$ifdef FPC_LITTLE_ENDIAN}
    if CurrentWord=$0A0D then
      inc(fInMemPosition,2)
    else
      inc(fInMemPosition);
  {$else}
    if CurrentWord=$0D0A then
      inc(fInMemPosition,2)
    else
      inc(fInMemPosition);
  {$endif}

    {CurrentByte:=fMemory[fInMemPosition];
    inc(fInMemPosition);
    if CurrentByte=byte(ChCR)then begin
      CurrentByte:=fMemory[fInMemPosition];
      inc(fInMemPosition);
      if CurrentByte<>byte(ChLF)then
        dec(fInMemPosition);
    end;}

  end;
end;


function TZInMemoryReader.FindEOL:int64;
const
  CR_XOR_MASK4=$0d0d0d0d;
  LF_XOR_MASK4=$0a0a0a0a;
  SUB_MASK4=Integer(-$01010101);
  OVERFLOW_MASK4=Integer($80808080);

  CR_XOR_MASK8=$0d0d0d0d0d0d0d0d;
  LF_XOR_MASK8=$0a0a0a0a0a0a0a0a;
  SUB_MASK8=Int64(-$0101010101010101);
  OVERFLOW_MASK8=Int64($8080808080808080);
var
  InMemPos:int64;
  pch:pchar;
  i,n,optin,nn:NativeInt;
  X4,T4,V4:Integer;
  X8,T8,V8:NativeInt;
begin
  inc(FindEOLcount);

  ScipEOLifNeed;

  InMemPos:=fInMemPosition;
  pch:=@fMemory[InMemPos];
  n:=fCurrentViewSize-InMemPos;

  //проверяем по 8 байт
  optin:=n div sizeof(qword);
  if optin>0 then begin
    for i:=optin-1 downto 0 do begin
      X8:=pqword(pch)^;
      T8 := (X8 xor CR_XOR_MASK8);
      X8 := (X8 xor LF_XOR_MASK8);
      V8 := T8 + SUB_MASK8;
      T8 := not T8;
      T8 := T8 and V8;
      V8 := X8 + SUB_MASK8;
      X8 := (not X8);
      V8 := V8 and X8;
      T8 := T8 or V8;
      if (T8 and OVERFLOW_MASK8<>0) then begin
        nn := Byte(Byte(T8 and $80 = 0) + Byte(T8 and $8080 = 0) + Byte(T8 and $808080 = 0) + Byte(T8 and $80808080 = 0) + Byte(T8 and $8080808080 = 0) + Byte(T8 and $808080808080 = 0) + Byte(T8 and $80808080808080 = 0));
        FNeedScipEOL:=True;
        inc(InMemPos,(optin-i)*sizeof(qword)-(8-nn));
        exit(InMemPos);

        T4:=lo(T8) and OVERFLOW_MASK4;
        if ((T4 and OVERFLOW_MASK4)<>0) then begin
          nn := Byte(Byte(T4 and $80 = 0) + Byte(T4 and $8080 = 0) + Byte(T4 and $808080 = 0));
          FNeedScipEOL:=True;
          inc(InMemPos,(optin-i)*sizeof(qword)-(4-nn));
          exit(InMemPos);
        end;

        T4:=hi(T8) and OVERFLOW_MASK4;
        if (T4 and OVERFLOW_MASK4)<>0 then begin
          nn := Byte(Byte(T4 and $80 = 0) + Byte(T4 and $8080 = 0) + Byte(T4 and $808080 = 0));
          FNeedScipEOL:=True;
          inc(InMemPos,(optin-i)*sizeof(qword)-(4-nn));
          exit(InMemPos);
        end;
      end;
      inc(pqword(pch));
    end;
    inc(InMemPos,optin*sizeof(qword));
    n:=n mod sizeof(qword);
  end;

  //проверяем по 4 байта
  optin:=n div sizeof(dword);
  if optin>0 then begin
    for i:=optin-1 downto 0 do begin
      x4:=pdword(pch)^;
      T4 := (X4 xor CR_XOR_MASK4);
      X4 := (X4 xor LF_XOR_MASK4);
      V4 := T4 + SUB_MASK4;
      T4 := not T4;
      T4 := T4 and V4;
      V4 := X4 + SUB_MASK4;
      X4 := (not X4);
      V4 := V4 and X4;
      T4 := T4 or V4;
      T4 := (T4 and OVERFLOW_MASK4);
      if (T4 and OVERFLOW_MASK4)<>0 then begin
        nn := Byte(Byte(T4 and $80 = 0) + Byte(T4 and $8080 = 0) + Byte(T4 and $808080 = 0));
        FNeedScipEOL:=True;
        inc(InMemPos,(optin-i)*sizeof(dword)-(4-nn));
        exit(InMemPos);
      end;
      inc(pdword(pch));
    end;
    inc(InMemPos,optin*sizeof(dword));
    n:=n mod sizeof(dword);
  end;

  //проверяем по 2 байта
  optin:=n div sizeof(word);
  if optin>0 then begin
    for i:=optin-1 downto 0 do begin
      x4:=pword(pch)^;
      T4 := (X4 xor CR_XOR_MASK4);
      X4 := (X4 xor LF_XOR_MASK4);
      V4 := T4 + SUB_MASK4;
      T4 := not T4;
      T4 := T4 and V4;
      V4 := X4 + SUB_MASK4;
      X4 := (not X4);
      V4 := V4 and X4;
      T4 := T4 or V4;
      T4 := (T4 and OVERFLOW_MASK4);

      if T4<>0 then begin
        nn := Byte(Byte(T8 and $80 = 0));
        FNeedScipEOL:=True;
        inc(InMemPos,(optin-i)*sizeof(qword)-(8-nn));
        exit(InMemPos);
      end;
      inc(pword(pch));
    end;
    inc(InMemPos,optin*sizeof(word));
    n:=n mod sizeof(word);
  end;

  //остатки проверяем по байту
  for i:=n-1 downto 0 do begin
    if byte(pch^)<14 then
      if (pch^=ChLF)or(pch^=ChCR) then begin  //pch^ in CLFCR медленней в 2 раза
        FNeedScipEOL:=True;
        inc(InMemPos,n-i-1);
        exit(InMemPos);
      end;
    inc(pch);
  end;
  inc(InMemPos,n);


  if InMemPos=fSize then
    result:=InMemPos
  else
    result:=CNotInThisPage;
end;


function TZInMemoryReader.ParseString:String;
var
  PEOL:int64;
  l:int64;
  ts:string;
begin
  inc(ParseStringcount);
  PEOL:=FindEOL;
  if PEOL=fInMemPosition then
    exit('')
  else if PEOL=CNotInThisPage then begin
    {//}l:=fCurrentViewSize-fInMemPosition;
    {//}SetLength(Result,l);
    {//}Move(fMemory[fInMemPosition],Result[1],l);
    setFromTMemViewInfo(fIS.MoveMemViewProc(fCurrentViewOffset+fCurrentViewSize));
    ts:=ParseString();
    {//}result:=result+ts;
  end else begin
    {//}l:=PEOL-fInMemPosition;
    {//}SetLength(Result,l);
    {//}Move(fMemory[fInMemPosition],Result[1],l);
    fInMemPosition:=PEOL;
  end;
end;
function TZInMemoryReader.ParseString(out s:String):boolean;
var
  PEOL:int64;
  l:int64;
  ts:string;
begin
  if fCurrentViewOffset+fInMemPosition=fSize then
    exit(false);
  PEOL:=FindEOL;
  if PEOL=fInMemPosition then begin
    s:='';
    if fCurrentViewOffset+fInMemPosition=fSize then
      exit(false)
    else
      exit(true);
  end
  else if PEOL=CNotInThisPage then begin
    l:=fCurrentViewSize-fInMemPosition;
    result:=l<>0;
    SetLength(s,l);
    Move(fMemory[fInMemPosition],s[1],l);
    if fCurrentViewOffset+fInMemPosition=fSize then
      exit(true);
    setFromTMemViewInfo(fIS.MoveMemViewProc(fCurrentViewOffset+fCurrentViewSize));
    result:=result or ParseString(ts);
    s:=s+ts;
  end else begin
    l:=PEOL-fInMemPosition;
    SetLength(s,l);
    Move(fMemory[fInMemPosition],s[1],l);
    fInMemPosition:=PEOL;
    result:=true;
  end;
end;
begin
end.
