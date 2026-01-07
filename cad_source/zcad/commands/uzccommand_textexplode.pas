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

{$mode delphi}
unit uzcCommand_TextExplode;

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
  zUndoCmdSaveEntityState,
  uzeentity,
  uzbtypes,uzbBaseUtils;

implementation

{Команда TextExplode заменяет Template на Content для текстовых примитивов}
function TextExplode_cmd(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  pEntity:PGDBObjEntity;
  ir:itrec;
  processedCount:integer;
  drawing:PTZCADDrawing;
  dc:TDrawContext;
  needUndoCommand:boolean;
begin
  processedCount:=0;
  needUndoCommand:=true;
  //drawing := PTZCADDrawing(drawings.GetCurrentDWG);
  drawing:=Context.PCurrentDWG;

  dc:=drawing^.CreateDrawingRC;

  {Перебор всех примитивов в текущем корне}
  pEntity:=drawing.GetCurrentROOT.ObjArray.beginiterate(ir);
  if pEntity<>nil then
    repeat
      {Обработка только выбранных текстовых примитивов}
      if pEntity^.Selected then begin
        if IsObjectIt(typeof(pEntity^),typeof(GDBObjText))then begin
          if needUndoCommand then begin
            needUndoCommand:=false;
            {Начало группировки операций для undo}
            zcStartUndoCommand(drawing^,'TextExplode',False);
          end;

          {Сохранение состояния примитива для возможности отмены}
          TUndoCmdSaveEntityState.CreateAndPush(pEntity,drawing^.UndoStack);

          {Замена Template на Content}
          PGDBObjText(pEntity)^.Template:=PGDBObjText(pEntity)^.Content;

          {Обновление форматирования примитива}
          pEntity^.FormatEntity(drawing^,dc);

          Inc(processedCount);
        end;
      end;
      pEntity:=drawing.GetCurrentROOT.ObjArray.iterate(ir);
    until pEntity=nil;

  {Завершение группировки операций для undo}
  if not needUndoCommand then
    zcEndUndoCommand(drawing^);

  {Перерисовка текущего чертежа}
  zcRedrawCurrentDrawing;

  {Вывод информации о количестве обработанных примитивов}
  zcUI.TextMessage(Format(rscmNEntitiesProcessed,[processedCount]),TMWOHistoryOut);

  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@TextExplode_cmd,'TextExplode',CADWG or CASelEnts,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
