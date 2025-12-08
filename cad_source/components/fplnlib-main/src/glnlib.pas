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

unit gLNLib;

{$mode delphi}{$H+}

interface

uses
  SysUtils,dynlibs,
  LNEnums_CAPI,
  LNObject_CAPI,
  NurbsCurve_CAPI,
  NurbsSurface_CAPI;

const
  {** Имя динамической библиотеки LNLib для разных платформ **}
  {$IFDEF WINDOWS}
  LNLIB_DLL='libCApi.dll';
  {$ELSE}
  {$IFDEF DARWIN}
  LNLIB_DLL='libCApi.dylib';
  {$ELSE}
  LNLIB_DLL='libCApi.so';
  {$ENDIF}
  {$ENDIF}
  { ========================================================================== }
  {                         Статус загрузки библиотеки                         }
  { ========================================================================== }

var
  {** Флаг успешной загрузки библиотеки **}
  LNLibLoaded:boolean=False;

  {** Дескриптор загруженной библиотеки **}
  LNLibHandle:TLibHandle=NilHandle;

type
  gLNLibRec<gXYZ,gXYZW,gUV,gMatrix4d>=record
  type
    PMatrix4d=^gMatrix4d;
    PXYZ=^gXYZ;
    PXYZW=^gXYZW;
    PUV=^gUV;
    { ========================================================================== }
    {                    Типы указателей на функции XYZ_CAPI                     }
    { ========================================================================== }
    Txyz_create=function(x,y,z:double):gXYZ;cdecl;
    Txyz_zero=function :gXYZ;cdecl;
    Txyz_add=function(a,b:gXYZ):gXYZ;cdecl;
    Txyz_subtract=function(a,b:gXYZ):gXYZ;cdecl;
    Txyz_negative=function(a:gXYZ):gXYZ;cdecl;
    Txyz_multiply=function(a:gXYZ;scalar:double):gXYZ;cdecl;
    Txyz_divide=function(a:gXYZ;scalar:double):gXYZ;cdecl;
    Txyz_length=function(v:gXYZ):double;cdecl;
    Txyz_sqr_length=function(v:gXYZ):double;cdecl;
    Txyz_is_zero=function(v:gXYZ;epsilon:double):integer;cdecl;
    Txyz_is_unit=function(v:gXYZ;epsilon:double):integer;cdecl;
    Txyz_normalize=function(v:gXYZ):gXYZ;cdecl;
    Txyz_dot=function(a,b:gXYZ):double;cdecl;
    Txyz_cross=function(a,b:gXYZ):gXYZ;cdecl;
    Txyz_distance=function(a,b:gXYZ):double;cdecl;
    Txyz_equals=function(a,b:gXYZ):integer;cdecl;

    { ========================================================================== }
    {                   Типы указателей на функции XYZW_CAPI                     }
    { ========================================================================== }

  type
    Txyzw_create=function(wx,wy,wz,w:double):gXYZW;cdecl;
    Txyzw_create_from_xyz=function(xyz:gXYZ;w:double):gXYZW;cdecl;
    Txyzw_to_xyz=function(v:gXYZW;divideWeight:integer):gXYZ;cdecl;
    Txyzw_add=function(a,b:gXYZW):gXYZW;cdecl;
    Txyzw_multiply=function(a:gXYZW;scalar:double):gXYZW;cdecl;
    Txyzw_divide=function(a:gXYZW;scalar:double):gXYZW;cdecl;
    Txyzw_distance=function(a,b:gXYZW):double;cdecl;
    Txyzw_get_wx=function(v:gXYZW):double;cdecl;
    Txyzw_get_wy=function(v:gXYZW):double;cdecl;
    Txyzw_get_wz=function(v:gXYZW):double;cdecl;
    Txyzw_get_w=function(v:gXYZW):double;cdecl;

    { ========================================================================== }
    {                    Типы указателей на функции UV_CAPI                      }
    { ========================================================================== }

  type
    Tuv_create=function(u,v:double):gUV;cdecl;
    Tuv_get_u=function(uv:gUV):double;cdecl;
    Tuv_get_v=function(uv:gUV):double;cdecl;
    Tuv_add=function(a,b:gUV):gUV;cdecl;
    Tuv_subtract=function(a,b:gUV):gUV;cdecl;
    Tuv_negative=function(uv:gUV):gUV;cdecl;
    Tuv_normalize=function(uv:gUV):gUV;cdecl;
    Tuv_scale=function(uv:gUV;factor:double):gUV;cdecl;
    Tuv_divide=function(uv:gUV;divisor:double):gUV;cdecl;
    Tuv_length=function(uv:gUV):double;cdecl;
    Tuv_sqr_length=function(uv:gUV):double;cdecl;
    Tuv_distance=function(a,b:gUV):double;cdecl;
    Tuv_is_zero=function(uv:gUV;epsilon:double):integer;cdecl;
    Tuv_is_unit=function(uv:gUV;epsilon:double):integer;cdecl;
    Tuv_is_almost_equal=function(a,b:gUV;epsilon:double):integer;cdecl;
    Tuv_dot=function(a,b:gUV):double;cdecl;
    Tuv_cross=function(a,b:gUV):double;cdecl;

    { ========================================================================== }
    {                 Типы указателей на функции Matrix4d_CAPI                   }
    { ========================================================================== }

  type
    Tmatrix4d_identity=function :gMatrix4d;cdecl;
    Tmatrix4d_create_translation=function(vector:gXYZ):gMatrix4d;cdecl;
    Tmatrix4d_create_rotation=function(axis:gXYZ;rad:double):gMatrix4d;cdecl;
    Tmatrix4d_create_scale=function(scale:gXYZ):gMatrix4d;cdecl;
    Tmatrix4d_create_reflection=function(normal:gXYZ):gMatrix4d;cdecl;
    Tmatrix4d_get_basis_x=function(matrix:gMatrix4d):gXYZ;cdecl;
    Tmatrix4d_get_basis_y=function(matrix:gMatrix4d):gXYZ;cdecl;
    Tmatrix4d_get_basis_z=function(matrix:gMatrix4d):gXYZ;cdecl;
    Tmatrix4d_get_basis_w=function(matrix:gMatrix4d):gXYZ;cdecl;
    Tmatrix4d_of_point=function(matrix:gMatrix4d;point:gXYZ):gXYZ;cdecl;
    Tmatrix4d_of_vector=function(matrix:gMatrix4d;vector:gXYZ):gXYZ;cdecl;
    Tmatrix4d_multiply=function(a,b:gMatrix4d):gMatrix4d;cdecl;
    Tmatrix4d_get_inverse=function(matrix:gMatrix4d;
      out_inverse:PMatrix4d):integer;cdecl;
    Tmatrix4d_get_determinant=function(matrix:gMatrix4d):double;cdecl;

    { ========================================================================== }
    {               Типы указателей на функции Projection_CAPI                   }
    { ========================================================================== }

  type
    Tprojection_point_to_ray=function(origin,direction,point:gXYZ):gXYZ;cdecl;
    Tprojection_point_to_line=function(start_point,end_point,point:gXYZ;
      out_project_point:PXYZ):integer;cdecl;
    Tprojection_stereographic=function(point_on_sphere:gXYZ;
      radius:double):gXYZ;cdecl;

    { ========================================================================== }
    {              Типы указателей на функции BezierCurve_CAPI                   }
    { ========================================================================== }

  type
    Tbezier_curve_get_point_by_bernstein=function(degree:integer;
      control_points:PXYZ;control_points_count:integer;paramT:double):gXYZ;cdecl;
    Tbezier_curve_get_point_by_de_casteljau=function(degree:integer;
      control_points:PXYZ;control_points_count:integer;paramT:double):gXYZ;cdecl;
    Tbezier_curve_get_point_by_bernstein_rational=function(degree:integer;
      control_points:PXYZW;control_points_count:integer;paramT:double):gXYZW;cdecl;

    { ========================================================================== }
    {             Типы указателей на функции BezierSurface_CAPI                  }
    { ========================================================================== }

  type
    Tbezier_surface_get_point_by_de_casteljau=function(degree_u,degree_v:integer;
      control_points:PXYZ;num_u,num_v:integer;uv:gUV):gXYZ;cdecl;

    { ========================================================================== }
    {              Типы указателей на функции Polynomials_CAPI                   }
    { ========================================================================== }

  type
    Tpolynomials_bernstein=function(index,degree:integer;
      paramT:double):double;cdecl;
    Tpolynomials_all_bernstein=procedure(degree:integer;paramT:double;
      out_array:PDouble);cdecl;
    Tpolynomials_horner_curve=function(degree:integer;
      const coefficients:PDouble;coeff_count:integer;paramT:double):double;cdecl;
    Tpolynomials_get_knot_span_index=function(degree:integer;
      const knot_vector:PDouble;knot_count:integer;paramT:double):integer;cdecl;
    Tpolynomials_get_knot_multiplicity=function(const knot_vector:PDouble;
      knot_count:integer;paramT:double):integer;cdecl;
    Tpolynomials_basis_functions=procedure(span_index,degree:integer;
      const knot_vector:PDouble;knot_count:integer;paramT:double;
      basis_functions:PDouble);cdecl;
    Tpolynomials_bezier_to_power_matrix=procedure(degree:integer;
      out_matrix:PDouble);cdecl;

    { ========================================================================== }
    {            Типы указателей на функции KnotVectorUtils_CAPI                 }
    { ========================================================================== }

  type
    Tknot_vector_utils_get_continuity=function(degree:integer;
      knot_vector:PDouble;knot_vector_count:integer;knot:double):integer;cdecl;
    Tknot_vector_utils_rescale=procedure(knot_vector:PDouble;
      knot_vector_count:integer;min_val,max_val:double;
      out_rescaled_knot_vector:PDouble);cdecl;
    Tknot_vector_utils_is_uniform=function(knot_vector:PDouble;
      knot_vector_count:integer):integer;cdecl;
    Tknot_vector_utils_get_knot_multiplicity_map_size=function(knot_vector:PDouble;
      knot_vector_count:integer):integer;cdecl;
    Tknot_vector_utils_get_knot_multiplicity_map=procedure(knot_vector:PDouble;
      knot_vector_count:integer;out_unique_knots:PDouble;
      out_multiplicities:PInteger);cdecl;

    { ========================================================================== }
    {             Типы указателей на функции Intersection_CAPI                   }
    { ========================================================================== }

  type
    Tintersection_compute_rays=function(point0,vector0,point1,vector1:gXYZ;
      out_param0,out_param1:PDouble;
      out_intersect_point:PXYZ):TCurveCurveIntersectionType;cdecl;
    Tintersection_compute_line_and_plane=
    function(plane_normal,point_on_plane,point_on_line,line_direction:gXYZ;
      out_intersect_point:PXYZ):TLinePlaneIntersectionType;cdecl;

    { ========================================================================== }
    {            Типы указателей на функции ValidationUtils_CAPI                 }
    { ========================================================================== }

  type
    Tvalidation_utils_is_valid_knot_vector=function(const knot_vector:PDouble;
      Count:integer):integer;cdecl;
    Tvalidation_utils_is_valid_bezier=function(degree,control_points_count:integer):
      integer;cdecl;
    Tvalidation_utils_is_valid_bspline=function(degree,knot_count,cp_count:integer):
      integer;cdecl;
    Tvalidation_utils_is_valid_nurbs=function(degree,knot_count,
      weighted_cp_count:integer):integer;cdecl;
    Tvalidation_utils_compute_curve_modify_tolerance=function(
      const control_points:PXYZW;Count:integer):double;cdecl;

    { ========================================================================== }
    {              Типы указателей на функции NurbsCurve_CAPI                    }
    { ========================================================================== }

  type
    { Создание кривых }
    Tnurbs_curve_create_line=function(start_point,end_point:gXYZ):TLN_NurbsCurve;
      cdecl;
    Tnurbs_curve_create_arc=function(center,x_axis,y_axis:gXYZ;
      start_rad,end_rad,x_radius,y_radius:double;
      out_curve:PLN_NurbsCurve):integer;cdecl;
    Tnurbs_curve_create_open_conic=function(start_point,start_tangent,
      end_point,end_tangent,point_on_conic:gXYZ;
      out_curve:PLN_NurbsCurve):integer;cdecl;

    { Интерполяция и аппроксимация }
    Tnurbs_curve_global_interpolation=procedure(degree:integer;
      points:PXYZ;point_count:integer;out_curve:PLN_NurbsCurve);cdecl;
    Tnurbs_curve_global_interpolation_with_tangents=procedure(degree:integer;
      points,tangents:PXYZ;tangent_factor:double;point_count:integer;
      out_curve:PLN_NurbsCurve);cdecl;
    Tnurbs_curve_cubic_local_interpolation=function(points:PXYZ;
      point_count:integer;out_curve:PLN_NurbsCurve):integer;cdecl;
    Tnurbs_curve_least_squares_approximation=function(degree:integer;
      points:PXYZ;point_count,control_point_count:integer;
      out_curve:PLN_NurbsCurve):integer;cdecl;
    Tnurbs_curve_weighted_constrained_least_squares=function(degree:integer;
      points:PXYZ;point_weights:PDouble;tangents:PXYZ;
      tangent_indices:PInteger;tangent_weights:PDouble;
      tangent_count,control_point_count:integer;
      out_curve:PLN_NurbsCurve):integer;cdecl;
    Tnurbs_curve_global_approximation_by_error_bound=procedure(degree:integer;
      points:PXYZ;point_count:integer;max_error:double;
      out_curve:PLN_NurbsCurve);cdecl;

    { Вычисление точек }
    Tnurbs_curve_get_point_on_curve=function(curve:TLN_NurbsCurve;
      paramT:double):gXYZ;cdecl;
    Tnurbs_curve_get_point_on_curve_by_corner_cut=function(curve:TLN_NurbsCurve;
      paramT:double):gXYZ;cdecl;

    { Производные }
    Tnurbs_curve_compute_rational_derivatives=function(curve:TLN_NurbsCurve;
      derivative_order:integer;paramT:double;out_derivatives:PXYZ):integer;cdecl;
    Tnurbs_curve_curvature=function(curve:TLN_NurbsCurve;
      paramT:double):double;cdecl;
    Tnurbs_curve_torsion=function(curve:TLN_NurbsCurve;paramT:double):double;cdecl;
    Tnurbs_curve_normal=function(curve:TLN_NurbsCurve;normal_type:TCurveNormal;
      paramT:double):gXYZ;cdecl;
    Tnurbs_curve_project_normal=function(curve:TLN_NurbsCurve;
      out_normals:PXYZ):integer;cdecl;

    { Параметризация }
    Tnurbs_curve_get_param_on_curve_by_point=function(curve:TLN_NurbsCurve;
      given_point:gXYZ):double;cdecl;
    Tnurbs_curve_approximate_length=function(curve:TLN_NurbsCurve;
      integrator_type:TIntegratorType):double;cdecl;
    Tnurbs_curve_get_param_by_length=function(curve:TLN_NurbsCurve;
      given_length:double;integrator_type:TIntegratorType):double;cdecl;
    Tnurbs_curve_get_params_by_equal_length=function(curve:TLN_NurbsCurve;
      segment_length:double;integrator_type:TIntegratorType;
      out_params:PDouble):integer;cdecl;

    { Разбиение }
    Tnurbs_curve_split_at=function(curve:TLN_NurbsCurve;paramT:double;
      out_left,out_right:PLN_NurbsCurve):integer;cdecl;
    Tnurbs_curve_segment=function(curve:TLN_NurbsCurve;
      start_param,end_param:double;out_segment:PLN_NurbsCurve):integer;cdecl;
    Tnurbs_curve_decompose_to_beziers=function(curve:TLN_NurbsCurve;
      out_segments:PLN_NurbsCurve;max_segments:integer):integer;cdecl;
    Tnurbs_curve_tessellate=function(curve:TLN_NurbsCurve;
      out_points:PXYZ):integer;cdecl;

    { Преобразование }
    Tnurbs_curve_create_transformed=procedure(curve:TLN_NurbsCurve;
      matrix:gMatrix4d;out_curve:PLN_NurbsCurve);cdecl;
    Tnurbs_curve_reverse=procedure(curve:TLN_NurbsCurve;
      out_curve:PLN_NurbsCurve);cdecl;
    Tnurbs_curve_reparametrize_to_interval=procedure(curve:TLN_NurbsCurve;
      min_val,max_val:double;out_curve:PLN_NurbsCurve);cdecl;
    Tnurbs_curve_reparametrize_linear_rational=procedure(curve:TLN_NurbsCurve;
      alpha,beta,gamma,delta:double;out_curve:PLN_NurbsCurve);cdecl;

    { Модификация узлов }
    Tnurbs_curve_insert_knot=function(curve:TLN_NurbsCurve;
      knot_value:double;times:integer;out_curve:PLN_NurbsCurve):integer;cdecl;
    Tnurbs_curve_remove_knot=function(curve:TLN_NurbsCurve;
      knot_value:double;times:integer;out_curve:PLN_NurbsCurve):integer;cdecl;
    Tnurbs_curve_remove_excessive_knots=procedure(curve:TLN_NurbsCurve;
      out_curve:PLN_NurbsCurve);cdecl;
    Tnurbs_curve_refine_knot_vector=procedure(curve:TLN_NurbsCurve;
      insert_knots:PDouble;insert_count:integer;out_curve:PLN_NurbsCurve);cdecl;
    Tnurbs_curve_elevate_degree=procedure(curve:TLN_NurbsCurve;
      times:integer;out_curve:PLN_NurbsCurve);cdecl;
    Tnurbs_curve_reduce_degree=function(curve:TLN_NurbsCurve;
      out_curve:PLN_NurbsCurve):integer;cdecl;

    { Проверка свойств }
    Tnurbs_curve_is_closed=function(curve:TLN_NurbsCurve):integer;cdecl;
    Tnurbs_curve_is_linear=function(curve:TLN_NurbsCurve):integer;cdecl;
    Tnurbs_curve_is_clamped=function(curve:TLN_NurbsCurve):integer;cdecl;
    Tnurbs_curve_is_periodic=function(curve:TLN_NurbsCurve):integer;cdecl;
    Tnurbs_curve_can_compute_derivative=function(curve:TLN_NurbsCurve;
      paramT:double):integer;cdecl;

    { Модификация контрольных точек }
    Tnurbs_curve_control_point_reposition=function(curve:TLN_NurbsCurve;
      paramT:double;move_index:integer;move_direction:gXYZ;
      move_distance:double;out_curve:PLN_NurbsCurve):integer;cdecl;
    Tnurbs_curve_weight_modification=procedure(curve:TLN_NurbsCurve;
      paramT:double;move_index:integer;move_distance:double;
      out_curve:PLN_NurbsCurve);cdecl;
    Tnurbs_curve_neighbor_weights_modification=function(curve:TLN_NurbsCurve;
      paramT:double;move_index:integer;move_distance,scale:double;
      out_curve:PLN_NurbsCurve):integer;cdecl;

    { Деформация }
    Tnurbs_curve_warping=procedure(curve:TLN_NurbsCurve;warp_shape:PDouble;
      warp_shape_count:integer;warp_distance:double;plane_normal:gXYZ;
      start_param,end_param:double;out_curve:PLN_NurbsCurve);cdecl;
    Tnurbs_curve_flattening=function(curve:TLN_NurbsCurve;
      line_start,line_end:gXYZ;start_param,end_param:double;
      out_curve:PLN_NurbsCurve):integer;cdecl;
    Tnurbs_curve_bending=procedure(curve:TLN_NurbsCurve;
      start_param,end_param:double;bend_center:gXYZ;
      radius,cross_ratio:double;out_curve:PLN_NurbsCurve);cdecl;
    Tnurbs_curve_constraint_based_modification=procedure(curve:TLN_NurbsCurve;
      constraint_params:PDouble;derivative_constraints:PXYZ;
      applied_indices,applied_degrees,fixed_cp_indices:PInteger;
      constraint_count,fixed_count:integer;out_curve:PLN_NurbsCurve);cdecl;

    { Преобразование типа }
    Tnurbs_curve_to_clamp_curve=procedure(curve:TLN_NurbsCurve;
      out_curve:PLN_NurbsCurve);cdecl;
    Tnurbs_curve_to_unclamp_curve=procedure(curve:TLN_NurbsCurve;
      out_curve:PLN_NurbsCurve);cdecl;
    Tnurbs_curve_equally_tessellate=procedure(curve:TLN_NurbsCurve;
      out_points:PXYZ;out_knots:PDouble;max_count:integer);cdecl;

    { ========================================================================== }
    {             Типы указателей на функции NurbsSurface_CAPI                   }
    { ========================================================================== }

  type
    { Вычисление точек }
    Tnurbs_surface_get_point_on_surface=function(surface:TLN_NurbsSurface;
      uv:gUV):gXYZ;cdecl;
    Tnurbs_surface_compute_rational_derivatives=function(surface:TLN_NurbsSurface;
      derivative_order:integer;uv:gUV;out_derivatives:PXYZ):integer;cdecl;
    Tnurbs_surface_compute_first_order_derivative=procedure(surface:TLN_NurbsSurface;
      uv:gUV;out_S,out_Su,out_Sv:PXYZ);cdecl;
    Tnurbs_surface_curvature=function(surface:TLN_NurbsSurface;
      curvature_type:integer;uv:gUV):double;cdecl;
    Tnurbs_surface_normal=function(surface:TLN_NurbsSurface;uv:gUV):gXYZ;cdecl;

    { Преобразования }
    Tnurbs_surface_swap_uv=procedure(surface:TLN_NurbsSurface;
      out_surface:PLN_NurbsSurface);cdecl;
    Tnurbs_surface_reverse=procedure(surface:TLN_NurbsSurface;
      direction:integer;out_surface:PLN_NurbsSurface);cdecl;
    Tnurbs_surface_is_closed=function(surface:TLN_NurbsSurface;
      is_u_direction:integer):integer;cdecl;

    { Модификация узлов }
    Tnurbs_surface_insert_knot=procedure(surface:TLN_NurbsSurface;
      knot_value:double;times,is_u_direction:integer;
      out_surface:PLN_NurbsSurface);cdecl;
    Tnurbs_surface_refine_knot_vector=procedure(surface:TLN_NurbsSurface;
      insert_knots:PDouble;insert_count,is_u_direction:integer;
      out_surface:PLN_NurbsSurface);cdecl;
    Tnurbs_surface_remove_knot=procedure(surface:TLN_NurbsSurface;
      knot_value:double;times,is_u_direction:integer;
      out_surface:PLN_NurbsSurface);cdecl;

    { Изменение степени }
    Tnurbs_surface_elevate_degree=procedure(surface:TLN_NurbsSurface;
      times,is_u_direction:integer;out_surface:PLN_NurbsSurface);cdecl;
    Tnurbs_surface_reduce_degree=function(surface:TLN_NurbsSurface;
      is_u_direction:integer;out_surface:PLN_NurbsSurface):integer;cdecl;

    { Декомпозиция и тесселяция }
    Tnurbs_surface_decompose_to_beziers=function(surface:TLN_NurbsSurface;
      out_patches:PLN_NurbsSurface;max_patches:integer):integer;cdecl;
    Tnurbs_surface_equally_tessellate=procedure(surface:TLN_NurbsSurface;
      out_points:PXYZ;out_uvs:PUV;max_count:integer);cdecl;

    { Поиск параметров }
    Tnurbs_surface_get_param_on_surface=function(surface:TLN_NurbsSurface;
      given_point:gXYZ):gUV;cdecl;
    Tnurbs_surface_get_param_on_surface_by_gsa=function(surface:TLN_NurbsSurface;
      given_point:gXYZ):gUV;cdecl;
    Tnurbs_surface_get_uv_tangent=function(surface:TLN_NurbsSurface;
      param:gUV;tangent:gXYZ;out_uv_tangent:PUV):integer;cdecl;

    { Перепараметризация }
    Tnurbs_surface_reparametrize=procedure(surface:TLN_NurbsSurface;
      min_u,max_u,min_v,max_v:double;out_surface:PLN_NurbsSurface);cdecl;

    { Создание примитивов }
    Tnurbs_surface_create_bilinear=procedure(top_left,top_right,
      bottom_left,bottom_right:gXYZ;out_surface:PLN_NurbsSurface);cdecl;
    Tnurbs_surface_create_cylindrical=function(origin,x_axis,y_axis:gXYZ;
      start_rad,end_rad,radius,Height:double;
      out_surface:PLN_NurbsSurface):integer;cdecl;
    Tnurbs_surface_create_ruled=procedure(curve0,curve1:TLN_NurbsCurve;
      out_surface:PLN_NurbsSurface);cdecl;
    Tnurbs_surface_create_revolved=function(origin,axis:gXYZ;
      rad:double;profile:TLN_NurbsCurve;out_surface:PLN_NurbsSurface):integer;cdecl;

    { Интерполяция и аппроксимация }
    Tnurbs_surface_global_interpolation=procedure(points:PXYZ;
      rows,cols,degree_u,degree_v:integer;out_surface:PLN_NurbsSurface);cdecl;
    Tnurbs_surface_bicubic_local_interpolation=function(points:PXYZ;
      rows,cols:integer;out_surface:PLN_NurbsSurface):integer;cdecl;
    Tnurbs_surface_global_approximation=function(points:PXYZ;
      rows,cols,degree_u,degree_v,ctrl_rows,ctrl_cols:integer;
      out_surface:PLN_NurbsSurface):integer;cdecl;

    { Развёртка }
    Tnurbs_surface_create_swung=function(profile,trajectory:TLN_NurbsCurve;
      scale:double;out_surface:PLN_NurbsSurface):integer;cdecl;
    Tnurbs_surface_create_loft=procedure(sections:PLN_NurbsCurve;
      section_count:integer;out_surface:PLN_NurbsSurface;
      custom_trajectory_degree:integer;custom_knots:PDouble;
      knot_count:integer);cdecl;
    Tnurbs_surface_create_generalized_translational_sweep=procedure(
      profile,trajectory:TLN_NurbsCurve;out_surface:PLN_NurbsSurface);cdecl;
    Tnurbs_surface_create_sweep_interpolated=procedure(
      profile,trajectory:TLN_NurbsCurve;min_profiles:integer;
      out_surface:PLN_NurbsSurface);cdecl;
    Tnurbs_surface_create_sweep_noninterpolated=procedure(
      profile,trajectory:TLN_NurbsCurve;min_profiles,trajectory_degree:integer;
      out_surface:PLN_NurbsSurface);cdecl;

    { Поверхности по сетке кривых }
    Tnurbs_surface_create_gordon=procedure(u_curves:PLN_NurbsCurve;
      u_count:integer;v_curves:PLN_NurbsCurve;v_count:integer;
      intersections:PXYZ;out_surface:PLN_NurbsSurface);cdecl;
    Tnurbs_surface_create_coons=procedure(left,bottom,right,top:TLN_NurbsCurve;
      out_surface:PLN_NurbsSurface);cdecl;

    { Площадь и триангуляция }
    Tnurbs_surface_approximate_area=function(surface:TLN_NurbsSurface;
      integrator_type:integer):double;cdecl;
    Tnurbs_surface_triangulate=function(surface:TLN_NurbsSurface;
      resolution_u,resolution_v,use_delaunay:integer):TLNMesh;cdecl;

    { ========================================================================== }
    {                   Глобальные указатели на функции                          }
    { ========================================================================== }
    class var
      { XYZ_CAPI }
      xyz_create:Txyz_create;
      xyz_zero:Txyz_zero;
      xyz_add:Txyz_add;
      xyz_subtract:Txyz_subtract;
      xyz_negative:Txyz_negative;
      xyz_multiply:Txyz_multiply;
      xyz_divide:Txyz_divide;
      xyz_length:Txyz_length;
      xyz_sqr_length:Txyz_sqr_length;
      xyz_is_zero:Txyz_is_zero;
      xyz_is_unit:Txyz_is_unit;
      xyz_normalize:Txyz_normalize;
      xyz_dot:Txyz_dot;
      xyz_cross:Txyz_cross;
      xyz_distance:Txyz_distance;
      xyz_equals:Txyz_equals;

      { XYZW_CAPI }
      xyzw_create:Txyzw_create;
      xyzw_create_from_xyz:Txyzw_create_from_xyz;
      xyzw_to_xyz:Txyzw_to_xyz;
      xyzw_add:Txyzw_add;
      xyzw_multiply:Txyzw_multiply;
      xyzw_divide:Txyzw_divide;
      xyzw_distance:Txyzw_distance;
      xyzw_get_wx:Txyzw_get_wx;
      xyzw_get_wy:Txyzw_get_wy;
      xyzw_get_wz:Txyzw_get_wz;
      xyzw_get_w:Txyzw_get_w;

      { UV_CAPI }
      uv_create:Tuv_create;
      uv_get_u:Tuv_get_u;
      uv_get_v:Tuv_get_v;
      uv_add:Tuv_add;
      uv_subtract:Tuv_subtract;
      uv_negative:Tuv_negative;
      uv_normalize:Tuv_normalize;
      uv_scale:Tuv_scale;
      uv_divide:Tuv_divide;
      uv_length:Tuv_length;
      uv_sqr_length:Tuv_sqr_length;
      uv_distance:Tuv_distance;
      uv_is_zero:Tuv_is_zero;
      uv_is_unit:Tuv_is_unit;
      uv_is_almost_equal:Tuv_is_almost_equal;
      uv_dot:Tuv_dot;
      uv_cross:Tuv_cross;

      { Matrix4d_CAPI }
      matrix4d_identity:Tmatrix4d_identity;
      matrix4d_create_translation:Tmatrix4d_create_translation;
      matrix4d_create_rotation:Tmatrix4d_create_rotation;
      matrix4d_create_scale:Tmatrix4d_create_scale;
      matrix4d_create_reflection:Tmatrix4d_create_reflection;
      matrix4d_get_basis_x:Tmatrix4d_get_basis_x;
      matrix4d_get_basis_y:Tmatrix4d_get_basis_y;
      matrix4d_get_basis_z:Tmatrix4d_get_basis_z;
      matrix4d_get_basis_w:Tmatrix4d_get_basis_w;
      matrix4d_of_point:Tmatrix4d_of_point;
      matrix4d_of_vector:Tmatrix4d_of_vector;
      matrix4d_multiply:Tmatrix4d_multiply;
      matrix4d_get_inverse:Tmatrix4d_get_inverse;
      matrix4d_get_determinant:Tmatrix4d_get_determinant;

      { Projection_CAPI }
      projection_point_to_ray:Tprojection_point_to_ray;
      projection_point_to_line:Tprojection_point_to_line;
      projection_stereographic:Tprojection_stereographic;

      { BezierCurve_CAPI }
      bezier_curve_get_point_by_bernstein:Tbezier_curve_get_point_by_bernstein;
      bezier_curve_get_point_by_de_casteljau:Tbezier_curve_get_point_by_de_casteljau;
      bezier_curve_get_point_by_bernstein_rational:
      Tbezier_curve_get_point_by_bernstein_rational;

      { BezierSurface_CAPI }
      bezier_surface_get_point_by_de_casteljau:Tbezier_surface_get_point_by_de_casteljau;

      { Polynomials_CAPI }
      polynomials_bernstein:Tpolynomials_bernstein;
      polynomials_all_bernstein:Tpolynomials_all_bernstein;
      polynomials_horner_curve:Tpolynomials_horner_curve;
      polynomials_get_knot_span_index:Tpolynomials_get_knot_span_index;
      polynomials_get_knot_multiplicity:Tpolynomials_get_knot_multiplicity;
      polynomials_basis_functions:Tpolynomials_basis_functions;
      polynomials_bezier_to_power_matrix:Tpolynomials_bezier_to_power_matrix;

      { KnotVectorUtils_CAPI }
      knot_vector_utils_get_continuity:Tknot_vector_utils_get_continuity;
      knot_vector_utils_rescale:Tknot_vector_utils_rescale;
      knot_vector_utils_is_uniform:Tknot_vector_utils_is_uniform;
      knot_vector_utils_get_knot_multiplicity_map_size:
      Tknot_vector_utils_get_knot_multiplicity_map_size;
      knot_vector_utils_get_knot_multiplicity_map:
      Tknot_vector_utils_get_knot_multiplicity_map;

      { Intersection_CAPI }
      intersection_compute_rays:Tintersection_compute_rays;
      intersection_compute_line_and_plane:Tintersection_compute_line_and_plane;

      { ValidationUtils_CAPI }
      validation_utils_is_valid_knot_vector:Tvalidation_utils_is_valid_knot_vector;
      validation_utils_is_valid_bezier:Tvalidation_utils_is_valid_bezier;
      validation_utils_is_valid_bspline:Tvalidation_utils_is_valid_bspline;
      validation_utils_is_valid_nurbs:Tvalidation_utils_is_valid_nurbs;
      validation_utils_compute_curve_modify_tolerance:
      Tvalidation_utils_compute_curve_modify_tolerance;

      { NurbsCurve_CAPI - Создание }
      nurbs_curve_create_line:Tnurbs_curve_create_line;
      nurbs_curve_create_arc:Tnurbs_curve_create_arc;
      nurbs_curve_create_open_conic:Tnurbs_curve_create_open_conic;

      { NurbsCurve_CAPI - Интерполяция }
      nurbs_curve_global_interpolation:Tnurbs_curve_global_interpolation;
      nurbs_curve_global_interpolation_with_tangents:
      Tnurbs_curve_global_interpolation_with_tangents;
      nurbs_curve_cubic_local_interpolation:Tnurbs_curve_cubic_local_interpolation;
      nurbs_curve_least_squares_approximation:Tnurbs_curve_least_squares_approximation;
      nurbs_curve_weighted_constrained_least_squares:
      Tnurbs_curve_weighted_constrained_least_squares;
      nurbs_curve_global_approximation_by_error_bound:
      Tnurbs_curve_global_approximation_by_error_bound;

      { NurbsCurve_CAPI - Вычисление точек }
      nurbs_curve_get_point_on_curve:Tnurbs_curve_get_point_on_curve;
      nurbs_curve_get_point_on_curve_by_corner_cut:
      Tnurbs_curve_get_point_on_curve_by_corner_cut;

      { NurbsCurve_CAPI - Производные }
      nurbs_curve_compute_rational_derivatives:Tnurbs_curve_compute_rational_derivatives;
      nurbs_curve_curvature:Tnurbs_curve_curvature;
      nurbs_curve_torsion:Tnurbs_curve_torsion;
      nurbs_curve_normal:Tnurbs_curve_normal;
      nurbs_curve_project_normal:Tnurbs_curve_project_normal;

      { NurbsCurve_CAPI - Параметризация }
      nurbs_curve_get_param_on_curve_by_point:Tnurbs_curve_get_param_on_curve_by_point;
      nurbs_curve_approximate_length:Tnurbs_curve_approximate_length;
      nurbs_curve_get_param_by_length:Tnurbs_curve_get_param_by_length;
      nurbs_curve_get_params_by_equal_length:Tnurbs_curve_get_params_by_equal_length;

      { NurbsCurve_CAPI - Разбиение }
      nurbs_curve_split_at:Tnurbs_curve_split_at;
      nurbs_curve_segment:Tnurbs_curve_segment;
      nurbs_curve_decompose_to_beziers:Tnurbs_curve_decompose_to_beziers;
      nurbs_curve_tessellate:Tnurbs_curve_tessellate;

      { NurbsCurve_CAPI - Преобразование }
      nurbs_curve_create_transformed:Tnurbs_curve_create_transformed;
      nurbs_curve_reverse:Tnurbs_curve_reverse;
      nurbs_curve_reparametrize_to_interval:Tnurbs_curve_reparametrize_to_interval;
      nurbs_curve_reparametrize_linear_rational:Tnurbs_curve_reparametrize_linear_rational;

      { NurbsCurve_CAPI - Модификация узлов }
      nurbs_curve_insert_knot:Tnurbs_curve_insert_knot;
      nurbs_curve_remove_knot:Tnurbs_curve_remove_knot;
      nurbs_curve_remove_excessive_knots:Tnurbs_curve_remove_excessive_knots;
      nurbs_curve_refine_knot_vector:Tnurbs_curve_refine_knot_vector;
      nurbs_curve_elevate_degree:Tnurbs_curve_elevate_degree;
      nurbs_curve_reduce_degree:Tnurbs_curve_reduce_degree;

      { NurbsCurve_CAPI - Проверка свойств }
      nurbs_curve_is_closed:Tnurbs_curve_is_closed;
      nurbs_curve_is_linear:Tnurbs_curve_is_linear;
      nurbs_curve_is_clamped:Tnurbs_curve_is_clamped;
      nurbs_curve_is_periodic:Tnurbs_curve_is_periodic;
      nurbs_curve_can_compute_derivative:Tnurbs_curve_can_compute_derivative;

      { NurbsCurve_CAPI - Модификация контрольных точек }
      nurbs_curve_control_point_reposition:Tnurbs_curve_control_point_reposition;
      nurbs_curve_weight_modification:Tnurbs_curve_weight_modification;
      nurbs_curve_neighbor_weights_modification:Tnurbs_curve_neighbor_weights_modification;

      { NurbsCurve_CAPI - Деформация }
      nurbs_curve_warping:Tnurbs_curve_warping;
      nurbs_curve_flattening:Tnurbs_curve_flattening;
      nurbs_curve_bending:Tnurbs_curve_bending;
      nurbs_curve_constraint_based_modification:Tnurbs_curve_constraint_based_modification;

      { NurbsCurve_CAPI - Преобразование типа }
      nurbs_curve_to_clamp_curve:Tnurbs_curve_to_clamp_curve;
      nurbs_curve_to_unclamp_curve:Tnurbs_curve_to_unclamp_curve;
      nurbs_curve_equally_tessellate:Tnurbs_curve_equally_tessellate;

      { NurbsSurface_CAPI - Вычисление точек }
      nurbs_surface_get_point_on_surface:Tnurbs_surface_get_point_on_surface;
      nurbs_surface_compute_rational_derivatives:
      Tnurbs_surface_compute_rational_derivatives;
      nurbs_surface_compute_first_order_derivative:
      Tnurbs_surface_compute_first_order_derivative;
      nurbs_surface_curvature:Tnurbs_surface_curvature;
      nurbs_surface_normal:Tnurbs_surface_normal;

      { NurbsSurface_CAPI - Преобразования }
      nurbs_surface_swap_uv:Tnurbs_surface_swap_uv;
      nurbs_surface_reverse:Tnurbs_surface_reverse;
      nurbs_surface_is_closed:Tnurbs_surface_is_closed;

      { NurbsSurface_CAPI - Модификация узлов }
      nurbs_surface_insert_knot:Tnurbs_surface_insert_knot;
      nurbs_surface_refine_knot_vector:Tnurbs_surface_refine_knot_vector;
      nurbs_surface_remove_knot:Tnurbs_surface_remove_knot;

      { NurbsSurface_CAPI - Изменение степени }
      nurbs_surface_elevate_degree:Tnurbs_surface_elevate_degree;
      nurbs_surface_reduce_degree:Tnurbs_surface_reduce_degree;

      { NurbsSurface_CAPI - Декомпозиция и тесселяция }
      nurbs_surface_decompose_to_beziers:Tnurbs_surface_decompose_to_beziers;
      nurbs_surface_equally_tessellate:Tnurbs_surface_equally_tessellate;

      { NurbsSurface_CAPI - Поиск параметров }
      nurbs_surface_get_param_on_surface:Tnurbs_surface_get_param_on_surface;
      nurbs_surface_get_param_on_surface_by_gsa:Tnurbs_surface_get_param_on_surface_by_gsa;
      nurbs_surface_get_uv_tangent:Tnurbs_surface_get_uv_tangent;

      { NurbsSurface_CAPI - Перепараметризация }
      nurbs_surface_reparametrize:Tnurbs_surface_reparametrize;

      { NurbsSurface_CAPI - Создание примитивов }
      nurbs_surface_create_bilinear:Tnurbs_surface_create_bilinear;
      nurbs_surface_create_cylindrical:Tnurbs_surface_create_cylindrical;
      nurbs_surface_create_ruled:Tnurbs_surface_create_ruled;
      nurbs_surface_create_revolved:Tnurbs_surface_create_revolved;

      { NurbsSurface_CAPI - Интерполяция и аппроксимация }
      nurbs_surface_global_interpolation:Tnurbs_surface_global_interpolation;
      nurbs_surface_bicubic_local_interpolation:Tnurbs_surface_bicubic_local_interpolation;
      nurbs_surface_global_approximation:Tnurbs_surface_global_approximation;

      { NurbsSurface_CAPI - Развёртка }
      nurbs_surface_create_swung:Tnurbs_surface_create_swung;
      nurbs_surface_create_loft:Tnurbs_surface_create_loft;
      nurbs_surface_create_generalized_translational_sweep:
      Tnurbs_surface_create_generalized_translational_sweep;
      nurbs_surface_create_sweep_interpolated:Tnurbs_surface_create_sweep_interpolated;
      nurbs_surface_create_sweep_noninterpolated:
      Tnurbs_surface_create_sweep_noninterpolated;

      { NurbsSurface_CAPI - Поверхности по сетке кривых }
      nurbs_surface_create_gordon:Tnurbs_surface_create_gordon;
      nurbs_surface_create_coons:Tnurbs_surface_create_coons;

      { NurbsSurface_CAPI - Площадь и триангуляция }
      nurbs_surface_approximate_area:Tnurbs_surface_approximate_area;
      nurbs_surface_triangulate:Tnurbs_surface_triangulate;

    class constructor CreateRec;
      { ========================================================================== }
      {                      Функции загрузки и выгрузки                           }
      { ========================================================================== }
    class function LoadLNLib:boolean;static;
    class procedure UnloadLNLib;static;
    class function IsLNLibLoaded:boolean;static;

    class function LoadXYZFunctions:boolean;static;
    class function LoadXYZWFunctions:boolean;static;
    class function LoadUVFunctions:boolean;static;
    class function LoadMatrix4dFunctions:boolean;static;
    class function LoadProjectionFunctions:boolean;static;
    class function LoadNurbsSurfaceFunctions:boolean;static;
    class function LoadNurbsCurveFunctions:boolean;static;
    class function LoadValidationUtilsFunctions:boolean;static;
    class function LoadIntersectionFunctions:boolean;static;
    class function LoadKnotVectorUtilsFunctions:boolean;static;
    class function LoadPolynomialsFunctions:boolean;static;
    class function LoadBezierSurfaceFunctions:boolean;static;
    class function LoadBezierCurveFunctions:boolean;static;
    class procedure ClearAllFunctionPointers;static;
  end;

