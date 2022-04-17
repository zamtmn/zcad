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
unit uzccommand_executefile;

{$INCLUDE zengineconfig.inc}

interface
uses
  LazLogger,
  uzbpaths,
  uzcdrawings,
  uzccommandsabstract,uzccommandsimpl,
  uzccommandsmanager;

implementation

function ExecuteFile_com(operands:TCommandOperands):TCommandResult;
begin
  commandmanager.executefile(ExpandPath(operands),drawings.GetCurrentDWG,nil);
  result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@ExecuteFile_com,'ExecuteFile',0,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
