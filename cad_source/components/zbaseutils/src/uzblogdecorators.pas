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

unit uzbLogDecorators;
{$mode objfpc}{$H+}

interface

uses
  uzbLogTypes,uzbLog,
  StrUtils,SysUtils;

type

  TTimeDecorator=object(TLogerBaseDecorator)
    function GetDecor(const msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk):TLogMsg;virtual;
    constructor init;
  end;
  TPositionDecorator=object(TLogerBaseDecorator)
    offset:integer;
    function GetDecor(const msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk):TLogMsg;virtual;
    constructor init;
  end;

var
  lp_IncPos,lp_DecPos:TMsgOpt;

implementation

function TPositionDecorator.GetDecor(const msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk):TLogMsg;
begin
 if (MsgOptions and lp_DecPos)>0 then
   dec(offset,2);
 result:=dupestring(' ',offset);
 if (MsgOptions and lp_IncPos)>0 then
   inc(offset,2);
end;

constructor TPositionDecorator.init;
begin
  offset:=1;
end;

constructor TTimeDecorator.init;
begin
end;

function TTimeDecorator.GetDecor(const msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk):TLogMsg;
begin
  result:=TimeToStr(Time);
end;

initialization
  lp_DecPos:=MsgOpt.GetEnum;
  lp_IncPos:=MsgOpt.GetEnum;
finalization
end.

