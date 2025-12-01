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
@author(Vladimir Bobrov)
}
{$mode delphi}

{**Модуль реализации команды exdRectangle для черчения прямоугольника с расширениями}
unit uzvcommand_exdRectangle;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,
  uzccommandsimpl,
  uzcstrconsts,
  uzccommandsmanager,
  uzeentity,
  uzcEnitiesVariablesExtender,
  uzcExtdrIncludingVolume,
  uzccommand_rectangle;

implementation

{**Функция добавления расширений к прямоугольнику на разных стадиях настройки
   @param(AStage - стадия настройки примитива)
   @param(APEnt - указатель на примитив)
   @return(true если обработка успешна)}
function AddExtdrToRectangle(const AStage:TEntitySetupStage;
  const APEnt:PGDBObjEntity):boolean;
begin
  case AStage of
    ESSSuppressCommandParams:
      result:=false;
    ESSSetEntity:begin
      if APEnt<>nil then begin
        // Добавляем расширение extdrVariables первым
        AddVariablesToEntity(APEnt);
        // Затем добавляем расширение extdrIncludingVolume
        AddVolumeExtenderToEntity(APEnt);
        result:=true;
      end else
        result:=False;
      end;
    ESSCommandEnd:
      result:=False;
  end;
end;

{**Команда черчения прямоугольника с расширениями
   @param(Context - контекст команды ZCAD)
   @param(operands - операнды команды)
   @return(результат выполнения команды)}
function ExdRectangle_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
begin
  Result:=InteractiveDrawRectangle(
    Context,
    rscmSpecifyFirstPoint,
    rscmSpecifySecondPoint,
    AddExtdrToRectangle
  );
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@ExdRectangle_com,'exdRectangle',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
