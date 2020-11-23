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
unit uzccommand_colors;

{$INCLUDE def.inc}

interface
uses
  SysUtils,
  LazLogger,
  uzcfcolors,
  uzctreenode,
  uzcsysvars,
  uzcinterface,
  Varman,
  uzccommandsabstract,uzccommandsimpl,
  uzcuitypes;

implementation

function Colors_cmd(operands:TCommandOperands):TCommandResult;
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
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@Colors_cmd,'Colors',CADWG,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
