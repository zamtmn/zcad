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

#include "BezierSurface.h"
#include "BezierCurve.h"
#include "LNLibDefinitions.h"
#include "LNObject.h"
#include <vector>

namespace LNLib {

	class UV;
	class XYZ;
	class XYZW;
	class LNLIB_EXPORT BezierSurface
	{
	public:

		template <typename T>
		static void Check(const LN_BezierSurface<T>& surface)
		{
			int degreeU = surface.DegreeU;
			int degreeV = surface.DegreeV;
			std::vector<T> controlPoints = surface.ControlPoints;

			VALIDATE_ARGUMENT(degreeU > 0, "degreeU", "Degree must be greater than zero.");
			VALIDATE_ARGUMENT(degreeV > 0, "degreeV", "Degree must be greater than zero.");
			VALIDATE_ARGUMENT(controlPoints.size() > 0, "controlPoints", "ControlPoints must contain one point at least.");
			VALIDATE_ARGUMENT(degreeU + 1 == controlPoints.size(), "controlPoints", "ControlPoints row size equals degreeU plus one.");
			VALIDATE_ARGUMENT(degreeV + 1 == controlPoints[0].size(), "controlPoints", "ControlPoints column size equals degreeV plus one.");
		}

		/// <summary>
		/// The NURBS Book 2nd Edition Page39
		/// Algorithm A1.7
		/// Compute a point on a Bezier surface by the deCasteljau.
		/// 
		/// Controlpoints with (n+1) rows * (m+1) columns
		///  
		///  [0][0]  [0][1] ... ...  [0][m]     ------- v direction
		///  [1][0]  [1][1] ... ...  [1][m]    |
		///    .                               |
		///    .                               u direction
		///    .							   
		///  [n][0]  [n][1] ... ...  [n][m]      
		/// 
		/// Rational Bezier Surface:Use XYZW
		/// </summary>
		template <typename T>
		static T GetPointOnSurfaceByDeCasteljau(const LN_BezierSurface<T>& surface, UV uv)
		{
			VALIDATE_ARGUMENT_RANGE(uv.GetU(), 0.0, 1.0);
			VALIDATE_ARGUMENT_RANGE(uv.GetV(), 0.0, 1.0);

			int degreeU = surface.DegreeU;
			int degreeV = surface.DegreeV;
			std::vector<std::vector<T>> controlPoints = surface.ControlPoints;

			T point;
			std::vector<T> temp(degreeU + 1);
			for (int i = 0; i <= degreeU; i++)
			{
				LN_BezierCurve<T> b;
				b.Degree = degreeV;
				b.ControlPoints = controlPoints[i];

				temp[i] = BezierCurve::GetPointOnCurveByDeCasteljau(b, uv.GetV());
			}

			LN_BezierCurve<T> bezierCurve;
			bezierCurve.Degree = degreeU;
			bezierCurve.ControlPoints = temp;

			point = BezierCurve::GetPointOnCurveByDeCasteljau(bezierCurve, uv.GetU());
			return point;
		}
	};
}



