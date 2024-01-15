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
{$mode delphi}
unit uzccommand_textstyles;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  uzcLog,
  uzcftextstyles,
  uzctreenode,
  uzcsysvars,
  uzcinterface,
  Varman,
  uzccommandsabstract,uzccommandsimpl;

implementation

function TextStyles_cmd(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  TextStylesForm:=TTextStylesForm.Create(nil);
  SetHeightControl(TextStylesForm,sysvar.INTF.INTF_DefaultControlHeight^);
  ZCMsgCallBackInterface.DOShowModal(TextStylesForm);
  Freeandnil(TextStylesForm);
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@TextStyles_cmd,'TextStyles',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
