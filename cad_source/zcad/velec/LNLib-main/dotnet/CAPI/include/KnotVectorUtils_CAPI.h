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

#ifdef __cplusplus
extern "C" {
#endif

LNLIB_EXPORT int knot_vector_utils_get_continuity(
    int degree,
    const double* knot_vector,
    int knot_vector_count,
    double knot);

LNLIB_EXPORT void knot_vector_utils_rescale(
    const double* knot_vector,
    int knot_vector_count,
    double min_val,
    double max_val,
    double* out_rescaled_knot_vector);

LNLIB_EXPORT int knot_vector_utils_is_uniform(
    const double* knot_vector,
    int knot_vector_count);

LNLIB_EXPORT int knot_vector_utils_get_knot_multiplicity_map_size(
    const double* knot_vector,
    int knot_vector_count);

LNLIB_EXPORT void knot_vector_utils_get_knot_multiplicity_map(
    const double* knot_vector,
    int knot_vector_count,
    double* out_unique_knots,
    int* out_multiplicities);

#ifdef __cplusplus
}
#endif