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
  Модуль: uzccommand_tablestyles
  Назначение: регистрирует команду TableStyles для открытия менеджера стилей таблиц.
  При выполнении команды открывается модальный диалог менеджера стилей таблиц,
  в котором можно просматривать, создавать и удалять стили таблиц.
  Зависимости: uzclog, uzcftablestyles, uzcinterface, uzccommandsabstract
}
{$mode delphi}
unit uzccommand_tablestyles;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzcLog,
  uzcftablestyles,
  uzctreenode,
  uzcsysvars,
  uzcinterface,
  Varman,
  uzccommandsabstract,
  uzccommandsimpl;

implementation

{ Открывает менеджер стилей таблиц в модальном диалоге }
function TableStyles_cmd(const Context: TZCADCommandContext;
  operands: TCommandOperands): TCommandResult;
begin
  programlog.LogOutFormatStr(
    'uzccommand_tablestyles: открытие менеджера стилей таблиц',
    [], LM_Info);

  TableStylesForm := TTableStylesForm.Create(nil);
  SetHeightControl(TableStylesForm, sysvar.INTF.INTF_DefaultControlHeight^);
  zcUI.DOShowModal(TableStylesForm);
  FreeAndNil(TableStylesForm);

  Result := cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsInitializeLMId);
  CreateZCADCommand(@TableStyles_cmd, 'TableStyles', CADWG, 0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsFinalizeLMId);
end.
