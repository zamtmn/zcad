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
  Модуль Intersection_CAPI - обёртка для функций пересечения геометрических
  объектов.

  Предоставляет интерфейс к функциям C-библиотеки LNLib для вычисления
  пересечений между лучами, линиями и плоскостями.

  Оригинальный C-заголовок: Intersection_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: LNLibDefinitions, LNEnums_CAPI, XYZ_CAPI
}
unit Intersection_CAPI;

{$mode delphi}{$H+}

interface

uses
  LNLibDefinitions,
  LNEnums_CAPI,
  XYZ_CAPI;

{**
  Вычисление пересечения двух лучей в 3D-пространстве.

  Анализирует взаимное расположение двух лучей, заданных начальными точками
  и направляющими векторами. Определяет тип пересечения и вычисляет параметры
  точки пересечения (если она существует).

  @param point0 Начальная точка первого луча
  @param vector0 Направляющий вектор первого луча
  @param point1 Начальная точка второго луча
  @param vector1 Направляющий вектор второго луча
  @param out_param0 Выходной параметр: значение t для первого луча в точке
                    пересечения (точка = point0 + t * vector0)
  @param out_param1 Выходной параметр: значение t для второго луча в точке
                    пересечения (точка = point1 + t * vector1)
  @param out_intersect_point Выходной параметр: координаты точки пересечения
  @return Тип пересечения кривых (пересекаются, параллельны, совпадают,
          скрещиваются)
}
function intersection_compute_rays(
  point0: TXYZ; vector0: TXYZ;
  point1: TXYZ; vector1: TXYZ;
  out_param0: PDouble;
  out_param1: PDouble;
  out_intersect_point: PXYZ): TCurveCurveIntersectionType;
  cdecl; external LNLIB_DLL;

{**
  Вычисление пересечения линии и плоскости в 3D-пространстве.

  Анализирует взаимное расположение линии и плоскости. Плоскость задаётся
  нормалью и точкой на ней, линия — точкой и направляющим вектором.

  @param plane_normal Нормаль к плоскости (определяет ориентацию)
  @param point_on_plane Произвольная точка, лежащая на плоскости
  @param point_on_line Произвольная точка, лежащая на линии
  @param line_direction Направляющий вектор линии
  @param out_intersect_point Выходной параметр: координаты точки пересечения
                             (если пересечение существует)
  @return Тип пересечения линии и плоскости (пересекает, параллельна,
          лежит на плоскости)
}
function intersection_compute_line_and_plane(
  plane_normal: TXYZ;
  point_on_plane: TXYZ;
  point_on_line: TXYZ;
  line_direction: TXYZ;
  out_intersect_point: PXYZ): TLinePlaneIntersectionType;
  cdecl; external LNLIB_DLL;

implementation

end.
