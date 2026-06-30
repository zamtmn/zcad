{*************************************************************************** }
{  fpdwg - DWG import timing log module                                      }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

unit uzedwgtimerlog;

{$mode objfpc}{$H+}

interface

uses
  uzbLogTypes;

const
  DWG_TIMER_LOG_MODULE_NAME = 'DWGTIMER';

var
  { Dedicated DWG loader timing module. It is registered without EEnable, so
    normal imports stay quiet unless the user enables it with the regular
    programlog module switches, for example "lem DWGTIMER". }
  DWGTimerLogModuleId: TModuleDesk;

procedure DWGTimerLogTiming(const Phase: String; ElapsedMsec: Integer;
  const Detail: String = '');

implementation

uses
  uzclog;

procedure DWGTimerLogTiming(const Phase: String; ElapsedMsec: Integer;
  const Detail: String);
begin
  if Detail = '' then
    programlog.LogOutFormatStr('DWG timing: phase=%s elapsed_ms=%d',
      [Phase, ElapsedMsec], LM_Info, DWGTimerLogModuleId)
  else
    programlog.LogOutFormatStr('DWG timing: phase=%s elapsed_ms=%d %s',
      [Phase, ElapsedMsec, Detail], LM_Info, DWGTimerLogModuleId);
end;

initialization
  DWGTimerLogModuleId := programlog.RegisterModule(DWG_TIMER_LOG_MODULE_NAME);
end.
