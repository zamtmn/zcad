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
unit uzccommand_saveoptions;

{$INCLUDE zengineconfig.inc}

interface

uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzctnrVectorBytesStream,
  uzbpaths,
  Varman,
  uzcsysparams,uzcFileStructure;

implementation

function SaveOptions_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  mem:TZctnrVectorBytes;
begin
  mem.init(1024);
  SysVarUnit^.SavePasToMem(mem);
  mem.SaveToFile(GetWritableFilePath(CFSconfigsDir,CFSsysvarpasFile));
  mem.done;
  SaveParams(GetWritableFilePath(CFSconfigsDir,CFSconfigxmlFile),ZCSysParams.saved);
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@SaveOptions_com,'SaveOptions',0,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
