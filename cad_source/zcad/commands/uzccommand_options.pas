{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
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
unit uzccommand_options;

{$INCLUDE def.inc}

interface
uses
  LazLogger,
  uzccommandsabstract,uzccommandsimpl,
  uzcinterface,
  uzcdrawings,
  Varman,
  uzcsysvars,
  uzcstrconsts;

implementation

function Options_com(operands:TCommandOperands):TCommandResult;
begin
  ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar,drawings.GetCurrentDWG);
  ZCMsgCallBackInterface.TextMessage(rscmOptions2OI,TMWOMessageBox);
  result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@Options_com,'Options',0,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
