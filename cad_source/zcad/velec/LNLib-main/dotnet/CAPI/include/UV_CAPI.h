/*
 * Author:
 * 2025/11/25 - Yuqing Liang (BIMCoder Liang)
 * bim.frankliang@foxmail.com
 * 
 *
 * Use of this source code is governed by a LGPL-2.1 license that can be found in
 * the LICENSE file.
 */

#pragma once

#include "LNLibDefinitions.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    double u;
    double v;
} UV_C;

LNLIB_EXPORT UV_C uv_create(double u, double v);
LNLIB_EXPORT double uv_get_u(UV_C uv);
LNLIB_EXPORT double uv_get_v(UV_C uv);

LNLIB_EXPORT UV_C uv_add(UV_C a, UV_C b);
LNLIB_EXPORT UV_C uv_subtract(UV_C a, UV_C b);
LNLIB_EXPORT UV_C uv_negative(UV_C uv);
LNLIB_EXPORT UV_C uv_normalize(UV_C uv);
LNLIB_EXPORT UV_C uv_scale(UV_C uv, double factor);
LNLIB_EXPORT UV_C uv_divide(UV_C uv, double divisor);

LNLIB_EXPORT double uv_length(UV_C uv);
LNLIB_EXPORT double uv_sqr_length(UV_C uv);
LNLIB_EXPORT double uv_distance(UV_C a, UV_C b);
LNLIB_EXPORT int    uv_is_zero(UV_C uv, double epsilon);
LNLIB_EXPORT int    uv_is_unit(UV_C uv, double epsilon);
LNLIB_EXPORT int    uv_is_almost_equal(UV_C a, UV_C b, double epsilon);

LNLIB_EXPORT double uv_dot(UV_C a, UV_C b);
LNLIB_EXPORT double uv_cross(UV_C a, UV_C b); 

#ifdef __cplusplus
}
#endif
