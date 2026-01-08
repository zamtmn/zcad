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
  uzetextpreprocessor,
  uzeTypes,
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
  ch,lcch:TDXFEntsInternalCharType;
  value:TDXFEntsInternalStringType;
  num,code:integer;
begin
  //описание происходящего
  //https://adndevblog.typepad.com/autocad/2017/09/dissecting-mtext-format-codes.html
  result:='';
  if NextSymbolPos>0 then
  if NextSymbolPos<=length(str) then
  begin
    ch:=str[NextSymbolPos];
    lcch:=TDXFEntsInternalCharType(ord(ch) or 32);//lowercase
    case lcch of
      'l':result:=Chr(1); //подчеркивание
      'p':result:=Chr(10);//перевод строки
      'u':begin           //символ юникода
        value:='$'+copy(str,NextSymbolPos+2,4);
        val(value,num,code);
        result:=UnicodeToUtf8(num);
        NextSymbolPos:=NextSymbolPos+5;
      end;
      'o':result:='';//надчеркивание
      'c',//цвет
      'q',//наклон
      'f',//имя фонта
      'h',//высота
      'a',//выравнивание
      't',//Межсимвольное расстояние
      'w':begin//ширина текста
        while (NextSymbolPos<=length(str))and(str[NextSymbolPos]<>';') do
          inc(NextSymbolPos);
        result:='';
      end
    else
      result:=ch;//экранирование
    end;
    inc(NextSymbolPos);
  end;
end;
function BracesArea(const str:TDXFEntsInternalStringType;const operands:TDXFEntsInternalStringType;var NextSymbolPos:integer;var SPA:TStrProcessAttributes;pobj:Pointer):String;
var
  CloseBracetPos:integer;
  code,l:integer;
begin
  code:=1;
  CloseBracetPos:=NextSymbolPos;
  while (CloseBracetPos<=length(str))and(code<>0) do begin
    if str[CloseBracetPos]='{'then
      inc(code)
    else if str[CloseBracetPos]='}'then
      dec(code);
    inc(CloseBracetPos);
  end;
  if code=0 then begin
    l:=CloseBracetPos-NextSymbolPos-1;
    result:=copy(str,NextSymbolPos,l);
    if l>0 then
      include(spa,SPARecursive);
    NextSymbolPos:=CloseBracetPos;
  end;
end;

initialization
  _SPFSdxf:=SPFSources.GetEnum;
  Prefix2ProcessFunc.RegisterProcessor('\',#0,#0,@EscapeSeq,_SPFSdxf);
  Prefix2ProcessFunc.RegisterProcessor('{',#0,#0,@BracesArea,_SPFSdxf);
end.
