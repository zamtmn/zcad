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
unit uzccommand_show;

{$INCLUDE zcadconfig.inc}

interface
uses
  SysUtils,
  Controls,AnchorDocking,
  LazLogger,
  uzcinterface,
  uzcstrconsts,
  uzccommandsabstract,uzccommandsimpl;

implementation

function Show_com(operands:TCommandOperands):TCommandResult;
var
   ctrl:TControl;
begin
  if Operands<>'' then begin
    ctrl:=DockMaster.FindControl(Operands);
    if (ctrl<>nil)and(ctrl.IsVisible) then begin
      DockMaster.ManualFloat(ctrl);
      DockMaster.GetAnchorSite(ctrl).Close;
    end else begin
      If IsValidIdent(Operands) then
        DockMaster.ShowControl(Operands,true)
      else
        ZCMsgCallBackInterface.TextMessage('Show: invalid identificator!',TMWOShowError);
    end;
  end else
    ZCMsgCallBackInterface.TextMessage(rscmCmdMustHaveOperand,TMWOShowError);
  result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@Show_com,'Show',0,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
