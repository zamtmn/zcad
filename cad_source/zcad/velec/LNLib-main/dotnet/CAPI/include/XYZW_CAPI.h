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
#include "XYZ_CAPI.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct { double wx, wy, wz, w; } XYZW_C;

LNLIB_EXPORT XYZW_C xyzw_create(double wx, double wy, double wz, double w);
LNLIB_EXPORT XYZW_C xyzw_create_from_xyz(XYZ_C xyz, double w);

LNLIB_EXPORT XYZ_C xyzw_to_xyz(XYZW_C v, int divideWeight);
LNLIB_EXPORT XYZW_C xyzw_add(XYZW_C a, XYZW_C b);
LNLIB_EXPORT XYZW_C xyzw_multiply(XYZW_C a, double scalar);
LNLIB_EXPORT XYZW_C xyzw_divide(XYZW_C a, double scalar);
LNLIB_EXPORT double xyzw_distance(XYZW_C a, XYZW_C b);

LNLIB_EXPORT double xyzw_get_wx(XYZW_C v);
LNLIB_EXPORT double xyzw_get_wy(XYZW_C v);
LNLIB_EXPORT double xyzw_get_wz(XYZW_C v);
LNLIB_EXPORT double xyzw_get_w(XYZW_C v);

#ifdef __cplusplus
}
#endif
