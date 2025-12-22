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
  Модуль BezierCurve_CAPI - обёртка для работы с кривыми Безье.

  Предоставляет интерфейс к функциям C-библиотеки LNLib для вычисления
  точек на кривых Безье различными методами.

  Кривая Безье — это параметрическая кривая, определяемая набором
  контрольных точек и полиномами Бернштейна.

  Функции загружаются динамически через модуль LNLibLoader.
  Перед использованием функций необходимо проверить IsLNLibLoaded.

  Оригинальный C-заголовок: BezierCurve_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: XYZ_CAPI, XYZW_CAPI
}
unit BezierCurve_CAPI;

{$mode delphi}{$H+}

interface

uses
  XYZ_CAPI,
  XYZW_CAPI;

{ Функции загружаются динамически через LNLibLoader }
{ Используйте переменные-указатели из LNLibLoader:
  bezier_curve_get_point_by_bernstein, bezier_curve_get_point_by_de_casteljau,
  bezier_curve_get_point_by_bernstein_rational }

implementation

end.