function LoadFuncAddr(const FuncName:string;var FuncPtr:Pointer):boolean;

implementation

uses
  XYZ_CAPI,XYZW_CAPI,UV_CAPI,Matrix4d_CAPI;

{**
  Вспомогательная функция для загрузки адреса функции из библиотеки.

  @param FuncName Имя функции для загрузки
  @param FuncPtr Указатель на переменную для сохранения адреса
  @return True если адрес загружен успешно, False при ошибке
}
function LoadFuncAddr(const FuncName:string;var FuncPtr:Pointer):boolean;
begin
  FuncPtr:=GetProcAddress(LNLibHandle,PChar(FuncName));
  Result:=FuncPtr<>nil;
end;

{**
  Загрузка всех функций XYZ_CAPI.

  @return True если все функции загружены успешно
}
class function gLNLibRec<gXYZ,gXYZW,gUV,gMatrix4d>.LoadXYZFunctions:boolean;
begin
  Result:=True;
  Result:=LoadFuncAddr('xyz_create',@xyz_create) and Result;
  Result:=LoadFuncAddr('xyz_zero',@xyz_zero) and Result;
  Result:=LoadFuncAddr('xyz_add',@xyz_add) and Result;
  Result:=LoadFuncAddr('xyz_subtract',@xyz_subtract) and Result;
  Result:=LoadFuncAddr('xyz_negative',@xyz_negative) and Result;
  Result:=LoadFuncAddr('xyz_multiply',@xyz_multiply) and Result;
  Result:=LoadFuncAddr('xyz_divide',@xyz_divide) and Result;
  Result:=LoadFuncAddr('xyz_length',@xyz_length) and Result;
  Result:=LoadFuncAddr('xyz_sqr_length',@xyz_sqr_length) and Result;
  Result:=LoadFuncAddr('xyz_is_zero',@xyz_is_zero) and Result;
  Result:=LoadFuncAddr('xyz_is_unit',@xyz_is_unit) and Result;
  Result:=LoadFuncAddr('xyz_normalize',@xyz_normalize) and Result;
  Result:=LoadFuncAddr('xyz_dot',@xyz_dot) and Result;
  Result:=LoadFuncAddr('xyz_cross',@xyz_cross) and Result;
  Result:=LoadFuncAddr('xyz_distance',@xyz_distance) and Result;
  Result:=LoadFuncAddr('xyz_equals',@xyz_equals) and Result;
