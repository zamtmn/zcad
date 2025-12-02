/*
 * Author:
 * 2025/11/27 - Yuqing Liang (BIMCoder Liang)
 * bim.frankliang@foxmail.com
 * 
 *
 * Use of this source code is governed by a LGPL-2.1 license that can be found in
 * the LICENSE file.
 */

#pragma once
#include "LNLibDefinitions.h"
#include "UV_CAPI.h"
#include "XYZ_CAPI.h"
#include "XYZW_CAPI.h"
#include "LNObject_CAPI.h"
#include "NurbsCurve_CAPI.h"

#ifdef __cplusplus
extern "C" {
#endif

    typedef struct {
        int degree_u;
        int degree_v;
        const double* knot_vector_u;
        int knot_count_u;
        const double* knot_vector_v;
        int knot_count_v;
        const XYZW_C* control_points;
        int control_point_rows;
        int control_point_cols;
    } LN_NurbsSurface_C;

    LNLIB_EXPORT XYZ_C nurbs_surface_get_point_on_surface(LN_NurbsSurface_C surface, UV_C uv);
    LNLIB_EXPORT int nurbs_surface_compute_rational_derivatives(
        LN_NurbsSurface_C surface,
        int derivative_order,
        UV_C uv,
        XYZ_C* out_derivatives);
    LNLIB_EXPORT void nurbs_surface_compute_first_order_derivative(
        LN_NurbsSurface_C surface,
        UV_C uv,
        XYZ_C* out_S,
        XYZ_C* out_Su,
        XYZ_C* out_Sv);
    LNLIB_EXPORT double nurbs_surface_curvature(LN_NurbsSurface_C surface, int curvature_type, UV_C uv);
    LNLIB_EXPORT XYZ_C nurbs_surface_normal(LN_NurbsSurface_C surface, UV_C uv);

    LNLIB_EXPORT void nurbs_surface_swap_uv(LN_NurbsSurface_C surface, LN_NurbsSurface_C* out_surface);
    LNLIB_EXPORT void nurbs_surface_reverse(LN_NurbsSurface_C surface, int direction, LN_NurbsSurface_C* out_surface);
    LNLIB_EXPORT int nurbs_surface_is_closed(LN_NurbsSurface_C surface, int is_u_direction);

    LNLIB_EXPORT void nurbs_surface_insert_knot(
        LN_NurbsSurface_C surface,
        double knot_value,
        int times,
        int is_u_direction,
        LN_NurbsSurface_C* out_surface);
    LNLIB_EXPORT void nurbs_surface_refine_knot_vector(
        LN_NurbsSurface_C surface,
        const double* insert_knots,
        int insert_count,
        int is_u_direction,
        LN_NurbsSurface_C* out_surface);
    LNLIB_EXPORT void nurbs_surface_remove_knot(
        LN_NurbsSurface_C surface,
        double knot_value,
        int times,
        int is_u_direction,
        LN_NurbsSurface_C* out_surface);

    LNLIB_EXPORT void nurbs_surface_elevate_degree(
        LN_NurbsSurface_C surface,
        int times,
        int is_u_direction,
        LN_NurbsSurface_C* out_surface);
    LNLIB_EXPORT int nurbs_surface_reduce_degree(
        LN_NurbsSurface_C surface,
        int is_u_direction,
        LN_NurbsSurface_C* out_surface);

    LNLIB_EXPORT int nurbs_surface_decompose_to_beziers(
        LN_NurbsSurface_C surface,
        LN_NurbsSurface_C* out_patches,
        int max_patches);
    LNLIB_EXPORT void nurbs_surface_equally_tessellate(
        LN_NurbsSurface_C surface,
        XYZ_C* out_points,
        UV_C* out_uvs,
        int max_count);

    LNLIB_EXPORT UV_C nurbs_surface_get_param_on_surface(LN_NurbsSurface_C surface, XYZ_C given_point);
    LNLIB_EXPORT UV_C nurbs_surface_get_param_on_surface_by_gsa(LN_NurbsSurface_C surface, XYZ_C given_point);
    LNLIB_EXPORT int nurbs_surface_get_uv_tangent(
        LN_NurbsSurface_C surface,
        UV_C param,
        XYZ_C tangent,
        UV_C* out_uv_tangent);

    LNLIB_EXPORT void nurbs_surface_reparametrize(
        LN_NurbsSurface_C surface,
        double min_u, double max_u,
        double min_v, double max_v,
        LN_NurbsSurface_C* out_surface);

    LNLIB_EXPORT void nurbs_surface_create_bilinear(
        XYZ_C top_left, XYZ_C top_right,
        XYZ_C bottom_left, XYZ_C bottom_right,
        LN_NurbsSurface_C* out_surface);
    LNLIB_EXPORT int nurbs_surface_create_cylindrical(
        XYZ_C origin, XYZ_C x_axis, XYZ_C y_axis,
        double start_rad, double end_rad,
        double radius, double height,
        LN_NurbsSurface_C* out_surface);
    LNLIB_EXPORT void nurbs_surface_create_ruled(
        LN_NurbsCurve_C curve0,
        LN_NurbsCurve_C curve1,
        LN_NurbsSurface_C* out_surface);
    LNLIB_EXPORT int nurbs_surface_create_revolved(
        XYZ_C origin, XYZ_C axis, double rad,
        LN_NurbsCurve_C profile,
        LN_NurbsSurface_C* out_surface);

    LNLIB_EXPORT void nurbs_surface_global_interpolation(
        const XYZ_C* points,
        int rows, int cols,
        int degree_u, int degree_v,
        LN_NurbsSurface_C* out_surface);
    LNLIB_EXPORT int nurbs_surface_bicubic_local_interpolation(
        const XYZ_C* points,
        int rows, int cols,
        LN_NurbsSurface_C* out_surface);
    LNLIB_EXPORT int nurbs_surface_global_approximation(
        const XYZ_C* points, 
        int rows, int cols,
        int degree_u, int degree_v,
        int ctrl_rows, int ctrl_cols,
        LN_NurbsSurface_C* out_surface);
    LNLIB_EXPORT int nurbs_surface_create_swung(
        LN_NurbsCurve_C profile,
        LN_NurbsCurve_C trajectory,
        double scale,
        LN_NurbsSurface_C* out_surface);
    LNLIB_EXPORT void nurbs_surface_create_loft(
        const LN_NurbsCurve_C* sections,
        int section_count,
        LN_NurbsSurface_C* out_surface,
        int custom_trajectory_degree,
        const double* custom_knots,
        int knot_count);
    LNLIB_EXPORT void nurbs_surface_create_generalized_translational_sweep(
        LN_NurbsCurve_C profile,
        LN_NurbsCurve_C trajectory,
        LN_NurbsSurface_C* out_surface);
    LNLIB_EXPORT void nurbs_surface_create_sweep_interpolated(
        LN_NurbsCurve_C profile,
        LN_NurbsCurve_C trajectory,
        int min_profiles,
        LN_NurbsSurface_C* out_surface);
    LNLIB_EXPORT void nurbs_surface_create_sweep_noninterpolated(
        LN_NurbsCurve_C profile,
        LN_NurbsCurve_C trajectory,
        int min_profiles,
        int trajectory_degree,
        LN_NurbsSurface_C* out_surface);
    LNLIB_EXPORT void nurbs_surface_create_gordon(
        const LN_NurbsCurve_C* u_curves,
        int u_count,
        const LN_NurbsCurve_C* v_curves,
        int v_count,
        const XYZ_C* intersections,
        LN_NurbsSurface_C* out_surface);
    LNLIB_EXPORT void nurbs_surface_create_coons(
        LN_NurbsCurve_C left,
        LN_NurbsCurve_C bottom,
        LN_NurbsCurve_C right,
        LN_NurbsCurve_C top,
        LN_NurbsSurface_C* out_surface);

    LNLIB_EXPORT double nurbs_surface_approximate_area(LN_NurbsSurface_C surface, int integrator_type);

    LNLIB_EXPORT LN_Mesh_C nurbs_surface_triangulate(
        LN_NurbsSurface_C surface,
        int resolution_u,
        int resolution_v,
        int use_delaunay);

#ifdef __cplusplus
}
#endif