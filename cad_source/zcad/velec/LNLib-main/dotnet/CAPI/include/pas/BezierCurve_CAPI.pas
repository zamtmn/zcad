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

  Оригинальный C-заголовок: BezierCurve_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: LNLibDefinitions, XYZ_CAPI, XYZW_CAPI
}
unit BezierCurve_CAPI;

{$mode delphi}{$H+}

interface

uses
  LNLibDefinitions,
  XYZ_CAPI,
  XYZW_CAPI;

{**
  Вычисление точки на кривой Безье методом полиномов Бернштейна.

  Использует прямое вычисление через полиномы Бернштейна B_{i,n}(t).
  Эффективен для однократного вычисления, но менее стабилен численно
  для высоких степеней.

  @param degree Степень кривой Безье (n)
  @param control_points Указатель на массив контрольных точек (n+1 точек)
  @param control_points_count Количество контрольных точек (должно быть
                              равно degree + 1)
  @param paramT Параметр на кривой (обычно в диапазоне [0, 1])
  @return Координаты точки на кривой при заданном параметре t
}
function bezier_curve_get_point_by_bernstein(
  degree: Integer;
  control_points: PXYZ;
  control_points_count: Integer;
  paramT: Double): TXYZ;
  cdecl; external LNLIB_DLL;

{**
  Вычисление точки на кривой Безье алгоритмом де Кастельжо.

  Использует рекурсивный алгоритм линейной интерполяции де Кастельжо.
  Численно более стабилен, особенно для кривых высокой степени.
  Позволяет одновременно разбить кривую на две части.

  @param degree Степень кривой Безье (n)
  @param control_points Указатель на массив контрольных точек (n+1 точек)
  @param control_points_count Количество контрольных точек (должно быть
                              равно degree + 1)
  @param paramT Параметр на кривой (обычно в диапазоне [0, 1])
  @return Координаты точки на кривой при заданном параметре t
}
function bezier_curve_get_point_by_de_casteljau(
  degree: Integer;
  control_points: PXYZ;
  control_points_count: Integer;
  paramT: Double): TXYZ;
  cdecl; external LNLIB_DLL;

{**
  Вычисление точки на рациональной кривой Безье методом Бернштейна.

  Рациональная кривая Безье использует взвешенные контрольные точки,
  что позволяет точно представлять конические сечения (окружности,
  эллипсы, параболы, гиперболы).

  @param degree Степень кривой Безье (n)
  @param control_points Указатель на массив взвешенных контрольных точек
                        в однородных координатах (n+1 точек)
  @param control_points_count Количество контрольных точек (должно быть
                              равно degree + 1)
  @param paramT Параметр на кривой (обычно в диапазоне [0, 1])
  @return Однородные координаты точки на кривой при заданном параметре t
}
function bezier_curve_get_point_by_bernstein_rational(
  degree: Integer;
  control_points: PXYZW;
  control_points_count: Integer;
  paramT: Double): TXYZW;
  cdecl; external LNLIB_DLL;

implementation

end.
