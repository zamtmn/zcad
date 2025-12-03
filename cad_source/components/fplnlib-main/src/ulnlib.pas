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
  Модуль uLNLib - динамическая загрузка библиотеки LNLib.

  Обеспечивает кроссплатформенную динамическую загрузку библиотеки LNLib
  вместо статической линковки. Позволяет корректно обрабатывать ситуации,
  когда библиотека отсутствует, и предоставляет гибкое управление загрузкой.

  Основные возможности:
  - Динамическая загрузка библиотеки при старте или по требованию
  - Корректная обработка ошибок загрузки
  - Логирование всех операций
  - Кроссплатформенная поддержка (Windows, Linux, macOS)

  Дата создания: 2025-12-02
}
unit uLNLib;

{$mode delphi}{$H+}

interface

uses
  SysUtils, dynlibs,
  XYZ_CAPI,
  XYZW_CAPI,
  UV_CAPI,
  Matrix4d_CAPI,
  LNEnums_CAPI,
  LNObject_CAPI,
  NurbsCurve_CAPI,
  NurbsSurface_CAPI;

const
  {** Имя динамической библиотеки LNLib для разных платформ **}
    {$IFDEF WINDOWS}
  LNLIB_DLL = 'libCApi.dll';
  {$ELSE}
    {$IFDEF DARWIN}
    LNLIB_DLL = 'libCApi.dylib';
    {$ELSE}
    LNLIB_DLL = 'libCApi.so';
    {$ENDIF}
  {$ENDIF}

{ ========================================================================== }
{                         Статус загрузки библиотеки                         }
{ ========================================================================== }

var
  {** Флаг успешной загрузки библиотеки **}
  LNLibLoaded: Boolean = False;

  {** Дескриптор загруженной библиотеки **}
  LNLibHandle: TLibHandle = NilHandle;

{ ========================================================================== }
{                    Типы указателей на функции XYZ_CAPI                     }
{ ========================================================================== }

type
  Txyz_create = function(x, y, z: Double): TXYZ; cdecl;
  Txyz_zero = function: TXYZ; cdecl;
  Txyz_add = function(a, b: TXYZ): TXYZ; cdecl;
  Txyz_subtract = function(a, b: TXYZ): TXYZ; cdecl;
  Txyz_negative = function(a: TXYZ): TXYZ; cdecl;
  Txyz_multiply = function(a: TXYZ; scalar: Double): TXYZ; cdecl;
  Txyz_divide = function(a: TXYZ; scalar: Double): TXYZ; cdecl;
  Txyz_length = function(v: TXYZ): Double; cdecl;
  Txyz_sqr_length = function(v: TXYZ): Double; cdecl;
  Txyz_is_zero = function(v: TXYZ; epsilon: Double): Integer; cdecl;
  Txyz_is_unit = function(v: TXYZ; epsilon: Double): Integer; cdecl;
  Txyz_normalize = function(v: TXYZ): TXYZ; cdecl;
  Txyz_dot = function(a, b: TXYZ): Double; cdecl;
  Txyz_cross = function(a, b: TXYZ): TXYZ; cdecl;
  Txyz_distance = function(a, b: TXYZ): Double; cdecl;
  Txyz_equals = function(a, b: TXYZ): Integer; cdecl;

{ ========================================================================== }
{                   Типы указателей на функции XYZW_CAPI                     }
{ ========================================================================== }

type
  Txyzw_create = function(wx, wy, wz, w: Double): TXYZW; cdecl;
  Txyzw_create_from_xyz = function(xyz: TXYZ; w: Double): TXYZW; cdecl;
  Txyzw_to_xyz = function(v: TXYZW; divideWeight: Integer): TXYZ; cdecl;
  Txyzw_add = function(a, b: TXYZW): TXYZW; cdecl;
  Txyzw_multiply = function(a: TXYZW; scalar: Double): TXYZW; cdecl;
  Txyzw_divide = function(a: TXYZW; scalar: Double): TXYZW; cdecl;
  Txyzw_distance = function(a, b: TXYZW): Double; cdecl;
  Txyzw_get_wx = function(v: TXYZW): Double; cdecl;
  Txyzw_get_wy = function(v: TXYZW): Double; cdecl;
  Txyzw_get_wz = function(v: TXYZW): Double; cdecl;
  Txyzw_get_w = function(v: TXYZW): Double; cdecl;

{ ========================================================================== }
{                    Типы указателей на функции UV_CAPI                      }
{ ========================================================================== }

type
  Tuv_create = function(u, v: Double): TUV; cdecl;
  Tuv_get_u = function(uv: TUV): Double; cdecl;
  Tuv_get_v = function(uv: TUV): Double; cdecl;
  Tuv_add = function(a, b: TUV): TUV; cdecl;
  Tuv_subtract = function(a, b: TUV): TUV; cdecl;
  Tuv_negative = function(uv: TUV): TUV; cdecl;
  Tuv_normalize = function(uv: TUV): TUV; cdecl;
  Tuv_scale = function(uv: TUV; factor: Double): TUV; cdecl;
  Tuv_divide = function(uv: TUV; divisor: Double): TUV; cdecl;
  Tuv_length = function(uv: TUV): Double; cdecl;
  Tuv_sqr_length = function(uv: TUV): Double; cdecl;
  Tuv_distance = function(a, b: TUV): Double; cdecl;
  Tuv_is_zero = function(uv: TUV; epsilon: Double): Integer; cdecl;
  Tuv_is_unit = function(uv: TUV; epsilon: Double): Integer; cdecl;
  Tuv_is_almost_equal = function(a, b: TUV; epsilon: Double): Integer; cdecl;
  Tuv_dot = function(a, b: TUV): Double; cdecl;
  Tuv_cross = function(a, b: TUV): Double; cdecl;

{ ========================================================================== }
{                 Типы указателей на функции Matrix4d_CAPI                   }
{ ========================================================================== }

type
  Tmatrix4d_identity = function: TMatrix4d; cdecl;
  Tmatrix4d_create_translation = function(vector: TXYZ): TMatrix4d; cdecl;
  Tmatrix4d_create_rotation = function(axis: TXYZ; rad: Double): TMatrix4d; cdecl;
  Tmatrix4d_create_scale = function(scale: TXYZ): TMatrix4d; cdecl;
  Tmatrix4d_create_reflection = function(normal: TXYZ): TMatrix4d; cdecl;
  Tmatrix4d_get_basis_x = function(matrix: TMatrix4d): TXYZ; cdecl;
  Tmatrix4d_get_basis_y = function(matrix: TMatrix4d): TXYZ; cdecl;
  Tmatrix4d_get_basis_z = function(matrix: TMatrix4d): TXYZ; cdecl;
  Tmatrix4d_get_basis_w = function(matrix: TMatrix4d): TXYZ; cdecl;
  Tmatrix4d_of_point = function(matrix: TMatrix4d; point: TXYZ): TXYZ; cdecl;
  Tmatrix4d_of_vector = function(matrix: TMatrix4d; vector: TXYZ): TXYZ; cdecl;
  Tmatrix4d_multiply = function(a, b: TMatrix4d): TMatrix4d; cdecl;
  Tmatrix4d_get_inverse = function(matrix: TMatrix4d; out_inverse: PMatrix4d): Integer; cdecl;
  Tmatrix4d_get_determinant = function(matrix: TMatrix4d): Double; cdecl;

{ ========================================================================== }
{               Типы указателей на функции Projection_CAPI                   }
{ ========================================================================== }

type
  Tprojection_point_to_ray = function(origin, direction, point: TXYZ): TXYZ; cdecl;
  Tprojection_point_to_line = function(start_point, end_point, point: TXYZ;
    out_project_point: PXYZ): Integer; cdecl;
  Tprojection_stereographic = function(point_on_sphere: TXYZ; radius: Double): TXYZ; cdecl;

{ ========================================================================== }
{              Типы указателей на функции BezierCurve_CAPI                   }
{ ========================================================================== }

type
  Tbezier_curve_get_point_by_bernstein = function(degree: Integer;
    control_points: PXYZ; control_points_count: Integer; paramT: Double): TXYZ; cdecl;
  Tbezier_curve_get_point_by_de_casteljau = function(degree: Integer;
    control_points: PXYZ; control_points_count: Integer; paramT: Double): TXYZ; cdecl;
  Tbezier_curve_get_point_by_bernstein_rational = function(degree: Integer;
    control_points: PXYZW; control_points_count: Integer; paramT: Double): TXYZW; cdecl;

{ ========================================================================== }
{             Типы указателей на функции BezierSurface_CAPI                  }
{ ========================================================================== }

type
  Tbezier_surface_get_point_by_de_casteljau = function(degree_u, degree_v: Integer;
    control_points: PXYZ; num_u, num_v: Integer; uv: TUV): TXYZ; cdecl;

{ ========================================================================== }
{              Типы указателей на функции Polynomials_CAPI                   }
{ ========================================================================== }

type
  Tpolynomials_bernstein = function(index, degree: Integer; paramT: Double): Double; cdecl;
  Tpolynomials_all_bernstein = procedure(degree: Integer; paramT: Double;
    out_array: PDouble); cdecl;
  Tpolynomials_horner_curve = function(degree: Integer; const coefficients: PDouble;
    coeff_count: Integer; paramT: Double): Double; cdecl;
  Tpolynomials_get_knot_span_index = function(degree: Integer;
    const knot_vector: PDouble; knot_count: Integer; paramT: Double): Integer; cdecl;
  Tpolynomials_get_knot_multiplicity = function(const knot_vector: PDouble;
    knot_count: Integer; paramT: Double): Integer; cdecl;
  Tpolynomials_basis_functions = procedure(span_index, degree: Integer;
    const knot_vector: PDouble; knot_count: Integer; paramT: Double;
    basis_functions: PDouble); cdecl;
  Tpolynomials_bezier_to_power_matrix = procedure(degree: Integer;
    out_matrix: PDouble); cdecl;

