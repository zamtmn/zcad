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

#include "Polynomials.h"
#include "ValidationUtils.h"
#include "LNLibDefinitions.h"
#include "LNLibExceptions.h"
#include "LNObject.h"
#include <vector>

namespace LNLib
{
	class XYZ;
	class XYZW;
	class LNLIB_EXPORT BezierCurve
	{
	public:

		template <typename T>
		static void Check(const LN_BezierCurve<T>& curve)
		{
			int degree = curve.Degree;
			std::vector<T> controlPoints = curve.ControlPoints;

			VALIDATE_ARGUMENT(degree > 0, "degree", "Degree must be greater than zero.");
			VALIDATE_ARGUMENT(controlPoints.size() > 0, "controlPoints", "ControlPoints must contain one point at least.");
			VALIDATE_ARGUMENT(ValidationUtils::IsValidBezier(degree, controlPoints.size()), "controlPoints", "ControlPoints count equals degree plus one.");
		}

		/// <summary>
		/// The NURBS Book 2nd Edition Page22
		/// Algorithm A1.4
		/// Compute point on Bezier curve.
		/// 
		/// Rational Bezier Curve:Use XYZW 
		/// </summary>
		template <typename T>
		static T GetPointOnCurveByBernstein(const LN_BezierCurve<T>& curve, double paramT)
		{
			VALIDATE_ARGUMENT_RANGE(paramT, 0.0, 1.0);

			int degree = curve.Degree;
			std::vector<T> controlPoints = curve.ControlPoints;

			std::vector<double> bernsteinArray = Polynomials::AllBernstein(degree, paramT);
			T temp;
			for (int k = 0; k <= degree; k++)
			{
				temp += bernsteinArray[k] * controlPoints[k];
			}
			return temp;
		}

		/// <summary>
		/// The NURBS Book 2nd Edition Page24
		/// Algorithm A1.5
		/// Compute point on Bezier curve.
		/// 
		/// Rational Bezier Curve:Use XYZW 
		/// </summary>
		template <typename T>
		static T GetPointOnCurveByDeCasteljau(const LN_BezierCurve<T>& curve, double paramT)
		{
			VALIDATE_ARGUMENT_RANGE(paramT, 0.0, 1.0);

			int degree = curve.Degree;
			std::vector<T> temp = curve.ControlPoints;
			for (int k = 1; k <= degree; k++)
			{
				for (int i = 0; i <= degree - k; i++)
				{
					temp[i] = (1.0 - paramT) * temp[i] + paramT * temp[i + 1];
				}
			}
			return temp[0];
		}

		/// <summary>
		/// The NURBS Book 2nd Edition Page291
		/// The quadratic rational Bezier arc.
		/// </summary>
		static XYZ GetPointOnQuadraticArc(const XYZW& startPoint, const XYZW& middlePoint, const XYZW& endPoint, double paramT);
		
		/// <summary>
		/// The NURBS Book 2nd Edition Page392
		/// Local rational quadratic curve interpolation.
		/// </summary>
		static bool ComputerMiddleControlPointsOnQuadraticCurve(const XYZ& startPoint, const XYZ& startTangent, const XYZ& endPoint, const XYZ& endTangent, std::vector<XYZW>& controlPoints);

	};
}


