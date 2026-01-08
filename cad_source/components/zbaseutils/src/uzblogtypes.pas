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
interface

type
  TMsgOpt=LongWord;
  TLogMsg=AnsiString;
  TModuleDesk=SizeUInt;
  TModuleDeskNameType=AnsiString;
  TLogLevelType=(LLTInfo,LLTWarning,LLTError,LLTNecessarily);
  TLogLevel=Integer;
  TLogLevelHandleNameType=AnsiString;
  TLogExtHandle=SizeInt;
  PTLogerBaseBackend=^TLogerBaseBackend;
  TLogerBaseBackend=object
    procedure DoLog(const msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk);virtual;abstract;
    constructor init;
    destructor Done;virtual;
  end;
  PTLogerBaseDecorator=^TLogerBaseDecorator;
  TLogerBaseDecorator=object
    function GetDecor(const msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk):TLogMsg;virtual;abstract;
    constructor init;
    destructor Done;virtual;
  end;

implementation

constructor TLogerBaseDecorator.init;
begin
end;


destructor TLogerBaseDecorator.Done;
begin
end;

constructor TLogerBaseBackend.init;
begin
end;

destructor TLogerBaseBackend.Done;
begin
end;

begin
end.

