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
unit uzcTextPreprocessorDXFImpl;
{$INCLUDE zengineconfig.inc}
{$mode objfpc}{$H+}

interface
uses
  sysutils,
  uzetextpreprocessor,uzbstrproc,
  uzbtypes,
  LazUTF8;
function SPFSdxf:TSPFSourceEnum;
implementation
var
  _SPFSdxf:TSPFSourceEnum;
function SPFSdxf:TSPFSourceEnum;
begin
  Result:=_SPFSdxf;
end;

function EscapeSeq(const str:TDXFEntsInternalStringType;const operands:TDXFEntsInternalStringType;var NextSymbolPos:integer;var SPA:TStrProcessAttributes;pobj:Pointer):String;
var
  sym:char;
  value:TDXFEntsInternalStringType;
  num,code:integer;
begin
  result:='';
  if NextSymbolPos>0 then
  if NextSymbolPos<=length(str) then
  begin
    sym:=str[NextSymbolPos];
    case sym of
      'L','l':result:=Chr(1);
      'P','p':result:=Chr(10);
      'U','u':begin
                value:='$'+copy(str,NextSymbolPos+2,4);
                val(value,num,code);
                result:=UnicodeToUtf8(num);
                NextSymbolPos:=NextSymbolPos+5;
              end;
      'C','c','Q','q','F','f','H','h','A','a','W','w':begin
        while (NextSymbolPos<=length(str))and(str[NextSymbolPos]<>';') do
           inc(NextSymbolPos);
           result:='';
        end
    else
      result:=sym;
    end;
    inc(NextSymbolPos);
  end;
end;
function BracesArea(const str:TDXFEntsInternalStringType;const operands:TDXFEntsInternalStringType;var NextSymbolPos:integer;var SPA:TStrProcessAttributes;pobj:Pointer):String;
var
  CloseBracetPos:integer;
  code:integer;
begin
  code:=1;
  CloseBracetPos:=NextSymbolPos;
    while (CloseBracetPos<=length(str))and(code<>0) do begin
       inc(CloseBracetPos);
       if str[CloseBracetPos]='{'then
         inc(code)
       else if str[CloseBracetPos]='}'then
         dec(code);
    end;
    if code=0 then begin
      result:=copy(str,NextSymbolPos,CloseBracetPos-NextSymbolPos);
      NextSymbolPos:=CloseBracetPos+1;
    end;
end;

initialization
  _SPFSdxf:=SPFSources.GetEnum;
  Prefix2ProcessFunc.RegisterProcessor('\',#0,#0,@EscapeSeq,_SPFSdxf);
  Prefix2ProcessFunc.RegisterProcessor('{',#0,#0,@BracesArea,_SPFSdxf);
end.
