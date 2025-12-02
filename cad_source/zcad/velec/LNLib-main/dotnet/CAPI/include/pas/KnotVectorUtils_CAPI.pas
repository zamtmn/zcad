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

  Функции загружаются динамически через модуль LNLibLoader.
  Перед использованием функций необходимо проверить IsLNLibLoaded.

  Оригинальный C-заголовок: KnotVectorUtils_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: нет
}
unit KnotVectorUtils_CAPI;

{$mode delphi}{$H+}

interface

{ Функции загружаются динамически через LNLibLoader }
{ Используйте переменные-указатели из LNLibLoader:
  knot_vector_utils_get_continuity, knot_vector_utils_rescale,
  knot_vector_utils_is_uniform, knot_vector_utils_get_knot_multiplicity_map_size,
  knot_vector_utils_get_knot_multiplicity_map }

implementation

end.
