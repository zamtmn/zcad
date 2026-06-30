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
@author(Vladimir Bobrov) <- Created using AI
}
{
  Модуль: uzccommand_scale2
  Назначение: Расширенная команда масштабирования объектов ZCAD (SCALE2).
  Поддерживаемые режимы:
    - Scale     — масштабирование по числовому коэффициенту
    - Reference — масштабирование по опорным точкам (как в AutoCAD)
    - Copy      — масштабирование с сохранением оригинала
  Архитектура команды реализована по образцу uzccommand_rotate.pas:
    - машина состояний (state machine)
    - пошаговый интерактивный ввод
    - обработка ключевых слов (Copy, Reference, Points)
  Зависимости:
    uzccommand_rotate       — образец архитектуры
    uzccommand_scale        — базовая математика масштабирования
    uzegeometry             — операции с матрицами и точками
    uzccommandsmanager      — менеджер команд
    uzeparsercmdprompt      — парсер подсказок командной строки
    uzcutils                — вспомогательные функции (CloneEnts и др.)
    uzclog                  — логирование
}
{$mode delphi}
unit uzccommand_scale2;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzbUnitsUtils,
  gzctnrVectorTypes,
  uzcLog,
  uzccommandsabstract,
  uzccommandsimpl,
  uzcstrconsts,
  uzegeometrytypes,
  uzccommandsmanager,
  uzeentity,
  uzcutils,
  uzeparsercmdprompt,
  uzegeometry,
  uzcinterface,
  uzcCommand_MoveEntsByMouse,
  uzgldrawcontext,
  uzcdrawings;

resourcestring
  // Подсказки командной строки
  RSCLPScale2BasePoint = 'Specify base point:';
  RSCLPScale2ScaleFactor =
    'Specify scale factor or [${"&[C]opy",Keys[c,m],StrId[CLPIdCopy]}, ' +
    '${"&[R]eference",Keys[r],StrId[CLPIdReference]}]';
  RSCLPScale2ScaleFactorMove =
    'Specify scale factor or [${"&[R]eference",Keys[r],StrId[CLPIdReference]}]';
  RSCLPScale2ReferenceLength =
    'Specify reference length or [${"&[P]oints",Keys[p],StrId[CLPIdUser]}]:';
  RSCLPScale2NewLength =
    'Specify new length or [${"&[P]oints",Keys[p],StrId[CLPIdUser]}]:';
  RSCLPScale2FirstRefPoint  = 'Specify first reference point:';
  RSCLPScale2SecondRefPoint = 'Specify second reference point:';
  RSCLPScale2FirstNewPoint  = 'Specify first new point:';
  RSCLPScale2SecondNewPoint = 'Specify second new point:';

implementation

// ---------------------------------------------------------------------------
//  Константы
// ---------------------------------------------------------------------------

const
  // Минимальный коэффициент масштаба (защита от нуля и отрицательных значений)
  SCALE2_MIN_FACTOR = 1e-10;

// ---------------------------------------------------------------------------
//  Вспомогательные процедуры
// ---------------------------------------------------------------------------

{
  PrintMessage
  Выводит строку в историю командной строки.
}
procedure PrintMessage(const Msg: string);
begin
  zcUI.TextMessage(Msg, TMWOHistoryOut);
end;

{
  PrintError
  Выводит сообщение об ошибке в командную строку.
}
procedure PrintError(const Msg: string);
begin
  zcUI.TextMessage(Msg, TMWOShowError);
end;

{
  LogMessage
  Выводит отладочное сообщение в историю командной строки.
  Используется для отладки команды SCALE2.
}
procedure LogMessage(const msg: string);
begin
  zcUI.TextMessage(msg, TMWOHistoryOut);
end;

{
  Point3DToStr
  Преобразует точку 3D в строку для отладочного вывода.
}
function Point3DToStr(const p: TzePoint3d): string;
begin
  Result := Format('X=%.6f, Y=%.6f, Z=%.6f', [p.x, p.y, p.z]);
end;

