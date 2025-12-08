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
{$MODE OBJFPC}{$H+}
unit uzCVCommand_SpaceAddPoly;
{$INCLUDE zengineconfig.inc}

interface

uses
  uzccommandsabstract,
  uzccommandsimpl,
  uzcLog,
  //это раскомегнтируй
  //uzvcommand_spaceadd
  uzccommand_3dpoly;

implementation

function _SpaceAddPoly_com_CommandStart(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
begin
  result:=_3DPoly_com_CommandStart(Context,operands);
  p3dplESP:=nil{AddExtdrToRectangle};//это раскомегнтируй
  if assigned(p3dplESP) then
    p3dplESP(ESSSuppressCommandParams,nil);
end;


procedure startup;
begin
  CreateCommandRTEdObjectPlugin(@_SpaceAddPoly_com_CommandStart,@_3DPoly_com_CommandEnd,
    @_3DPoly_com_CommandEnd,nil,@_3DPoly_com_BeforeClick,@_3DPoly_com_AfterClick,
  nil,nil,'SpaceAddPoly',0,0);
end;

procedure Finalize;
begin
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  startup;

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
  finalize;
end.