end;

{**
  Загрузка всех функций XYZW_CAPI.

  @return True если все функции загружены успешно
}
class function gLNLibRec<gXYZ,gXYZW,gUV,gMatrix4d>.LoadXYZWFunctions:boolean;
begin
  Result:=True;
  Result:=LoadFuncAddr('xyzw_create',@xyzw_create) and Result;
  Result:=LoadFuncAddr('xyzw_create_from_xyz',@xyzw_create_from_xyz) and Result;
  Result:=LoadFuncAddr('xyzw_to_xyz',@xyzw_to_xyz) and Result;
  Result:=LoadFuncAddr('xyzw_add',@xyzw_add) and Result;
  Result:=LoadFuncAddr('xyzw_multiply',@xyzw_multiply) and Result;
  Result:=LoadFuncAddr('xyzw_divide',@xyzw_divide) and Result;
  Result:=LoadFuncAddr('xyzw_distance',@xyzw_distance) and Result;
  Result:=LoadFuncAddr('xyzw_get_wx',@xyzw_get_wx) and Result;
  Result:=LoadFuncAddr('xyzw_get_wy',@xyzw_get_wy) and Result;
  Result:=LoadFuncAddr('xyzw_get_wz',@xyzw_get_wz) and Result;
  Result:=LoadFuncAddr('xyzw_get_w',@xyzw_get_w) and Result;
