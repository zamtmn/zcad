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
  Модуль: uzccommand_mleaderstylemanager
  Назначение: регистрирует команду MLeaderStyleManager для открытия диалога
  управления стилями мультивыносок (по образцу TableStyleManager).
  Команда требует открытого чертежа (флаг CADWG).
  Зависимости: uzclog, uzcui_mleaderstylemanager, uzcinterface, uzcsysvars,
               uzccommandsabstract, uzccommandsimpl
}
{$mode delphi}
unit uzccommand_mleaderstylemanager;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzcLog,
  uzcui_mleaderstylemanager,
  uzcsysvars,
  uzcinterface,
  uzctreenode,
  uzccommandsabstract,
  uzccommandsimpl;

implementation

{ Открывает диалог управления стилями мультивыносок в модальном режиме }
function MLeaderStyleManager_cmd(
  const Context: TZCADCommandContext;
  operands: TCommandOperands): TCommandResult;
begin
  programlog.LogOutFormatStr(
    'uzccommand_mleaderstylemanager: открытие менеджера стилей мультивыносок',
    [], LM_Info);

  MLeaderStyleManagerForm := TMLeaderStyleManagerForm.Create(nil);
  SetHeightControl(MLeaderStyleManagerForm,
    sysvar.INTF.INTF_DefaultControlHeight^);
  zcUI.DOShowModal(MLeaderStyleManagerForm);
  FreeAndNil(MLeaderStyleManagerForm);

  Result := cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsInitializeLMId);
  CreateZCADCommand(@MLeaderStyleManager_cmd, 'MLeaderStyleManager', CADWG, 0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsFinalizeLMId);
end.