// ---------------------------------------------------------------------------
//  Математика масштабирования
// ---------------------------------------------------------------------------

{
  CalcScaleMatrix
  Формирует матрицу масштабирования относительно базовой точки.
  Параметры:
    basePoint   — базовая точка, относительно которой выполняется масштаб
    scaleFactor — коэффициент масштабирования (должен быть > 0)
  Возвращает матрицу трансформации: T(-base) * Scale(k) * T(base)
}
function CalcScaleMatrix(
  const basePoint: TzePoint3d;
  const scaleFactor: double
): TzeTypedMatrix4d;
var
  translateToOrigin: TzeTypedMatrix4d;
  scaleMatrix:       TzeTypedMatrix4d;
  translateBack:     TzeTypedMatrix4d;
  resultMatrix:      TzeTypedMatrix4d;
begin
  //LogMessage('');
  //LogMessage('[SCALE2 DEBUG] CalcScaleMatrix:');
  //LogMessage('  BasePoint: ' + Point3DToStr(basePoint));
  //LogMessage('  ScaleFactor: ' + FloatToStrF(scaleFactor, ffFixed, 15, 6));

  // Переносим в начало координат, масштабируем, переносим обратно
  translateToOrigin := uzegeometry.CreateTranslationMatrix(-basePoint);
  scaleMatrix       := CreateScaleMatrix(scaleFactor);
  translateBack     := uzegeometry.CreateTranslationMatrix(basePoint);

  resultMatrix := uzegeometry.MatrixMultiply(translateToOrigin, scaleMatrix);
  resultMatrix := uzegeometry.MatrixMultiply(resultMatrix, translateBack);

  Result := resultMatrix;

  //LogMessage('  Matrix created successfully');
end;

{
  CalcReferenceScaleFactor
  Вычисляет коэффициент масштаба из двух длин (Reference-режим).
  Формула: scale = newLength / referenceLength
  Параметры:
    referenceLength — исходная длина (опорное расстояние)
    newLength       — новая длина
  Возвращает коэффициент масштаба или 1.0 при ошибке (деление на ноль).
}
function CalcReferenceScaleFactor(
  const referenceLength, newLength: double
): double;
begin
  //LogMessage('');
  //LogMessage('[SCALE2 DEBUG] CalcReferenceScaleFactor:');
  //LogMessage('  ReferenceLength: ' + FloatToStrF(referenceLength, ffFixed, 15, 6));
  //LogMessage('  NewLength: ' + FloatToStrF(newLength, ffFixed, 15, 6));

  if referenceLength < SCALE2_MIN_FACTOR then begin
    LogMessage('  ERROR: Reference length is too small or zero!');
    PrintError('Reference length is too small or zero, scale not applied.');
    Result := 1.0;
    Exit;
  end;

  Result := newLength / referenceLength;

  //LogMessage('  Calculated ScaleFactor: ' + FloatToStrF(Result, ffFixed, 15, 6));

  //programlog.LogOutFormatStr(
  //  'uzccommand_scale2: refLen=%.6f newLen=%.6f scale=%.6f',
  //  [referenceLength, newLength, Result],
  //  LM_Info
  //);
end;

// ---------------------------------------------------------------------------
//  Применение трансформации к объектам
// ---------------------------------------------------------------------------

{
  ApplyScaleTransform
  Применяет матрицу масштабирования к выбранным объектам чертежа.
  При copyMode=True — перемещает объекты из ConstructRoot в чертёж (копия).
  При copyMode=False — трансформирует оригинальные объекты с записью в Undo.
  Параметры:
    scaleMatrix — матрица трансформации
    copyMode    — True: оставить оригиналы, False: трансформировать оригиналы
}
procedure ApplyScaleTransform(
  const scaleMatrix: TzeTypedMatrix4d;
  const copyMode: boolean
);
var
  p:  PGDBObjEntity;
  ir: itrec;
  dc: TDrawContext;