{ ========================================================================== }
{            Типы указателей на функции KnotVectorUtils_CAPI                 }
{ ========================================================================== }

type
  Tknot_vector_utils_get_continuity = function(degree: Integer;
    knot_vector: PDouble; knot_vector_count: Integer; knot: Double): Integer; cdecl;
  Tknot_vector_utils_rescale = procedure(knot_vector: PDouble;
    knot_vector_count: Integer; min_val, max_val: Double;
    out_rescaled_knot_vector: PDouble); cdecl;
  Tknot_vector_utils_is_uniform = function(knot_vector: PDouble;
    knot_vector_count: Integer): Integer; cdecl;
  Tknot_vector_utils_get_knot_multiplicity_map_size = function(
    knot_vector: PDouble; knot_vector_count: Integer): Integer; cdecl;
  Tknot_vector_utils_get_knot_multiplicity_map = procedure(knot_vector: PDouble;
    knot_vector_count: Integer; out_unique_knots: PDouble;
    out_multiplicities: PInteger); cdecl;

{ ========================================================================== }
{             Типы указателей на функции Intersection_CAPI                   }
{ ========================================================================== }

type
  Tintersection_compute_rays = function(point0, vector0, point1, vector1: TXYZ;
    out_param0, out_param1: PDouble;
    out_intersect_point: PXYZ): TCurveCurveIntersectionType; cdecl;
  Tintersection_compute_line_and_plane = function(plane_normal, point_on_plane,
    point_on_line, line_direction: TXYZ;
    out_intersect_point: PXYZ): TLinePlaneIntersectionType; cdecl;

{ ========================================================================== }
{            Типы указателей на функции ValidationUtils_CAPI                 }
{ ========================================================================== }

type
  Tvalidation_utils_is_valid_knot_vector = function(const knot_vector: PDouble;
    count: Integer): Integer; cdecl;
  Tvalidation_utils_is_valid_bezier = function(degree, control_points_count: Integer): Integer; cdecl;
  Tvalidation_utils_is_valid_bspline = function(degree, knot_count, cp_count: Integer): Integer; cdecl;
  Tvalidation_utils_is_valid_nurbs = function(degree, knot_count,
    weighted_cp_count: Integer): Integer; cdecl;
  Tvalidation_utils_compute_curve_modify_tolerance = function(
    const control_points: PXYZW; count: Integer): Double; cdecl;

{ ========================================================================== }
{              Типы указателей на функции NurbsCurve_CAPI                    }
{ ========================================================================== }

type
  { Создание кривых }
  Tnurbs_curve_create_line = function(start_point, end_point: TXYZ): TLN_NurbsCurve; cdecl;
  Tnurbs_curve_create_arc = function(center, x_axis, y_axis: TXYZ;
    start_rad, end_rad, x_radius, y_radius: Double;
    out_curve: PLN_NurbsCurve): Integer; cdecl;
  Tnurbs_curve_create_open_conic = function(start_point, start_tangent,
    end_point, end_tangent, point_on_conic: TXYZ;
    out_curve: PLN_NurbsCurve): Integer; cdecl;

  { Интерполяция и аппроксимация }
  Tnurbs_curve_global_interpolation = procedure(degree: Integer; points: PXYZ;
    point_count: Integer; out_curve: PLN_NurbsCurve); cdecl;
  Tnurbs_curve_global_interpolation_with_tangents = procedure(degree: Integer;
    points, tangents: PXYZ; tangent_factor: Double; point_count: Integer;
    out_curve: PLN_NurbsCurve); cdecl;
  Tnurbs_curve_cubic_local_interpolation = function(points: PXYZ;
    point_count: Integer; out_curve: PLN_NurbsCurve): Integer; cdecl;
  Tnurbs_curve_least_squares_approximation = function(degree: Integer;
    points: PXYZ; point_count, control_point_count: Integer;
    out_curve: PLN_NurbsCurve): Integer; cdecl;
  Tnurbs_curve_weighted_constrained_least_squares = function(degree: Integer;
    points: PXYZ; point_weights: PDouble; tangents: PXYZ;
    tangent_indices: PInteger; tangent_weights: PDouble;
    tangent_count, control_point_count: Integer;
    out_curve: PLN_NurbsCurve): Integer; cdecl;
  Tnurbs_curve_global_approximation_by_error_bound = procedure(degree: Integer;
    points: PXYZ; point_count: Integer; max_error: Double;
    out_curve: PLN_NurbsCurve); cdecl;

  { Вычисление точек }
  Tnurbs_curve_get_point_on_curve = function(curve: TLN_NurbsCurve;
    paramT: Double): TXYZ; cdecl;
  Tnurbs_curve_get_point_on_curve_by_corner_cut = function(curve: TLN_NurbsCurve;
    paramT: Double): TXYZ; cdecl;

  { Производные }
  Tnurbs_curve_compute_rational_derivatives = function(curve: TLN_NurbsCurve;
    derivative_order: Integer; paramT: Double; out_derivatives: PXYZ): Integer; cdecl;
  Tnurbs_curve_curvature = function(curve: TLN_NurbsCurve; paramT: Double): Double; cdecl;
  Tnurbs_curve_torsion = function(curve: TLN_NurbsCurve; paramT: Double): Double; cdecl;
  Tnurbs_curve_normal = function(curve: TLN_NurbsCurve; normal_type: TCurveNormal;
    paramT: Double): TXYZ; cdecl;
  Tnurbs_curve_project_normal = function(curve: TLN_NurbsCurve;
    out_normals: PXYZ): Integer; cdecl;

  { Параметризация }
  Tnurbs_curve_get_param_on_curve_by_point = function(curve: TLN_NurbsCurve;
    given_point: TXYZ): Double; cdecl;
  Tnurbs_curve_approximate_length = function(curve: TLN_NurbsCurve;
    integrator_type: TIntegratorType): Double; cdecl;
  Tnurbs_curve_get_param_by_length = function(curve: TLN_NurbsCurve;
    given_length: Double; integrator_type: TIntegratorType): Double; cdecl;
  Tnurbs_curve_get_params_by_equal_length = function(curve: TLN_NurbsCurve;
    segment_length: Double; integrator_type: TIntegratorType;
    out_params: PDouble): Integer; cdecl;

  { Разбиение }
  Tnurbs_curve_split_at = function(curve: TLN_NurbsCurve; paramT: Double;
    out_left, out_right: PLN_NurbsCurve): Integer; cdecl;
  Tnurbs_curve_segment = function(curve: TLN_NurbsCurve;
    start_param, end_param: Double; out_segment: PLN_NurbsCurve): Integer; cdecl;
  Tnurbs_curve_decompose_to_beziers = function(curve: TLN_NurbsCurve;
    out_segments: PLN_NurbsCurve; max_segments: Integer): Integer; cdecl;
  Tnurbs_curve_tessellate = function(curve: TLN_NurbsCurve;
    out_points: PXYZ): Integer; cdecl;

  { Преобразование }
  Tnurbs_curve_create_transformed = procedure(curve: TLN_NurbsCurve;
    matrix: TMatrix4d; out_curve: PLN_NurbsCurve); cdecl;
  Tnurbs_curve_reverse = procedure(curve: TLN_NurbsCurve;
    out_curve: PLN_NurbsCurve); cdecl;
  Tnurbs_curve_reparametrize_to_interval = procedure(curve: TLN_NurbsCurve;
    min_val, max_val: Double; out_curve: PLN_NurbsCurve); cdecl;
  Tnurbs_curve_reparametrize_linear_rational = procedure(curve: TLN_NurbsCurve;
    alpha, beta, gamma, delta: Double; out_curve: PLN_NurbsCurve); cdecl;

  { Модификация узлов }
  Tnurbs_curve_insert_knot = function(curve: TLN_NurbsCurve;
    knot_value: Double; times: Integer; out_curve: PLN_NurbsCurve): Integer; cdecl;
  Tnurbs_curve_remove_knot = function(curve: TLN_NurbsCurve;
    knot_value: Double; times: Integer; out_curve: PLN_NurbsCurve): Integer; cdecl;
  Tnurbs_curve_remove_excessive_knots = procedure(curve: TLN_NurbsCurve;
    out_curve: PLN_NurbsCurve); cdecl;
  Tnurbs_curve_refine_knot_vector = procedure(curve: TLN_NurbsCurve;
    insert_knots: PDouble; insert_count: Integer; out_curve: PLN_NurbsCurve); cdecl;
  Tnurbs_curve_elevate_degree = procedure(curve: TLN_NurbsCurve; times: Integer;
    out_curve: PLN_NurbsCurve); cdecl;
  Tnurbs_curve_reduce_degree = function(curve: TLN_NurbsCurve;
    out_curve: PLN_NurbsCurve): Integer; cdecl;

  { Проверка свойств }
  Tnurbs_curve_is_closed = function(curve: TLN_NurbsCurve): Integer; cdecl;
  Tnurbs_curve_is_linear = function(curve: TLN_NurbsCurve): Integer; cdecl;
  Tnurbs_curve_is_clamped = function(curve: TLN_NurbsCurve): Integer; cdecl;
  Tnurbs_curve_is_periodic = function(curve: TLN_NurbsCurve): Integer; cdecl;
  Tnurbs_curve_can_compute_derivative = function(curve: TLN_NurbsCurve;
    paramT: Double): Integer; cdecl;

  { Модификация контрольных точек }
  Tnurbs_curve_control_point_reposition = function(curve: TLN_NurbsCurve;
    paramT: Double; move_index: Integer; move_direction: TXYZ;
    move_distance: Double; out_curve: PLN_NurbsCurve): Integer; cdecl;
  Tnurbs_curve_weight_modification = procedure(curve: TLN_NurbsCurve;
    paramT: Double; move_index: Integer; move_distance: Double;
    out_curve: PLN_NurbsCurve); cdecl;
  Tnurbs_curve_neighbor_weights_modification = function(curve: TLN_NurbsCurve;
    paramT: Double; move_index: Integer; move_distance, scale: Double;
    out_curve: PLN_NurbsCurve): Integer; cdecl;

  { Деформация }
  Tnurbs_curve_warping = procedure(curve: TLN_NurbsCurve; warp_shape: PDouble;
    warp_shape_count: Integer; warp_distance: Double; plane_normal: TXYZ;
    start_param, end_param: Double; out_curve: PLN_NurbsCurve); cdecl;
  Tnurbs_curve_flattening = function(curve: TLN_NurbsCurve;
    line_start, line_end: TXYZ; start_param, end_param: Double;
    out_curve: PLN_NurbsCurve): Integer; cdecl;
  Tnurbs_curve_bending = procedure(curve: TLN_NurbsCurve;
    start_param, end_param: Double; bend_center: TXYZ;
    radius, cross_ratio: Double; out_curve: PLN_NurbsCurve); cdecl;
  Tnurbs_curve_constraint_based_modification = procedure(curve: TLN_NurbsCurve;
    constraint_params: PDouble; derivative_constraints: PXYZ;
    applied_indices, applied_degrees, fixed_cp_indices: PInteger;
    constraint_count, fixed_count: Integer; out_curve: PLN_NurbsCurve); cdecl;

  { Преобразование типа }
  Tnurbs_curve_to_clamp_curve = procedure(curve: TLN_NurbsCurve;
    out_curve: PLN_NurbsCurve); cdecl;
  Tnurbs_curve_to_unclamp_curve = procedure(curve: TLN_NurbsCurve;
    out_curve: PLN_NurbsCurve); cdecl;
  Tnurbs_curve_equally_tessellate = procedure(curve: TLN_NurbsCurve;
    out_points: PXYZ; out_knots: PDouble; max_count: Integer); cdecl;

