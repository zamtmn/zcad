/*
 * Author:
 * 2024/01/13 - Yuqing Liang (BIMCoder Liang)
 * bim.frankliang@foxmail.com
 * 
 *
 * Use of this source code is governed by a LGPL-2.1 license that can be found in
 * the LICENSE file.
 */

#pragma once

namespace LNLib
{
	enum class CurveCurveIntersectionType : int
	{
		Intersecting = 0,
		Parallel = 1,
		Coincident = 2,
		Skew = 3,
	};

	enum class LinePlaneIntersectionType : int
	{
		Intersecting = 0,
		Parallel = 1,
		On = 2,
	};

	enum class CurveNormal :int
	{
		Normal = 0,
		Binormal = 1,
	};

	enum class SurfaceDirection : int
	{
		All = 0,
		UDirection = 1,
		VDirection = 2,
	};

	enum class SurfaceCurvature : int
	{
		Maximum = 0,
		Minimum = 1,
		Gauss = 2,
		Mean = 3,
		Abs = 4,
		Rms = 5
	};

	enum class IntegratorType :int
	{
		Simpson = 0,
		GaussLegendre = 1,
		Chebyshev = 2,
	};

	enum class OffsetType :int
	{
		// Tiller & Hanson Algorithm for C0 profile.
		// 
		// 1. Tiller & Hanson Algorithm should iterative use. 
		// When diff is larger than tolerance, should subdivide curve until less than tolerance.
		// Finally use Merge curve.
		// 
		// 2. Tiller & Hanson Algorithm is not good in negative offset & high degree curve.
		TillerAndHanson = 0,

		// Piegl & Tiller Algorithm for high degree profile,
		// which had better controlled by error tolerance and yet self-intersection had not dealt with.
		PieglAndTiller = 1,
	};
}



