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

unit uzccommand_loadtoolbars;
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzcLog,
  Forms,ActnList,Laz2_DOM,
  uzbpaths,uzccommandsabstract,uzccommandsimpl,uztoolbarsmanager,uzctbextmenus,
  uzcTranslations,uzctreenode,uzctbexttoolbars;

implementation

function TBCheckFunc(fmf:TForm;AcnLst:TActionList;aTBNode:TDomNode;
  aName,aCaption,aType:string):boolean;
var
  AcnName:string;
  Action:tmyaction;
begin
  AcnName:=ToolBarNameToActionName(aName);
  Action:=tmyaction(AcnLst.ActionByName(AcnName));
  if Action<>nil then
    exit(False);
  aCaption:=InterfaceTranslate(format(CToolBarCaptionTranslateFormat,[aName]),aCaption);
  CreateTBShowAction(AcnName,aName,aCaption,AcnLst);
  Result:=True;
end;

function LoadToolbars_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
begin
  ToolBarsManager.LoadToolBarsContent(ExpandPath(operands),@TBCheckFunc);
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@LoadToolbars_com,'LoadToolbars',0,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