{ ========================================================================== }
{             Типы указателей на функции NurbsSurface_CAPI                   }
{ ========================================================================== }

type
  { Вычисление точек }
  Tnurbs_surface_get_point_on_surface = function(surface: TLN_NurbsSurface;
    uv: TUV): TXYZ; cdecl;
  Tnurbs_surface_compute_rational_derivatives = function(surface: TLN_NurbsSurface;
    derivative_order: Integer; uv: TUV; out_derivatives: PXYZ): Integer; cdecl;
  Tnurbs_surface_compute_first_order_derivative = procedure(surface: TLN_NurbsSurface;
    uv: TUV; out_S, out_Su, out_Sv: PXYZ); cdecl;
  Tnurbs_surface_curvature = function(surface: TLN_NurbsSurface;
    curvature_type: Integer; uv: TUV): Double; cdecl;
  Tnurbs_surface_normal = function(surface: TLN_NurbsSurface; uv: TUV): TXYZ; cdecl;

  { Преобразования }
  Tnurbs_surface_swap_uv = procedure(surface: TLN_NurbsSurface;
    out_surface: PLN_NurbsSurface); cdecl;
  Tnurbs_surface_reverse = procedure(surface: TLN_NurbsSurface; direction: Integer;
    out_surface: PLN_NurbsSurface); cdecl;
  Tnurbs_surface_is_closed = function(surface: TLN_NurbsSurface;
    is_u_direction: Integer): Integer; cdecl;

  { Модификация узлов }
  Tnurbs_surface_insert_knot = procedure(surface: TLN_NurbsSurface;
    knot_value: Double; times, is_u_direction: Integer;
    out_surface: PLN_NurbsSurface); cdecl;
  Tnurbs_surface_refine_knot_vector = procedure(surface: TLN_NurbsSurface;
    insert_knots: PDouble; insert_count, is_u_direction: Integer;
    out_surface: PLN_NurbsSurface); cdecl;
  Tnurbs_surface_remove_knot = procedure(surface: TLN_NurbsSurface;
    knot_value: Double; times, is_u_direction: Integer;
    out_surface: PLN_NurbsSurface); cdecl;

  { Изменение степени }
  Tnurbs_surface_elevate_degree = procedure(surface: TLN_NurbsSurface;
    times, is_u_direction: Integer; out_surface: PLN_NurbsSurface); cdecl;
  Tnurbs_surface_reduce_degree = function(surface: TLN_NurbsSurface;
    is_u_direction: Integer; out_surface: PLN_NurbsSurface): Integer; cdecl;

  { Декомпозиция и тесселяция }
  Tnurbs_surface_decompose_to_beziers = function(surface: TLN_NurbsSurface;
    out_patches: PLN_NurbsSurface; max_patches: Integer): Integer; cdecl;
  Tnurbs_surface_equally_tessellate = procedure(surface: TLN_NurbsSurface;
    out_points: PXYZ; out_uvs: PUV; max_count: Integer); cdecl;

  { Поиск параметров }
  Tnurbs_surface_get_param_on_surface = function(surface: TLN_NurbsSurface;
    given_point: TXYZ): TUV; cdecl;
  Tnurbs_surface_get_param_on_surface_by_gsa = function(surface: TLN_NurbsSurface;
    given_point: TXYZ): TUV; cdecl;
  Tnurbs_surface_get_uv_tangent = function(surface: TLN_NurbsSurface;
    param: TUV; tangent: TXYZ; out_uv_tangent: PUV): Integer; cdecl;

  { Перепараметризация }
  Tnurbs_surface_reparametrize = procedure(surface: TLN_NurbsSurface;
    min_u, max_u, min_v, max_v: Double; out_surface: PLN_NurbsSurface); cdecl;

  { Создание примитивов }
  Tnurbs_surface_create_bilinear = procedure(top_left, top_right,
    bottom_left, bottom_right: TXYZ; out_surface: PLN_NurbsSurface); cdecl;
  Tnurbs_surface_create_cylindrical = function(origin, x_axis, y_axis: TXYZ;
    start_rad, end_rad, radius, height: Double;
    out_surface: PLN_NurbsSurface): Integer; cdecl;
  Tnurbs_surface_create_ruled = procedure(curve0, curve1: TLN_NurbsCurve;
    out_surface: PLN_NurbsSurface); cdecl;
  Tnurbs_surface_create_revolved = function(origin, axis: TXYZ; rad: Double;
    profile: TLN_NurbsCurve; out_surface: PLN_NurbsSurface): Integer; cdecl;

  { Интерполяция и аппроксимация }
  Tnurbs_surface_global_interpolation = procedure(points: PXYZ;
    rows, cols, degree_u, degree_v: Integer;
    out_surface: PLN_NurbsSurface); cdecl;
  Tnurbs_surface_bicubic_local_interpolation = function(points: PXYZ;
    rows, cols: Integer; out_surface: PLN_NurbsSurface): Integer; cdecl;
  Tnurbs_surface_global_approximation = function(points: PXYZ;
    rows, cols, degree_u, degree_v, ctrl_rows, ctrl_cols: Integer;
    out_surface: PLN_NurbsSurface): Integer; cdecl;

  { Развёртка }
  Tnurbs_surface_create_swung = function(profile, trajectory: TLN_NurbsCurve;
    scale: Double; out_surface: PLN_NurbsSurface): Integer; cdecl;
  Tnurbs_surface_create_loft = procedure(sections: PLN_NurbsCurve;
    section_count: Integer; out_surface: PLN_NurbsSurface;
    custom_trajectory_degree: Integer; custom_knots: PDouble;
    knot_count: Integer); cdecl;
  Tnurbs_surface_create_generalized_translational_sweep = procedure(
    profile, trajectory: TLN_NurbsCurve; out_surface: PLN_NurbsSurface); cdecl;
  Tnurbs_surface_create_sweep_interpolated = procedure(
    profile, trajectory: TLN_NurbsCurve; min_profiles: Integer;
    out_surface: PLN_NurbsSurface); cdecl;
  Tnurbs_surface_create_sweep_noninterpolated = procedure(
    profile, trajectory: TLN_NurbsCurve; min_profiles, trajectory_degree: Integer;
    out_surface: PLN_NurbsSurface); cdecl;

  { Поверхности по сетке кривых }
  Tnurbs_surface_create_gordon = procedure(u_curves: PLN_NurbsCurve;
    u_count: Integer; v_curves: PLN_NurbsCurve; v_count: Integer;
    intersections: PXYZ; out_surface: PLN_NurbsSurface); cdecl;
  Tnurbs_surface_create_coons = procedure(left, bottom, right, top: TLN_NurbsCurve;
    out_surface: PLN_NurbsSurface); cdecl;

  { Площадь и триангуляция }
  Tnurbs_surface_approximate_area = function(surface: TLN_NurbsSurface;
    integrator_type: Integer): Double; cdecl;
  Tnurbs_surface_triangulate = function(surface: TLN_NurbsSurface;
    resolution_u, resolution_v, use_delaunay: Integer): TLNMesh; cdecl;

{ ========================================================================== }
{                   Глобальные указатели на функции                          }
{ ========================================================================== }

