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

typedef struct { double m[16]; } Matrix4d_C;

LNLIB_EXPORT Matrix4d_C matrix4d_identity();
LNLIB_EXPORT Matrix4d_C matrix4d_create_translation(XYZ_C vector);
LNLIB_EXPORT Matrix4d_C matrix4d_create_rotation(XYZ_C axis, double rad);
LNLIB_EXPORT Matrix4d_C matrix4d_create_scale(XYZ_C scale);
LNLIB_EXPORT Matrix4d_C matrix4d_create_reflection(XYZ_C normal);

LNLIB_EXPORT XYZ_C matrix4d_get_basis_x(Matrix4d_C m);
LNLIB_EXPORT XYZ_C matrix4d_get_basis_y(Matrix4d_C m);
LNLIB_EXPORT XYZ_C matrix4d_get_basis_z(Matrix4d_C m);
LNLIB_EXPORT XYZ_C matrix4d_get_basis_w(Matrix4d_C m); 

LNLIB_EXPORT XYZ_C matrix4d_of_point(Matrix4d_C m, XYZ_C point);
LNLIB_EXPORT XYZ_C matrix4d_of_vector(Matrix4d_C m, XYZ_C vector);

LNLIB_EXPORT Matrix4d_C matrix4d_multiply(Matrix4d_C a, Matrix4d_C b);
LNLIB_EXPORT int matrix4d_get_inverse(Matrix4d_C m, Matrix4d_C* out_inverse);
LNLIB_EXPORT double matrix4d_get_determinant(Matrix4d_C m);

#ifdef __cplusplus
}
#endif