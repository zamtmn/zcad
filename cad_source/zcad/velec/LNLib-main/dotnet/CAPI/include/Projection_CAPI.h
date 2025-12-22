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

#ifdef __cplusplus
extern "C" {
#endif

LNLIB_EXPORT XYZ_C projection_point_to_ray(
    XYZ_C origin,
    XYZ_C direction,
    XYZ_C point
);

LNLIB_EXPORT int projection_point_to_line(
    XYZ_C start,
    XYZ_C end,
    XYZ_C point,
    XYZ_C* out_project_point
);

LNLIB_EXPORT XYZ_C projection_stereographic(
    XYZ_C point_on_sphere,
    double radius
);

#ifdef __cplusplus
}
#endif