var
  { XYZ_CAPI }
  xyz_create: Txyz_create = nil;
  xyz_zero: Txyz_zero = nil;
  xyz_add: Txyz_add = nil;
  xyz_subtract: Txyz_subtract = nil;
  xyz_negative: Txyz_negative = nil;
  xyz_multiply: Txyz_multiply = nil;
  xyz_divide: Txyz_divide = nil;
  xyz_length: Txyz_length = nil;
  xyz_sqr_length: Txyz_sqr_length = nil;
  xyz_is_zero: Txyz_is_zero = nil;
  xyz_is_unit: Txyz_is_unit = nil;
  xyz_normalize: Txyz_normalize = nil;
  xyz_dot: Txyz_dot = nil;
  xyz_cross: Txyz_cross = nil;
  xyz_distance: Txyz_distance = nil;
  xyz_equals: Txyz_equals = nil;

  { XYZW_CAPI }
  xyzw_create: Txyzw_create = nil;
  xyzw_create_from_xyz: Txyzw_create_from_xyz = nil;
  xyzw_to_xyz: Txyzw_to_xyz = nil;
  xyzw_add: Txyzw_add = nil;
  xyzw_multiply: Txyzw_multiply = nil;
  xyzw_divide: Txyzw_divide = nil;
  xyzw_distance: Txyzw_distance = nil;
  xyzw_get_wx: Txyzw_get_wx = nil;
  xyzw_get_wy: Txyzw_get_wy = nil;
  xyzw_get_wz: Txyzw_get_wz = nil;
  xyzw_get_w: Txyzw_get_w = nil;

  { UV_CAPI }
  uv_create: Tuv_create = nil;
  uv_get_u: Tuv_get_u = nil;
  uv_get_v: Tuv_get_v = nil;
  uv_add: Tuv_add = nil;
  uv_subtract: Tuv_subtract = nil;
  uv_negative: Tuv_negative = nil;
  uv_normalize: Tuv_normalize = nil;
  uv_scale: Tuv_scale = nil;
  uv_divide: Tuv_divide = nil;
  uv_length: Tuv_length = nil;
  uv_sqr_length: Tuv_sqr_length = nil;
  uv_distance: Tuv_distance = nil;
  uv_is_zero: Tuv_is_zero = nil;
  uv_is_unit: Tuv_is_unit = nil;
  uv_is_almost_equal: Tuv_is_almost_equal = nil;
  uv_dot: Tuv_dot = nil;
  uv_cross: Tuv_cross = nil;

  { Matrix4d_CAPI }
  matrix4d_identity: Tmatrix4d_identity = nil;
  matrix4d_create_translation: Tmatrix4d_create_translation = nil;
  matrix4d_create_rotation: Tmatrix4d_create_rotation = nil;
  matrix4d_create_scale: Tmatrix4d_create_scale = nil;
  matrix4d_create_reflection: Tmatrix4d_create_reflection = nil;
  matrix4d_get_basis_x: Tmatrix4d_get_basis_x = nil;
  matrix4d_get_basis_y: Tmatrix4d_get_basis_y = nil;
  matrix4d_get_basis_z: Tmatrix4d_get_basis_z = nil;
  matrix4d_get_basis_w: Tmatrix4d_get_basis_w = nil;
  matrix4d_of_point: Tmatrix4d_of_point = nil;
  matrix4d_of_vector: Tmatrix4d_of_vector = nil;
  matrix4d_multiply: Tmatrix4d_multiply = nil;
  matrix4d_get_inverse: Tmatrix4d_get_inverse = nil;
  matrix4d_get_determinant: Tmatrix4d_get_determinant = nil;

  { Projection_CAPI }
  projection_point_to_ray: Tprojection_point_to_ray = nil;
  projection_point_to_line: Tprojection_point_to_line = nil;
  projection_stereographic: Tprojection_stereographic = nil;

  { BezierCurve_CAPI }
  bezier_curve_get_point_by_bernstein: Tbezier_curve_get_point_by_bernstein = nil;
  bezier_curve_get_point_by_de_casteljau: Tbezier_curve_get_point_by_de_casteljau = nil;
  bezier_curve_get_point_by_bernstein_rational: Tbezier_curve_get_point_by_bernstein_rational = nil;

  { BezierSurface_CAPI }
  bezier_surface_get_point_by_de_casteljau: Tbezier_surface_get_point_by_de_casteljau = nil;

  { Polynomials_CAPI }
  polynomials_bernstein: Tpolynomials_bernstein = nil;
  polynomials_all_bernstein: Tpolynomials_all_bernstein = nil;
  polynomials_horner_curve: Tpolynomials_horner_curve = nil;
  polynomials_get_knot_span_index: Tpolynomials_get_knot_span_index = nil;
  polynomials_get_knot_multiplicity: Tpolynomials_get_knot_multiplicity = nil;
  polynomials_basis_functions: Tpolynomials_basis_functions = nil;
  polynomials_bezier_to_power_matrix: Tpolynomials_bezier_to_power_matrix = nil;

  { KnotVectorUtils_CAPI }
  knot_vector_utils_get_continuity: Tknot_vector_utils_get_continuity = nil;
  knot_vector_utils_rescale: Tknot_vector_utils_rescale = nil;
  knot_vector_utils_is_uniform: Tknot_vector_utils_is_uniform = nil;
  knot_vector_utils_get_knot_multiplicity_map_size: Tknot_vector_utils_get_knot_multiplicity_map_size = nil;
  knot_vector_utils_get_knot_multiplicity_map: Tknot_vector_utils_get_knot_multiplicity_map = nil;

  { Intersection_CAPI }
  intersection_compute_rays: Tintersection_compute_rays = nil;
  intersection_compute_line_and_plane: Tintersection_compute_line_and_plane = nil;

  { ValidationUtils_CAPI }
  validation_utils_is_valid_knot_vector: Tvalidation_utils_is_valid_knot_vector = nil;
  validation_utils_is_valid_bezier: Tvalidation_utils_is_valid_bezier = nil;
  validation_utils_is_valid_bspline: Tvalidation_utils_is_valid_bspline = nil;
  validation_utils_is_valid_nurbs: Tvalidation_utils_is_valid_nurbs = nil;
  validation_utils_compute_curve_modify_tolerance: Tvalidation_utils_compute_curve_modify_tolerance = nil;

  { NurbsCurve_CAPI - Создание }
  nurbs_curve_create_line: Tnurbs_curve_create_line = nil;
  nurbs_curve_create_arc: Tnurbs_curve_create_arc = nil;
  nurbs_curve_create_open_conic: Tnurbs_curve_create_open_conic = nil;

  { NurbsCurve_CAPI - Интерполяция }
  nurbs_curve_global_interpolation: Tnurbs_curve_global_interpolation = nil;
  nurbs_curve_global_interpolation_with_tangents: Tnurbs_curve_global_interpolation_with_tangents = nil;
  nurbs_curve_cubic_local_interpolation: Tnurbs_curve_cubic_local_interpolation = nil;
  nurbs_curve_least_squares_approximation: Tnurbs_curve_least_squares_approximation = nil;
  nurbs_curve_weighted_constrained_least_squares: Tnurbs_curve_weighted_constrained_least_squares = nil;
  nurbs_curve_global_approximation_by_error_bound: Tnurbs_curve_global_approximation_by_error_bound = nil;

  { NurbsCurve_CAPI - Вычисление точек }
  nurbs_curve_get_point_on_curve: Tnurbs_curve_get_point_on_curve = nil;
  nurbs_curve_get_point_on_curve_by_corner_cut: Tnurbs_curve_get_point_on_curve_by_corner_cut = nil;

  { NurbsCurve_CAPI - Производные }
  nurbs_curve_compute_rational_derivatives: Tnurbs_curve_compute_rational_derivatives = nil;
  nurbs_curve_curvature: Tnurbs_curve_curvature = nil;
  nurbs_curve_torsion: Tnurbs_curve_torsion = nil;
  nurbs_curve_normal: Tnurbs_curve_normal = nil;
  nurbs_curve_project_normal: Tnurbs_curve_project_normal = nil;

  { NurbsCurve_CAPI - Параметризация }
  nurbs_curve_get_param_on_curve_by_point: Tnurbs_curve_get_param_on_curve_by_point = nil;
  nurbs_curve_approximate_length: Tnurbs_curve_approximate_length = nil;
  nurbs_curve_get_param_by_length: Tnurbs_curve_get_param_by_length = nil;
  nurbs_curve_get_params_by_equal_length: Tnurbs_curve_get_params_by_equal_length = nil;

  { NurbsCurve_CAPI - Разбиение }
  nurbs_curve_split_at: Tnurbs_curve_split_at = nil;
  nurbs_curve_segment: Tnurbs_curve_segment = nil;
  nurbs_curve_decompose_to_beziers: Tnurbs_curve_decompose_to_beziers = nil;
  nurbs_curve_tessellate: Tnurbs_curve_tessellate = nil;

  { NurbsCurve_CAPI - Преобразование }
  nurbs_curve_create_transformed: Tnurbs_curve_create_transformed = nil;
  nurbs_curve_reverse: Tnurbs_curve_reverse = nil;
  nurbs_curve_reparametrize_to_interval: Tnurbs_curve_reparametrize_to_interval = nil;
  nurbs_curve_reparametrize_linear_rational: Tnurbs_curve_reparametrize_linear_rational = nil;

  { NurbsCurve_CAPI - Модификация узлов }
  nurbs_curve_insert_knot: Tnurbs_curve_insert_knot = nil;
  nurbs_curve_remove_knot: Tnurbs_curve_remove_knot = nil;
  nurbs_curve_remove_excessive_knots: Tnurbs_curve_remove_excessive_knots = nil;
  nurbs_curve_refine_knot_vector: Tnurbs_curve_refine_knot_vector = nil;
  nurbs_curve_elevate_degree: Tnurbs_curve_elevate_degree = nil;
  nurbs_curve_reduce_degree: Tnurbs_curve_reduce_degree = nil;

  { NurbsCurve_CAPI - Проверка свойств }
  nurbs_curve_is_closed: Tnurbs_curve_is_closed = nil;
  nurbs_curve_is_linear: Tnurbs_curve_is_linear = nil;
  nurbs_curve_is_clamped: Tnurbs_curve_is_clamped = nil;
  nurbs_curve_is_periodic: Tnurbs_curve_is_periodic = nil;
  nurbs_curve_can_compute_derivative: Tnurbs_curve_can_compute_derivative = nil;

  { NurbsCurve_CAPI - Модификация контрольных точек }
  nurbs_curve_control_point_reposition: Tnurbs_curve_control_point_reposition = nil;
  nurbs_curve_weight_modification: Tnurbs_curve_weight_modification = nil;
  nurbs_curve_neighbor_weights_modification: Tnurbs_curve_neighbor_weights_modification = nil;

  { NurbsCurve_CAPI - Деформация }
  nurbs_curve_warping: Tnurbs_curve_warping = nil;
  nurbs_curve_flattening: Tnurbs_curve_flattening = nil;
  nurbs_curve_bending: Tnurbs_curve_bending = nil;
  nurbs_curve_constraint_based_modification: Tnurbs_curve_constraint_based_modification = nil;

  { NurbsCurve_CAPI - Преобразование типа }
  nurbs_curve_to_clamp_curve: Tnurbs_curve_to_clamp_curve = nil;
  nurbs_curve_to_unclamp_curve: Tnurbs_curve_to_unclamp_curve = nil;
  nurbs_curve_equally_tessellate: Tnurbs_curve_equally_tessellate = nil;

  { NurbsSurface_CAPI - Вычисление точек }
  nurbs_surface_get_point_on_surface: Tnurbs_surface_get_point_on_surface = nil;
  nurbs_surface_compute_rational_derivatives: Tnurbs_surface_compute_rational_derivatives = nil;
  nurbs_surface_compute_first_order_derivative: Tnurbs_surface_compute_first_order_derivative = nil;
  nurbs_surface_curvature: Tnurbs_surface_curvature = nil;
  nurbs_surface_normal: Tnurbs_surface_normal = nil;

  { NurbsSurface_CAPI - Преобразования }
  nurbs_surface_swap_uv: Tnurbs_surface_swap_uv = nil;
  nurbs_surface_reverse: Tnurbs_surface_reverse = nil;
  nurbs_surface_is_closed: Tnurbs_surface_is_closed = nil;

  { NurbsSurface_CAPI - Модификация узлов }
  nurbs_surface_insert_knot: Tnurbs_surface_insert_knot = nil;
  nurbs_surface_refine_knot_vector: Tnurbs_surface_refine_knot_vector = nil;
  nurbs_surface_remove_knot: Tnurbs_surface_remove_knot = nil;

  { NurbsSurface_CAPI - Изменение степени }
  nurbs_surface_elevate_degree: Tnurbs_surface_elevate_degree = nil;
  nurbs_surface_reduce_degree: Tnurbs_surface_reduce_degree = nil;

  { NurbsSurface_CAPI - Декомпозиция и тесселяция }
  nurbs_surface_decompose_to_beziers: Tnurbs_surface_decompose_to_beziers = nil;
  nurbs_surface_equally_tessellate: Tnurbs_surface_equally_tessellate = nil;

  { NurbsSurface_CAPI - Поиск параметров }
  nurbs_surface_get_param_on_surface: Tnurbs_surface_get_param_on_surface = nil;
  nurbs_surface_get_param_on_surface_by_gsa: Tnurbs_surface_get_param_on_surface_by_gsa = nil;
  nurbs_surface_get_uv_tangent: Tnurbs_surface_get_uv_tangent = nil;

  { NurbsSurface_CAPI - Перепараметризация }
  nurbs_surface_reparametrize: Tnurbs_surface_reparametrize = nil;

  { NurbsSurface_CAPI - Создание примитивов }
  nurbs_surface_create_bilinear: Tnurbs_surface_create_bilinear = nil;
  nurbs_surface_create_cylindrical: Tnurbs_surface_create_cylindrical = nil;
  nurbs_surface_create_ruled: Tnurbs_surface_create_ruled = nil;
  nurbs_surface_create_revolved: Tnurbs_surface_create_revolved = nil;

  { NurbsSurface_CAPI - Интерполяция и аппроксимация }
  nurbs_surface_global_interpolation: Tnurbs_surface_global_interpolation = nil;
  nurbs_surface_bicubic_local_interpolation: Tnurbs_surface_bicubic_local_interpolation = nil;
  nurbs_surface_global_approximation: Tnurbs_surface_global_approximation = nil;

  { NurbsSurface_CAPI - Развёртка }
  nurbs_surface_create_swung: Tnurbs_surface_create_swung = nil;
  nurbs_surface_create_loft: Tnurbs_surface_create_loft = nil;
  nurbs_surface_create_generalized_translational_sweep: Tnurbs_surface_create_generalized_translational_sweep = nil;
  nurbs_surface_create_sweep_interpolated: Tnurbs_surface_create_sweep_interpolated = nil;
  nurbs_surface_create_sweep_noninterpolated: Tnurbs_surface_create_sweep_noninterpolated = nil;

  { NurbsSurface_CAPI - Поверхности по сетке кривых }
  nurbs_surface_create_gordon: Tnurbs_surface_create_gordon = nil;
  nurbs_surface_create_coons: Tnurbs_surface_create_coons = nil;

  { NurbsSurface_CAPI - Площадь и триангуляция }
  nurbs_surface_approximate_area: Tnurbs_surface_approximate_area = nil;
  nurbs_surface_triangulate: Tnurbs_surface_triangulate = nil;

