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

{
  Модуль: uzccommand_createblockinsert
  Назначение:
    Команда CreateBlockInsert — создаёт новый блок (BlockDef) из выделенных
    примитивов и сразу предлагает вставить этот блок в чертёж командой Insert.

  Алгоритм работы:
    1. Проверка наличия выделенных примитивов. Если выделения нет —
       выводится сообщение и команда завершается.
    2. Запрос начальной (базовой) точки будущего блока. Координаты
       примитивов внутри блока будут пересчитаны относительно этой точки.
    3. Запрос имени блока через командную строку ZCAD. Пустое имя или
       совпадение с уже существующим блоком — ошибка.
    4. Создаётся новый BlockDef в текущем чертеже. Копии всех выделенных
       примитивов добавляются в блок со смещением относительно базовой точки.
    5. После успешного создания блока асинхронно запускается команда Insert
       с подставленным именем блока — пользователю остаётся лишь указать
       место вставки.

  Зависимости:
    uzccommandsmanager, uzccommandsimpl, uzccommandsabstract,
    uzcdrawings, uzcdrawing, uzegeometry, uzegeometrytypes, uzeentity,
    uzeentwithlocalcs, uzeblockdef, uzgldrawcontext, uzcinterface,
    uzcstrconsts, uzcLog, Forms.
}

unit uzccommand_createblockinsert;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  Forms,
  gzctnrVectorTypes,
  uzcLog,
  uzegeometry,
  uzegeometrytypes,
  uzcdrawings,
  uzcdrawing,
  uzedrawingsimple,
  uzgldrawcontext,
  uzccommandsabstract,
  uzccommandsimpl,
  uzccommandsmanager,
  uzcinterface,
  uzcstrconsts,
  uzeblockdef,
  uzeentity,
  uzeentwithlocalcs,
  uzeconsts;

implementation

resourcestring
  RSCLPBasePoint           = 'Начальная точка вставки блока:';
  RSCLPBlockName           = 'Введите имя блока:';
  RSSelectEntsFirst        =
    'Перед запуском команды, предварительно должны быть выделены ' +
    'примитивы будущего блока.';
  RSEmptyBlockName         = 'Имя блока не может быть пустым. Команда прервана.';
  RSBlockNameExists        =
    'Блок с именем "%s" уже существует в чертеже. Команда прервана.';
  RSCreateBlockCancelled   = 'Команда CreateBlockInsert отменена.';
  RSCreateBlockDone        = 'Блок "%s" создан (примитивов: %d).';

const
  CommandName = 'CreateBlockInsert';

{
  Асинхронно запускаемая команда Insert.
  Вызывается через Application.QueueAsyncCall после завершения текущей команды,
  иначе commandmanager.executecommand откажется запускать команду в состоянии
  isBusy.
  QueueAsyncCall требует метод объекта (of object), поэтому используется
  вспомогательный класс TAsyncInsertRunner.
}

{
  Вспомогательный класс для асинхронного запуска команды Insert.
  Метод RunInsert соответствует сигнатуре, ожидаемой QueueAsyncCall.
}
type
  TAsyncInsertRunner = class
    BlockName: string;
    // Запускает команду Insert с сохранённым именем блока.
    procedure RunInsert(Data: PtrInt);
  end;

procedure TAsyncInsertRunner.RunInsert(Data: PtrInt);
var
  cmdStr: string;
begin
  if BlockName = '' then
    Exit;
  cmdStr := 'Insert(' + BlockName + ')';
  BlockName := '';
  commandmanager.executecommand(
    cmdStr,
    drawings.GetCurrentDWG,
    drawings.GetCurrentOGLWParam
  );
end;

var
  AsyncInsertRunner: TAsyncInsertRunner;

{
  Подсчитывает количество выделенных примитивов в текущем чертеже.
}
function CountSelectedEntities: Integer;
var
  pobj: PGDBObjEntity;
  ir: itrec;
begin
  Result := 0;
  pobj := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj <> nil then
    repeat
      if pobj^.selected then
        Inc(Result);
      pobj := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pobj = nil;
end;

{
  Копирует все выделенные примитивы в новый BlockDef со смещением
  относительно базовой точки.
  Возвращает количество добавленных в блок примитивов.
}
function CopySelectedEntitiesIntoBlock(
  pBlockDef: PGDBObjBlockdef;
  const basePoint: TzePoint3d
): Integer;
var
  pobj, pclone: PGDBObjEntity;
  ir: itrec;
  shiftMatrix: TzeTypedMatrix4d;
  dc: TDrawContext;
begin
  Result := 0;
  shiftMatrix := CreateTranslationMatrix(NulVertex);
  dc := drawings.GetCurrentDWG^.CreateDrawingRC;
  Exclude(dc.Options, DCODrawable);

  pobj := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj <> nil then
    repeat
      if pobj^.selected then begin
        pclone := pobj^.Clone(pBlockDef);
        if pclone <> nil then begin
          pclone^.correctobjects(pBlockDef, pBlockDef^.ObjArray.Count);
          if pclone^.IsHaveLCS then
            PGDBObjWithLocalCS(pclone)^.CalcObjMatrix;
          pclone^.transform(shiftMatrix);
          pclone^.BuildGeometry(drawings.GetCurrentDWG^);
          pclone^.FormatEntity(drawings.GetCurrentDWG^, dc);
          pBlockDef^.ObjArray.AddPEntity(pclone^);
          Inc(Result);
        end;
      end;
      pobj := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pobj = nil;
end;

