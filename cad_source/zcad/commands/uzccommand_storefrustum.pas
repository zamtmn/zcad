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
unit uzccommand_storefrustum;

{$INCLUDE def.inc}

interface
uses
  uzccommandsabstract,uzccommandsimpl,
  uzcdrawings;

implementation

function StoreFrustum_com(operands:TCommandOperands):TCommandResult;
begin
   drawings.GetCurrentDWG.wa.param.debugfrustum:=drawings.GetCurrentDWG.pcamera.frustum;
   drawings.GetCurrentDWG.wa.param.ShowDebugFrustum:=true;
   result:=cmd_ok;
end;

initialization
  CreateCommandFastObjectPlugin(@StoreFrustum_com,'StoreFrustum',CADWG,0).overlay:=true;
end.