{ ========================================================================== }
{                      Функции загрузки и выгрузки                           }
{ ========================================================================== }

{**
  Загрузка библиотеки LNLib.

  Выполняет динамическую загрузку библиотеки и разрешение адресов всех
  экспортируемых функций. При ошибке логирует информацию и возвращает False.

  @return True если библиотека загружена успешно, False при ошибке
}
function LoadLNLib: Boolean;

{**
  Выгрузка библиотеки LNLib.

  Освобождает загруженную библиотеку и обнуляет все указатели на функции.
}
procedure UnloadLNLib;

{**
  Проверка, загружена ли библиотека LNLib.

  @return True если библиотека загружена, False в противном случае
}
function IsLNLibLoaded: Boolean;

implementation

{**
  Вспомогательная функция для загрузки адреса функции из библиотеки.

  @param FuncName Имя функции для загрузки
  @param FuncPtr Указатель на переменную для сохранения адреса
  @return True если адрес загружен успешно, False при ошибке
}
function LoadFuncAddr(const FuncName: string; var FuncPtr: Pointer): Boolean;
begin
  FuncPtr := GetProcAddress(LNLibHandle, PChar(FuncName));
  Result := FuncPtr <> nil;
end;

{**
  Загрузка всех функций XYZ_CAPI.

  @return True если все функции загружены успешно
}
function LoadXYZFunctions: Boolean;
begin
  Result := True;
  Result := LoadFuncAddr('xyz_create', @xyz_create) and Result;
  Result := LoadFuncAddr('xyz_zero', @xyz_zero) and Result;
  Result := LoadFuncAddr('xyz_add', @xyz_add) and Result;
  Result := LoadFuncAddr('xyz_subtract', @xyz_subtract) and Result;
  Result := LoadFuncAddr('xyz_negative', @xyz_negative) and Result;
  Result := LoadFuncAddr('xyz_multiply', @xyz_multiply) and Result;
  Result := LoadFuncAddr('xyz_divide', @xyz_divide) and Result;
  Result := LoadFuncAddr('xyz_length', @xyz_length) and Result;
  Result := LoadFuncAddr('xyz_sqr_length', @xyz_sqr_length) and Result;
  Result := LoadFuncAddr('xyz_is_zero', @xyz_is_zero) and Result;
  Result := LoadFuncAddr('xyz_is_unit', @xyz_is_unit) and Result;
  Result := LoadFuncAddr('xyz_normalize', @xyz_normalize) and Result;
  Result := LoadFuncAddr('xyz_dot', @xyz_dot) and Result;
  Result := LoadFuncAddr('xyz_cross', @xyz_cross) and Result;
  Result := LoadFuncAddr('xyz_distance', @xyz_distance) and Result;
  Result := LoadFuncAddr('xyz_equals', @xyz_equals) and Result;
end;

{**
  Загрузка всех функций XYZW_CAPI.

  @return True если все функции загружены успешно
}
function LoadXYZWFunctions: Boolean;
begin
  Result := True;
  Result := LoadFuncAddr('xyzw_create', @xyzw_create) and Result;
  Result := LoadFuncAddr('xyzw_create_from_xyz', @xyzw_create_from_xyz) and Result;
  Result := LoadFuncAddr('xyzw_to_xyz', @xyzw_to_xyz) and Result;
  Result := LoadFuncAddr('xyzw_add', @xyzw_add) and Result;
  Result := LoadFuncAddr('xyzw_multiply', @xyzw_multiply) and Result;
  Result := LoadFuncAddr('xyzw_divide', @xyzw_divide) and Result;
  Result := LoadFuncAddr('xyzw_distance', @xyzw_distance) and Result;
  Result := LoadFuncAddr('xyzw_get_wx', @xyzw_get_wx) and Result;
  Result := LoadFuncAddr('xyzw_get_wy', @xyzw_get_wy) and Result;
  Result := LoadFuncAddr('xyzw_get_wz', @xyzw_get_wz) and Result;
  Result := LoadFuncAddr('xyzw_get_w', @xyzw_get_w) and Result;
end;

