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
unit uzccommand_clearfilehistory;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  Varman,
  uzctbextmenus;

implementation

function ClearFileHistory_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var i:integer;
    pstr:PAnsiString;
begin
     for i:=0 to 9 do
     begin
          pstr:=SavedUnit.FindValue('PATH_File'+inttostr(i)).data.Addr.Instance;
          if assigned(pstr) then
          pstr^:='';
          if assigned(FileHistory[i]) then
          begin
              FileHistory[i].Caption:='';
              FileHistory[i].command:='';
              FileHistory[i].Visible:=false;
          end;
     end;
     result:=cmd_ok;
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@ClearFileHistory_com,'ClearFileHistory',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
