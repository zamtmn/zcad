/*
 * Author:
 * 2023/07/04 - Yuqing Liang (BIMCoder Liang)
 * bim.frankliang@foxmail.com
 * 
 *
 * Use of this source code is governed by a LGPL-2.1 license that can be found in
 * the LICENSE file.
 */

#pragma once
#include "LNLibDefinitions.h"
#include <vector>

namespace LNLib
{
	class XYZ;
	class LNLIB_EXPORT Interpolation
	{
	public:

		/// <summary>
		/// The NURBS Book 2nd Edition Page364
		/// The total chord length.
		/// </summary>
		static double GetTotalChordLength(const std::vector<XYZ>& throughPoints);

		/// <summary>
		/// The NURBS Book 2nd Edition Page365
		/// The chord length parameterization.
		/// </summary>
		static std::vector<double> GetChordParameterization(const std::vector<XYZ>& throughPoints);

		/// <summary>
		/// The NURBS Book 2nd Edition Page365
		/// The total centripetal length.
		/// </summary>
		static double GetCentripetalLength(const std::vector<XYZ>& throughPoints);

		/// <summary>
		/// The NURBS Book 2nd Edition Page365
		/// The centripetal length parameterization.
		/// </summary>
		static std::vector<double> GetCentripetalParameterization(const std::vector<XYZ>& throughPoints);

		/// <summary>
		/// The NURBS Book 2nd Edition Page365
		/// Technique of averaging.
		/// </summary>
		static std::vector<double> AverageKnotVector(int degree, const std::vector<double>& params);

		/// <summary>
		/// The NURBS Book 2nd Edition Page377
		/// Algorithm A9.3
		/// Compute paramters for global surface interpolation.
		/// </summary>
		static bool GetSurfaceMeshParameterization(const std::vector<std::vector<XYZ>>& throughPoints, std::vector<double>& paramsU, std::vector<double>& paramsV);

		/// <summary>
		/// The NURBS Book 2nd Edition Page386
		/// Computer tangent of each through point (at least three points).
		/// </summary>
		static std::vector<XYZ> ComputeTangent(const std::vector<XYZ>& throughPoints);

		/// <summary>
		/// The NURBS Book 2nd Edition Page386
		/// Computer tangent of each through point (at least five points).
		/// </summary>
		static bool ComputeTangent(const std::vector<XYZ>& throughPoints, std::vector<XYZ>& tangents);

		/// <summary>
		/// The NURBS Book 2nd Edition Page394
		/// Compute weight for local rational quadratic curve interpolation.
		/// </summary>
		static bool ComputerWeightForRationalQuadraticInterpolation(const XYZ& startPoint, const XYZ& middleControlPoint, const XYZ& endPoint, double& weight);

		/// <summary>
		/// The NURBS Book 2nd Edition Page412
		/// Computes a knot vector ensuring that every knot span has at least one.
		/// </summary>
		static std::vector<double> ComputeKnotVector(int degree, int pointsCount, int controlPointsCount, const std::vector<double>& params);	
	};
}