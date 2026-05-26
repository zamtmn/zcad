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

unit uzeentproxylog;

{$mode objfpc}{$H+}

interface

uses
  uzbLogTypes;

const
  PROXY_LOG_MODULE_NAME = 'PROXY';

var
  { Dedicated ProxyEntity diagnostics module. It is registered without
    EEnable, so normal ProxyEntity loading stays quiet unless the user
    enables it with the regular programlog module switches, for example
    "lem PROXY". }
  ProxyLogModuleId: TModuleDesk;

procedure ProxyLogInfoFormatStr(const Fmt: String; const Args: array of const);
procedure ProxyLogWarningFormatStr(const Fmt: String; const Args: array of const);
procedure ProxyLogErrorFormatStr(const Fmt: String; const Args: array of const);

implementation

uses
  uzclog;

procedure ProxyLogInfoFormatStr(const Fmt: String; const Args: array of const);
begin
  programlog.LogOutFormatStr(Fmt, Args, LM_Info, ProxyLogModuleId);
end;

procedure ProxyLogWarningFormatStr(const Fmt: String;
  const Args: array of const);
begin
  programlog.LogOutFormatStr(Fmt, Args, LM_Warning, ProxyLogModuleId);
end;

procedure ProxyLogErrorFormatStr(const Fmt: String; const Args: array of const);
begin
  programlog.LogOutFormatStr(Fmt, Args, LM_Error, ProxyLogModuleId);
end;

initialization
  ProxyLogModuleId := programlog.RegisterModule(PROXY_LOG_MODULE_NAME);
end.
