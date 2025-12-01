/*
 * Author:
 * 2023/10/17 - Yuqing Liang (BIMCoder Liang)
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
#include <map>

namespace LNLib
{
	class UV;

	class LNLIB_EXPORT KnotVectorUtils
	{
	public:
		
		/// <summary>
		/// The NURBS Book 2nd Edition Page88
		/// Compute the continuity.
		/// </summary>
		static int GetContinuity(int degree, const std::vector<double>& knotVector, double knot);

		static std::vector<double> Rescale(const std::vector<double>& knotVector, double min, double max);

		/// <summary>
		/// The NURBS Book 2nd Edition Page533
		/// Get insert elements from [Us, Ue] for refine knot vector.
		/// </summary>
		static std::vector<double> GetInsertedKnotElement(int degree, const std::vector<double>& knotVector, double startParam, double endParam);

		/// <summary>
		/// The NURBS Book 2nd Edition Page338
		/// Get knot multiplcity map.
		/// </summary>
		static std::map<double, int> GetKnotMultiplicityMap(const std::vector<double>& knotVector);

		/// <summary>
		/// Get internal knot multiplcity map.
		/// </summary>
		static std::map<double, int> GetInternalKnotMultiplicityMap(const std::vector<double>& knotVector);

		/// <summary>
		/// The NURBS Book 2nd Edition Page338
		/// Get insert elements between two knot vector for create ruled surface.
		/// </summary>
		static void GetInsertedKnotElement(const std::vector<double>& knotVector0, const std::vector<double>& knotVector1, std::vector<double>& insertElements0, std::vector<double>& insertElements1);

		/// <summary>
		/// The NURBS Book 2nd Edition Page472
		/// Get insert elements between knot vectors for create sweep surface.
		/// </summary>
		static std::vector<std::vector<double>> GetInsertedKnotElements(const std::vector<std::vector<double>>& knotVectors);

		/// <summary>
		/// The NURBS Book 2nd Edition Page476
		/// Insert [insertKnotsNumber] knots into [knotVector] 
		/// by insert at the midpoint of the longest span will do.
		/// </summary>
		static std::vector<double> GetInsertedKnotElements(int insertKnotsNumber, const std::vector<double>& knotVector);

		/// <summary>
		/// The NURBS Book 2nd Edition Page572
		/// </summary>
		static bool IsUniform(const std::vector<double>& knotVector);
	};

}



