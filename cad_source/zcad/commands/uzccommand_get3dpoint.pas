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
unit uzccommand_get3dpoint;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcdrawings,uzeconsts,uzcinterface,
  uzcstrconsts,uzegeometrytypes,
  uzglviewareadata,uzccommandsmanager;

implementation

function Line_com_CommandStart(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  if operands='' then
                     ZCMsgCallBackInterface.TextMessage(rscmPoint,TMWOHistoryOut)
                 else
                     ZCMsgCallBackInterface.TextMessage(operands,TMWOHistoryOut);
  result:=cmd_ok;
end;
function Line_com_BeforeClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer): Integer;
begin
  if (button and MZW_LBUTTON)<>0 then
  begin
       commandmanager.PushValue('','GDBVertex',@wc);
       commandmanager.executecommandend;
       result:=1;
  end
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateCommandRTEdObjectPlugin(@Line_com_CommandStart,nil,nil,nil,@Line_com_BeforeClick,nil,nil,nil,'Get3DPoint',0,0).overlay:=true;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
