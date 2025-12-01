/*
 * Author:
 * 2023/06/23 - Yuqing Liang (BIMCoder Liang)
 * bim.frankliang@foxmail.com
 * 
 *
 * Use of this source code is governed by a LGPL-2.1 license that can be found in
 * the LICENSE file.
 */

#pragma once

#include "LNEnums.h"
#include "LNLibDefinitions.h"

namespace LNLib
{
	class XYZ;
	class LNLIB_EXPORT Intersection
	{

	public:
		static CurveCurveIntersectionType ComputeRays(const XYZ& point0, const XYZ& vector0, const XYZ& point1, const XYZ& vector1, double& param0, double& param1, XYZ& intersectPoint);

		static LinePlaneIntersectionType ComputeLineAndPlane(const XYZ& normal, const XYZ& pointOnPlane, const XYZ& pointOnLine, const XYZ& lineDirection, XYZ& intersectPoint);

	};
}

