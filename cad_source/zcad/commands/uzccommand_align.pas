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
{$mode delphi}

unit uzccommand_align;
{$INCLUDE zengineconfig.inc}

interface

uses
  Math,
  SysUtils,
  gzctnrVectorTypes,
  uzcdrawing,
  uzgldrawcontext,
  uzcdrawings,
  uzeutils,
  uzglviewareadata,
  uzccommand_move,
  uzccommandsabstract,
  uzccommandsimpl,
  uzccommandsmanager,
  uzcinterface,
  uzcstrconsts,
  uzegeometry,
  uzeparsercmdprompt,
  zcmultiobjectchangeundocommand,
  uzegeometrytypes,
  uzeentity,
  uzcLog;

resourcestring
  // Подсказки командной строки для каждого шага диалога
  RSCLPAlignSrc1       = 'Укажите первую исходную точку:';
  RSCLPAlignDst1       = 'Укажите первую целевую точку:';
  RSCLPAlignSrc2       = 'Укажите вторую исходную точку:';
  RSCLPAlignDst2       = 'Укажите вторую целевую точку:';
  // Интерактивный запрос третьей точки с кнопкой [Enter] для пропуска
  RSCLPAlignSrc3       = 'Укажите третью исходную точку или ${"[Отменить]",Keys[VK_RETURN],StrId[CLPIdUser1]}:';
  RSCLPAlignDst3       = 'Укажите третью целевую точку:';
  // Интерактивное меню выбора масштабирования с клавишами [Y] и [N]
  RSCLPAlignScaleYesNo =
    'Масштабировать объекты по точкам выравнивания? [${"&[Y]es",Keys[y],StrId[CLPIdUser1]}, ${"&[N]o",Keys[n],StrId[CLPIdUser2]}] <No>:';

{ Команда ALIGN — функция-обработчик, регистрируемая в менеджере команд }
function AlignCommand(
  const Context: TZCADCommandContext;
  Operands: TCommandOperands
): TCommandResult;

implementation

const
  // Минимальное расстояние для корректного вычисления угла и масштаба
  ALIGN_MIN_DISTANCE = 1e-10;

var
  // Кэш разобранной строки меню масштабирования (инициализируется при первом вызове)
  clScaleYesNo: CMDLinePromptParser.TGeneralParsedText = nil;
  // Кэш разобранной строки запроса третьей точки (инициализируется при первом вызове)
  clSrc3: CMDLinePromptParser.TGeneralParsedText = nil;

{ --- Вычисление матрицы трансформации ALIGN --- }

