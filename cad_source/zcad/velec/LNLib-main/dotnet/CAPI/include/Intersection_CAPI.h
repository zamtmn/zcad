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
#include "LNEnums_CAPI.h"
#include "XYZ_CAPI.h"

#ifdef __cplusplus
extern "C" {
#endif

LNLIB_EXPORT CurveCurveIntersectionType_C intersection_compute_rays(
    XYZ_C point0, XYZ_C vector0,
    XYZ_C point1, XYZ_C vector1,
    double* out_param0,
    double* out_param1,
    XYZ_C* out_intersect_point);


LNLIB_EXPORT LinePlaneIntersectionType_C intersection_compute_line_and_plane(
    XYZ_C plane_normal,
    XYZ_C point_on_plane,
    XYZ_C point_on_line,
    XYZ_C line_direction,
    XYZ_C* out_intersect_point);

#ifdef __cplusplus
}
#endif