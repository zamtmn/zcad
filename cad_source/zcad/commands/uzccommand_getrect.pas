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
unit uzccommand_getrect;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcdrawings,uzcinterface,
  uzccommandsmanager;

implementation

var
   c1,c2:integer;

function Rect_com_CommandStart(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
     c1:=commandmanager.GetValueHeap;
     c2:=-1;
     commandmanager.executecommandsilent('Get3DPoint(Первая точка:)',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
     result:=cmd_ok;
end;

procedure Rect_com_CommandCont(const Context:TZCADCommandContext);
begin
     if c2=-1 then
                  c2:=commandmanager.GetValueHeap
              else
                  begin
                       commandmanager.executecommandend;
                       exit;
                  end;
     if c1=c2 then
                  commandmanager.executecommandend
              else
                  commandmanager.executecommandsilent('Get3DPoint_DrawRect(Вторая точка:)',drawings.GetCurrentDWG,drawings.GetCurrentOGLWParam);
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateCommandRTEdObjectPlugin(@Rect_com_CommandStart,nil,nil,nil,nil,nil,nil,@Rect_com_CommandCont,'GetRect',0,0).overlay:=true;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