{
  Calc3DRotationMatrix
  Вычисляет матрицу 3D-поворота, которая совмещает вектор srcVec с вектором dstVec.

  Использует формулу Родригеса для поворота вокруг произвольной оси.
  Матрица строится в строчно-мажорном порядке (v' = v * M), как принято в ZCAD.

  Особые случаи:
    - Векторы параллельны (угол ≈ 0°): возвращается единичная матрица.
    - Векторы антипараллельны (угол ≈ 180°): поворот на 180° вокруг
      произвольной оси, перпендикулярной srcVec.

  Параметры:
    srcVec — нормализованный исходный вектор
    dstVec — нормализованный целевой вектор
}
function Calc3DRotationMatrix(
  const srcVec, dstVec: TzePoint3d
): TzeTypedMatrix4d;
var
  // Скалярное произведение (косинус угла между векторами)
  cosAngle: double;
  // Синус угла через длину векторного произведения
  sinAngle: double;
  // Ось вращения = нормализованное векторное произведение srcVec × dstVec
  rotAxis: TzePoint3d;
  axisLen: double;
  // Компоненты оси вращения
  kx, ky, kz: double;
  // Вспомогательные переменные для формулы Родригеса
  c1: double;
  // Перпендикулярная ось для случая антипараллельных векторов
  perpAxis: TzePoint3d;
  m: TzeTypedMatrix4d;
begin
  // Вычисляем скалярное произведение вручную (cos угла между нормализованными векторами)
  cosAngle := srcVec.x * dstVec.x + srcVec.y * dstVec.y + srcVec.z * dstVec.z;

  // Ограничиваем диапазон для защиты от ошибок округления в ArcCos
  if cosAngle > 1.0 then cosAngle := 1.0
  else if cosAngle < -1.0 then cosAngle := -1.0;

  // Векторное произведение srcVec × dstVec даёт ось вращения
  // VectorDot в uzegeometry — это векторное (крестовое) произведение
  rotAxis := uzegeometry.VectorDot(srcVec, dstVec);
  axisLen := Sqrt(rotAxis.x * rotAxis.x + rotAxis.y * rotAxis.y + rotAxis.z * rotAxis.z);

  // Частный случай: векторы практически параллельны — поворот не нужен
  if axisLen < ALIGN_MIN_DISTANCE then begin
    if cosAngle > 0 then begin
      // Угол ≈ 0°: возвращаем единичную матрицу
      Result := onematrix;
      Exit;
    end;
    // Угол ≈ 180°: выбираем произвольную перпендикулярную ось
    // Выбираем ось, наименее параллельную srcVec
    if Abs(srcVec.x) <= Abs(srcVec.y) then
      perpAxis := uzegeometry.CreateVertex(1, 0, 0)
    else
      perpAxis := uzegeometry.CreateVertex(0, 1, 0);
    // Ось = normalize(srcVec × perpAxis)
    rotAxis := uzegeometry.VectorDot(srcVec, perpAxis);
    axisLen := Sqrt(rotAxis.x * rotAxis.x + rotAxis.y * rotAxis.y + rotAxis.z * rotAxis.z);
    if axisLen < ALIGN_MIN_DISTANCE then begin
      Result := onematrix;
      Exit;
    end;
    rotAxis.x := rotAxis.x / axisLen;
    rotAxis.y := rotAxis.y / axisLen;
    rotAxis.z := rotAxis.z / axisLen;
    // Поворот на 180°: cos(π)=-1, sin(π)=0
    kx := rotAxis.x; ky := rotAxis.y; kz := rotAxis.z;
    m := onematrix;
    m.mtr.v[0].v[0] := 2.0 * kx * kx - 1.0;
    m.mtr.v[0].v[1] := 2.0 * kx * ky;
    m.mtr.v[0].v[2] := 2.0 * kx * kz;
    m.mtr.v[1].v[0] := 2.0 * ky * kx;
    m.mtr.v[1].v[1] := 2.0 * ky * ky - 1.0;
    m.mtr.v[1].v[2] := 2.0 * ky * kz;
    m.mtr.v[2].v[0] := 2.0 * kz * kx;
    m.mtr.v[2].v[1] := 2.0 * kz * ky;
    m.mtr.v[2].v[2] := 2.0 * kz * kz - 1.0;
    Result := m;
    Exit;
  end;

  // Нормализуем ось вращения
  rotAxis.x := rotAxis.x / axisLen;
  rotAxis.y := rotAxis.y / axisLen;
  rotAxis.z := rotAxis.z / axisLen;

  kx := rotAxis.x;
  ky := rotAxis.y;
  kz := rotAxis.z;

  sinAngle := axisLen; // |srcVec × dstVec| = sin(угол) для нормализованных векторов
  // Ограничиваем sinAngle на случай ошибки округления
  if sinAngle > 1.0 then sinAngle := 1.0;

  // Коэффициент (1 - cos θ) для формулы Родригеса
  c1 := 1.0 - cosAngle;

  // Строим матрицу Родригеса в строчно-мажорном порядке ZCAD (v' = v * M).
  // Строки матрицы — это новые образы базисных векторов X, Y, Z.
  // R[i][j] = δ(i,j)*c + ki*kj*(1-c) + ε(i,k,j)*kk*s
  m := onematrix;
  m.mtr.v[0].v[0] := cosAngle + kx * kx * c1;
  m.mtr.v[0].v[1] := kx * ky * c1 + kz * sinAngle;
  m.mtr.v[0].v[2] := kx * kz * c1 - ky * sinAngle;
  m.mtr.v[1].v[0] := kx * ky * c1 - kz * sinAngle;
  m.mtr.v[1].v[1] := cosAngle + ky * ky * c1;
  m.mtr.v[1].v[2] := ky * kz * c1 + kx * sinAngle;
  m.mtr.v[2].v[0] := kx * kz * c1 + ky * sinAngle;
  m.mtr.v[2].v[1] := ky * kz * c1 - kx * sinAngle;
  m.mtr.v[2].v[2] := cosAngle + kz * kz * c1;

  Result := m;
end;

{
  CalcAlignMatrix
  Вычисляет матрицу трансформации по двум парам точек.

  Алгоритм:
    1. Трансляция: смещение так, чтобы srcPoint1 совпал с dstPoint1.
    2. Поворот вокруг dstPoint1: направление src1->src2 совмещается с dst1->dst2
       в трёхмерном пространстве (использует формулу Родригеса).
    3. Масштабирование (если applyScale = True):
       коэффициент = |dst1-dst2| / |src1-src2|.

  При нулевом расстоянии между точками поворот и масштабирование пропускаются.
}
function CalcAlignMatrix(
  const srcPoint1, dstPoint1: TzePoint3d;
  const srcPoint2, dstPoint2: TzePoint3d;
  const applyScale: boolean
): TzeTypedMatrix4d;
var
  srcLen, dstLen, scaleValue: double;
  srcVec, dstVec: TzePoint3d;
  rotationMatrix, scaleMatrix: TzeTypedMatrix4d;
  resultMatrix: TzeTypedMatrix4d;
begin
  // Шаг 1: Трансляция — смещаем srcPoint1 в dstPoint1
  resultMatrix := uzegeometry.CreateTranslationMatrix(
    uzegeometry.VertexSub(dstPoint1, srcPoint1)
  );

  // Шаг 2: Поворот — применяем только при ненулевых расстояниях
  srcLen := uzegeometry.Vertexlength(srcPoint1, srcPoint2);
  dstLen := uzegeometry.Vertexlength(dstPoint1, dstPoint2);

  if (srcLen > ALIGN_MIN_DISTANCE) and (dstLen > ALIGN_MIN_DISTANCE) then begin
    // Нормализуем направляющие векторы для 3D-поворота
    srcVec.x := (srcPoint2.x - srcPoint1.x) / srcLen;
    srcVec.y := (srcPoint2.y - srcPoint1.y) / srcLen;
    srcVec.z := (srcPoint2.z - srcPoint1.z) / srcLen;

    dstVec.x := (dstPoint2.x - dstPoint1.x) / dstLen;
    dstVec.y := (dstPoint2.y - dstPoint1.y) / dstLen;
    dstVec.z := (dstPoint2.z - dstPoint1.z) / dstLen;

    // Матрица 3D-поворота вокруг dstPoint1:
    //   T(-dstPoint1) * R3D(srcVec→dstVec) * T(dstPoint1)
    rotationMatrix := uzegeometry.CreateTranslationMatrix(-dstPoint1);
    rotationMatrix := uzegeometry.MatrixMultiply(
      rotationMatrix,
      Calc3DRotationMatrix(srcVec, dstVec)
    );
    rotationMatrix := uzegeometry.MatrixMultiply(
      rotationMatrix,
      uzegeometry.CreateTranslationMatrix(dstPoint1)
    );

    resultMatrix := uzegeometry.MatrixMultiply(resultMatrix, rotationMatrix);

    // Шаг 3: Масштабирование — только по запросу пользователя
    // Масштаб вычисляется по длине векторов src1→src2 и dst1→dst2
    if applyScale then begin
      scaleValue := dstLen / srcLen;

      // Матрица масштабирования относительно точки dstPoint1:
      //   T(-dstPoint1) * Scale(scaleValue) * T(dstPoint1)
      scaleMatrix := uzegeometry.CreateTranslationMatrix(-dstPoint1);
      scaleMatrix := uzegeometry.MatrixMultiply(
        scaleMatrix,
        CreateScaleMatrix(scaleValue)
      );
      scaleMatrix := uzegeometry.MatrixMultiply(
        scaleMatrix,
        uzegeometry.CreateTranslationMatrix(dstPoint1)
      );

      resultMatrix := uzegeometry.MatrixMultiply(resultMatrix, scaleMatrix);
    end;
  end;

  Result := resultMatrix;
end;

{
  CalcAlignMatrix3Point
  Вычисляет матрицу трансформации по трём парам точек.

  Алгоритм:
    1. Вычисляем матрицу M1 по двум парам точек (трансляция + 3D-поворот).
    2. Применяем M1 к srcPoint3 → получаем transformedSrc3.
    3. Вычисляем «крен» — поворот вокруг оси dst1→dst2:
       - Проецируем (transformedSrc3 - dstPoint1) и (dstPoint3 - dstPoint1)
         перпендикулярно оси dst1→dst2.
       - Ось поворота = normalize(dst2 - dst1).
       - Угол = угол между проекциями в плоскости, перпендикулярной оси.
    4. Итоговая матрица = M1 * M_roll.

  Масштабирование (applyScale=True) применяется только по длине src1→src2 / dst1→dst2,
  независимо от третьей пары точек.
}
function CalcAlignMatrix3Point(
  const srcPoint1, dstPoint1: TzePoint3d;
  const srcPoint2, dstPoint2: TzePoint3d;
  const srcPoint3, dstPoint3: TzePoint3d;
  const applyScale: boolean
): TzeTypedMatrix4d;
var
  // Матрица по двум парам точек (без масштабирования для промежуточного вычисления)
  twoPointMatrix: TzeTypedMatrix4d;
  // Позиция src3 после применения двухточечного преобразования
  transformedSrc3: TzePoint3d;
  // Ось «крена» = направление dst1→dst2 (нормализованное)
  rollAxis: TzePoint3d;
  rollAxisLen: double;
  // Векторы от dst1 к трансформированному src3 и к dst3
  vSrc, vDst: TzePoint3d;
  // Проекции вдоль оси (скалярные)
  projSrc, projDst: double;
  // Перпендикулярные компоненты
  perpSrc, perpDst: TzePoint3d;
  perpSrcLen, perpDstLen: double;
  // Матрица «крена» вокруг оси dst1→dst2
  rollMatrix: TzeTypedMatrix4d;
begin
  // Шаг 1: матрица по двум парам точек (масштаб не применяем —
  // нужна точная позиция transformedSrc3 до масштабирования)
  twoPointMatrix := CalcAlignMatrix(
    srcPoint1, dstPoint1, srcPoint2, dstPoint2, False
  );

  // Шаг 2: находим куда попадает srcPoint3 после двухточечного преобразования
  transformedSrc3 := uzegeometry.VectorTransform3D(srcPoint3, twoPointMatrix);

  // Шаг 3: вычисляем поворот «крен» вокруг оси dst1→dst2
  rollAxisLen := uzegeometry.Vertexlength(dstPoint1, dstPoint2);

  if rollAxisLen > ALIGN_MIN_DISTANCE then begin
    // Нормализованная ось поворота
    rollAxis.x := (dstPoint2.x - dstPoint1.x) / rollAxisLen;
    rollAxis.y := (dstPoint2.y - dstPoint1.y) / rollAxisLen;
    rollAxis.z := (dstPoint2.z - dstPoint1.z) / rollAxisLen;

    // Вектор от dstPoint1 до transformedSrc3
    vSrc.x := transformedSrc3.x - dstPoint1.x;
    vSrc.y := transformedSrc3.y - dstPoint1.y;
    vSrc.z := transformedSrc3.z - dstPoint1.z;

    // Вектор от dstPoint1 до dstPoint3
    vDst.x := dstPoint3.x - dstPoint1.x;
    vDst.y := dstPoint3.y - dstPoint1.y;
    vDst.z := dstPoint3.z - dstPoint1.z;

    // Проекции вдоль оси (скалярное произведение)
    projSrc := vSrc.x * rollAxis.x + vSrc.y * rollAxis.y + vSrc.z * rollAxis.z;
    projDst := vDst.x * rollAxis.x + vDst.y * rollAxis.y + vDst.z * rollAxis.z;

    // Перпендикулярные компоненты (убираем осевую составляющую)
    perpSrc.x := vSrc.x - projSrc * rollAxis.x;
    perpSrc.y := vSrc.y - projSrc * rollAxis.y;
    perpSrc.z := vSrc.z - projSrc * rollAxis.z;

    perpDst.x := vDst.x - projDst * rollAxis.x;
    perpDst.y := vDst.y - projDst * rollAxis.y;
    perpDst.z := vDst.z - projDst * rollAxis.z;

    perpSrcLen := Sqrt(perpSrc.x * perpSrc.x + perpSrc.y * perpSrc.y + perpSrc.z * perpSrc.z);
    perpDstLen := Sqrt(perpDst.x * perpDst.x + perpDst.y * perpDst.y + perpDst.z * perpDst.z);

    if (perpSrcLen > ALIGN_MIN_DISTANCE) and (perpDstLen > ALIGN_MIN_DISTANCE) then begin
      // Нормализуем перпендикулярные векторы
      perpSrc.x := perpSrc.x / perpSrcLen;
      perpSrc.y := perpSrc.y / perpSrcLen;
      perpSrc.z := perpSrc.z / perpSrcLen;
      perpDst.x := perpDst.x / perpDstLen;
      perpDst.y := perpDst.y / perpDstLen;
      perpDst.z := perpDst.z / perpDstLen;

      // Матрица «крена» вокруг dst1→dst2 через Calc3DRotationMatrix,
      // дополнительно ограничиваем вращение вокруг нужной оси:
      //   T(-dst1) * R_roll(perpSrc→perpDst, вокруг rollAxis) * T(dst1)
      rollMatrix := uzegeometry.CreateTranslationMatrix(-dstPoint1);
      rollMatrix := uzegeometry.MatrixMultiply(
        rollMatrix,
        Calc3DRotationMatrix(perpSrc, perpDst)
      );
      rollMatrix := uzegeometry.MatrixMultiply(
        rollMatrix,
        uzegeometry.CreateTranslationMatrix(dstPoint1)
      );

      twoPointMatrix := uzegeometry.MatrixMultiply(twoPointMatrix, rollMatrix);
    end;
  end;

  // Шаг 4: добавляем масштабирование (по двум точкам, не по трём)
  if applyScale then begin
    // Применяем масштабирование относительно dstPoint1
    // Масштаб = |dst1→dst2| / |src1→src2|, третья точка не участвует
    rollAxisLen := uzegeometry.Vertexlength(dstPoint1, dstPoint2);
    if rollAxisLen > ALIGN_MIN_DISTANCE then begin
      perpSrcLen := uzegeometry.Vertexlength(srcPoint1, srcPoint2);
      if perpSrcLen > ALIGN_MIN_DISTANCE then begin
        rollMatrix := uzegeometry.CreateTranslationMatrix(-dstPoint1);
        rollMatrix := uzegeometry.MatrixMultiply(
          rollMatrix,
          CreateScaleMatrix(rollAxisLen / perpSrcLen)
        );
        rollMatrix := uzegeometry.MatrixMultiply(
          rollMatrix,
          uzegeometry.CreateTranslationMatrix(dstPoint1)
        );
        twoPointMatrix := uzegeometry.MatrixMultiply(twoPointMatrix, rollMatrix);
      end;
    end;
  end;

  Result := twoPointMatrix;
end;

{ --- Применение трансформации к объектам --- }

{
  ApplyTransformToObjects
  Применяет матрицу трансформации dispmatr ко всем объектам из pcoa.
  Операция регистрируется в стеке undo/redo.
}
procedure ApplyTransformToObjects(
  const pcoa: ptpcoavector;
  const dispmatr: TzeTypedMatrix4d
);
var
  invertedMatrix: TzeTypedMatrix4d;
  ir: itrec;
  pcd: PTCopyObjectDesc;
  m: tmethod;
  dc: TDrawContext;
begin
  // Вычисляем обратную матрицу для поддержки undo
  invertedMatrix := dispmatr;
  uzegeometry.MatrixInvert(invertedMatrix);

  // Создаём контекст отрисовки до начала цикла трансформации
  dc := drawings.GetCurrentDWG^.CreateDrawingRC;

  PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushStartMarker('Align');
  with PushCreateTGMultiObjectChangeCommand(
      @PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,
      dispmatr, invertedMatrix, pcoa^.Count) do begin
    pcd := pcoa^.beginiterate(ir);
    if pcd <> nil then
      repeat
        // В режиме {$mode delphi} нельзя взять адрес метода через @obj^.Method,
        // поэтому используем явное присвоение полей tmethod (как в uzcutils.pas)
        m.Code := pointer(pcd^.sourceEnt^.Transform);
        m.Data := pcd^.sourceEnt;
        AddMethod(m);
        Dec(pcd^.sourceEnt^.vp.LastCameraPos);
        pcd^.sourceEnt^.Formatentity(drawings.GetCurrentDWG^, dc);
        pcd := pcoa^.iterate(ir);
      until pcd = nil;
    comit;
  end;
  PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack.PushEndMarker;

  // Обновляем отображение после применения трансформации
  drawings.GetCurrentROOT^.FormatAfterEdit(drawings.GetCurrentDWG^, dc);
end;

{ --- Работа со списком объектов --- }

{
  CollectSelectedObjects
  Формирует список выбранных объектов для последующего применения трансформации.
  Возвращает количество выбранных объектов (0 — если ничего не выбрано).
}
function CollectSelectedObjects(out pcoa: ptpcoavector): integer;
var
  pobj: PGDBObjEntity;
  ir: itrec;
  counter: integer;
  tcd: TCopyObjectDesc;
begin
  counter := 0;
  pcoa := nil;

  // Первый проход: подсчёт выбранных объектов
  pobj := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj <> nil then
    repeat
      if pobj^.selected then
        Inc(counter);
      pobj := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pobj = nil;

  if counter = 0 then begin
    Result := 0;
    Exit;
  end;

  // Выделяем память и заполняем список ссылками на выбранные объекты
  Getmem(Pointer(pcoa), sizeof(tpcoavector));
  pcoa^.init(counter);

  pobj := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj <> nil then
    repeat
      if pobj^.selected then begin
        tcd.sourceEnt := pobj;
        tcd.tmpProxy := nil;
        tcd.copyEnt := nil;
        pcoa^.PushBackData(tcd);
      end;
      pobj := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pobj = nil;

  Result := counter;
end;

{
  FreeObjectsList
  Освобождает память вектора объектов.
}
procedure FreeObjectsList(var pcoa: ptpcoavector);
begin
  if pcoa <> nil then begin
    pcoa^.done;
    Freemem(Pointer(pcoa));
    pcoa := nil;
  end;
end;

{ --- Основная функция команды --- }

{
  AlignCommand
  Реализует диалог команды ALIGN с интерактивным меню в стиле команды Rotate.

  Состояния команды (TAlignCmdMode):
    ACMWaitSrc1  — ожидание первой исходной точки
    ACMWaitDst1  — ожидание первой целевой точки
    ACMWaitSrc2  — ожидание второй исходной точки
    ACMWaitDst2  — ожидание второй целевой точки
    ACMWaitSrc3  — ожидание третьей исходной точки (Enter — пропуск)
    ACMWaitDst3  — ожидание третьей целевой точки
    ACMWaitScale — ожидание ответа о масштабировании [Yes/No]

  Для ввода точек используется Get3DPoint.
  Для ввода ответа на вопрос о масштабировании — GetInput с интерактивным меню.
  Пользователь может в любой момент нажать ESC для отмены.
}
function AlignCommand(
  const Context: TZCADCommandContext;
  Operands: TCommandOperands
): TCommandResult;
type
  TAlignCmdMode = (
    ACMWaitSrc1,
    ACMWaitDst1,
    ACMWaitSrc2,
    ACMWaitDst2,
    ACMWaitSrc3,
    ACMWaitDst3,
    ACMWaitScale
  );
var
  pcoa: ptpcoavector;
  objectCount: integer;
  srcPoint1, dstPoint1: TzePoint3d;
  srcPoint2, dstPoint2: TzePoint3d;
  srcPoint3, dstPoint3: TzePoint3d;
  hasPoint3: boolean;
  applyScale: boolean;
  CmdMode: TAlignCmdMode;
  gr: TzcInteractiveResult;
  p1: TzePoint3d;
  inputStr: string;

  procedure LogMessage(const msg: string);
  begin
    zcUI.TextMessage(msg, TMWOHistoryOut);
  end;

  // Устанавливает текущее состояние диалога и обновляет подсказку командной строки
  procedure SetAlignCmdMode(ANewMode: TAlignCmdMode);
  begin
    CmdMode := ANewMode;
    case ANewMode of
      ACMWaitSrc1: begin
        LogMessage('ALIGN: Укажите первую исходную точку');
        commandmanager.ChangeInputMode([], [IPEmpty]);
        commandmanager.SetPrompt(RSCLPAlignSrc1);
      end;
      ACMWaitDst1: begin
        LogMessage(Format('ALIGN: Первая исходная точка = (%.3f, %.3f, %.3f)',
          [srcPoint1.x, srcPoint1.y, srcPoint1.z]));
        LogMessage('ALIGN: Укажите первую целевую точку');
        commandmanager.ChangeInputMode([], [IPEmpty]);
        commandmanager.SetPrompt(RSCLPAlignDst1);
      end;
      ACMWaitSrc2: begin
        LogMessage(Format('ALIGN: Первая целевая точка = (%.3f, %.3f, %.3f)',
          [dstPoint1.x, dstPoint1.y, dstPoint1.z]));
        LogMessage('ALIGN: Укажите вторую исходную точку');
        commandmanager.ChangeInputMode([], [IPEmpty]);
        commandmanager.SetPrompt(RSCLPAlignSrc2);
      end;
      ACMWaitDst2: begin
        LogMessage(Format('ALIGN: Вторая исходная точка = (%.3f, %.3f, %.3f)',
          [srcPoint2.x, srcPoint2.y, srcPoint2.z]));
        LogMessage('ALIGN: Укажите вторую целевую точку');
        commandmanager.ChangeInputMode([], [IPEmpty]);
        commandmanager.SetPrompt(RSCLPAlignDst2);
      end;
      ACMWaitSrc3: begin
        LogMessage(Format('ALIGN: Вторая целевая точка = (%.3f, %.3f, %.3f)',
          [dstPoint2.x, dstPoint2.y, dstPoint2.z]));
        LogMessage('ALIGN: Укажите третью исходную точку или нажмите Enter для пропуска');
        // Разрешаем ввод кнопки [Отменить] (Enter) для пропуска третьей пары точек
        commandmanager.ChangeInputMode([], [IPEmpty]);
        // Инициализируем кэш разобранной строки при первом вызове
        if clSrc3 = nil then
          clSrc3 := CMDLinePromptParser.GetTokens(RSCLPAlignSrc3);
        commandmanager.SetPrompt(clSrc3);
      end;
      ACMWaitDst3: begin
        LogMessage(Format('ALIGN: Третья исходная точка = (%.3f, %.3f, %.3f)',
          [srcPoint3.x, srcPoint3.y, srcPoint3.z]));
        LogMessage('ALIGN: Укажите третью целевую точку');
        commandmanager.ChangeInputMode([], [IPEmpty]);
        commandmanager.SetPrompt(RSCLPAlignDst3);
      end;
      ACMWaitScale: begin
        if not hasPoint3 then
          LogMessage('ALIGN: Третья пара точек пропущена');
        LogMessage('ALIGN: Масштабировать объекты? [Yes/No]');
        // Разрешаем пустой ввод (Enter = No по умолчанию)
        commandmanager.ChangeInputMode([IPEmpty], []);
        // Инициализируем кэш разобранной строки меню при первом вызове
        if clScaleYesNo = nil then
          clScaleYesNo := CMDLinePromptParser.GetTokens(RSCLPAlignScaleYesNo);
        commandmanager.SetPrompt(clScaleYesNo);
      end;
    end;
  end;

  // Применяет вычисленную трансформацию и логирует результат
  procedure ApplyAndFinish;
  var
    dispmatr: TzeTypedMatrix4d;
  begin
    if hasPoint3 then
      dispmatr := CalcAlignMatrix3Point(
        srcPoint1, dstPoint1, srcPoint2, dstPoint2, srcPoint3, dstPoint3, applyScale
      )
    else
      dispmatr := CalcAlignMatrix(
        srcPoint1, dstPoint1, srcPoint2, dstPoint2, applyScale
      );
    ApplyTransformToObjects(pcoa, dispmatr);

  end;

begin
  Result := cmd_ok;
  pcoa := nil;
  applyScale := False;
  hasPoint3 := False;

  LogMessage('========================================');
  LogMessage('ALIGN: Запуск команды ALIGN');
  //LogMessage('========================================');

  programlog.LogOutFormatStr(
    'uzccommand_align: запуск команды ALIGN', [], LM_Info
  );

  // Проверяем наличие выбранных объектов
  objectCount := CollectSelectedObjects(pcoa);
  if objectCount = 0 then begin
    LogMessage('ALIGN: Ошибка - нет выбранных объектов');
    zcUI.TextMessage(rscmSelEntBeforeComm, TMWOHistoryOut);
    programlog.LogOutFormatStr(
      'uzccommand_align: нет выбранных объектов, команда завершена', [], LM_Info
    );
    Exit;
  end;

  LogMessage(Format('ALIGN: Выбрано объектов: %d', [objectCount]));
  programlog.LogOutFormatStr(
    'uzccommand_align: выбрано объектов: %d', [objectCount], LM_Info
  );

  try
    SetAlignCmdMode(ACMWaitSrc1);

    // Основной цикл: сбор точек (шаги src1..dst3)
    repeat
      gr := commandmanager.Get3DPoint('', p1);

      case gr of
        IRNormal:
          // Пользователь указал точку — записываем и переходим к следующему шагу
          case CmdMode of
            ACMWaitSrc1: begin
              srcPoint1 := p1;
              SetAlignCmdMode(ACMWaitDst1);
            end;
            ACMWaitDst1: begin
              dstPoint1 := p1;
              SetAlignCmdMode(ACMWaitSrc2);
            end;
            ACMWaitSrc2: begin
              srcPoint2 := p1;
              SetAlignCmdMode(ACMWaitDst2);
            end;
            ACMWaitDst2: begin
              dstPoint2 := p1;
              SetAlignCmdMode(ACMWaitSrc3);
            end;
            ACMWaitSrc3: begin
              // Третья исходная точка — сохраняем и переходим к ожиданию целевой
              srcPoint3 := p1;
              SetAlignCmdMode(ACMWaitDst3);
            end;
            ACMWaitDst3: begin
              // Третья пара принята — используется для вращения вокруг оси dst1→dst2
              dstPoint3 := p1;
              hasPoint3 := True;
              SetAlignCmdMode(ACMWaitScale);
            end;
          end;

        IRId:
          // Нажатие кнопки [Отменить] (Enter) для пропуска третьей пары точек
          if (CmdMode = ACMWaitSrc3) and (commandmanager.GetLastId = CLPIdUser1) then begin
            SetAlignCmdMode(ACMWaitScale);
          end;

      end; // case gr
    until (gr = IRCancel) or (CmdMode = ACMWaitScale);

    // Прерываем если пользователь отменил до достижения шага масштабирования
    if gr = IRCancel then begin
      LogMessage('ALIGN: Команда отменена пользователем');
      Exit;
    end;

    // Цикл ожидания ответа о масштабировании [Yes/No]
    repeat
      gr := commandmanager.GetInput('', inputStr);

      case gr of
        IRNormal, IRInput: begin
          // Пустой ввод (Enter) = No по умолчанию
          applyScale := False;
          LogMessage('ALIGN: Масштабирование: No (по умолчанию, Enter)');
          programlog.LogOutFormatStr(
            'uzccommand_align: масштабирование=No (по умолчанию)', [], LM_Info
          );
          ApplyAndFinish;
          Break;
        end;
        IRId:
          case commandmanager.GetLastId of
            CLPIdUser1: begin
              // Пользователь нажал [Y]es
              applyScale := True;
              LogMessage('ALIGN: Масштабирование: Yes (клавиша Y)');
              programlog.LogOutFormatStr(
                'uzccommand_align: масштабирование=Yes', [], LM_Info
              );
              ApplyAndFinish;
              Break;
            end;
            CLPIdUser2: begin
              // Пользователь нажал [N]o
              applyScale := False;
              LogMessage('ALIGN: Масштабирование: No (клавиша N)');
              programlog.LogOutFormatStr(
                'uzccommand_align: масштабирование=No', [], LM_Info
              );
              ApplyAndFinish;
              Break;
            end;
          end;
      end; // case gr
    until gr = IRCancel;

  finally
    // Освобождаем ресурсы независимо от пути завершения
    FreeObjectsList(pcoa);
    if Result = cmd_ok then begin
      LogMessage('ALIGN: Команда завершена успешно');
      LogMessage('========================================');
    end
    else begin
      LogMessage('ALIGN: Команда завершена с ошибкой');
    end;
  end;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsInitializeLMId);
  // Регистрируем команду ALIGN в системе команд ZCAD
  CreateZCADCommand(@AlignCommand, 'Align', CADWG, 0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsFinalizeLMId);
  clScaleYesNo.Free;
  clSrc3.Free;
end.
