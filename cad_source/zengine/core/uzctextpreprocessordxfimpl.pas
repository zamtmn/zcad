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
              end
    else
      result:=sym;
    end;
    inc(NextSymbolPos);
  end;
end;

function date2value(const str:TDXFEntsInternalStringType;const operands:TDXFEntsInternalStringType;var NextSymbolPos:integer;pobj:Pointer):String;
begin
  result:=datetostr(date);
end;

initialization
  Prefix2ProcessFunc.RegisterProcessor('\',#0,#0,@EscapeSeq);
  Prefix2ProcessFunc.RegisterProcessor('%%DATE',#0,#0,@date2value,true);
end.
