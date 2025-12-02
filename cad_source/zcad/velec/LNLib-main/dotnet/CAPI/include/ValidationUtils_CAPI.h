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
#include "XYZW_CAPI.h"

#ifdef __cplusplus
extern "C" {
#endif

LNLIB_EXPORT int validation_utils_is_valid_knot_vector(const double* knot_vector, int count);
LNLIB_EXPORT int validation_utils_is_valid_bezier(int degree, int control_points_count);
LNLIB_EXPORT int validation_utils_is_valid_bspline(int degree, int knot_count, int cp_count);
LNLIB_EXPORT int validation_utils_is_valid_nurbs(int degree, int knot_count, int weighted_cp_count);

LNLIB_EXPORT double validation_utils_compute_curve_modify_tolerance(
    const XYZW_C* control_points,
    int count
);

#ifdef __cplusplus
}
#endif