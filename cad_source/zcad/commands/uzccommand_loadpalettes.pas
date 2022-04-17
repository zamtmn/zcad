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

unit uzccommand_loadpalettes;
{$INCLUDE zengineconfig.inc}

interface
uses
 LCLProc,
 uzbpaths,uzccommandsabstract,uzccommandsimpl,uztoolbarsmanager;

implementation
function LoadPalettes_com(operands:TCommandOperands):TCommandResult;
begin
  ToolBarsManager.LoadPalettes(ExpandPath(operands));
  result:=cmd_ok;
end;


initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@LoadPalettes_com,'LoadPalettes',0,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
