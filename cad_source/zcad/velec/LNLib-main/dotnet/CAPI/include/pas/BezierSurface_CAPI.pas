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
  Модуль BezierSurface_CAPI - обёртка для работы с поверхностями Безье.

  Предоставляет интерфейс к функциям C-библиотеки LNLib для вычисления
  точек на поверхностях Безье.

  Поверхность Безье — это параметрическая поверхность, определяемая
  двумерной сеткой контрольных точек и тензорным произведением
  полиномов Бернштейна по направлениям U и V.

  Оригинальный C-заголовок: BezierSurface_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: LNLibDefinitions, XYZ_CAPI, UV_CAPI
}
unit BezierSurface_CAPI;

{$mode delphi}{$H+}

interface

uses
  LNLibDefinitions,
  XYZ_CAPI,
  UV_CAPI;

{**
  Вычисление точки на поверхности Безье алгоритмом де Кастельжо.

  Использует двумерное обобщение алгоритма де Кастельжо для вычисления
  точки на тензорной поверхности Безье. Контрольные точки организованы
  в двумерную сетку размером (num_u x num_v), хранящуюся построчно.

  Алгоритм выполняет последовательную интерполяцию:
  1. Сначала по направлению U для каждой строки контрольных точек
  2. Затем по направлению V для полученных промежуточных точек

  @param degree_u Степень поверхности по направлению U
  @param degree_v Степень поверхности по направлению V
  @param control_points Указатель на двумерную сетку контрольных точек,
                        хранящуюся построчно (сначала все точки первой
                        строки по U, затем второй и т.д.)
  @param num_u Количество контрольных точек по направлению U
               (должно быть равно degree_u + 1)
  @param num_v Количество контрольных точек по направлению V
               (должно быть равно degree_v + 1)
  @param uv Параметрические координаты точки на поверхности
            (u и v обычно в диапазоне [0, 1])
  @return Координаты точки на поверхности при заданных параметрах (u, v)
}
function bezier_surface_get_point_by_de_casteljau(
  degree_u: Integer;
  degree_v: Integer;
  control_points: PXYZ;
  num_u: Integer;
  num_v: Integer;
  uv: TUV): TXYZ;
  cdecl; external LNLIB_DLL;

implementation

end.
