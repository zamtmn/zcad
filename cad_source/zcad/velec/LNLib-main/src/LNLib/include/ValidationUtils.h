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

#include "LNLibDefinitions.h"
#include "MathUtils.h"
#include <vector>

namespace LNLib
{
	class XYZ;
	class XYZW;
	class LNLIB_EXPORT ValidationUtils
	{
	public:

		static bool IsValidBezier(int degree, int controlPointsCount);

		/// <summary>
		/// The NURBS Book 2nd Edition Page50
		/// Knot Vector is a nondecreasing sequence of real numbers.
		/// </summary>
		static bool IsValidKnotVector(const std::vector<double>& knotVector);

		static bool IsValidBspline(int degree, int knotVectorCount, int controlPointsCount);

		static bool IsValidNurbs(int degree, int knotVectorCount, int weightedControlPointsCount);

		static bool IsValidDegreeReduction(int degree);

		/// <summary>
		/// The NURBS Book 2nd Edition Page185
		/// TOL = dWmin / (1+abs(Pmax))
		/// </summary>
		static double ComputeCurveModifyTolerance(const std::vector<XYZW>& controlPoints);
	};
}

