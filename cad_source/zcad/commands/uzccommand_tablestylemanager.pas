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
  Модуль: uzccommand_tablestylemanager
  Назначение: регистрирует команду TableStyleManager для открытия диалога
  управления стилями таблиц. Команда требует открытого чертежа (флаг CADWG).
  Зависимости: uzclog, uzcui_tablestylemanager, uzcinterface, uzcsysvars,
               uzccommandsabstract, uzccommandsimpl
}
{$mode delphi}
unit uzccommand_tablestylemanager;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzcLog,
  uzcui_tablestylemanager,
  uzcsysvars,
  uzcinterface,
  uzctreenode,
  uzccommandsabstract,
  uzccommandsimpl;

implementation

{ Открывает диалог управления стилями таблиц в модальном режиме }
function TableStyleManager_cmd(
  const Context: TZCADCommandContext;
  operands: TCommandOperands): TCommandResult;
begin
  programlog.LogOutFormatStr(
    'uzccommand_tablestylemanager: открытие менеджера стилей таблиц',
    [], LM_Info);

  TableStyleManagerForm := TTableStyleManagerForm.Create(nil);
  SetHeightControl(TableStyleManagerForm,
    sysvar.INTF.INTF_DefaultControlHeight^);
  zcUI.DOShowModal(TableStyleManagerForm);
  FreeAndNil(TableStyleManagerForm);

  Result := cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsInitializeLMId);
  CreateZCADCommand(@TableStyleManager_cmd, 'TableStyleManager', CADWG, 0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsFinalizeLMId);
end.
