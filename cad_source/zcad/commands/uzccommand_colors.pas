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
unit uzccommand_colors;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  uzcLog,
  uzcfcolors,
  uzctreenode,
  uzcsysvars,
  uzcinterface,
  Varman,
  uzccommandsabstract,uzccommandsimpl,
  uzcuitypes;

implementation

function Colors_cmd(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   mr:integer;
begin
  if not assigned(ColorSelectForm)then
    ColorSelectForm:=TColorSelectForm.Create(nil);
  SetHeightControl(ColorSelectForm,sysvar.INTF.INTF_DefaultControlHeight^);
  ZCMsgCallBackInterface.Do_BeforeShowModal(ColorSelectForm);
  mr:=ColorSelectForm.run(SysVar.dwg.DWG_CColor^,true){showmodal};
  if mr=ZCmrOK then
    SysVar.dwg.DWG_CColor^:=ColorSelectForm.ColorInfex;
  ZCMsgCallBackInterface.Do_AfterShowModal(ColorSelectForm);
  freeandnil(ColorSelectForm);
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@Colors_cmd,'Colors',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
