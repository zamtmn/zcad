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
unit uzccommand_units;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  LazLogger,
  uzedimensionaltypes,
  uzcfunits,
  uzctreenode,
  uzcsysvars,
  uzcsysparams,
  uzcinterface,
  uzcdrawings,
  Varman,
  uzcuitypes,
  uzccommandsabstract,uzccommandsimpl;

implementation

function units_cmd(operands:TCommandOperands):TCommandResult;
var
    _UnitsFormat:TzeUnitsFormat;
begin
   if not assigned(UnitsForm)then
   begin
       UnitsForm:=TUnitsForm.Create(nil);
       SetHeightControl(UnitsForm,sysvar.INTF.INTF_DefaultControlHeight^);
       UnitsForm.BoundsRect:=GetBoundsFromSavedUnit('UnitsWND',SysParam.notsaved.ScreenX,SysParam.notsaved.Screeny)
   end;

   _UnitsFormat:=drawings.GetUnitsFormat;

   ZCMsgCallBackInterface.Do_BeforeShowModal(UnitsForm);
   result:=UnitsForm.runmodal(_UnitsFormat,sysvar.DWG.DWG_InsUnits^);
   if result=ZCmrOK then
                      begin
                        drawings.SetUnitsFormat(_UnitsFormat);
                        ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
                      end;
   ZCMsgCallBackInterface.Do_AfterShowModal(UnitsForm);
   StoreBoundsToSavedUnit('UnitsWND',UnitsForm.BoundsRect);
   Freeandnil(UnitsForm);
   result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@units_cmd,'Units',CADWG,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
