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
  Модуль Projection_CAPI - функции проецирования точек.

  Предоставляет интерфейс к функциям C-библиотеки LNLib для проецирования
  точек на геометрические примитивы: лучи, отрезки, а также для
  стереографических проекций.

  Оригинальный C-заголовок: Projection_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: LNLibDefinitions, XYZ_CAPI
}
unit Projection_CAPI;

{$mode delphi}{$H+}

interface

uses
  LNLibDefinitions,
  XYZ_CAPI;

{**
  Проецирование точки на луч.

  Находит ближайшую точку на луче к заданной точке.

  @param origin Начальная точка луча
  @param direction Направляющий вектор луча (должен быть нормализован)
  @param point Точка, которую нужно спроецировать
  @return Координаты проекции точки на луч
}
function projection_point_to_ray(
  origin: TXYZ;
  direction: TXYZ;
  point: TXYZ
): TXYZ; cdecl; external LNLIB_DLL;

{**
  Проецирование точки на отрезок.

  Находит ближайшую точку на отрезке к заданной точке. Если проекция
  выходит за пределы отрезка, возвращается ближайшая конечная точка.

  @param start_point Начальная точка отрезка
  @param end_point Конечная точка отрезка
  @param point Точка, которую нужно спроецировать
  @param out_project_point Выходной параметр: координаты проекции
  @return 1 если проекция находится внутри отрезка, 0 если на границе
}
function projection_point_to_line(
  start_point: TXYZ;
  end_point: TXYZ;
  point: TXYZ;
  out_project_point: PXYZ
): Integer; cdecl; external LNLIB_DLL;

{**
  Стереографическая проекция точки со сферы на плоскость.

  Выполняет стереографическую проекцию точки, лежащей на сфере,
  на касательную плоскость в противоположном полюсе.

  @param point_on_sphere Точка на поверхности сферы
  @param radius Радиус сферы
  @return Координаты проекции на плоскости
}
function projection_stereographic(
  point_on_sphere: TXYZ;
  radius: Double
): TXYZ; cdecl; external LNLIB_DLL;

implementation

end.