{
  Создаёт новый BlockDef с указанным именем и базовой точкой,
  наполняет его копиями выделенных примитивов.
  Возвращает указатель на созданный BlockDef или nil при ошибке.
}
function BuildNewBlockDef(
  const blockName: string;
  const basePoint: TzePoint3d;
  out entitiesAdded: Integer
): PGDBObjBlockdef;
var
  dc: TDrawContext;
begin
  entitiesAdded := 0;
  Result := drawings.GetCurrentDWG^.BlockDefArray.create(blockName);
  if Result = nil then
    Exit;
  Result^.VarFromFile := '';
  Result^.Base := basePoint;

  entitiesAdded := CopySelectedEntitiesIntoBlock(Result, basePoint);

  dc := drawings.GetCurrentDWG^.CreateDrawingRC;
  Result^.FormatEntity(drawings.GetCurrentDWG^, dc);
end;

{
  Точка входа команды CreateBlockInsert.
}
function CreateBlockInsert_com(
  const Context: TZCADCommandContext;
  Operands: TCommandOperands
): TCommandResult;
var
  selectedCount: Integer;
  basePoint: TzePoint3d;
  blockName: string;
  gr: TzcInteractiveResult;
  pBlockDef: PGDBObjBlockdef;
  addedCount: Integer;
begin
  Result := cmd_ok;
  programlog.LogOutFormatStr(
    'uzccommand_createblockinsert: команда CreateBlockInsert запущена',
    [], LM_Info
  );

  // Шаг 1: проверка наличия выделенных примитивов
  selectedCount := CountSelectedEntities;
  if selectedCount = 0 then begin
    zcUI.TextMessage(RSSelectEntsFirst, TMWOHistoryOut);
    programlog.LogOutFormatStr(
      'uzccommand_createblockinsert: нет выделенных примитивов, команда завершена',
      [], LM_Info
    );
    Result := cmd_error;
    Exit;
  end;
  zcUI.TextMessage(
    Format('CreateBlockInsert: выделено примитивов: %d', [selectedCount]),
    TMWOHistoryOut
  );

  // Шаг 2: запрос базовой точки
  commandmanager.ChangeInputMode([], [IPEmpty]);
  commandmanager.SetPrompt(RSCLPBasePoint);
  gr := commandmanager.Get3DPoint(RSCLPBasePoint, basePoint);
  if gr = IRCancel then begin
    zcUI.TextMessage(RSCreateBlockCancelled, TMWOHistoryOut);
    programlog.LogOutFormatStr(
      'uzccommand_createblockinsert: пользователь отменил ввод базовой точки',
      [], LM_Info
    );
    Result := cmd_error;
    Exit;
  end;
  zcUI.TextMessage(
    Format('CreateBlockInsert: базовая точка = (%.3f, %.3f, %.3f)',
      [basePoint.x, basePoint.y, basePoint.z]),
    TMWOHistoryOut
  );

  // Шаг 3: запрос имени блока
  commandmanager.ChangeInputMode([], [IPEmpty]);
  commandmanager.SetPrompt(RSCLPBlockName);
  gr := commandmanager.GetInput(RSCLPBlockName, blockName);
  if gr = IRCancel then begin
    zcUI.TextMessage(RSCreateBlockCancelled, TMWOHistoryOut);
    programlog.LogOutFormatStr(
      'uzccommand_createblockinsert: пользователь отменил ввод имени блока',
      [], LM_Info
    );
    Result := cmd_error;
    Exit;
  end;
  blockName := Trim(blockName);
  if blockName = '' then begin
    zcUI.TextMessage(RSEmptyBlockName, TMWOHistoryOut);
    programlog.LogOutFormatStr(
      'uzccommand_createblockinsert: пустое имя блока, команда прервана',
      [], LM_Info
    );
    Result := cmd_error;
    Exit;
  end;
  if drawings.GetCurrentDWG^.BlockDefArray.getblockdef(blockName) <> nil then begin
    zcUI.TextMessage(Format(RSBlockNameExists, [blockName]), TMWOHistoryOut);
    programlog.LogOutFormatStr(
      'uzccommand_createblockinsert: блок "%s" уже существует, команда прервана',
      [blockName], LM_Info
    );
    Result := cmd_error;
    Exit;
  end;

  // Шаг 4: создание BlockDef и наполнение его копиями выделенных примитивов
  pBlockDef := BuildNewBlockDef(blockName, basePoint, addedCount);
  if (pBlockDef = nil) or (addedCount = 0) then begin
    zcUI.TextMessage(
      'CreateBlockInsert: не удалось создать блок.',
      TMWOHistoryOut
    );
    programlog.LogOutFormatStr(
      'uzccommand_createblockinsert: ошибка создания блока "%s"',
      [blockName], LM_Info
    );
    Result := cmd_error;
    Exit;
  end;

  zcUI.TextMessage(Format(RSCreateBlockDone, [blockName, addedCount]),
    TMWOHistoryOut);
  programlog.LogOutFormatStr(
    'uzccommand_createblockinsert: блок "%s" создан, примитивов=%d',
    [blockName, addedCount], LM_Info
  );

  // Шаг 5: асинхронно запустить команду Insert с подставленным именем блока
  AsyncInsertRunner.BlockName := blockName;
  Application.QueueAsyncCall(AsyncInsertRunner.RunInsert, 0);
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsInitializeLMId);
  AsyncInsertRunner := TAsyncInsertRunner.Create;
  CreateZCADCommand(@CreateBlockInsert_com, CommandName, CADWG or CASelEnts, 0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsFinalizeLMId);
  FreeAndNil(AsyncInsertRunner);
end.
