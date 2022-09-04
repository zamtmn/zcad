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
  StrUtils,SysUtils,
  LazUTF8;

type

  TLogFileBackend=object(TLogerBaseBackend)
    LogFileName:AnsiString;
    FileHandle:cardinal;
    procedure doLog(msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk);virtual;
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

procedure TLogFileBackend.doLog(msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk);
begin
  OpenLog;
  FileWrite(FileHandle,msg[1],Length(msg)*SizeOf(msg[1]));
  FileWrite(FileHandle,LineEnding[1],Length(LineEnding)*SizeOf(LineEnding[1]));
  CloseLog;
end;

procedure TLogFileBackend.endLog;
begin
end;

constructor TLogFileBackend.init(fn:AnsiString);
begin
  logfilename:=fn;
  CreateLog;
end;

destructor TLogFileBackend.done;
begin
  logfilename:='';
end;

initialization
finalization
end.