{**
  Загрузка всех функций UV_CAPI.

  @return True если все функции загружены успешно
}
function LoadUVFunctions: Boolean;
begin
  Result := True;
  Result := LoadFuncAddr('uv_create', @uv_create) and Result;
  Result := LoadFuncAddr('uv_get_u', @uv_get_u) and Result;
  Result := LoadFuncAddr('uv_get_v', @uv_get_v) and Result;
  Result := LoadFuncAddr('uv_add', @uv_add) and Result;
  Result := LoadFuncAddr('uv_subtract', @uv_subtract) and Result;
  Result := LoadFuncAddr('uv_negative', @uv_negative) and Result;
  Result := LoadFuncAddr('uv_normalize', @uv_normalize) and Result;
  Result := LoadFuncAddr('uv_scale', @uv_scale) and Result;
  Result := LoadFuncAddr('uv_divide', @uv_divide) and Result;
  Result := LoadFuncAddr('uv_length', @uv_length) and Result;
  Result := LoadFuncAddr('uv_sqr_length', @uv_sqr_length) and Result;
  Result := LoadFuncAddr('uv_distance', @uv_distance) and Result;
  Result := LoadFuncAddr('uv_is_zero', @uv_is_zero) and Result;
  Result := LoadFuncAddr('uv_is_unit', @uv_is_unit) and Result;
  Result := LoadFuncAddr('uv_is_almost_equal', @uv_is_almost_equal) and Result;
  Result := LoadFuncAddr('uv_dot', @uv_dot) and Result;
  Result := LoadFuncAddr('uv_cross', @uv_cross) and Result;
end;

{**
  Загрузка всех функций Matrix4d_CAPI.

  @return True если все функции загружены успешно
}
function LoadMatrix4dFunctions: Boolean;
begin
  Result := True;
  Result := LoadFuncAddr('matrix4d_identity', @matrix4d_identity) and Result;
  Result := LoadFuncAddr('matrix4d_create_translation', @matrix4d_create_translation) and Result;
  Result := LoadFuncAddr('matrix4d_create_rotation', @matrix4d_create_rotation) and Result;
  Result := LoadFuncAddr('matrix4d_create_scale', @matrix4d_create_scale) and Result;
  Result := LoadFuncAddr('matrix4d_create_reflection', @matrix4d_create_reflection) and Result;
  Result := LoadFuncAddr('matrix4d_get_basis_x', @matrix4d_get_basis_x) and Result;
  Result := LoadFuncAddr('matrix4d_get_basis_y', @matrix4d_get_basis_y) and Result;
  Result := LoadFuncAddr('matrix4d_get_basis_z', @matrix4d_get_basis_z) and Result;
  Result := LoadFuncAddr('matrix4d_get_basis_w', @matrix4d_get_basis_w) and Result;
  Result := LoadFuncAddr('matrix4d_of_point', @matrix4d_of_point) and Result;
  Result := LoadFuncAddr('matrix4d_of_vector', @matrix4d_of_vector) and Result;
  Result := LoadFuncAddr('matrix4d_multiply', @matrix4d_multiply) and Result;
  Result := LoadFuncAddr('matrix4d_get_inverse', @matrix4d_get_inverse) and Result;
  Result := LoadFuncAddr('matrix4d_get_determinant', @matrix4d_get_determinant) and Result;
end;

{**
  Загрузка всех функций Projection_CAPI.

  @return True если все функции загружены успешно
}
function LoadProjectionFunctions: Boolean;
begin
  Result := True;
  Result := LoadFuncAddr('projection_point_to_ray', @projection_point_to_ray) and Result;
  Result := LoadFuncAddr('projection_point_to_line', @projection_point_to_line) and Result;
  Result := LoadFuncAddr('projection_stereographic', @projection_stereographic) and Result;
end;

{**
  Загрузка всех функций BezierCurve_CAPI.

  @return True если все функции загружены успешно
}
function LoadBezierCurveFunctions: Boolean;
begin
  Result := True;
  Result := LoadFuncAddr('bezier_curve_get_point_by_bernstein',
    @bezier_curve_get_point_by_bernstein) and Result;
  Result := LoadFuncAddr('bezier_curve_get_point_by_de_casteljau',
    @bezier_curve_get_point_by_de_casteljau) and Result;
  Result := LoadFuncAddr('bezier_curve_get_point_by_bernstein_rational',
    @bezier_curve_get_point_by_bernstein_rational) and Result;
end;

{**
  Загрузка всех функций BezierSurface_CAPI.

  @return True если все функции загружены успешно
}
function LoadBezierSurfaceFunctions: Boolean;
begin
  Result := True;
  Result := LoadFuncAddr('bezier_surface_get_point_by_de_casteljau',
    @bezier_surface_get_point_by_de_casteljau) and Result;
end;

{**
  Загрузка всех функций Polynomials_CAPI.

  @return True если все функции загружены успешно
}
function LoadPolynomialsFunctions: Boolean;
begin
  Result := True;
  Result := LoadFuncAddr('polynomials_bernstein', @polynomials_bernstein) and Result;
  Result := LoadFuncAddr('polynomials_all_bernstein', @polynomials_all_bernstein) and Result;
  Result := LoadFuncAddr('polynomials_horner_curve', @polynomials_horner_curve) and Result;
  Result := LoadFuncAddr('polynomials_get_knot_span_index',
    @polynomials_get_knot_span_index) and Result;
  Result := LoadFuncAddr('polynomials_get_knot_multiplicity',
    @polynomials_get_knot_multiplicity) and Result;
  Result := LoadFuncAddr('polynomials_basis_functions', @polynomials_basis_functions) and Result;
  Result := LoadFuncAddr('polynomials_bezier_to_power_matrix',
    @polynomials_bezier_to_power_matrix) and Result;
end;

{**
  Загрузка всех функций KnotVectorUtils_CAPI.

  @return True если все функции загружены успешно
}
function LoadKnotVectorUtilsFunctions: Boolean;
begin
  Result := True;
  Result := LoadFuncAddr('knot_vector_utils_get_continuity',
    @knot_vector_utils_get_continuity) and Result;
  Result := LoadFuncAddr('knot_vector_utils_rescale',
    @knot_vector_utils_rescale) and Result;
  Result := LoadFuncAddr('knot_vector_utils_is_uniform',
    @knot_vector_utils_is_uniform) and Result;
  Result := LoadFuncAddr('knot_vector_utils_get_knot_multiplicity_map_size',
    @knot_vector_utils_get_knot_multiplicity_map_size) and Result;
  Result := LoadFuncAddr('knot_vector_utils_get_knot_multiplicity_map',
    @knot_vector_utils_get_knot_multiplicity_map) and Result;
end;

{**
  Загрузка всех функций Intersection_CAPI.

  @return True если все функции загружены успешно
}
function LoadIntersectionFunctions: Boolean;
begin
  Result := True;
  Result := LoadFuncAddr('intersection_compute_rays',
    @intersection_compute_rays) and Result;
  Result := LoadFuncAddr('intersection_compute_line_and_plane',
    @intersection_compute_line_and_plane) and Result;
end;

{**
  Загрузка всех функций ValidationUtils_CAPI.

  @return True если все функции загружены успешно
}
function LoadValidationUtilsFunctions: Boolean;
begin
  Result := True;
  Result := LoadFuncAddr('validation_utils_is_valid_knot_vector',
    @validation_utils_is_valid_knot_vector) and Result;
  Result := LoadFuncAddr('validation_utils_is_valid_bezier',
    @validation_utils_is_valid_bezier) and Result;
  Result := LoadFuncAddr('validation_utils_is_valid_bspline',
    @validation_utils_is_valid_bspline) and Result;
  Result := LoadFuncAddr('validation_utils_is_valid_nurbs',
    @validation_utils_is_valid_nurbs) and Result;
  Result := LoadFuncAddr('validation_utils_compute_curve_modify_tolerance',
    @validation_utils_compute_curve_modify_tolerance) and Result;
end;

