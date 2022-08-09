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

unit uzbLogTypes;
{$mode objfpc}{$H+}
{$modeswitch TypeHelpers}{$modeswitch advancedrecords}
interface

uses
  gvector,strutils,sysutils{$IFNDEF DELPHI},LazUTF8{$ENDIF},
  Generics.Collections,uzbnamedhandles,uzbnamedhandleswithdata;

type
  TLogMsg=AnsiString;
  TModuleDesk=LongInt;
  TModuleDeskNameType=AnsiString;
  TLogLevelType=(LLTInfo,LLTWarning,LLTError);
  TLogLevel=Byte;
  TLogLevelHandleNameType=AnsiString;
  PTLogerBaseBackend=^TLogerBaseBackend;
  TLogerBaseBackend=object
    procedure doLog(msg:TLogMsg);virtual;abstract;
    procedure endLog;virtual;abstract;
  end;

implementation

begin
end.

