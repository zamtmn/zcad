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
  Модуль NurbsCurve_CAPI - обёртка для работы с NURBS-кривыми.

  Предоставляет интерфейс к функциям C-библиотеки LNLib для создания,
  анализа, модификации и преобразования NURBS-кривых.

  NURBS (Non-Uniform Rational B-Spline) — это математическое представление
  кривых и поверхностей, широко используемое в компьютерной графике и CAD.
  NURBS-кривая определяется степенью, узловым вектором и взвешенными
  контрольными точками.

  Функции загружаются динамически через модуль LNLibLoader.
  Перед использованием функций необходимо проверить IsLNLibLoaded.

  Оригинальный C-заголовок: NurbsCurve_CAPI.h
  Дата создания: 2025-12-02
  Зависимости: XYZ_CAPI, XYZW_CAPI, Matrix4d_CAPI, LNEnums_CAPI
}
unit NurbsCurve_CAPI;

{$mode delphi}{$H+}

interface

uses
  XYZ_CAPI,
  XYZW_CAPI,
  Matrix4d_CAPI,
  LNEnums_CAPI;

type
  {**
    Структура для представления NURBS-кривой.

    Содержит все данные, необходимые для определения NURBS-кривой:
    степень, узловой вектор и взвешенные контрольные точки.

    @member degree Степень кривой (порядок минус 1)
    @member knot_vector Указатель на массив узловых значений
    @member knot_count Количество узлов в узловом векторе
    @member control_points Указатель на массив контрольных точек в
                           однородных координатах
    @member control_point_count Количество контрольных точек
  }
  TLN_NurbsCurve = record
    degree: Integer;
    knot_vector: PDouble;
    knot_count: Integer;
    control_points: PXYZW;
    control_point_count: Integer;
  end;
  PLN_NurbsCurve = ^TLN_NurbsCurve;

{ Все функции загружаются динамически через LNLibLoader }
{ Используйте переменные-указатели из LNLibLoader:

  Создание кривых:
    nurbs_curve_create_line, nurbs_curve_create_arc,
    nurbs_curve_create_open_conic

  Интерполяция и аппроксимация:
    nurbs_curve_global_interpolation, nurbs_curve_global_interpolation_with_tangents,
    nurbs_curve_cubic_local_interpolation, nurbs_curve_least_squares_approximation,
    nurbs_curve_weighted_constrained_least_squares,
    nurbs_curve_global_approximation_by_error_bound

  Вычисление точек:
    nurbs_curve_get_point_on_curve, nurbs_curve_get_point_on_curve_by_corner_cut

  Производные:
    nurbs_curve_compute_rational_derivatives, nurbs_curve_curvature,
    nurbs_curve_torsion, nurbs_curve_normal, nurbs_curve_project_normal

  Параметризация:
    nurbs_curve_get_param_on_curve_by_point, nurbs_curve_approximate_length,
    nurbs_curve_get_param_by_length, nurbs_curve_get_params_by_equal_length

  Разбиение:
    nurbs_curve_split_at, nurbs_curve_segment, nurbs_curve_decompose_to_beziers,
    nurbs_curve_tessellate

  Преобразование:
    nurbs_curve_create_transformed, nurbs_curve_reverse,
    nurbs_curve_reparametrize_to_interval, nurbs_curve_reparametrize_linear_rational

  Модификация узлов:
    nurbs_curve_insert_knot, nurbs_curve_remove_knot,
    nurbs_curve_remove_excessive_knots, nurbs_curve_refine_knot_vector,
    nurbs_curve_elevate_degree, nurbs_curve_reduce_degree

  Проверка свойств:
    nurbs_curve_is_closed, nurbs_curve_is_linear, nurbs_curve_is_clamped,
    nurbs_curve_is_periodic, nurbs_curve_can_compute_derivative

  Модификация контрольных точек:
    nurbs_curve_control_point_reposition, nurbs_curve_weight_modification,
    nurbs_curve_neighbor_weights_modification

  Деформация:
    nurbs_curve_warping, nurbs_curve_flattening, nurbs_curve_bending,
    nurbs_curve_constraint_based_modification

  Преобразование типа:
    nurbs_curve_to_clamp_curve, nurbs_curve_to_unclamp_curve,
    nurbs_curve_equally_tessellate
}

implementation

end.