end;

{**
  Загрузка всех функций UV_CAPI.

  @return True если все функции загружены успешно
}
class function gLNLibRec<gXYZ,gXYZW,gUV,gMatrix4d>.LoadUVFunctions:boolean;
begin
  Result:=True;
  Result:=LoadFuncAddr('uv_create',@uv_create) and Result;
  Result:=LoadFuncAddr('uv_get_u',@uv_get_u) and Result;
  Result:=LoadFuncAddr('uv_get_v',@uv_get_v) and Result;
  Result:=LoadFuncAddr('uv_add',@uv_add) and Result;
  Result:=LoadFuncAddr('uv_subtract',@uv_subtract) and Result;
  Result:=LoadFuncAddr('uv_negative',@uv_negative) and Result;
  Result:=LoadFuncAddr('uv_normalize',@uv_normalize) and Result;
  Result:=LoadFuncAddr('uv_scale',@uv_scale) and Result;
  Result:=LoadFuncAddr('uv_divide',@uv_divide) and Result;
  Result:=LoadFuncAddr('uv_length',@uv_length) and Result;
  Result:=LoadFuncAddr('uv_sqr_length',@uv_sqr_length) and Result;
  Result:=LoadFuncAddr('uv_distance',@uv_distance) and Result;
  Result:=LoadFuncAddr('uv_is_zero',@uv_is_zero) and Result;
  Result:=LoadFuncAddr('uv_is_unit',@uv_is_unit) and Result;
  Result:=LoadFuncAddr('uv_is_almost_equal',@uv_is_almost_equal) and Result;
  Result:=LoadFuncAddr('uv_dot',@uv_dot) and Result;
  Result:=LoadFuncAddr('uv_cross',@uv_cross) and Result;
