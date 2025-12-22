/*
 * Author:
 * 2025/11/26 - Yuqing Liang (BIMCoder Liang)
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

typedef struct { double x, y, z; } XYZ_C;

LNLIB_EXPORT XYZ_C xyz_create(double x, double y, double z);
LNLIB_EXPORT XYZ_C xyz_zero();

LNLIB_EXPORT XYZ_C xyz_add(XYZ_C a, XYZ_C b);
LNLIB_EXPORT XYZ_C xyz_subtract(XYZ_C a, XYZ_C b);
LNLIB_EXPORT XYZ_C xyz_negative(XYZ_C a);
LNLIB_EXPORT XYZ_C xyz_multiply(XYZ_C a, double scalar);
LNLIB_EXPORT XYZ_C xyz_divide(XYZ_C a, double scalar);

LNLIB_EXPORT double xyz_length(XYZ_C v);
LNLIB_EXPORT double xyz_sqr_length(XYZ_C v);
LNLIB_EXPORT int xyz_is_zero(XYZ_C v, double epsilon);
LNLIB_EXPORT int xyz_is_unit(XYZ_C v, double epsilon);

LNLIB_EXPORT XYZ_C xyz_normalize(XYZ_C v);

LNLIB_EXPORT double xyz_dot(XYZ_C a, XYZ_C b);
LNLIB_EXPORT XYZ_C xyz_cross(XYZ_C a, XYZ_C b);
LNLIB_EXPORT double xyz_distance(XYZ_C a, XYZ_C b);

LNLIB_EXPORT int xyz_equals(XYZ_C a, XYZ_C b);

#ifdef __cplusplus
}
#endif
