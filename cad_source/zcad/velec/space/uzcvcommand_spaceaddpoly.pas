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
  uzvcommand_spaceadd,
  uzvcommand_spaceutils,
  uzccommand_3dpoly;

implementation

function _SpaceAddPoly_com_CommandStart(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
begin
  result:=_3DPoly_com_CommandStart(Context,operands);
  p3dplESP:=@AddExtdrToRectangle;
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

    // Initialize operands structure
  uzvcommand_spaceadd.gOperandsStruct.listParam := TParamInfoList.Create;  // Создаем экземпляр TVector / Create TVector instance
  uzvcommand_spaceadd.gOperandsStruct.indexColor := 256;  // ByLayer
  uzvcommand_spaceadd.gOperandsStruct.namelayer := '';


  startup;

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
  finalize;
end.
