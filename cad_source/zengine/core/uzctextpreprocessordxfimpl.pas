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
implementation
function EscapeSeq(const str:TDXFEntsInternalStringType;const operands:TDXFEntsInternalStringType;var NextSymbolPos:integer;pobj:Pointer):String;
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
      'f','H','A':begin
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
function BracesArea(const str:TDXFEntsInternalStringType;const operands:TDXFEntsInternalStringType;var NextSymbolPos:integer;pobj:Pointer):String;
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

function date2value(const str:TDXFEntsInternalStringType;const operands:TDXFEntsInternalStringType;var NextSymbolPos:integer;pobj:Pointer):String;
begin
  result:=datetostr(date);
end;

initialization
  Prefix2ProcessFunc.RegisterProcessor('\',#0,#0,@EscapeSeq);
  Prefix2ProcessFunc.RegisterProcessor('{',#0,#0,@BracesArea);
  Prefix2ProcessFunc.RegisterProcessor('%%DATE',#0,#0,@date2value,true);
end.