end;

{**
  Загрузка всех функций Matrix4d_CAPI.

  @return True если все функции загружены успешно
}
class function gLNLibRec<gXYZ,gXYZW,gUV,gMatrix4d>.LoadMatrix4dFunctions:boolean;
begin
  Result:=True;
  Result:=LoadFuncAddr('matrix4d_identity',@matrix4d_identity) and Result;
  Result:=LoadFuncAddr('matrix4d_create_translation',
    @matrix4d_create_translation) and Result;
  Result:=LoadFuncAddr('matrix4d_create_rotation',@matrix4d_create_rotation) and
    Result;
  Result:=LoadFuncAddr('matrix4d_create_scale',@matrix4d_create_scale) and Result;
  Result:=LoadFuncAddr('matrix4d_create_reflection',@matrix4d_create_reflection) and
    Result;
  Result:=LoadFuncAddr('matrix4d_get_basis_x',@matrix4d_get_basis_x) and Result;
  Result:=LoadFuncAddr('matrix4d_get_basis_y',@matrix4d_get_basis_y) and Result;
  Result:=LoadFuncAddr('matrix4d_get_basis_z',@matrix4d_get_basis_z) and Result;
  Result:=LoadFuncAddr('matrix4d_get_basis_w',@matrix4d_get_basis_w) and Result;
  Result:=LoadFuncAddr('matrix4d_of_point',@matrix4d_of_point) and Result;
  Result:=LoadFuncAddr('matrix4d_of_vector',@matrix4d_of_vector) and Result;
  Result:=LoadFuncAddr('matrix4d_multiply',@matrix4d_multiply) and Result;
  Result:=LoadFuncAddr('matrix4d_get_inverse',@matrix4d_get_inverse) and Result;
  Result:=LoadFuncAddr('matrix4d_get_determinant',@matrix4d_get_determinant) and
    Result;
