/*
 * Author:
 * 2023/06/08 - Yuqing Liang (BIMCoder Liang)
 * bim.frankliang@foxmail.com
 * 
 *
 * Use of this source code is governed by a LGPL-2.1 license that can be found in
 * the LICENSE file.
 */

#pragma once

#define DLL_EXPORT __declspec(dllexport)
#define DLL_IMPORT __declspec(dllimport)

#if defined(WIN64) || defined(_WIN64) || defined(__WIN64__) || defined(__CYGWIN__)
    #ifdef LNLIB_HOME
        #define LNLIB_EXPORT __declspec(dllexport)
    #else
        #define LNLIB_EXPORT __declspec(dllimport)
    #endif
#else
    #ifdef LNLIB_HOME
        #define LNLIB_EXPORT __attribute__((visibility("default")))
    #else
        #define LNLIB_EXPORT
    #endif
#endif
