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

unit uzeBaseUtils;
{$INCLUDE zengineconfig.inc}
{$Mode delphi}

interface

uses
  SysUtils,StrUtils,
  uzbHandles,uzegeometrytypes,uzeTypes;

function ConvertFromDxfString(const str:TDXFEntsInternalStringType):String;
function ConvertToDxfString(const str:String):TDXFEntsInternalStringType;

implementation

function ConvertFromDxfString(const str:TDXFEntsInternalStringType):String;
begin
  result:=UTF8Encode(StringsReplace(str, ['\P'],[LineEnding],[rfReplaceAll,rfIgnoreCase]));
end;

function ConvertToDxfString(const str:String):TDXFEntsInternalStringType;
begin
  result:=UTF8ToString(StringsReplace(str, [LineEnding],['\P'],[rfReplaceAll,rfIgnoreCase]));
end;


initialization
finalization
end.
