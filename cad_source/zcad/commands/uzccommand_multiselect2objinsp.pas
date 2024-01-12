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
unit uzccommand_multiselect2objinsp;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcoimultiobjects,
  uzcdrawings,
  uzcinterface,
  Varman;

implementation

var
  ms2objinsp:PCommandObjectDef;

function MultiSelect2ObjIbsp_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  MSEditor.CreateUnit(drawings.GetUnitsFormat);
  ZCMsgCallBackInterface.Do_PrepareObject(drawings.GetUndoStack,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('TMSEditor'),@MSEditor,drawings.GetCurrentDWG);
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  ms2objinsp:=CreateZCADCommand(@MultiSelect2ObjIbsp_com,'MultiSelect2ObjIbsp',CADWG,0);
  ms2objinsp.overlay:=true;
  ms2objinsp.CEndActionAttr:=[];
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