end;

{**
  Загрузка всех функций Projection_CAPI.

  @return True если все функции загружены успешно
}
class function gLNLibRec<gXYZ,gXYZW,gUV,gMatrix4d>.LoadProjectionFunctions:boolean;
begin
  Result:=True;
  Result:=LoadFuncAddr('projection_point_to_ray',@projection_point_to_ray) and Result;
  Result:=LoadFuncAddr('projection_point_to_line',@projection_point_to_line) and
    Result;
  Result:=LoadFuncAddr('projection_stereographic',@projection_stereographic) and
    Result;
end;

{**
  Загрузка всех функций BezierCurve_CAPI.

  @return True если все функции загружены успешно
}
class function gLNLibRec<gXYZ,gXYZW,gUV,gMatrix4d>.LoadBezierCurveFunctions:boolean;
begin
  Result:=True;
  Result:=LoadFuncAddr('bezier_curve_get_point_by_bernstein',
    @bezier_curve_get_point_by_bernstein) and Result;
  Result:=LoadFuncAddr('bezier_curve_get_point_by_de_casteljau',
    @bezier_curve_get_point_by_de_casteljau) and Result;
  Result:=LoadFuncAddr('bezier_curve_get_point_by_bernstein_rational',
    @bezier_curve_get_point_by_bernstein_rational) and Result;
end;

{**
  Загрузка всех функций BezierSurface_CAPI.

  @return True если все функции загружены успешно
}
class function gLNLibRec<gXYZ,gXYZW,gUV,gMatrix4d>.LoadBezierSurfaceFunctions:boolean;
begin
  Result:=True;
  Result:=LoadFuncAddr('bezier_surface_get_point_by_de_casteljau',
    @bezier_surface_get_point_by_de_casteljau) and Result;
end;

{**
  Загрузка всех функций Polynomials_CAPI.

  @return True если все функции загружены успешно
}
class function gLNLibRec<gXYZ,gXYZW,gUV,gMatrix4d>.LoadPolynomialsFunctions:boolean;
begin
  Result:=True;
  Result:=LoadFuncAddr('polynomials_bernstein',@polynomials_bernstein) and Result;
  Result:=LoadFuncAddr('polynomials_all_bernstein',@polynomials_all_bernstein) and
    Result;
  Result:=LoadFuncAddr('polynomials_horner_curve',@polynomials_horner_curve) and
    Result;
  Result:=LoadFuncAddr('polynomials_get_knot_span_index',
    @polynomials_get_knot_span_index) and Result;
  Result:=LoadFuncAddr('polynomials_get_knot_multiplicity',
    @polynomials_get_knot_multiplicity) and Result;
  Result:=LoadFuncAddr('polynomials_basis_functions',
    @polynomials_basis_functions) and Result;
  Result:=LoadFuncAddr('polynomials_bezier_to_power_matrix',
    @polynomials_bezier_to_power_matrix) and Result;
end;

{**
  Загрузка всех функций KnotVectorUtils_CAPI.

  @return True если все функции загружены успешно
}
class function gLNLibRec<gXYZ,gXYZW,gUV,gMatrix4d>.LoadKnotVectorUtilsFunctions:boolean;
begin
  Result:=True;
  Result:=LoadFuncAddr('knot_vector_utils_get_continuity',
    @knot_vector_utils_get_continuity) and Result;
  Result:=LoadFuncAddr('knot_vector_utils_rescale',@knot_vector_utils_rescale) and
    Result;
  Result:=LoadFuncAddr('knot_vector_utils_is_uniform',
    @knot_vector_utils_is_uniform) and Result;
  Result:=LoadFuncAddr('knot_vector_utils_get_knot_multiplicity_map_size',
    @knot_vector_utils_get_knot_multiplicity_map_size) and Result;
  Result:=LoadFuncAddr('knot_vector_utils_get_knot_multiplicity_map',
    @knot_vector_utils_get_knot_multiplicity_map) and Result;
end;

{**
  Загрузка всех функций Intersection_CAPI.

  @return True если все функции загружены успешно
}
class function gLNLibRec<gXYZ,gXYZW,gUV,gMatrix4d>.LoadIntersectionFunctions:boolean;
begin
  Result:=True;
  Result:=LoadFuncAddr('intersection_compute_rays',@intersection_compute_rays) and
    Result;
  Result:=LoadFuncAddr('intersection_compute_line_and_plane',
    @intersection_compute_line_and_plane) and Result;
end;

{**
  Загрузка всех функций ValidationUtils_CAPI.

  @return True если все функции загружены успешно
}
class function gLNLibRec<gXYZ,gXYZW,gUV,gMatrix4d>.LoadValidationUtilsFunctions:boolean;
begin
  Result:=True;
  Result:=LoadFuncAddr('validation_utils_is_valid_knot_vector',
    @validation_utils_is_valid_knot_vector) and Result;
  Result:=LoadFuncAddr('validation_utils_is_valid_bezier',
    @validation_utils_is_valid_bezier) and Result;
  Result:=LoadFuncAddr('validation_utils_is_valid_bspline',
    @validation_utils_is_valid_bspline) and Result;
  Result:=LoadFuncAddr('validation_utils_is_valid_nurbs',
    @validation_utils_is_valid_nurbs) and Result;
  Result:=LoadFuncAddr('validation_utils_compute_curve_modify_tolerance',
    @validation_utils_compute_curve_modify_tolerance) and Result;
end;

{**
  Загрузка всех функций NurbsCurve_CAPI.

  @return True если все функции загружены успешно
}
class function gLNLibRec<gXYZ,gXYZW,gUV,gMatrix4d>.LoadNurbsCurveFunctions:boolean;
begin
  Result:=True;

  { Создание кривых }
  Result:=LoadFuncAddr('nurbs_curve_create_line',@nurbs_curve_create_line) and Result;
  Result:=LoadFuncAddr('nurbs_curve_create_arc',@nurbs_curve_create_arc) and Result;
  Result:=LoadFuncAddr('nurbs_curve_create_open_conic',
    @nurbs_curve_create_open_conic) and Result;

  { Интерполяция и аппроксимация }
  Result:=LoadFuncAddr('nurbs_curve_global_interpolation',
    @nurbs_curve_global_interpolation) and Result;
  Result:=LoadFuncAddr('nurbs_curve_global_interpolation_with_tangents',
    @nurbs_curve_global_interpolation_with_tangents) and Result;
  Result:=LoadFuncAddr('nurbs_curve_cubic_local_interpolation',
    @nurbs_curve_cubic_local_interpolation) and Result;
  Result:=LoadFuncAddr('nurbs_curve_least_squares_approximation',
    @nurbs_curve_least_squares_approximation) and Result;
  Result:=LoadFuncAddr('nurbs_curve_weighted_constrained_least_squares',
    @nurbs_curve_weighted_constrained_least_squares) and Result;
  Result:=LoadFuncAddr('nurbs_curve_global_approximation_by_error_bound',
    @nurbs_curve_global_approximation_by_error_bound) and Result;

  { Вычисление точек }
  Result:=LoadFuncAddr('nurbs_curve_get_point_on_curve',
    @nurbs_curve_get_point_on_curve) and Result;
  Result:=LoadFuncAddr('nurbs_curve_get_point_on_curve_by_corner_cut',
    @nurbs_curve_get_point_on_curve_by_corner_cut) and Result;

  { Производные }
  Result:=LoadFuncAddr('nurbs_curve_compute_rational_derivatives',
    @nurbs_curve_compute_rational_derivatives) and Result;
  Result:=LoadFuncAddr('nurbs_curve_curvature',@nurbs_curve_curvature) and Result;
  Result:=LoadFuncAddr('nurbs_curve_torsion',@nurbs_curve_torsion) and Result;
  Result:=LoadFuncAddr('nurbs_curve_normal',@nurbs_curve_normal) and Result;
  Result:=LoadFuncAddr('nurbs_curve_project_normal',@nurbs_curve_project_normal) and
    Result;

  { Параметризация }
  Result:=LoadFuncAddr('nurbs_curve_get_param_on_curve_by_point',
    @nurbs_curve_get_param_on_curve_by_point) and Result;
  Result:=LoadFuncAddr('nurbs_curve_approximate_length',
    @nurbs_curve_approximate_length) and Result;
  Result:=LoadFuncAddr('nurbs_curve_get_param_by_length',
    @nurbs_curve_get_param_by_length) and Result;
  Result:=LoadFuncAddr('nurbs_curve_get_params_by_equal_length',
    @nurbs_curve_get_params_by_equal_length) and Result;

  { Разбиение }
  Result:=LoadFuncAddr('nurbs_curve_split_at',@nurbs_curve_split_at) and Result;
  Result:=LoadFuncAddr('nurbs_curve_segment',@nurbs_curve_segment) and Result;
  Result:=LoadFuncAddr('nurbs_curve_decompose_to_beziers',
    @nurbs_curve_decompose_to_beziers) and Result;
  Result:=LoadFuncAddr('nurbs_curve_tessellate',@nurbs_curve_tessellate) and Result;

  { Преобразование }
  Result:=LoadFuncAddr('nurbs_curve_create_transformed',
    @nurbs_curve_create_transformed) and Result;
  Result:=LoadFuncAddr('nurbs_curve_reverse',@nurbs_curve_reverse) and Result;
  Result:=LoadFuncAddr('nurbs_curve_reparametrize_to_interval',
    @nurbs_curve_reparametrize_to_interval) and Result;
  Result:=LoadFuncAddr('nurbs_curve_reparametrize_linear_rational',
    @nurbs_curve_reparametrize_linear_rational) and Result;

  { Модификация узлов }
  Result:=LoadFuncAddr('nurbs_curve_insert_knot',@nurbs_curve_insert_knot) and Result;
  Result:=LoadFuncAddr('nurbs_curve_remove_knot',@nurbs_curve_remove_knot) and Result;
  Result:=LoadFuncAddr('nurbs_curve_remove_excessive_knots',
    @nurbs_curve_remove_excessive_knots) and Result;
  Result:=LoadFuncAddr('nurbs_curve_refine_knot_vector',
    @nurbs_curve_refine_knot_vector) and Result;
  Result:=LoadFuncAddr('nurbs_curve_elevate_degree',@nurbs_curve_elevate_degree) and
    Result;
  Result:=LoadFuncAddr('nurbs_curve_reduce_degree',@nurbs_curve_reduce_degree) and
    Result;

  { Проверка свойств }
  Result:=LoadFuncAddr('nurbs_curve_is_closed',@nurbs_curve_is_closed) and Result;
  Result:=LoadFuncAddr('nurbs_curve_is_linear',@nurbs_curve_is_linear) and Result;
  Result:=LoadFuncAddr('nurbs_curve_is_clamped',@nurbs_curve_is_clamped) and Result;
  Result:=LoadFuncAddr('nurbs_curve_is_periodic',@nurbs_curve_is_periodic) and Result;
  Result:=LoadFuncAddr('nurbs_curve_can_compute_derivative',
    @nurbs_curve_can_compute_derivative) and Result;

  { Модификация контрольных точек }
  Result:=LoadFuncAddr('nurbs_curve_control_point_reposition',
    @nurbs_curve_control_point_reposition) and Result;
  Result:=LoadFuncAddr('nurbs_curve_weight_modification',
    @nurbs_curve_weight_modification) and Result;
  Result:=LoadFuncAddr('nurbs_curve_neighbor_weights_modification',
    @nurbs_curve_neighbor_weights_modification) and Result;

  { Деформация }
  Result:=LoadFuncAddr('nurbs_curve_warping',@nurbs_curve_warping) and Result;
  Result:=LoadFuncAddr('nurbs_curve_flattening',@nurbs_curve_flattening) and Result;
  Result:=LoadFuncAddr('nurbs_curve_bending',@nurbs_curve_bending) and Result;
  Result:=LoadFuncAddr('nurbs_curve_constraint_based_modification',
    @nurbs_curve_constraint_based_modification) and Result;

  { Преобразование типа }
  Result:=LoadFuncAddr('nurbs_curve_to_clamp_curve',@nurbs_curve_to_clamp_curve) and
    Result;
  Result:=LoadFuncAddr('nurbs_curve_to_unclamp_curve',
    @nurbs_curve_to_unclamp_curve) and Result;
  Result:=LoadFuncAddr('nurbs_curve_equally_tessellate',
    @nurbs_curve_equally_tessellate) and Result;
