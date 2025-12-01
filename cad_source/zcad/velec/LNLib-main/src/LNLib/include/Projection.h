/*
 * Author:
 * 2023/06/29 - Yuqing Liang (BIMCoder Liang)
 * bim.frankliang@foxmail.com
 * 
 *
 * Use of this source code is governed by a LGPL-2.1 license that can be found in
 * the LICENSE file.
 */

#pragma once

#include "LNLibDefinitions.h"

namespace LNLib
{
	class XYZ;
	class LNLIB_EXPORT Projection
	{
	public:
		static XYZ PointToRay(const XYZ& origin, const XYZ& vector, const XYZ& Point);
		static bool PointToLine(const XYZ& start, const XYZ& end, const XYZ& point, XYZ& projectPoint);
		static XYZ Stereographic(const XYZ& pointOnSphere, double radius);
	};
}


