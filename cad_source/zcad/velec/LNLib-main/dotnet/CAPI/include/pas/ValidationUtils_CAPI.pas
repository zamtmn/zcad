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

  Функции загружаются динамически через модуль LNLibLoader.
  Перед использованием функций необходимо проверить IsLNLibLoaded.

  Оригинальный C-заголовок: ValidationUtils_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: XYZW_CAPI
}
unit ValidationUtils_CAPI;

{$mode delphi}{$H+}

interface

uses
  XYZW_CAPI;

{ Функции загружаются динамически через LNLibLoader }
{ Используйте переменные-указатели из LNLibLoader:
  validation_utils_is_valid_knot_vector, validation_utils_is_valid_bezier,
  validation_utils_is_valid_bspline, validation_utils_is_valid_nurbs,
  validation_utils_compute_curve_modify_tolerance }

implementation

end.
