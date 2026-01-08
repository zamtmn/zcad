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

unit uzbLogFileBackend;
{$mode objfpc}{$H+}

interface

uses
  uzbLogTypes,uzbLog,
  {StrUtils,}SysUtils,
  LazUTF8;

const
  myLineEnding:TLogMsg=LineEnding;

type

  TLogFileBackend=object(TLogerBaseBackend)
    LogFileName:AnsiString;
    FileHandle:cardinal;
    procedure doLog(const msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk);virtual;
    procedure endLog;virtual;
    constructor init(fn:AnsiString);
    destructor done;virtual;
    procedure OpenLog;
    procedure CloseLog;
    procedure CreateLog;
  end;

implementation

procedure TLogFileBackend.OpenLog;
begin
  FileHandle := FileOpen({$IFNDEF DELPHI}UTF8ToSys{$ENDIF}(logfilename), fmOpenWrite);
  FileSeek(FileHandle, 0, 2);
end;

procedure TLogFileBackend.CloseLog;
begin
  fileclose(FileHandle);
  FileHandle:=0;
end;
procedure TLogFileBackend.CreateLog;
begin
  FileHandle:=FileCreate({$IFNDEF DELPHI}UTF8ToSys{$ENDIF}(logfilename));
  CloseLog;
end;

procedure TLogFileBackend.doLog(const msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk);
begin
  OpenLog;
  FileWrite(FileHandle,msg[1],Length(msg)*SizeOf(msg[1]));
  FileWrite(FileHandle,myLineEnding[1],Length(myLineEnding)*SizeOf(myLineEnding[1]));
  CloseLog;
end;

procedure TLogFileBackend.endLog;
begin
end;

constructor TLogFileBackend.init(fn:AnsiString);
begin
  logfilename:=fn;
  CreateLog;
  inherited init;
end;

destructor TLogFileBackend.done;
begin
  logfilename:='';
  inherited;
end;

initialization
finalization
end.

