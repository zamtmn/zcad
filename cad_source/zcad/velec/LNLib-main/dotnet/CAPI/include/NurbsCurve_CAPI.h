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
 #include "XYZ_CAPI.h"
 #include "XYZW_CAPI.h"
 #include "LNObject.h"
 #include "Matrix4d_CAPI.h"
 #include "LNEnums_CAPI.h"
 #include "LNObject_CAPI.h"

#ifdef __cplusplus
extern "C" {
#endif

    typedef struct {
        int degree;
        const double* knot_vector;
        int knot_count;
        const XYZW_C* control_points;
        int control_point_count;
    } LN_NurbsCurve_C;

    LNLIB_EXPORT LN_NurbsCurve_C nurbs_curve_create_line(XYZ_C start, XYZ_C end);
    LNLIB_EXPORT int nurbs_curve_create_arc(
        XYZ_C center, XYZ_C x_axis, XYZ_C y_axis,
        double start_rad, double end_rad,
        double x_radius, double y_radius,
        LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT int nurbs_curve_create_open_conic(
        XYZ_C start, XYZ_C start_tangent,
        XYZ_C end, XYZ_C end_tangent,
        XYZ_C point_on_conic,
        LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT void nurbs_curve_global_interpolation(
        int degree,
        const XYZ_C* points,
        int point_count,
        LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT void nurbs_curve_global_interpolation_with_tangents(
        int degree,
        const XYZ_C* points,
        const XYZ_C* tangents,
        double tangent_factor,
        int point_count,
        LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT int nurbs_curve_cubic_local_interpolation(
        const XYZ_C* points,
        int point_count,
        LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT int nurbs_curve_least_squares_approximation(
        int degree,
        const XYZ_C* points,
        int point_count,
        int control_point_count,
        LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT int nurbs_curve_weighted_constrained_least_squares(
        int degree,
        const XYZ_C* points,
        const double* point_weights,
        const XYZ_C* tangents,
        const int* tangent_indices,
        const double* tangent_weights,
        int tangent_count,
        int control_point_count,
        LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT void nurbs_curve_global_approximation_by_error_bound(
        int degree,
        const XYZ_C* points,
        int point_count,
        double max_error,
        LN_NurbsCurve_C* out_curve);

    LNLIB_EXPORT XYZ_C nurbs_curve_get_point_on_curve(LN_NurbsCurve_C curve, double paramT);
    LNLIB_EXPORT XYZ_C nurbs_curve_get_point_on_curve_by_corner_cut(LN_NurbsCurve_C curve, double paramT);

    LNLIB_EXPORT int nurbs_curve_compute_rational_derivatives(
        LN_NurbsCurve_C curve,
        int derivative_order,
        double paramT,
        XYZ_C* out_derivatives);
    LNLIB_EXPORT double nurbs_curve_curvature(LN_NurbsCurve_C curve, double paramT);
    LNLIB_EXPORT double nurbs_curve_torsion(LN_NurbsCurve_C curve, double paramT);
    LNLIB_EXPORT XYZ_C nurbs_curve_normal(LN_NurbsCurve_C curve, CurveNormal_C normal_type, double paramT);
    LNLIB_EXPORT int nurbs_curve_project_normal(LN_NurbsCurve_C curve, XYZ_C* out_normals);

    LNLIB_EXPORT double nurbs_curve_get_param_on_curve_by_point(LN_NurbsCurve_C curve, XYZ_C given_point);
    LNLIB_EXPORT double nurbs_curve_approximate_length(LN_NurbsCurve_C curve, IntegratorType_C integrator_type);
    LNLIB_EXPORT double nurbs_curve_get_param_by_length(LN_NurbsCurve_C curve, double given_length, IntegratorType_C integrator_type);
    LNLIB_EXPORT int nurbs_curve_get_params_by_equal_length(
        LN_NurbsCurve_C curve,
        double segment_length,
        IntegratorType_C integrator_type,
        double* out_params);

    LNLIB_EXPORT int nurbs_curve_split_at(
        LN_NurbsCurve_C curve,
        double paramT,
        LN_NurbsCurve_C* out_left,
        LN_NurbsCurve_C* out_right);
    LNLIB_EXPORT int nurbs_curve_segment(
        LN_NurbsCurve_C curve,
        double start_param,
        double end_param,
        LN_NurbsCurve_C* out_segment);
    LNLIB_EXPORT int nurbs_curve_decompose_to_beziers(
        LN_NurbsCurve_C curve,
        LN_NurbsCurve_C* out_segments,
        int max_segments);
    LNLIB_EXPORT int nurbs_curve_tessellate(
        LN_NurbsCurve_C curve,
        XYZ_C* out_points);

    LNLIB_EXPORT void nurbs_curve_create_transformed(
        LN_NurbsCurve_C curve,
        Matrix4d_C matrix,
        LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT void nurbs_curve_reverse(LN_NurbsCurve_C curve, LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT void nurbs_curve_reparametrize_to_interval(
        LN_NurbsCurve_C curve,
        double min_val,
        double max_val,
        LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT void nurbs_curve_reparametrize_linear_rational(
        LN_NurbsCurve_C curve,
        double alpha, double beta,
        double gamma, double delta,
        LN_NurbsCurve_C* out_curve);

    LNLIB_EXPORT int nurbs_curve_insert_knot(
        LN_NurbsCurve_C curve,
        double knot_value,
        int times,
        LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT int nurbs_curve_remove_knot(
        LN_NurbsCurve_C curve,
        double knot_value,
        int times,
        LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT void nurbs_curve_remove_excessive_knots(
        LN_NurbsCurve_C curve,
        LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT void nurbs_curve_refine_knot_vector(
        LN_NurbsCurve_C curve,
        const double* insert_knots,
        int insert_count,
        LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT void nurbs_curve_elevate_degree(
        LN_NurbsCurve_C curve,
        int times,
        LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT int nurbs_curve_reduce_degree(
        LN_NurbsCurve_C curve,
        LN_NurbsCurve_C* out_curve);

    LNLIB_EXPORT int nurbs_curve_is_closed(LN_NurbsCurve_C curve);
    LNLIB_EXPORT int nurbs_curve_is_linear(LN_NurbsCurve_C curve);
    LNLIB_EXPORT int nurbs_curve_is_clamped(LN_NurbsCurve_C curve);
    LNLIB_EXPORT int nurbs_curve_is_periodic(LN_NurbsCurve_C curve);
    LNLIB_EXPORT int nurbs_curve_can_compute_derivative(LN_NurbsCurve_C curve, double paramT);

    LNLIB_EXPORT int nurbs_curve_control_point_reposition(
        LN_NurbsCurve_C curve,
        double paramT,
        int move_index,
        XYZ_C move_direction,
        double move_distance,
        LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT void nurbs_curve_weight_modification(
        LN_NurbsCurve_C curve,
        double paramT,
        int move_index,
        double move_distance,
        LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT int nurbs_curve_neighbor_weights_modification(
        LN_NurbsCurve_C curve,
        double paramT,
        int move_index,
        double move_distance,
        double scale,
        LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT void nurbs_curve_warping(
        LN_NurbsCurve_C curve,
        const double* warp_shape,
        int warp_shape_count,
        double warp_distance,
        XYZ_C plane_normal,
        double start_param,
        double end_param,
        LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT int nurbs_curve_flattening(
        LN_NurbsCurve_C curve,
        XYZ_C line_start,
        XYZ_C line_end,
        double start_param,
        double end_param,
        LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT void nurbs_curve_bending(
        LN_NurbsCurve_C curve,
        double start_param,
        double end_param,
        XYZ_C bend_center,
        double radius,
        double cross_ratio,
        LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT void nurbs_curve_constraint_based_modification(
        LN_NurbsCurve_C curve,
        const double* constraint_params,
        const XYZ_C* derivative_constraints,
        const int* applied_indices,
        const int* applied_degrees,
        const int* fixed_cp_indices,
        int constraint_count,
        int fixed_count,
        LN_NurbsCurve_C* out_curve);

    LNLIB_EXPORT void nurbs_curve_to_clamp_curve(LN_NurbsCurve_C curve, LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT void nurbs_curve_to_unclamp_curve(LN_NurbsCurve_C curve, LN_NurbsCurve_C* out_curve);
    LNLIB_EXPORT void nurbs_curve_equally_tessellate(
        LN_NurbsCurve_C curve,
        XYZ_C* out_points,
        double* out_knots,
        int max_count);

#ifdef __cplusplus

}
#endif

#ifdef __cplusplus

inline LNLib::LN_NurbsCurve FromCAPI(LN_NurbsCurve_C c) {
    LNLib::LN_NurbsCurve s;
    s.Degree = c.degree;
    s.KnotVector.assign(c.knot_vector, c.knot_vector + c.knot_count);
    s.ControlPoints.resize(c.control_point_count);
    for (int i = 0; i < c.control_point_count; ++i) {
        XYZW_C cp = c.control_points[i];
        s.ControlPoints[i] = LNLib::XYZW(cp.wx, cp.wy, cp.wz, cp.w);
    }
    return s;
}

inline LN_NurbsCurve_C ToCAPI(const LNLib::LN_NurbsCurve& s) {
    static thread_local std::vector<double> g_knot_buffer;
    static thread_local std::vector<LNLib::XYZW> g_cp_2d_buffer;
    static thread_local std::vector<XYZW_C> g_cp_flat_buffer;

    g_knot_buffer = s.KnotVector;
    g_cp_2d_buffer = s.ControlPoints;
    g_cp_flat_buffer.clear();
    g_cp_flat_buffer.reserve(g_cp_2d_buffer.size());
    for (const auto& cp : g_cp_2d_buffer) {
        g_cp_flat_buffer.push_back({ cp.WX(), cp.WY(), cp.WZ(), cp.W() });
    }

    LN_NurbsCurve_C c;
    c.degree = s.Degree;
    c.knot_vector = g_knot_buffer.data();
    c.knot_count = static_cast<int>(g_knot_buffer.size());
    c.control_points = g_cp_flat_buffer.data();
    c.control_point_count = static_cast<int>(g_cp_flat_buffer.size());
    return c;
}

#endif