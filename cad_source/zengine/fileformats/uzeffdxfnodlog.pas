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
  Модуль: uzeffdxfnodlog
  Назначение: отдельный модуль лога «NOD» для разбора секции OBJECTS и
  Named Object Dictionary (ТЗ cad_source/zengine/TZ_NOD_NamedObjectDictionary.md).

  Модуль регистрируется без включения, поэтому детальная трасса разбора
  (количество объектов, ключи NOD, время) по умолчанию не пишется.
  Включается обычными ключами programlog:
    zcad ... logfile <path> lem NOD
  Предупреждения, важные для пользователя (например, несколько корневых
  словарей), пишутся через NODLogWarningFormatStr в общий лог и видны всегда.
}
unit uzeffdxfnodlog;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface

uses
  uzbLogTypes;

const
  NOD_LOG_MODULE_NAME = 'NOD';

var
  { Модуль детальной трассы NOD. Выключен по умолчанию. }
  NODLogModuleId: TModuleDesk;

{ Включена ли детальная трасса NOD (модуль NOD включён, уровень LM_Info
  проходит). Проверяется перед сборкой дорогих сообщений трассы. }
function NODLogTraceEnabled: Boolean;
{ Детальная трасса разбора (только при включённом модуле NOD). }
procedure NODLogTraceFormatStr(const Fmt: String; const Args: array of const);
{ Предупреждение: пишется в общий лог независимо от модуля NOD. }
procedure NODLogWarningFormatStr(const Fmt: String; const Args: array of const);

implementation

uses
  uzclog;

function NODLogTraceEnabled: Boolean;
begin
  { То же условие, что у TLog.IsNeedToLog для включённого модуля }
  Result := programlog.isModuleEnabled(NODLogModuleId) and
    (LM_Info >= programlog.GetCurrentLogLevel);
end;

procedure NODLogTraceFormatStr(const Fmt: String; const Args: array of const);
begin
  programlog.LogOutFormatStr(Fmt, Args, LM_Info, NODLogModuleId);
end;

procedure NODLogWarningFormatStr(const Fmt: String; const Args: array of const);
begin
  programlog.LogOutFormatStr(Fmt, Args, LM_Warning);
end;

initialization
  NODLogModuleId := programlog.RegisterModule(NOD_LOG_MODULE_NAME);
end.
