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

unit uzcCommand_MergeBlocks;
{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  uzcLog,
  uzbpaths,

  uzeffmanager,
  uzccommand_DWGNew,
  uzccommand_merge,uzccommandsimpl,uzccommandsabstract,
  uzcdrawings,uzedrawingsimple,
  uzcinterface,uzcstrconsts;

function MergeBlocks_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

function MergeBlocks_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   pdwg:PTSimpleDrawing;
   s:AnsiString;
begin
  if length(operands)>0 then
    s:=FindInPaths(GetSupportPaths,operands)
  else
    s:='';
  if s<>'' then begin
    pdwg:=drawings.CurrentDWG;
    drawings.CurrentDWG:=BlockBaseDWG;
    result:=Merge_com(Context,s);
    drawings.CurrentDWG:=pdwg;
  end else begin
    result:=cmd_error;
    zcUI.TextMessage('MergeBlocks:'+format(rsUnableToOpenFile,[ExpandPath(operands)]),TMWOShowError);
  end;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@MergeBlocks_com,'MergeBlocks',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
