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
  Модуль ValidationUtils_CAPI - утилиты для валидации NURBS-данных.

  Предоставляет интерфейс к функциям C-библиотеки LNLib для проверки
  корректности входных данных NURBS-кривых и поверхностей: узловых векторов,
  контрольных точек и степеней кривых.

  Оригинальный C-заголовок: ValidationUtils_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: LNLibDefinitions, XYZW_CAPI
}
unit ValidationUtils_CAPI;

{$mode delphi}{$H+}

interface

uses
  LNLibDefinitions,
  XYZW_CAPI;

{**
  Проверка корректности узлового вектора.

  Узловой вектор должен быть неубывающей последовательностью значений.

  @param knot_vector Указатель на массив значений узлового вектора
  @param count Количество элементов в узловом векторе
  @return 1 если узловой вектор корректен, 0 в противном случае
}
function validation_utils_is_valid_knot_vector(
  const knot_vector: PDouble;
  count: Integer
): Integer; cdecl; external LNLIB_DLL;

{**
  Проверка корректности параметров кривой Безье.

  Для кривой Безье количество контрольных точек должно быть равно degree + 1.

  @param degree Степень кривой Безье
  @param control_points_count Количество контрольных точек
  @return 1 если параметры корректны, 0 в противном случае
}
function validation_utils_is_valid_bezier(
  degree: Integer;
  control_points_count: Integer
): Integer; cdecl; external LNLIB_DLL;

{**
  Проверка корректности параметров B-сплайн кривой.

  Для B-сплайна должно выполняться: knot_count = cp_count + degree + 1.

  @param degree Степень B-сплайн кривой
  @param knot_count Количество узлов в узловом векторе
  @param cp_count Количество контрольных точек
  @return 1 если параметры корректны, 0 в противном случае
}
function validation_utils_is_valid_bspline(
  degree: Integer;
  knot_count: Integer;
  cp_count: Integer
): Integer; cdecl; external LNLIB_DLL;

{**
  Проверка корректности параметров NURBS-кривой.

  Для NURBS-кривой должно выполняться: knot_count = weighted_cp_count + degree + 1.

  @param degree Степень NURBS-кривой
  @param knot_count Количество узлов в узловом векторе
  @param weighted_cp_count Количество взвешенных контрольных точек
  @return 1 если параметры корректны, 0 в противном случае
}
function validation_utils_is_valid_nurbs(
  degree: Integer;
  knot_count: Integer;
  weighted_cp_count: Integer
): Integer; cdecl; external LNLIB_DLL;

{**
  Вычисление допуска модификации кривой на основе контрольных точек.

  Допуск рассчитывается на основе геометрических характеристик
  контрольного многоугольника и используется для оценки точности
  операций над кривой.

  @param control_points Указатель на массив взвешенных контрольных точек
  @param count Количество контрольных точек
  @return Значение допуска модификации
}
function validation_utils_compute_curve_modify_tolerance(
  const control_points: PXYZW;
  count: Integer
): Double; cdecl; external LNLIB_DLL;

implementation

end.
