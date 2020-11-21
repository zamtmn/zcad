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
unit uzccommand_dimstyles;

{$INCLUDE def.inc}

interface
uses
  SysUtils,
  LazLogger,
  uzcfdimstyles,
  uzctreenode,
  uzcsysvars,
  uzcinterface,
  Varman,
  uzccommandsabstract,uzccommandsimpl;

implementation

function DimStyles_cmd(operands:TCommandOperands):TCommandResult;
begin
  DimStylesForm:=TDimStylesForm.Create(nil);
  SetHeightControl(DimStylesForm,sysvar.INTF.INTF_DefaultControlHeight^);
  ZCMsgCallBackInterface.DOShowModal(DimStylesForm);
  Freeandnil(DimStylesForm);
  result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@DimStyles_cmd,'DimStyles',CADWG,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