begin
  //LogMessage('');
  //LogMessage('[SCALE2 DEBUG] ApplyScaleTransform:');
  //LogMessage('  CopyMode: ' + BoolToStr(copyMode, True));

  dc := drawings.GetCurrentDWG^.CreateDrawingRC;

  if copyMode then begin
    LogMessage('  Mode: COPY - cloning objects to ConstructRoot');
    // Копирование: применяем матрицу к клонам в ConstructRoot, затем
    // переносим их в основное пространство модели
    drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix := OneMatrix;
    p := drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.beginiterate(ir);
    if p <> nil then
      repeat
        p^.transform(scaleMatrix);
        p := drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.iterate(ir);
      until p = nil;

    zcMoveEntsFromConstructRootToCurrentDrawingWithUndo('Scale2[Copy]');

    //LogMessage('  Copy operation completed');
    //programlog.LogOutFormatStr(
    //  'uzccommand_scale2: копирование завершено', [], LM_Info
    //);
  end else begin
    //LogMessage('  Mode: MOVE - transforming original objects');
    // Перемещение: очищаем ConstructRoot, трансформируем оригиналы
    drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix := OneMatrix;
    zcFreeEntsInCurrentDrawingConstructRoot;
    zcTransformSelectedEntsInDrawingWithUndo('Scale2', scaleMatrix);

    drawings.GetCurrentROOT^.FormatAfterEdit(drawings.GetCurrentDWG^, dc);

    //LogMessage('  Transform operation completed');
    //programlog.LogOutFormatStr(
    //  'uzccommand_scale2: трансформация оригиналов завершена', [], LM_Info
    //);
  end;
end;

// ---------------------------------------------------------------------------
//  Основная функция команды SCALE2
// ---------------------------------------------------------------------------

{
  Scale2_com
  Реализует интерактивную команду SCALE2 с поддержкой трёх режимов:
    1. Scale     — по числовому коэффициенту
    2. Reference — по двум расстояниям или парам точек
    3. Copy      — с сохранением оригинала

  Состояния (state machine):
    SCMWaitBasePoint   — ожидание базовой точки
    SCMWaitScaleFactor — ожидание числа или ключевого слова
    SCMWaitRef0        — первая точка опорного расстояния
    SCMWaitRef1        — вторая точка опорного расстояния
    SCMWaitNew0        — ожидание новой длины (число или точка от базовой)
    SCMWaitNew1        — первая точка нового расстояния (режим Points)
    SCMWaitNew2        — вторая точка нового расстояния
}
function Scale2_com(
  const Context: TZCADCommandContext;
  Operands: TCommandOperands
): TCommandResult;
type
  TScale2CmdMode = (
    SCMWaitBasePoint,
    SCMWaitScaleFactor,
    SCMWaitRef0,
    SCMWaitRef1,
    SCMWaitNew0,
    SCMWaitNew1,
    SCMWaitNew2
  );
