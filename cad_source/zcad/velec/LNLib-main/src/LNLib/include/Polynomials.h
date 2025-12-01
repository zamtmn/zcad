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
#include "Constants.h"
#include <vector>

namespace LNLib
{
	class UV;
	class LNLIB_EXPORT Polynomials
	{
	public:
		
		/// <summary>
		/// The NURBS Book 2nd Edition Page20
		/// Algorithm A1.1
		/// Compute point on power basis curve.
		/// </summary>
		static double Horner(int degree, const std::vector<double>& coefficients, double paramT);

		/// <summary>
		/// The NURBS Book 2nd Edition Page7
		/// Algorithm A1.2
		/// compute the value of a Berstein polynomial.
		/// </summary>
		static double Bernstein(int index, int degree, double paramT);

		/// <summary>
		/// The NURBS Book 2nd Edition Page21
		/// Algorithm A1.3
		/// Compute All nth-degree Berstein polynomials.
		/// </summary>
		static std::vector<double> AllBernstein(int degree, double paramT);

		/// <summary>
		/// The NURBS Book 2nd Edition Page36
		/// Algorithm A1.6
		/// Compute point on a power basis surface.
		/// coefficients with (n+1) * (m+1)
		/// 
		///  [0][0]  [0][1] ... ...  [0][m]     ------- v direction
		///  [1][0]  [1][1] ... ...  [1][m]    |
		///    .                               |
		///    .                               u direction
		///    .
		///  [n][0]  [n][1] ... ...  [n][m]      
		///  
		/// </summary>
		static double Horner(int degreeU, int degreeV, const std::vector<std::vector<double>>& coefficients, UV& uv);

		/// <summary>
		/// The NURBS Book 2nd Edition Page63
		/// Get the knot multiplicity.
		/// </summary>
		static int GetKnotMultiplicity(const std::vector<double>& knotVector, double paramT);

		/// <summary>
		/// The NURBS Book 2nd Edition Page68
		/// Algorithm A2.1
		/// Determine the knot span index.
		/// </summary>
		static int GetKnotSpanIndex(int degree, const std::vector<double>& knotVector, double paramT);

		/// <summary>
		/// The NURBS Book 2nd Edition Page70
		/// Algorithm A2.2
		/// Compute the nonvanishing basis functions.
		/// </summary>
		static void BasisFunctions(int spanIndex, int degree, const std::vector<double>& knotVector, double paramT, double* basisFunctions);

		/// <summary>
		/// The NURBS Book 2nd Edition Page72
		/// Algorithm A2.3
		/// Compute nonzero basis functions and their derivative.
		/// </summary>
		static std::vector<std::vector<double>> BasisFunctionsDerivatives(int spanIndex, int degree, int derivative, const std::vector<double>& knotVector, double paramT);

		/// <summary>
		/// This is an optimized function of BasisFunctionsDerivatives, for order 1 case.
		/// </summary>
		static void BasisFunctionsFirstOrderDerivative(int spanIndex, int degree, const std::vector<double>& knotVector, double paramT, double derivatives[2][Constants::NURBSMaxDegree + 1]);

		/// <summary>
		/// The NURBS Book 2nd Edition Page74
		/// Algorithm A2.4
		/// Compute the basis function Ni,p.
		/// </summary>
		static double OneBasisFunction(int spanIndex, int degree, const std::vector<double>& knotVector, double paramT);

		/// <summary>
		/// The NURBS Book 2nd Edition Page76
		/// Algorithm A2.5
		/// Compute a single basis function and its derivative.
		/// </summary>
		static std::vector<double> OneBasisFunctionDerivative(int spanIndex, int degree, int derivative, const std::vector<double>& knotVector, double paramT);

		/// <summary>
		/// The NURBS Book 2nd Edition Page99
		/// A simple modification of A2.2 to return all nonzero basis functions of all degrees from 0 up to degree.
		/// </summary>
		static std::vector<std::vector<double>> AllBasisFunctions(int spanIndex, int degree, const std::vector<double>& knotVector, double knot);

		/// <summary>
		/// The NURBS Book 2nd Edition Page269
		/// Algorithm A6.1
		/// Compute pth degree Bezier matrix.
		/// </summary>
		static std::vector<std::vector<double>> BezierToPowerMatrix(int degree);

		/// <summary>
		/// The NURBS Book 2nd Edition Page275
		/// Algorithm A6.2
		/// Compute inverse of pth-degree Bezier matrix.
		/// </summary>
		static std::vector<std::vector<double>> PowerToBezierMatrix(int degree, const std::vector<std::vector<double>>& matrix);
	};

}



