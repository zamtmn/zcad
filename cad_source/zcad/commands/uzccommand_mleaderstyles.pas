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
@author(Vladimir Bobrov)
}
{
  Модуль: uzccommand_mleaderstyles
  Назначение: регистрирует команду MLeaderStyles для открытия менеджера стилей
  мультивыносок (по образцу uzccommand_tablestyles).
  При выполнении команды открывается модальный диалог менеджера стилей
  мультивыносок, в котором можно просматривать, создавать и удалять стили.
  Зависимости: uzclog, uzcfmleaderstyles, uzcinterface, uzccommandsabstract
}
{$mode delphi}
unit uzccommand_mleaderstyles;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzcLog,
  uzcfmleaderstyles,
  uzctreenode,
  uzcsysvars,
  uzcinterface,
  Varman,
  uzccommandsabstract,
  uzccommandsimpl;

implementation

{ Открывает менеджер стилей мультивыносок в модальном диалоге }
function MLeaderStyles_cmd(const Context: TZCADCommandContext;
  operands: TCommandOperands): TCommandResult;
begin
  programlog.LogOutFormatStr(
    'uzccommand_mleaderstyles: открытие менеджера стилей мультивыносок',
    [], LM_Info);

  MLeaderStylesForm := TMLeaderStylesForm.Create(nil);
  SetHeightControl(MLeaderStylesForm, sysvar.INTF.INTF_DefaultControlHeight^);
  zcUI.DOShowModal(MLeaderStylesForm);
  FreeAndNil(MLeaderStylesForm);

  Result := cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsInitializeLMId);
  CreateZCADCommand(@MLeaderStyles_cmd, 'MLeaderStyles', CADWG, 0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsFinalizeLMId);
end.
