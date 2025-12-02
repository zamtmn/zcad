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
  Модуль Polynomials_CAPI - функции для работы с полиномами и базисами.

  Предоставляет интерфейс к функциям C-библиотеки LNLib для вычисления
  полиномов Бернштейна, базисных функций B-сплайнов, работы с узловыми
  векторами и преобразования между представлениями кривых.

  Функции загружаются динамически через модуль LNLibLoader.
  Перед использованием функций необходимо проверить IsLNLibLoaded.

  Оригинальный C-заголовок: Polynomials_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: XYZ_CAPI, UV_CAPI
}
unit Polynomials_CAPI;

{$mode delphi}{$H+}

interface

uses
  XYZ_CAPI,
  UV_CAPI;

{ Функции загружаются динамически через LNLibLoader }
{ Используйте переменные-указатели из LNLibLoader:
  polynomials_bernstein, polynomials_all_bernstein, polynomials_horner_curve,
  polynomials_get_knot_span_index, polynomials_get_knot_multiplicity,
  polynomials_basis_functions, polynomials_bezier_to_power_matrix }

implementation

end.
