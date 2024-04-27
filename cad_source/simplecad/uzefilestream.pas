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
interface
uses
  SysUtils,
  uzctnrVectorBytes,
  Classes,bufstream,BeRoFileMappedStream,FileUtil,math;

type
  TSetOfBytes=set of AnsiChar;
const
  CSpaces:TSetOfBytes=[' '];
  CSpacesAndCR:TSetOfBytes=[' ',#13];
  CCR:TSetOfBytes=[#10];
  CDecDigits:TSetOfBytes=['0','1','2','3','4','5','6','7','8','9'];

type
  TZFileStream=TZctnrVectorBytes;

  TZFileStream2=class({TFileStream}{TMemoryStream}{TBufferedFileStream}TBeRoFileMappedStream{TMappedStream})
    function fastReadByte:byte;inline;
    function notEOF:Boolean;inline;
    procedure ResetLastChar;inline;
    function InternalParseInteger(const ASkipLeft:TSetOfBytes;out Value:Integer;const ASkipRight,AEnd:TSetOfBytes):boolean;inline;
    function InternalGetStr(const AEnd:TSetOfBytes):ShortString;inline;
    function ParseInteger(out Value:Integer):Integer;inline;
    function ParseString:ShortString;inline;
  end;

implementation

function TZFileStream2.fastReadByte:byte;
begin
  result:=pbyte(Memory)[fPosition-MemoryViewOffset];
  if (fPosition-MemoryViewOffset<MemoryViewSize-1)or(fPosition=fSize-1) then
    inc(fPosition)
  else
    Seek(1,soCurrent);
end;

procedure TZFileStream2.ResetLastChar;
begin
  if Position>0 then
    Seek(Position-1,soBeginning);
end;

function TZFileStream2.notEOF:Boolean;
begin
  result:=fPosition<fSize;
end;
function TZFileStream2.InternalGetStr(const AEnd:TSetOfBytes):ShortString;
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

function TZFileStream2.InternalParseInteger(const ASkipLeft:TSetOfBytes;out Value:Integer;const ASkipRight,AEnd:TSetOfBytes):boolean;
var
  CurrentByte:Byte;
  DigitCounter:integer;
begin

  CurrentByte:=fastReadByte;
  //Read(CurrentByte,1);
  while  not(AnsiChar(CurrentByte) in AEnd)do begin
    CurrentByte:=fastReadByte;
    //Read(CurrentByte,1);
  end;
  exit;

  value:=0;
  DigitCounter:=0;
  if ASkipLeft<>[] then
    repeat
      CurrentByte:=fastReadByte;
      //Read(CurrentByte,1);
    until not (AnsiChar(CurrentByte) in ASkipLeft)
  else
    CurrentByte:=ReadByte;

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

function TZFileStream2.ParseString:ShortString;
begin
  //result:=InternalGetStr(CCR);
  fastReadByte;
end;

function TZFileStream2.ParseInteger(out Value:Integer):Integer;
begin
  //InternalParseInteger(CSpaces,Value,CSpacesAndCR,CCR);
  fastReadByte;
end;

{function TZFileStream2.GetChar(rp:Int64): Ansichar;
var
  oldpos:Int64;
begin
  oldpos:=Seek(rp,soBeginning);
  result:=Ansichar(ReadByte);
  Seek(oldpos,soBeginning);
end;}
begin
end.
