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

unit uzccommand_mergeblocks;
{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzbpaths,

  uzeffmanager,
  uzccommand_DWGNew,
  uzccommand_merge,uzccommandsimpl,uzccommandsabstract,
  uzcdrawings,uzedrawingsimple;

function MergeBlocks_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

function MergeBlocks_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   pdwg:PTSimpleDrawing;
   s:AnsiString;
begin
  pdwg:=(drawings.CurrentDWG);
  drawings.CurrentDWG:=BlockBaseDWG;

  if length(operands)>0 then
  s:=FindInSupportPath(GetSupportPath,operands);
  result:=Merge_com(Context,s);

  drawings.CurrentDWG:=pdwg;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@MergeBlocks_com,'MergeBlocks',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
