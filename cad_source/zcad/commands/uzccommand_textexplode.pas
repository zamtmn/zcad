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
unit uzccommand_textexplode;

{$INCLUDE zengineconfig.inc}

interface

uses
  uzcLog,
  SysUtils,
  uzccommandsabstract,
  uzccommandsimpl,
  uzeenttext,
  uzeentmtext,
  uzeconsts,
  UGDBSelectedObjArray,
  gzctnrVectorTypes,
  uzgldrawcontext,
  uzcdrawings,
  uzcdrawing,
  uzcutils,
  uzcstrconsts,
  uzcinterface,
  zUndoCmdSaveEntityState;

implementation

{Команда TextExplode заменяет Template на Content для текстовых примитивов}
function TextExplode_cmd(const Context: TZCADCommandContext;
  operands: TCommandOperands): TCommandResult;
var
  pEntity: PGDBObjEntity;
  pText: PGDBObjText;
  ir: itrec;
  processedCount: integer;
  drawing: PTZCADDrawing;
  dc: TDrawContext;
begin
  processedCount := 0;
  drawing := PTZCADDrawing(drawings.GetCurrentDWG);

  {Проверка наличия выбранных примитивов}
  if (drawings.GetCurrentROOT.ObjArray.Count = 0) or
     (drawing^.wa.param.seldesc.Selectedobjcount = 0) then begin
    zcUI.TextMessage(rscmSelEntBeforeComm, TMWOHistoryOut);
    Result := cmd_ok;
    Exit;
  end;

  {Начало группировки операций для undo}
  zcStartUndoCommand(drawing^, 'TextExplode', False);

  dc := drawing^.CreateDrawingRC;

  {Перебор всех примитивов в текущем корне}
  pEntity := drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pEntity <> nil then
    repeat
      {Обработка только выбранных текстовых примитивов}
      if pEntity^.Selected then begin
        if (pEntity^.GetObjType = GDBTextID) or
           (pEntity^.GetObjType = GDBMTextID) then begin
          pText := PGDBObjText(pEntity);

          {Сохранение состояния примитива для возможности отмены}
          TUndoCmdSaveEntityState.CreateAndPush(pEntity, drawing^.UndoStack);

          {Замена Template на Content}
          pText^.Template := pText^.Content;

          {Обновление форматирования примитива}
          pText^.FormatEntity(drawing^, dc);

          Inc(processedCount);
        end;
      end;
      pEntity := drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pEntity = nil;

  {Завершение группировки операций для undo}
  zcEndUndoCommand(drawing^);

  {Перерисовка текущего чертежа}
  zcRedrawCurrentDrawing;

  {Вывод информации о количестве обработанных примитивов}
  programlog.LogOutFormatStr('TextExplode: обработано примитивов = %d',
    [processedCount], LM_Info);

  Result := cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsInitializeLMId);
  CreateZCADCommand(@TextExplode_cmd, 'TextExplode', CADWG, 0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsFinalizeLMId);
end.
