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
#include "UV_CAPI.h"
#include "XYZ_CAPI.h"

#ifdef __cplusplus
extern "C" {
#endif

    typedef struct {
        double radius;
        XYZ_C center;
    } LN_ArcInfo_C;

    typedef struct {
        const XYZ_C* vertices;
        int vertices_count;

        const int* faces;
        int faces_data_count;

        const UV_C* uvs;
        int uvs_count;

        const int* uv_indices;
        int uv_indices_data_count;

        const XYZ_C* normals;
        int normals_count;

        const int* normal_indices;
        int normal_indices_data_count;
    } LN_Mesh_C;

#ifdef __cplusplus
}
#endif