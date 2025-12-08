{
*****************************************************************************
*                                                                           *
*  This file is part of the fpLNLib                                         *
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
{**
  Модуль NurbsSurface_CAPI - обёртка для работы с NURBS-поверхностями.

  Предоставляет интерфейс к функциям C-библиотеки LNLib для создания,
  анализа, модификации и преобразования NURBS-поверхностей.

  NURBS-поверхность определяется степенями по направлениям U и V,
  двумя узловыми векторами и двумерной сеткой взвешенных контрольных точек.
  Поверхность параметризуется двумя параметрами: U и V.

  Функции загружаются динамически через модуль LNLibLoader.
  Перед использованием функций необходимо проверить IsLNLibLoaded.

  Оригинальный C-заголовок: NurbsSurface_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: UV_CAPI, XYZ_CAPI, XYZW_CAPI, LNObject_CAPI,
               NurbsCurve_CAPI, LNEnums_CAPI
}
unit NurbsSurface_CAPI;

{$mode delphi}{$H+}

interface

uses
  UV_CAPI,
  XYZ_CAPI,
  XYZW_CAPI,
  LNObject_CAPI,
  NurbsCurve_CAPI,
  LNEnums_CAPI;

type
  {**
    Структура для представления NURBS-поверхности.

    Содержит все данные, необходимые для определения NURBS-поверхности:
    степени по направлениям U и V, узловые векторы и двумерную сетку
    взвешенных контрольных точек.

    @member degree_u Степень поверхности по параметру U
    @member degree_v Степень поверхности по параметру V
    @member knot_vector_u Указатель на массив узловых значений по U
    @member knot_count_u Количество узлов в узловом векторе по U
    @member knot_vector_v Указатель на массив узловых значений по V
    @member knot_count_v Количество узлов в узловом векторе по V
    @member control_points Указатель на массив контрольных точек в
                           однородных координатах (хранятся построчно)
    @member control_point_rows Количество строк контрольных точек
    @member control_point_cols Количество столбцов контрольных точек
  }
  TLN_NurbsSurface = record
    degree_u: Integer;
    degree_v: Integer;
    knot_vector_u: PDouble;
    knot_count_u: Integer;
    knot_vector_v: PDouble;
    knot_count_v: Integer;
    control_points: PXYZW;
    control_point_rows: Integer;
    control_point_cols: Integer;
  end;
  PLN_NurbsSurface = ^TLN_NurbsSurface;

{ Все функции загружаются динамически через LNLibLoader }
{ Используйте переменные-указатели из LNLibLoader:

  Вычисление точек:
    nurbs_surface_get_point_on_surface, nurbs_surface_compute_rational_derivatives,
    nurbs_surface_compute_first_order_derivative, nurbs_surface_curvature,
    nurbs_surface_normal

  Преобразования:
    nurbs_surface_swap_uv, nurbs_surface_reverse, nurbs_surface_is_closed

  Модификация узлов:
    nurbs_surface_insert_knot, nurbs_surface_refine_knot_vector,
    nurbs_surface_remove_knot

  Изменение степени:
    nurbs_surface_elevate_degree, nurbs_surface_reduce_degree

  Декомпозиция и тесселяция:
    nurbs_surface_decompose_to_beziers, nurbs_surface_equally_tessellate

  Поиск параметров:
    nurbs_surface_get_param_on_surface, nurbs_surface_get_param_on_surface_by_gsa,
    nurbs_surface_get_uv_tangent

  Перепараметризация:
    nurbs_surface_reparametrize

  Создание примитивов:
    nurbs_surface_create_bilinear, nurbs_surface_create_cylindrical,
    nurbs_surface_create_ruled, nurbs_surface_create_revolved

  Интерполяция и аппроксимация:
    nurbs_surface_global_interpolation, nurbs_surface_bicubic_local_interpolation,
    nurbs_surface_global_approximation

  Развёртка:
    nurbs_surface_create_swung, nurbs_surface_create_loft,
    nurbs_surface_create_generalized_translational_sweep,
    nurbs_surface_create_sweep_interpolated, nurbs_surface_create_sweep_noninterpolated

  Поверхности по сетке кривых:
    nurbs_surface_create_gordon, nurbs_surface_create_coons

  Площадь и триангуляция:
    nurbs_surface_approximate_area, nurbs_surface_triangulate
}

implementation

end.