var
  BasePnt:         TzePoint3d;
  InputPnt:        TzePoint3d;
  Ref0Pnt, Ref1Pnt: TzePoint3d;  // Точки для опорного расстояния
  New0Pnt, New1Pnt: TzePoint3d;  // Точки для нового расстояния
  CmdMode:         TScale2CmdMode;
  CopyMode:        boolean;       // True — режим копирования (оригинал сохраняется)
  ReferenceMode:   boolean;       // True — режим Reference (масштаб по точкам)
  RefLength:       double;        // Опорная длина в режиме Reference
  NewLength:       double;        // Новая длина в режиме Reference
  ScaleFactor:     double;        // Итоговый коэффициент масштаба
  scaleMatrix:     TzeTypedMatrix4d;
  gr:              TzcInteractiveResult;

  clBasePoint:     CMDLinePromptParser.TGeneralParsedText;
  clScaleFactor:   CMDLinePromptParser.TGeneralParsedText;
  clScaleFactorMove: CMDLinePromptParser.TGeneralParsedText;
  clReferenceLength: CMDLinePromptParser.TGeneralParsedText;
  clNewLength:     CMDLinePromptParser.TGeneralParsedText;

  {
    SetMode
    Переключает состояние машины и устанавливает подсказку командной строки.
  }
  procedure SetMode(ANewMode: TScale2CmdMode; const AForce: boolean = False);
  begin
    if not AForce then
      if CmdMode = ANewMode then
        Exit;

    case ANewMode of
      SCMWaitBasePoint: begin
        if clBasePoint = nil then
          clBasePoint := CMDLinePromptParser.GetTokens(RSCLPScale2BasePoint);
        commandmanager.SetPrompt(clBasePoint);
        commandmanager.ChangeInputMode([IPEmpty], []);
      end;

      SCMWaitScaleFactor: begin
        // Подсказка зависит от режима Copy (Move/Copy)
        if CopyMode then begin
          if clScaleFactorMove = nil then
            clScaleFactorMove :=
              CMDLinePromptParser.GetTokens(RSCLPScale2ScaleFactorMove);
          commandmanager.SetPrompt(clScaleFactorMove);
        end else begin
          if clScaleFactor = nil then
            clScaleFactor :=
              CMDLinePromptParser.GetTokens(RSCLPScale2ScaleFactor);
          commandmanager.SetPrompt(clScaleFactor);
        end;
        commandmanager.ChangeInputMode([IPEmpty], []);
      end;

      SCMWaitRef0: begin
        commandmanager.SetPrompt(RSCLPScale2FirstRefPoint);
        commandmanager.ChangeInputMode([IPEmpty], []);
      end;

      SCMWaitRef1: begin
        commandmanager.SetPrompt(RSCLPScale2SecondRefPoint);
        commandmanager.ChangeInputMode([IPEmpty], []);
      end;

      SCMWaitNew0: begin
        if clNewLength = nil then
          clNewLength := CMDLinePromptParser.GetTokens(RSCLPScale2NewLength);
        commandmanager.SetPrompt(clNewLength);
        commandmanager.ChangeInputMode([IPEmpty], []);
      end;

      SCMWaitNew1: begin
        commandmanager.SetPrompt(RSCLPScale2FirstNewPoint);
        commandmanager.ChangeInputMode([IPEmpty], []);
      end;

      SCMWaitNew2: begin
        commandmanager.SetPrompt(RSCLPScale2SecondNewPoint);
        commandmanager.ChangeInputMode([IPEmpty], []);
      end;
    end;

    CmdMode := ANewMode;
  end;

  {
    DoApplyScale
    Вычисляет матрицу и применяет масштабирование.
    После применения клонирует объекты для следующей итерации (Copy-режим).
  }
  procedure DoApplyScale(const Factor: double);
  begin
    //LogMessage('');
    //LogMessage('[SCALE2 DEBUG] DoApplyScale:');
    //LogMessage('  Factor: ' + FloatToStrF(Factor, ffFixed, 15, 6));
    //LogMessage('  CopyMode: ' + BoolToStr(CopyMode, True));

    //programlog.LogOutFormatStr(
    //  'uzccommand_scale2: применяем scale=%.6f copyMode=%d',
    //  [Factor, Ord(CopyMode)],
    //  LM_Info
    //);

    scaleMatrix := CalcScaleMatrix(BasePnt, Factor);
    ApplyScaleTransform(scaleMatrix, CopyMode);

    if CopyMode then begin
      // Клонируем снова для возможности повторного масштабирования
      //LogMessage('  CopyMode enabled: cloning objects for next iteration');
      CloneEnts;
      zcRedrawCurrentDrawing;
      SetMode(SCMWaitScaleFactor, True);
    end;
  end;