{**
  Загрузка всех функций NurbsCurve_CAPI.

  @return True если все функции загружены успешно
}
function LoadNurbsCurveFunctions: Boolean;
begin
  Result := True;

  { Создание кривых }
  Result := LoadFuncAddr('nurbs_curve_create_line', @nurbs_curve_create_line) and Result;
  Result := LoadFuncAddr('nurbs_curve_create_arc', @nurbs_curve_create_arc) and Result;
  Result := LoadFuncAddr('nurbs_curve_create_open_conic', @nurbs_curve_create_open_conic) and Result;

  { Интерполяция и аппроксимация }
  Result := LoadFuncAddr('nurbs_curve_global_interpolation',
    @nurbs_curve_global_interpolation) and Result;
  Result := LoadFuncAddr('nurbs_curve_global_interpolation_with_tangents',
    @nurbs_curve_global_interpolation_with_tangents) and Result;
  Result := LoadFuncAddr('nurbs_curve_cubic_local_interpolation',
    @nurbs_curve_cubic_local_interpolation) and Result;
  Result := LoadFuncAddr('nurbs_curve_least_squares_approximation',
    @nurbs_curve_least_squares_approximation) and Result;
  Result := LoadFuncAddr('nurbs_curve_weighted_constrained_least_squares',
    @nurbs_curve_weighted_constrained_least_squares) and Result;
  Result := LoadFuncAddr('nurbs_curve_global_approximation_by_error_bound',
    @nurbs_curve_global_approximation_by_error_bound) and Result;

  { Вычисление точек }
  Result := LoadFuncAddr('nurbs_curve_get_point_on_curve',
    @nurbs_curve_get_point_on_curve) and Result;
  Result := LoadFuncAddr('nurbs_curve_get_point_on_curve_by_corner_cut',
    @nurbs_curve_get_point_on_curve_by_corner_cut) and Result;

  { Производные }
  Result := LoadFuncAddr('nurbs_curve_compute_rational_derivatives',
    @nurbs_curve_compute_rational_derivatives) and Result;
  Result := LoadFuncAddr('nurbs_curve_curvature', @nurbs_curve_curvature) and Result;
  Result := LoadFuncAddr('nurbs_curve_torsion', @nurbs_curve_torsion) and Result;
  Result := LoadFuncAddr('nurbs_curve_normal', @nurbs_curve_normal) and Result;
  Result := LoadFuncAddr('nurbs_curve_project_normal', @nurbs_curve_project_normal) and Result;

  { Параметризация }
  Result := LoadFuncAddr('nurbs_curve_get_param_on_curve_by_point',
    @nurbs_curve_get_param_on_curve_by_point) and Result;
  Result := LoadFuncAddr('nurbs_curve_approximate_length',
    @nurbs_curve_approximate_length) and Result;
  Result := LoadFuncAddr('nurbs_curve_get_param_by_length',
    @nurbs_curve_get_param_by_length) and Result;
  Result := LoadFuncAddr('nurbs_curve_get_params_by_equal_length',
    @nurbs_curve_get_params_by_equal_length) and Result;

  { Разбиение }
  Result := LoadFuncAddr('nurbs_curve_split_at', @nurbs_curve_split_at) and Result;
  Result := LoadFuncAddr('nurbs_curve_segment', @nurbs_curve_segment) and Result;
  Result := LoadFuncAddr('nurbs_curve_decompose_to_beziers',
    @nurbs_curve_decompose_to_beziers) and Result;
  Result := LoadFuncAddr('nurbs_curve_tessellate', @nurbs_curve_tessellate) and Result;

  { Преобразование }
  Result := LoadFuncAddr('nurbs_curve_create_transformed',
    @nurbs_curve_create_transformed) and Result;
  Result := LoadFuncAddr('nurbs_curve_reverse', @nurbs_curve_reverse) and Result;
  Result := LoadFuncAddr('nurbs_curve_reparametrize_to_interval',
    @nurbs_curve_reparametrize_to_interval) and Result;
  Result := LoadFuncAddr('nurbs_curve_reparametrize_linear_rational',
    @nurbs_curve_reparametrize_linear_rational) and Result;

  { Модификация узлов }
  Result := LoadFuncAddr('nurbs_curve_insert_knot', @nurbs_curve_insert_knot) and Result;
  Result := LoadFuncAddr('nurbs_curve_remove_knot', @nurbs_curve_remove_knot) and Result;
  Result := LoadFuncAddr('nurbs_curve_remove_excessive_knots',
    @nurbs_curve_remove_excessive_knots) and Result;
  Result := LoadFuncAddr('nurbs_curve_refine_knot_vector',
    @nurbs_curve_refine_knot_vector) and Result;
  Result := LoadFuncAddr('nurbs_curve_elevate_degree', @nurbs_curve_elevate_degree) and Result;
  Result := LoadFuncAddr('nurbs_curve_reduce_degree', @nurbs_curve_reduce_degree) and Result;

  { Проверка свойств }
  Result := LoadFuncAddr('nurbs_curve_is_closed', @nurbs_curve_is_closed) and Result;
  Result := LoadFuncAddr('nurbs_curve_is_linear', @nurbs_curve_is_linear) and Result;
  Result := LoadFuncAddr('nurbs_curve_is_clamped', @nurbs_curve_is_clamped) and Result;
  Result := LoadFuncAddr('nurbs_curve_is_periodic', @nurbs_curve_is_periodic) and Result;
  Result := LoadFuncAddr('nurbs_curve_can_compute_derivative',
    @nurbs_curve_can_compute_derivative) and Result;

  { Модификация контрольных точек }
  Result := LoadFuncAddr('nurbs_curve_control_point_reposition',
    @nurbs_curve_control_point_reposition) and Result;
  Result := LoadFuncAddr('nurbs_curve_weight_modification',
    @nurbs_curve_weight_modification) and Result;
  Result := LoadFuncAddr('nurbs_curve_neighbor_weights_modification',
    @nurbs_curve_neighbor_weights_modification) and Result;

  { Деформация }
  Result := LoadFuncAddr('nurbs_curve_warping', @nurbs_curve_warping) and Result;
  Result := LoadFuncAddr('nurbs_curve_flattening', @nurbs_curve_flattening) and Result;
  Result := LoadFuncAddr('nurbs_curve_bending', @nurbs_curve_bending) and Result;
  Result := LoadFuncAddr('nurbs_curve_constraint_based_modification',
    @nurbs_curve_constraint_based_modification) and Result;

  { Преобразование типа }
  Result := LoadFuncAddr('nurbs_curve_to_clamp_curve', @nurbs_curve_to_clamp_curve) and Result;
  Result := LoadFuncAddr('nurbs_curve_to_unclamp_curve', @nurbs_curve_to_unclamp_curve) and Result;
  Result := LoadFuncAddr('nurbs_curve_equally_tessellate',
    @nurbs_curve_equally_tessellate) and Result;
end;

{**
  Загрузка всех функций NurbsSurface_CAPI.

  @return True если все функции загружены успешно
}
function LoadNurbsSurfaceFunctions: Boolean;
begin
  Result := True;

  { Вычисление точек }
  Result := LoadFuncAddr('nurbs_surface_get_point_on_surface',
    @nurbs_surface_get_point_on_surface) and Result;
  Result := LoadFuncAddr('nurbs_surface_compute_rational_derivatives',
    @nurbs_surface_compute_rational_derivatives) and Result;
  Result := LoadFuncAddr('nurbs_surface_compute_first_order_derivative',
    @nurbs_surface_compute_first_order_derivative) and Result;
  Result := LoadFuncAddr('nurbs_surface_curvature', @nurbs_surface_curvature) and Result;
  Result := LoadFuncAddr('nurbs_surface_normal', @nurbs_surface_normal) and Result;

  { Преобразования }
  Result := LoadFuncAddr('nurbs_surface_swap_uv', @nurbs_surface_swap_uv) and Result;
  Result := LoadFuncAddr('nurbs_surface_reverse', @nurbs_surface_reverse) and Result;
  Result := LoadFuncAddr('nurbs_surface_is_closed', @nurbs_surface_is_closed) and Result;

  { Модификация узлов }
  Result := LoadFuncAddr('nurbs_surface_insert_knot', @nurbs_surface_insert_knot) and Result;
  Result := LoadFuncAddr('nurbs_surface_refine_knot_vector',
    @nurbs_surface_refine_knot_vector) and Result;
  Result := LoadFuncAddr('nurbs_surface_remove_knot', @nurbs_surface_remove_knot) and Result;

  { Изменение степени }
  Result := LoadFuncAddr('nurbs_surface_elevate_degree', @nurbs_surface_elevate_degree) and Result;
  Result := LoadFuncAddr('nurbs_surface_reduce_degree', @nurbs_surface_reduce_degree) and Result;

  { Декомпозиция и тесселяция }
  Result := LoadFuncAddr('nurbs_surface_decompose_to_beziers',
    @nurbs_surface_decompose_to_beziers) and Result;
  Result := LoadFuncAddr('nurbs_surface_equally_tessellate',
    @nurbs_surface_equally_tessellate) and Result;

  { Поиск параметров }
  Result := LoadFuncAddr('nurbs_surface_get_param_on_surface',
    @nurbs_surface_get_param_on_surface) and Result;
  Result := LoadFuncAddr('nurbs_surface_get_param_on_surface_by_gsa',
    @nurbs_surface_get_param_on_surface_by_gsa) and Result;
  Result := LoadFuncAddr('nurbs_surface_get_uv_tangent', @nurbs_surface_get_uv_tangent) and Result;

  { Перепараметризация }
  Result := LoadFuncAddr('nurbs_surface_reparametrize', @nurbs_surface_reparametrize) and Result;

  { Создание примитивов }
  Result := LoadFuncAddr('nurbs_surface_create_bilinear', @nurbs_surface_create_bilinear) and Result;
  Result := LoadFuncAddr('nurbs_surface_create_cylindrical',
    @nurbs_surface_create_cylindrical) and Result;
  Result := LoadFuncAddr('nurbs_surface_create_ruled', @nurbs_surface_create_ruled) and Result;
  Result := LoadFuncAddr('nurbs_surface_create_revolved', @nurbs_surface_create_revolved) and Result;

  { Интерполяция и аппроксимация }
  Result := LoadFuncAddr('nurbs_surface_global_interpolation',
    @nurbs_surface_global_interpolation) and Result;
  Result := LoadFuncAddr('nurbs_surface_bicubic_local_interpolation',
    @nurbs_surface_bicubic_local_interpolation) and Result;
  Result := LoadFuncAddr('nurbs_surface_global_approximation',
    @nurbs_surface_global_approximation) and Result;

  { Развёртка }
  Result := LoadFuncAddr('nurbs_surface_create_swung', @nurbs_surface_create_swung) and Result;
  Result := LoadFuncAddr('nurbs_surface_create_loft', @nurbs_surface_create_loft) and Result;
  Result := LoadFuncAddr('nurbs_surface_create_generalized_translational_sweep',
    @nurbs_surface_create_generalized_translational_sweep) and Result;
  Result := LoadFuncAddr('nurbs_surface_create_sweep_interpolated',
    @nurbs_surface_create_sweep_interpolated) and Result;
  Result := LoadFuncAddr('nurbs_surface_create_sweep_noninterpolated',
    @nurbs_surface_create_sweep_noninterpolated) and Result;

  { Поверхности по сетке кривых }
  Result := LoadFuncAddr('nurbs_surface_create_gordon', @nurbs_surface_create_gordon) and Result;
  Result := LoadFuncAddr('nurbs_surface_create_coons', @nurbs_surface_create_coons) and Result;

  { Площадь и триангуляция }
  Result := LoadFuncAddr('nurbs_surface_approximate_area',
    @nurbs_surface_approximate_area) and Result;
  Result := LoadFuncAddr('nurbs_surface_triangulate', @nurbs_surface_triangulate) and Result;
end;

