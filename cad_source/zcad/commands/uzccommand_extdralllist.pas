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
unit uzccommand_extdralllist;

{$INCLUDE def.inc}

interface
uses
  LazLogger,SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,gzctnrvectortypes,uzcdrawings,uzcdrawing,uzcstrconsts,
  uzcinterface,uzcutils,gzctnrstl,gutil;

function extdrAllList_com(operands:TCommandOperands):TCommandResult;

implementation

function extdrAllList_com(operands:TCommandOperands):TCommandResult;
begin
    result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@extdrAllList_com,'extdrAllList',CADWG or CASelEnts,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
