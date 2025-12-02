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
#include "UV_CAPI.h"

#ifdef __cplusplus
extern "C" {
#endif

LNLIB_EXPORT XYZ_C bezier_surface_get_point_by_de_casteljau(
    int degree_u,
    int degree_v,
    const XYZ_C* control_points,
    int num_u,
    int num_v,
    UV_C uv);

#ifdef __cplusplus
}
#endif