{**
  Обнуление всех указателей на функции.
}
procedure ClearAllFunctionPointers;
begin
  { XYZ_CAPI }
  xyz_create := nil;
  xyz_zero := nil;
  xyz_add := nil;
  xyz_subtract := nil;
  xyz_negative := nil;
  xyz_multiply := nil;
  xyz_divide := nil;
  xyz_length := nil;
  xyz_sqr_length := nil;
  xyz_is_zero := nil;
  xyz_is_unit := nil;
  xyz_normalize := nil;
  xyz_dot := nil;
  xyz_cross := nil;
  xyz_distance := nil;
  xyz_equals := nil;

  { XYZW_CAPI }
  xyzw_create := nil;
  xyzw_create_from_xyz := nil;
  xyzw_to_xyz := nil;
  xyzw_add := nil;
  xyzw_multiply := nil;
  xyzw_divide := nil;
  xyzw_distance := nil;
  xyzw_get_wx := nil;
  xyzw_get_wy := nil;
  xyzw_get_wz := nil;
  xyzw_get_w := nil;

  { UV_CAPI }
  uv_create := nil;
  uv_get_u := nil;
  uv_get_v := nil;
  uv_add := nil;
  uv_subtract := nil;
  uv_negative := nil;
  uv_normalize := nil;
  uv_scale := nil;
  uv_divide := nil;
  uv_length := nil;
  uv_sqr_length := nil;
  uv_distance := nil;
  uv_is_zero := nil;
  uv_is_unit := nil;
  uv_is_almost_equal := nil;
  uv_dot := nil;
  uv_cross := nil;

  { Matrix4d_CAPI }
  matrix4d_identity := nil;
  matrix4d_create_translation := nil;
  matrix4d_create_rotation := nil;
  matrix4d_create_scale := nil;
  matrix4d_create_reflection := nil;
  matrix4d_get_basis_x := nil;
  matrix4d_get_basis_y := nil;
  matrix4d_get_basis_z := nil;
  matrix4d_get_basis_w := nil;
  matrix4d_of_point := nil;
  matrix4d_of_vector := nil;
  matrix4d_multiply := nil;
  matrix4d_get_inverse := nil;
  matrix4d_get_determinant := nil;

  { Projection_CAPI }
  projection_point_to_ray := nil;
  projection_point_to_line := nil;
  projection_stereographic := nil;

  { BezierCurve_CAPI }
  bezier_curve_get_point_by_bernstein := nil;
  bezier_curve_get_point_by_de_casteljau := nil;
  bezier_curve_get_point_by_bernstein_rational := nil;

  { BezierSurface_CAPI }
  bezier_surface_get_point_by_de_casteljau := nil;

  { Polynomials_CAPI }
  polynomials_bernstein := nil;
  polynomials_all_bernstein := nil;
  polynomials_horner_curve := nil;
  polynomials_get_knot_span_index := nil;
  polynomials_get_knot_multiplicity := nil;
  polynomials_basis_functions := nil;
  polynomials_bezier_to_power_matrix := nil;

  { KnotVectorUtils_CAPI }
  knot_vector_utils_get_continuity := nil;
  knot_vector_utils_rescale := nil;
  knot_vector_utils_is_uniform := nil;
  knot_vector_utils_get_knot_multiplicity_map_size := nil;
  knot_vector_utils_get_knot_multiplicity_map := nil;

  { Intersection_CAPI }
  intersection_compute_rays := nil;
  intersection_compute_line_and_plane := nil;

  { ValidationUtils_CAPI }
  validation_utils_is_valid_knot_vector := nil;
  validation_utils_is_valid_bezier := nil;
  validation_utils_is_valid_bspline := nil;
  validation_utils_is_valid_nurbs := nil;
  validation_utils_compute_curve_modify_tolerance := nil;

  { NurbsCurve_CAPI }
  nurbs_curve_create_line := nil;
  nurbs_curve_create_arc := nil;
  nurbs_curve_create_open_conic := nil;
  nurbs_curve_global_interpolation := nil;
  nurbs_curve_global_interpolation_with_tangents := nil;
  nurbs_curve_cubic_local_interpolation := nil;
  nurbs_curve_least_squares_approximation := nil;
  nurbs_curve_weighted_constrained_least_squares := nil;
  nurbs_curve_global_approximation_by_error_bound := nil;
  nurbs_curve_get_point_on_curve := nil;
  nurbs_curve_get_point_on_curve_by_corner_cut := nil;
  nurbs_curve_compute_rational_derivatives := nil;
  nurbs_curve_curvature := nil;
  nurbs_curve_torsion := nil;
  nurbs_curve_normal := nil;
  nurbs_curve_project_normal := nil;
  nurbs_curve_get_param_on_curve_by_point := nil;
  nurbs_curve_approximate_length := nil;
  nurbs_curve_get_param_by_length := nil;
  nurbs_curve_get_params_by_equal_length := nil;
  nurbs_curve_split_at := nil;
  nurbs_curve_segment := nil;
  nurbs_curve_decompose_to_beziers := nil;
  nurbs_curve_tessellate := nil;
  nurbs_curve_create_transformed := nil;
  nurbs_curve_reverse := nil;
  nurbs_curve_reparametrize_to_interval := nil;
  nurbs_curve_reparametrize_linear_rational := nil;
  nurbs_curve_insert_knot := nil;
  nurbs_curve_remove_knot := nil;
  nurbs_curve_remove_excessive_knots := nil;
  nurbs_curve_refine_knot_vector := nil;
  nurbs_curve_elevate_degree := nil;
  nurbs_curve_reduce_degree := nil;
  nurbs_curve_is_closed := nil;
  nurbs_curve_is_linear := nil;
  nurbs_curve_is_clamped := nil;
  nurbs_curve_is_periodic := nil;
  nurbs_curve_can_compute_derivative := nil;
  nurbs_curve_control_point_reposition := nil;
  nurbs_curve_weight_modification := nil;
  nurbs_curve_neighbor_weights_modification := nil;
  nurbs_curve_warping := nil;
  nurbs_curve_flattening := nil;
  nurbs_curve_bending := nil;
  nurbs_curve_constraint_based_modification := nil;
  nurbs_curve_to_clamp_curve := nil;
  nurbs_curve_to_unclamp_curve := nil;
  nurbs_curve_equally_tessellate := nil;

  { NurbsSurface_CAPI }
  nurbs_surface_get_point_on_surface := nil;
  nurbs_surface_compute_rational_derivatives := nil;
  nurbs_surface_compute_first_order_derivative := nil;
  nurbs_surface_curvature := nil;
  nurbs_surface_normal := nil;
  nurbs_surface_swap_uv := nil;
  nurbs_surface_reverse := nil;
  nurbs_surface_is_closed := nil;
  nurbs_surface_insert_knot := nil;
  nurbs_surface_refine_knot_vector := nil;
  nurbs_surface_remove_knot := nil;
  nurbs_surface_elevate_degree := nil;
  nurbs_surface_reduce_degree := nil;
  nurbs_surface_decompose_to_beziers := nil;
  nurbs_surface_equally_tessellate := nil;
  nurbs_surface_get_param_on_surface := nil;
  nurbs_surface_get_param_on_surface_by_gsa := nil;
  nurbs_surface_get_uv_tangent := nil;
  nurbs_surface_reparametrize := nil;
  nurbs_surface_create_bilinear := nil;
  nurbs_surface_create_cylindrical := nil;
  nurbs_surface_create_ruled := nil;
  nurbs_surface_create_revolved := nil;
  nurbs_surface_global_interpolation := nil;
  nurbs_surface_bicubic_local_interpolation := nil;
  nurbs_surface_global_approximation := nil;
  nurbs_surface_create_swung := nil;
  nurbs_surface_create_loft := nil;
  nurbs_surface_create_generalized_translational_sweep := nil;
  nurbs_surface_create_sweep_interpolated := nil;
  nurbs_surface_create_sweep_noninterpolated := nil;
  nurbs_surface_create_gordon := nil;
  nurbs_surface_create_coons := nil;
  nurbs_surface_approximate_area := nil;
  nurbs_surface_triangulate := nil;
end;

function LoadLNLib: Boolean;
begin
  Result := False;

  { Проверка, не загружена ли уже библиотека }
  if LNLibLoaded then
  begin
    Result := True;
    Exit;
  end;

  LNLibHandle := LoadLibrary(PChar(LNLIB_DLL));

  { Загрузка всех функций }
  Result := True;
  Result := LoadXYZFunctions and Result;
  Result := LoadXYZWFunctions and Result;
  Result := LoadUVFunctions and Result;
  Result := LoadMatrix4dFunctions and Result;
  Result := LoadProjectionFunctions and Result;
  Result := LoadBezierCurveFunctions and Result;
  Result := LoadBezierSurfaceFunctions and Result;
  Result := LoadPolynomialsFunctions and Result;
  Result := LoadKnotVectorUtilsFunctions and Result;
  Result := LoadIntersectionFunctions and Result;
  Result := LoadValidationUtilsFunctions and Result;
  Result := LoadNurbsCurveFunctions and Result;
  Result := LoadNurbsSurfaceFunctions and Result;

  if Result then
    LNLibLoaded := True
  else
    { Выгружаем библиотеку, если не все функции загружены }
    UnloadLNLib;
end;

procedure UnloadLNLib;
begin
  if LNLibHandle <> NilHandle then
  begin
    FreeLibrary(LNLibHandle);
    LNLibHandle := NilHandle;
  end;

  ClearAllFunctionPointers;
  LNLibLoaded := False;
end;

function IsLNLibLoaded: Boolean;
begin
  Result := LNLibLoaded;
end;

initialization
  { Автоматическая загрузка при инициализации модуля }
  LoadLNLib;

finalization
  { Автоматическая выгрузка при завершении }
  UnloadLNLib;

end.
