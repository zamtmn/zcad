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
unit uzccommand_dimstyles;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  uzcLog,
  uzcfdimstyles,
  uzctreenode,
  uzcsysvars,
  uzcinterface,
  Varman,
  uzccommandsabstract,uzccommandsimpl;

implementation

function DimStyles_cmd(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  DimStylesForm:=TDimStylesForm.Create(nil);
  SetHeightControl(DimStylesForm,sysvar.INTF.INTF_DefaultControlHeight^);
  ZCMsgCallBackInterface.DOShowModal(DimStylesForm);
  Freeandnil(DimStylesForm);
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@DimStyles_cmd,'DimStyles',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