end;

{**
  Загрузка всех функций NurbsSurface_CAPI.

  @return True если все функции загружены успешно
}
class function gLNLibRec<gXYZ,gXYZW,gUV,gMatrix4d>.LoadNurbsSurfaceFunctions:boolean;
begin
  Result:=True;

  { Вычисление точек }
  Result:=LoadFuncAddr('nurbs_surface_get_point_on_surface',
    @nurbs_surface_get_point_on_surface) and Result;
  Result:=LoadFuncAddr('nurbs_surface_compute_rational_derivatives',
    @nurbs_surface_compute_rational_derivatives) and Result;
  Result:=LoadFuncAddr('nurbs_surface_compute_first_order_derivative',
    @nurbs_surface_compute_first_order_derivative) and Result;
  Result:=LoadFuncAddr('nurbs_surface_curvature',@nurbs_surface_curvature) and Result;
  Result:=LoadFuncAddr('nurbs_surface_normal',@nurbs_surface_normal) and Result;

  { Преобразования }
  Result:=LoadFuncAddr('nurbs_surface_swap_uv',@nurbs_surface_swap_uv) and Result;
  Result:=LoadFuncAddr('nurbs_surface_reverse',@nurbs_surface_reverse) and Result;
  Result:=LoadFuncAddr('nurbs_surface_is_closed',@nurbs_surface_is_closed) and Result;

  { Модификация узлов }
  Result:=LoadFuncAddr('nurbs_surface_insert_knot',@nurbs_surface_insert_knot) and
    Result;
  Result:=LoadFuncAddr('nurbs_surface_refine_knot_vector',
    @nurbs_surface_refine_knot_vector) and Result;
  Result:=LoadFuncAddr('nurbs_surface_remove_knot',@nurbs_surface_remove_knot) and
    Result;

  { Изменение степени }
  Result:=LoadFuncAddr('nurbs_surface_elevate_degree',
    @nurbs_surface_elevate_degree) and Result;
  Result:=LoadFuncAddr('nurbs_surface_reduce_degree',
    @nurbs_surface_reduce_degree) and Result;

  { Декомпозиция и тесселяция }
  Result:=LoadFuncAddr('nurbs_surface_decompose_to_beziers',
    @nurbs_surface_decompose_to_beziers) and Result;
  Result:=LoadFuncAddr('nurbs_surface_equally_tessellate',
    @nurbs_surface_equally_tessellate) and Result;

  { Поиск параметров }
  Result:=LoadFuncAddr('nurbs_surface_get_param_on_surface',
    @nurbs_surface_get_param_on_surface) and Result;
  Result:=LoadFuncAddr('nurbs_surface_get_param_on_surface_by_gsa',
    @nurbs_surface_get_param_on_surface_by_gsa) and Result;
  Result:=LoadFuncAddr('nurbs_surface_get_uv_tangent',
    @nurbs_surface_get_uv_tangent) and Result;

  { Перепараметризация }
  Result:=LoadFuncAddr('nurbs_surface_reparametrize',
    @nurbs_surface_reparametrize) and Result;

  { Создание примитивов }
  Result:=LoadFuncAddr('nurbs_surface_create_bilinear',
    @nurbs_surface_create_bilinear) and Result;
  Result:=LoadFuncAddr('nurbs_surface_create_cylindrical',
    @nurbs_surface_create_cylindrical) and Result;
  Result:=LoadFuncAddr('nurbs_surface_create_ruled',@nurbs_surface_create_ruled) and
    Result;
  Result:=LoadFuncAddr('nurbs_surface_create_revolved',
    @nurbs_surface_create_revolved) and Result;

  { Интерполяция и аппроксимация }
  Result:=LoadFuncAddr('nurbs_surface_global_interpolation',
    @nurbs_surface_global_interpolation) and Result;
  Result:=LoadFuncAddr('nurbs_surface_bicubic_local_interpolation',
    @nurbs_surface_bicubic_local_interpolation) and Result;
  Result:=LoadFuncAddr('nurbs_surface_global_approximation',
    @nurbs_surface_global_approximation) and Result;

  { Развёртка }
  Result:=LoadFuncAddr('nurbs_surface_create_swung',@nurbs_surface_create_swung) and
    Result;
  Result:=LoadFuncAddr('nurbs_surface_create_loft',@nurbs_surface_create_loft) and
    Result;
  Result:=LoadFuncAddr('nurbs_surface_create_generalized_translational_sweep',
    @nurbs_surface_create_generalized_translational_sweep) and Result;
  Result:=LoadFuncAddr('nurbs_surface_create_sweep_interpolated',
    @nurbs_surface_create_sweep_interpolated) and Result;
  Result:=LoadFuncAddr('nurbs_surface_create_sweep_noninterpolated',
    @nurbs_surface_create_sweep_noninterpolated) and Result;

  { Поверхности по сетке кривых }
  Result:=LoadFuncAddr('nurbs_surface_create_gordon',
    @nurbs_surface_create_gordon) and Result;
  Result:=LoadFuncAddr('nurbs_surface_create_coons',@nurbs_surface_create_coons) and
    Result;

  { Площадь и триангуляция }
  Result:=LoadFuncAddr('nurbs_surface_approximate_area',
    @nurbs_surface_approximate_area) and Result;
  Result:=LoadFuncAddr('nurbs_surface_triangulate',@nurbs_surface_triangulate) and
    Result;
end;

