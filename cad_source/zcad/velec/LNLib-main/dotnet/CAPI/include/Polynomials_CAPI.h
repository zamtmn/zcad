/*
 * Author:
 * 2025/11/29 - Yuqing Liang (BIMCoder Liang)
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

LNLIB_EXPORT double polynomials_bernstein(int index, int degree, double paramT);
LNLIB_EXPORT void polynomials_all_bernstein(int degree, double paramT, double* out_array);

LNLIB_EXPORT double polynomials_horner_curve(int degree, const double* coefficients, int coeff_count, double paramT);

LNLIB_EXPORT int polynomials_get_knot_span_index(int degree, const double* knot_vector, int knot_count, double paramT);
LNLIB_EXPORT int polynomials_get_knot_multiplicity(const double* knot_vector, int knot_count, double paramT);

LNLIB_EXPORT void polynomials_basis_functions(
    int span_index, int degree,
    const double* knot_vector, int knot_count,
    double paramT,
    double* basis_functions
);

LNLIB_EXPORT void polynomials_bezier_to_power_matrix(
    int degree,
    double* out_matrix
);

#ifdef __cplusplus
}
#endif