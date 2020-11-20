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
unit uzccommand_changeprojtype;

{$INCLUDE def.inc}

interface
uses
  LazLogger,
  uzccommandsabstract,uzccommandsimpl,
  uzcdrawings,
  uzcutils,
  uzeconsts;

implementation

function ChangeProjType_com(operands:TCommandOperands):TCommandResult;
begin
  if drawings.GetCurrentDWG.wa.param.projtype = projparalel then
  begin
    drawings.GetCurrentDWG.wa.param.projtype := projperspective;
  end
  else
    if drawings.GetCurrentDWG.wa.param.projtype = projPerspective then
    begin
    drawings.GetCurrentDWG.wa.param.projtype := projparalel;
    end;
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@ChangeProjType_com,'ChangeProjType',CADWG,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