{**
  Обнуление всех указателей на функции.
}
class procedure gLNLibRec<gXYZ,gXYZW,gUV,gMatrix4d>.ClearAllFunctionPointers;
begin
  { XYZ_CAPI }
  xyz_create:=nil;
  xyz_zero:=nil;
  xyz_add:=nil;
  xyz_subtract:=nil;
  xyz_negative:=nil;
  xyz_multiply:=nil;
  xyz_divide:=nil;
  xyz_length:=nil;
  xyz_sqr_length:=nil;
  xyz_is_zero:=nil;
  xyz_is_unit:=nil;
  xyz_normalize:=nil;
  xyz_dot:=nil;
  xyz_cross:=nil;
  xyz_distance:=nil;
  xyz_equals:=nil;

  { XYZW_CAPI }
  xyzw_create:=nil;
  xyzw_create_from_xyz:=nil;
  xyzw_to_xyz:=nil;
  xyzw_add:=nil;
  xyzw_multiply:=nil;
  xyzw_divide:=nil;
  xyzw_distance:=nil;
  xyzw_get_wx:=nil;
  xyzw_get_wy:=nil;
  xyzw_get_wz:=nil;
  xyzw_get_w:=nil;

  { UV_CAPI }
  uv_create:=nil;
  uv_get_u:=nil;
  uv_get_v:=nil;
  uv_add:=nil;
  uv_subtract:=nil;
  uv_negative:=nil;
  uv_normalize:=nil;
  uv_scale:=nil;
  uv_divide:=nil;
  uv_length:=nil;
  uv_sqr_length:=nil;
  uv_distance:=nil;
  uv_is_zero:=nil;
  uv_is_unit:=nil;
  uv_is_almost_equal:=nil;
  uv_dot:=nil;
  uv_cross:=nil;

  { Matrix4d_CAPI }
  matrix4d_identity:=nil;
  matrix4d_create_translation:=nil;
  matrix4d_create_rotation:=nil;
  matrix4d_create_scale:=nil;
  matrix4d_create_reflection:=nil;
  matrix4d_get_basis_x:=nil;
  matrix4d_get_basis_y:=nil;
  matrix4d_get_basis_z:=nil;
  matrix4d_get_basis_w:=nil;
  matrix4d_of_point:=nil;
  matrix4d_of_vector:=nil;
  matrix4d_multiply:=nil;
  matrix4d_get_inverse:=nil;
  matrix4d_get_determinant:=nil;

  { Projection_CAPI }
  projection_point_to_ray:=nil;
  projection_point_to_line:=nil;
  projection_stereographic:=nil;

  { BezierCurve_CAPI }
  bezier_curve_get_point_by_bernstein:=nil;
  bezier_curve_get_point_by_de_casteljau:=nil;
  bezier_curve_get_point_by_bernstein_rational:=nil;

  { BezierSurface_CAPI }
  bezier_surface_get_point_by_de_casteljau:=nil;

  { Polynomials_CAPI }
  polynomials_bernstein:=nil;
  polynomials_all_bernstein:=nil;
  polynomials_horner_curve:=nil;
  polynomials_get_knot_span_index:=nil;
  polynomials_get_knot_multiplicity:=nil;
  polynomials_basis_functions:=nil;
  polynomials_bezier_to_power_matrix:=nil;

  { KnotVectorUtils_CAPI }
  knot_vector_utils_get_continuity:=nil;
  knot_vector_utils_rescale:=nil;
  knot_vector_utils_is_uniform:=nil;
  knot_vector_utils_get_knot_multiplicity_map_size:=nil;
  knot_vector_utils_get_knot_multiplicity_map:=nil;

  { Intersection_CAPI }
  intersection_compute_rays:=nil;
  intersection_compute_line_and_plane:=nil;

  { ValidationUtils_CAPI }
  validation_utils_is_valid_knot_vector:=nil;
  validation_utils_is_valid_bezier:=nil;
  validation_utils_is_valid_bspline:=nil;
  validation_utils_is_valid_nurbs:=nil;
  validation_utils_compute_curve_modify_tolerance:=nil;

  { NurbsCurve_CAPI }
  nurbs_curve_create_line:=nil;
  nurbs_curve_create_arc:=nil;
  nurbs_curve_create_open_conic:=nil;
  nurbs_curve_global_interpolation:=nil;
  nurbs_curve_global_interpolation_with_tangents:=nil;
  nurbs_curve_cubic_local_interpolation:=nil;
  nurbs_curve_least_squares_approximation:=nil;
  nurbs_curve_weighted_constrained_least_squares:=nil;
  nurbs_curve_global_approximation_by_error_bound:=nil;
  nurbs_curve_get_point_on_curve:=nil;
  nurbs_curve_get_point_on_curve_by_corner_cut:=nil;
  nurbs_curve_compute_rational_derivatives:=nil;
  nurbs_curve_curvature:=nil;
  nurbs_curve_torsion:=nil;
  nurbs_curve_normal:=nil;
  nurbs_curve_project_normal:=nil;
  nurbs_curve_get_param_on_curve_by_point:=nil;
  nurbs_curve_approximate_length:=nil;
  nurbs_curve_get_param_by_length:=nil;
  nurbs_curve_get_params_by_equal_length:=nil;
  nurbs_curve_split_at:=nil;
  nurbs_curve_segment:=nil;
  nurbs_curve_decompose_to_beziers:=nil;
  nurbs_curve_tessellate:=nil;
  nurbs_curve_create_transformed:=nil;
  nurbs_curve_reverse:=nil;
  nurbs_curve_reparametrize_to_interval:=nil;
  nurbs_curve_reparametrize_linear_rational:=nil;
  nurbs_curve_insert_knot:=nil;
  nurbs_curve_remove_knot:=nil;
  nurbs_curve_remove_excessive_knots:=nil;
  nurbs_curve_refine_knot_vector:=nil;
  nurbs_curve_elevate_degree:=nil;
  nurbs_curve_reduce_degree:=nil;
  nurbs_curve_is_closed:=nil;
  nurbs_curve_is_linear:=nil;
  nurbs_curve_is_clamped:=nil;
  nurbs_curve_is_periodic:=nil;
  nurbs_curve_can_compute_derivative:=nil;
  nurbs_curve_control_point_reposition:=nil;
  nurbs_curve_weight_modification:=nil;
  nurbs_curve_neighbor_weights_modification:=nil;
  nurbs_curve_warping:=nil;
  nurbs_curve_flattening:=nil;
  nurbs_curve_bending:=nil;
  nurbs_curve_constraint_based_modification:=nil;
  nurbs_curve_to_clamp_curve:=nil;
  nurbs_curve_to_unclamp_curve:=nil;
  nurbs_curve_equally_tessellate:=nil;

  { NurbsSurface_CAPI }
  nurbs_surface_get_point_on_surface:=nil;
  nurbs_surface_compute_rational_derivatives:=nil;
  nurbs_surface_compute_first_order_derivative:=nil;
  nurbs_surface_curvature:=nil;
  nurbs_surface_normal:=nil;
  nurbs_surface_swap_uv:=nil;
  nurbs_surface_reverse:=nil;
  nurbs_surface_is_closed:=nil;
  nurbs_surface_insert_knot:=nil;
  nurbs_surface_refine_knot_vector:=nil;
  nurbs_surface_remove_knot:=nil;
  nurbs_surface_elevate_degree:=nil;
  nurbs_surface_reduce_degree:=nil;
  nurbs_surface_decompose_to_beziers:=nil;
  nurbs_surface_equally_tessellate:=nil;
  nurbs_surface_get_param_on_surface:=nil;
  nurbs_surface_get_param_on_surface_by_gsa:=nil;
  nurbs_surface_get_uv_tangent:=nil;
  nurbs_surface_reparametrize:=nil;
  nurbs_surface_create_bilinear:=nil;
  nurbs_surface_create_cylindrical:=nil;
  nurbs_surface_create_ruled:=nil;
  nurbs_surface_create_revolved:=nil;
  nurbs_surface_global_interpolation:=nil;
  nurbs_surface_bicubic_local_interpolation:=nil;
  nurbs_surface_global_approximation:=nil;
  nurbs_surface_create_swung:=nil;
  nurbs_surface_create_loft:=nil;
  nurbs_surface_create_generalized_translational_sweep:=nil;
  nurbs_surface_create_sweep_interpolated:=nil;
  nurbs_surface_create_sweep_noninterpolated:=nil;
  nurbs_surface_create_gordon:=nil;
  nurbs_surface_create_coons:=nil;
  nurbs_surface_approximate_area:=nil;
  nurbs_surface_triangulate:=nil;
end;
class constructor gLNLibRec<gXYZ,gXYZW,gUV,gMatrix4d>.CreateRec;
begin
  ClearAllFunctionPointers;
  Assert(sizeof(gXYZ)=sizeof(TXYZ),'gLNLibRec wrong gXYZ specialization');
  Assert(sizeof(gXYZW)=sizeof(TXYZW),'gLNLibRec wrong gXYZW specialization');
  Assert(sizeof(gUV)=sizeof(TUV),'gLNLibRec wrong gUV specialization');
  Assert(sizeof(gMatrix4d)=sizeof(TMatrix4d),'gLNLibRec wrong gMatrix4d specialization');
end;

class function gLNLibRec<gXYZ,gXYZW,gUV,gMatrix4d>.LoadLNLib:boolean;
begin
  Result:=False;

  { Проверка, не загружена ли уже библиотека }
  if LNLibLoaded then begin
    Result:=True;
    Exit;
  end;

  LNLibHandle:=LoadLibrary(PChar(LNLIB_DLL));

  { Загрузка всех функций }
  Result:=True;
  Result:=LoadXYZFunctions and Result;
  Result:=LoadXYZWFunctions and Result;
  Result:=LoadUVFunctions and Result;
  Result:=LoadMatrix4dFunctions and Result;
  Result:=LoadProjectionFunctions and Result;
  Result:=LoadBezierCurveFunctions and Result;
  Result:=LoadBezierSurfaceFunctions and Result;
  Result:=LoadPolynomialsFunctions and Result;
  Result:=LoadKnotVectorUtilsFunctions and Result;
  Result:=LoadIntersectionFunctions and Result;
  Result:=LoadValidationUtilsFunctions and Result;
  Result:=LoadNurbsCurveFunctions and Result;
  Result:=LoadNurbsSurfaceFunctions and Result;

  if Result then
    LNLibLoaded:=True
  else
    { Выгружаем библиотеку, если не все функции загружены }
    UnloadLNLib;
end;

class procedure gLNLibRec<gXYZ,gXYZW,gUV,gMatrix4d>.UnloadLNLib;
begin
  if LNLibHandle<>NilHandle then begin
    FreeLibrary(LNLibHandle);
    LNLibHandle:=NilHandle;
  end;

  ClearAllFunctionPointers;
  LNLibLoaded:=False;
end;

class function gLNLibRec<gXYZ,gXYZW,gUV,gMatrix4d>.IsLNLibLoaded:boolean;
begin
  Result:=LNLibLoaded;
end;


end.
