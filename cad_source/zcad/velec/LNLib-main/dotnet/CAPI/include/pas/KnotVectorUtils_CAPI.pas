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
{**
  Модуль KnotVectorUtils_CAPI - утилиты для работы с узловыми векторами.

  Предоставляет интерфейс к функциям C-библиотеки LNLib для анализа
  и манипуляции узловыми векторами NURBS-кривых и поверхностей.

  Узловой вектор — это неубывающая последовательность параметрических
  значений, определяющая области влияния базисных функций B-сплайна.

  Оригинальный C-заголовок: KnotVectorUtils_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: LNLibDefinitions
}
unit KnotVectorUtils_CAPI;

{$mode delphi}{$H+}

interface

uses
  LNLibDefinitions;

{**
  Вычисление непрерывности (гладкости) кривой в заданном узле.

  Возвращает класс непрерывности C^k в точке, соответствующей узловому
  значению. Непрерывность зависит от степени сплайна и кратности узла.

  @param degree Степень B-сплайна
  @param knot_vector Указатель на массив узловых значений
  @param knot_vector_count Количество элементов в узловом векторе
  @param knot Узловое значение для анализа
  @return Класс непрерывности (0 = C^0, 1 = C^1, и т.д.)
}
function knot_vector_utils_get_continuity(
  degree: Integer;
  knot_vector: PDouble;
  knot_vector_count: Integer;
  knot: Double): Integer;
  cdecl; external LNLIB_DLL;

{**
  Перемасштабирование узлового вектора в новый диапазон.

  Линейно преобразует все узловые значения из текущего диапазона
  в заданный диапазон [min_val, max_val].

  @param knot_vector Указатель на исходный массив узловых значений
  @param knot_vector_count Количество элементов в узловом векторе
  @param min_val Минимальное значение нового диапазона
  @param max_val Максимальное значение нового диапазона
  @param out_rescaled_knot_vector Указатель на выходной массив (должен быть
                                  предварительно выделен с размером
                                  knot_vector_count элементов)
}
procedure knot_vector_utils_rescale(
  knot_vector: PDouble;
  knot_vector_count: Integer;
  min_val: Double;
  max_val: Double;
  out_rescaled_knot_vector: PDouble);
  cdecl; external LNLIB_DLL;

{**
  Проверка, является ли узловой вектор равномерным.

  Равномерный узловой вектор имеет одинаковые интервалы между
  последовательными уникальными узловыми значениями.

  @param knot_vector Указатель на массив узловых значений
  @param knot_vector_count Количество элементов в узловом векторе
  @return 1 если вектор равномерный, 0 в противном случае
}
function knot_vector_utils_is_uniform(
  knot_vector: PDouble;
  knot_vector_count: Integer): Integer;
  cdecl; external LNLIB_DLL;

{**
  Получение размера карты кратности узлов.

  Возвращает количество уникальных узловых значений в векторе.
  Используется для предварительного выделения памяти перед вызовом
  knot_vector_utils_get_knot_multiplicity_map.

  @param knot_vector Указатель на массив узловых значений
  @param knot_vector_count Количество элементов в узловом векторе
  @return Количество уникальных узловых значений
}
function knot_vector_utils_get_knot_multiplicity_map_size(
  knot_vector: PDouble;
  knot_vector_count: Integer): Integer;
  cdecl; external LNLIB_DLL;

{**
  Построение карты кратности узлов.

  Анализирует узловой вектор и формирует два параллельных массива:
  уникальные узловые значения и соответствующие им кратности.

  @param knot_vector Указатель на массив узловых значений
  @param knot_vector_count Количество элементов в узловом векторе
  @param out_unique_knots Выходной массив уникальных узловых значений
                          (должен быть предварительно выделен)
  @param out_multiplicities Выходной массив кратностей узлов
                            (должен быть предварительно выделен)
}
procedure knot_vector_utils_get_knot_multiplicity_map(
  knot_vector: PDouble;
  knot_vector_count: Integer;
  out_unique_knots: PDouble;
  out_multiplicities: PInteger);
  cdecl; external LNLIB_DLL;

implementation

end.
