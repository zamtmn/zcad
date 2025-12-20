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
unit uzccommand_units;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzcLog,
  uzcfunits,
  uzctreenode,
  uzcsysvars,
  uzcsysparams,
  uzcinterface,
  uzcdrawings,
  Varman,
  uzcuitypes,
  uzccommandsabstract,uzccommandsimpl,
  uzbUnits;

implementation

function units_cmd(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  _UnitsFormat:TzeUnitsFormat;
begin
  if not assigned(UnitsForm) then begin
    UnitsForm:=TUnitsForm.Create(nil);
    SetHeightControl(UnitsForm,sysvar.INTF.INTF_DefaultControlHeight^);
    UnitsForm.BoundsRect:=GetBoundsFromSavedUnit(
      'UnitsWND',ZCSysParams.notsaved.ScreenX,ZCSysParams.notsaved.Screeny);
  end;

  _UnitsFormat:=drawings.GetUnitsFormat;

  zcUI.Do_BeforeShowModal(UnitsForm);
  Result:=UnitsForm.runmodal(_UnitsFormat,sysvar.DWG.DWG_InsUnits^);
  if Result=ZCmrOK then begin
    drawings.SetUnitsFormat(_UnitsFormat);
    zcUI.Do_GUIaction(nil,zcMsgUIReturnToDefaultObject);
  end;
  zcUI.Do_AfterShowModal(UnitsForm);
  StoreBoundsToSavedUnit('UnitsWND',UnitsForm.BoundsRect);
  FreeAndNil(UnitsForm);
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@units_cmd,'Units',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
