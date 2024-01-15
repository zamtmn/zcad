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
unit uzccommand_layer;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  uzcLog,
  uzcflayers,
  uzctreenode,
  uzcsysvars,
  uzcinterface,
  Varman,
  uzccommandsabstract,uzccommandsimpl;

function layer_cmd(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

function layer_cmd(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  LayersForm:=TLayersForm.Create(nil);
  SetHeightControl(LayersForm,sysvar.INTF.INTF_DefaultControlHeight^);
  ZCMsgCallBackInterface.DOShowModal(LayersForm);
  Freeandnil(LayersForm);
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@layer_cmd,'Layer',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