begin
  Result := cmd_ok;

  // Инициализация локальных переменных
  CopyMode      := False;
  ReferenceMode := False;
  RefLength     := 0.0;
  NewLength     := 0.0;
  ScaleFactor   := 1.0;

  clBasePoint      := nil;
  clScaleFactor    := nil;
  clScaleFactorMove := nil;
  clReferenceLength := nil;
  clNewLength      := nil;

  //LogMessage('');
  LogMessage('========================================');
  LogMessage('[SCALE2] ЗАПУСК КОМАНДЫ SCALE2');
  //LogMessage('========================================');

  programlog.LogOutFormatStr(
    'uzccommand_scale2: запуск команды SCALE2', [], LM_Info
  );

  // Проверяем наличие выбранных объектов
  if CloneEnts = 0 then begin
    //LogMessage('[SCALE2 DEBUG] Нет выбранных объектов');
    PrintMessage(rscmSelEntBeforeComm);
    programlog.LogOutFormatStr(
      'uzccommand_scale2: нет выбранных объектов, команда завершена',
      [],
      LM_Info
    );
    Result := cmd_ok;
    Exit;
  end;

  //LogMessage('[SCALE2 DEBUG] Объекты клонированы для работы');

  SetMode(SCMWaitBasePoint, True);

  repeat
    // Получаем ввод пользователя в зависимости от текущего состояния
    //LogMessage('');
    //LogMessage('[SCALE2 DEBUG] Текущее состояние: ' + Ord(CmdMode).ToString);
    case CmdMode of
      SCMWaitBasePoint:
        begin
          //LogMessage('[SCALE2 DEBUG] Ожидание базовой точки');
          gr := commandmanager.Get3DPoint('', InputPnt);
        end;
      SCMWaitScaleFactor:
        begin
          //LogMessage('[SCALE2 DEBUG] Ожидание коэффициента масштабирования или точки');
          gr := commandmanager.Get3DPoint('', InputPnt);
        end;
      SCMWaitRef0:
        begin
          //LogMessage('[SCALE2 DEBUG] Ожидание первой опорной точки');
          gr := commandmanager.Get3DPoint('', InputPnt);
        end;
      SCMWaitRef1:
        begin
          //LogMessage('[SCALE2 DEBUG] Ожидание второй опорной точки');
          gr := commandmanager.Get3DPointWithLineFromBase('', Ref0Pnt, InputPnt);
        end;
      SCMWaitNew0:
        begin
          //LogMessage('[SCALE2 DEBUG] Ожидание новой длины (число или точка)');
          gr := commandmanager.Get3DPoint('', InputPnt);
        end;
      SCMWaitNew1:
        begin
          //LogMessage('[SCALE2 DEBUG] Ожидание первой точки новой длины');
          gr := commandmanager.Get3DPoint('', InputPnt);
        end;
      SCMWaitNew2:
        begin
          //LogMessage('[SCALE2 DEBUG] Ожидание второй точки новой длины');
          gr := commandmanager.Get3DPointWithLineFromBase('', New0Pnt, InputPnt);
        end;
    else
      gr := commandmanager.Get3DPoint('', InputPnt);
    end;

    case gr of
      // --- Пользователь указал точку ---
      IRNormal:
        begin
          //LogMessage('[SCALE2 DEBUG] IRNormal: пользователь указал точку');
          //LogMessage('  InputPoint: ' + Point3DToStr(InputPnt));
          case CmdMode of
            SCMWaitBasePoint: begin
              BasePnt := InputPnt;
              LogMessage('[SCALE2] Базовая точка установлена: ' + Point3DToStr(BasePnt));
              programlog.LogOutFormatStr(
                'uzccommand_scale2: базовая точка (%.3f, %.3f, %.3f)',
                [BasePnt.x, BasePnt.y, BasePnt.z],
                LM_Info
              );
              SetMode(SCMWaitScaleFactor);
            end;

            SCMWaitScaleFactor: begin
              // В режиме ввода точки — вычисляем коэффициент по расстоянию
              // от базовой точки до указанной
              ScaleFactor := uzegeometry.Vertexlength(BasePnt, InputPnt);
              LogMessage('[SCALE2] Расстояние от базовой точки до указанной: ' + FloatToStrF(ScaleFactor, ffFixed, 15, 6));
              if ScaleFactor < SCALE2_MIN_FACTOR then begin
                LogMessage('[SCALE2] Расстояние слишком мало, используем коэффициент 1.0');
                ScaleFactor := 1.0;
              end;

              programlog.LogOutFormatStr(
                'uzccommand_scale2: коэффициент по точке = %.6f',
                [ScaleFactor],
                LM_Info
              );
              DoApplyScale(ScaleFactor);
              if not CopyMode then
                Break;
            end;

            SCMWaitRef0: begin
              Ref0Pnt := InputPnt;
              LogMessage('[SCALE2] Первая опорная точка: ' + Point3DToStr(Ref0Pnt));
              SetMode(SCMWaitRef1);
            end;

            SCMWaitRef1: begin
              Ref1Pnt := InputPnt;
              RefLength := uzegeometry.Vertexlength(Ref0Pnt, Ref1Pnt);
              LogMessage('[SCALE2] Вторая опорная точка: ' + Point3DToStr(Ref1Pnt));
              LogMessage('[SCALE2] Опорная длина: ' + FloatToStrF(RefLength, ffFixed, 15, 6));
              programlog.LogOutFormatStr(
                'uzccommand_scale2: опорная длина по точкам = %.6f',
                [RefLength],
                LM_Info
              );
              SetMode(SCMWaitNew0);
            end;

            SCMWaitNew0: begin
              // Пользователь указал точку — вычисляем новую длину как расстояние
              // от базовой точки до указанной точки
              NewLength := uzegeometry.Vertexlength(BasePnt, InputPnt);
              LogMessage('[SCALE2] Новая длина по точке от базовой точки: ' + FloatToStrF(NewLength, ffFixed, 15, 6));
              programlog.LogOutFormatStr(
                'uzccommand_scale2: новая длина по точке = %.6f',
                [NewLength],
                LM_Info
              );
              ScaleFactor := CalcReferenceScaleFactor(RefLength, NewLength);
              DoApplyScale(ScaleFactor);
              if not CopyMode then
                Break;
              SetMode(SCMWaitBasePoint, True);
            end;

            SCMWaitNew1: begin
              // Пользователь указал первую точку новой длины (режим Points)
              New0Pnt := InputPnt;
              LogMessage('[SCALE2] Первая точка новой длины: ' + Point3DToStr(New0Pnt));
              SetMode(SCMWaitNew2);
            end;

            SCMWaitNew2: begin
              // Пользователь указал вторую точку новой длины
              New1Pnt := InputPnt;
              NewLength := uzegeometry.Vertexlength(New0Pnt, New1Pnt);
              LogMessage('[SCALE2] Вторая точка новой длины: ' + Point3DToStr(New1Pnt));
              LogMessage('[SCALE2] Новая длина: ' + FloatToStrF(NewLength, ffFixed, 15, 6));
              ScaleFactor := CalcReferenceScaleFactor(RefLength, NewLength);
              DoApplyScale(ScaleFactor);
              if not CopyMode then
                Break;
              SetMode(SCMWaitBasePoint, True);
            end;
          end;
        end;

      // --- Пользователь ввёл текст (число или ключевое слово) ---
      IRInput:
        begin
          LogMessage('[SCALE2] Пользователь ввёл текст');
          //LogMessage('  InputText: ' + commandmanager.GetLastInput);
          case CmdMode of
            SCMWaitScaleFactor: begin
              // Пытаемся разобрать введённое число как коэффициент
              if TryStrToFloat(
                  StringReplace(commandmanager.GetLastInput, ',', '.', []),
                  ScaleFactor) then begin
                LogMessage('[SCALE2] Распознан коэффициент масштабирования: ' + FloatToStrF(ScaleFactor, ffFixed, 15, 6));
                if ScaleFactor < SCALE2_MIN_FACTOR then begin
                  LogMessage('[SCALE2] Коэффициент слишком мал, ошибка');
                  PrintError('Scale factor must be greater than zero.');
                end else begin
                  DoApplyScale(ScaleFactor);
                  if not CopyMode then
                    Break;
                end;
              end else begin
                LogMessage('[SCALE2] Не удалось распознать коэффициент');
                PrintError('Please enter a valid scale factor.');
              end;
            end;

            SCMWaitRef0, SCMWaitNew0: begin
              // Пользователь вводит число вместо точек — используем как длину
              if TryStrToFloat(
                  StringReplace(commandmanager.GetLastInput, ',', '.', []),
                  RefLength) then begin
                if CmdMode = SCMWaitRef0 then begin
                  LogMessage('[SCALE2] Распознана опорная длина (число): ' + FloatToStrF(RefLength, ffFixed, 15, 6));
                  programlog.LogOutFormatStr(
                    'uzccommand_scale2: опорная длина введена числом = %.6f',
                    [RefLength],
                    LM_Info
                  );
                  SetMode(SCMWaitNew0);
                end else begin
                  // SCMWaitNew0: пользователь ввёл число как новую длину
                  NewLength   := RefLength;
                  LogMessage('[SCALE2] Распознана новая длина (число): ' + FloatToStrF(NewLength, ffFixed, 15, 6));
                  ScaleFactor := CalcReferenceScaleFactor(
                    uzegeometry.Vertexlength(Ref0Pnt, Ref1Pnt),
                    NewLength
                  );
                  DoApplyScale(ScaleFactor);
                  if not CopyMode then
                    Break;
                  SetMode(SCMWaitBasePoint, True);
                end;
              end else begin
                LogMessage('[SCALE2] Не удалось распознать длину');
                PrintError('Please enter a valid length.');
              end;
            end;

          else
            LogMessage('[SCALE2] Неожиданный ввод в текущем состоянии');
            PrintError('Try use mouse Luke?');
          end;
        end;

      // --- Пользователь выбрал ключевое слово ---
      IRId:
        begin
          //LogMessage('[SCALE2] IRId: пользователь выбрал ключевое слово');
          //LogMessage('  KeyWord ID: ' + IntToStr(commandmanager.GetLastId));
          case commandmanager.GetLastId of
            CLPIdCopy: begin
              // Переключаем режим: Copy <-> Move
              CopyMode := not CopyMode;
              LogMessage('[SCALE2] Переключение CopyMode: ' + BoolToStr(CopyMode, True));
              if CopyMode then
                PrintMessage('Objects will be copied during scaling.')
              else
                PrintMessage('Scaling mode: move (original will be changed).');
              SetMode(CmdMode, True);
            end;

            CLPIdReference: begin
              // Переключаемся в режим Reference
              LogMessage('[SCALE2] Переключение в режим Reference');
              ReferenceMode := True;
              SetMode(SCMWaitRef0);
            end;

            CLPIdUser: begin
              // Ключевое слово "Points" — переходим к вводу точек
              //LogMessage('[SCALE2 DEBUG] Ключевое слово Points (CLPIdUser)');
              if CmdMode = SCMWaitNew0 then begin
                LogMessage('[SCALE2] Переход к вводу точек для новой длины');
                SetMode(SCMWaitNew1);
              end else if CmdMode = SCMWaitRef0 then begin
                LogMessage('[SCALE2] Переход к вводу точек для опорной длины');
                SetMode(SCMWaitRef0, True);
              end;
            end;
          else
            LogMessage('[SCALE2] Неизвестное ключевое слово');
          end;
        end;
    end;

  until gr = IRCancel;

  LogMessage('');
  LogMessage('[SCALE2] Команда завершена');
  LogMessage('========================================');

  // Освобождаем кэш разобранных подсказок
  clBasePoint.Free;
  clScaleFactor.Free;
  clScaleFactorMove.Free;
  clReferenceLength.Free;
  clNewLength.Free;

  programlog.LogOutFormatStr(
    'uzccommand_scale2: команда завершена', [], LM_Info
  );
end;

// ---------------------------------------------------------------------------
//  Инициализация и финализация модуля
// ---------------------------------------------------------------------------

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',
    [{$INCLUDE %FILE%}], LM_Info, UnitsInitializeLMId);
  // Регистрируем расширенную команду масштабирования
  CreateZCADCommand(@Scale2_com, 'Scale2', CADWG, 0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',
    [{$INCLUDE %FILE%}], LM_Info, UnitsFinalizeLMId);
end.
